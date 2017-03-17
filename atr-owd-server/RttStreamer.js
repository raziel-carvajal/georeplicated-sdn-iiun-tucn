module.exports = RttStreamer

var Its = require('its')
var Sh = require('shelljs')
var Log = typeof window === 'undefined' ? require('debug')('RttStreamer') : console.log
//TODO implement one lock (in JS code and in RTT/ATR bash scripts) to avoid 
//  discarting values from the stream. Currently a "negligible" set of
//  values might be lost from the stream.

function RttStreamer (file, timeout) {
  if (!(this instanceof RttStreamer)) return new RttStreamer(file, timeout)
  this._initTryNo = 0
  this._src = file //full path of file to read
  this._latr = undefined
  this._readyToR = false
  this._buffId = 0
  this._buff = {}
  this._readTimeout = timeout * 1000
  this._startThread = undefined
  this._initThread = undefined
  this._readsBefStart = 2
  this._initTimeout = 3000
  this._initTryNoLim= 5
  this._maxFails = 5
  this._failedTries = 0
  this.initialize()
}

RttStreamer.prototype.parseLine = function (line) {
  try {
    Its.defined(line)
    var array = line.split("icmp_seq=")
    Its(array.length !== 1)
  } catch (e) {
    Log("Current line doesn't contain any data")
    return undefined
  }
  //TODO remember to add one when you are in production mode
  // one unit is added to get the line number of source file
  //var ind = parseInt(array[1].split(" ")[0]) + 1
  var ind = parseInt(array[1].split(" ")[0])
  // RTT/2 in milliseconds
  var val = parseFloat(array[1].split(" ")[2].split("=")[1])
  //Log("Current indx=%d && val=", ind, val)
  return { 'indx': ind, 'val': val }
}

RttStreamer.prototype.initialize = function () {
  var map = this.parseLine( Sh.tail({ '-n': 1 } , this._src) )
  try {
    Its.defined(map)
    this._latr = map.indx
    Log("Init went well, first index: %d", this._latr)
  } catch(e) {
    this._initTryNo++
    Log("RTT file is not ready for reading [%d]", this._initTryNo)
    if (this._initTryNo >= this._initTryNoLim) {
      Log("Maximum number of tries to init() was reached")
      clearInterval(this._initThread)
      this.stop()
    } else {
      var self = this
      this._initThread = setInterval(function () {
        self.initialize()
      }, this._initTimeout)
    }
  } finally {
    Log("Intialize call is finished with initTryNo: %d", this._initTryNo)
  }
}

RttStreamer.prototype.start = function () {
  var self = this
  this._startThread = setInterval(function () {
    try {
      Its.defined(self._latr)
      Log("Calling start()")
    } catch (e) {
      Log("Initialization phase of RttStreamer is not yet completed")
      return
    }
    var go = self.readLatest()
    try {
      Its(go)
      //self._failedTries = 0
    } catch (e) {
      self._failedTries++
      Log("Fail [%d] while trying to read. Probably, source file is not being updated anymore", self._failedTries)
      if (self._failedTries >= self._maxFails) {
        Log("Maximum numbers of tries to read source file was reached")
        self.stop()
      }
      return
    }
    self._buffId++
    if (self._buffId > self._readsBefStart) {
      self._readyToR = true
    }
  }, this._readTimeout)
}

RttStreamer.prototype.readLatest = function () {
  var map = this.parseLine( Sh.tail({ '-n': 1 } , this._src) )
  try {
    Its.defined(map)
  } catch(e) {
    Log("WARNING: the latest line from source file is empty")
    return false
  }
  Log("Fetch chunk from lines %d to %d", this._latr, map.indx)
  var linesToRead = map.indx - this._latr
  if (linesToRead <= 0) {
    Log("WARNING: any new line was found")
    return false
  }
  this._latr = map.indx
  var buff = []
  var latestLines = ( Sh.tail({ '-n': linesToRead } , this._src) ).stdout.split("\n")
  for (var i = 0; i < latestLines.length; i++) {
    map = this.parseLine( latestLines[i] )
    try {
      Its.defined(map)
      buff.push(map.val)
    } catch (e) {/*XXX Nothing to cath if read line hasn't PING format*/}
  }
  this._buff[this._buffId] = buff
  //Log("Current buffer to store with index [%d]=", this._buffId, this._buff[this._buffId].toString())
  return true
}

RttStreamer.prototype.stop = function () {
  //TODO use Its!
  Log("RttStreamer stops its execution")
  this._readyToR = false
  this._latr = undefined
  clearInterval(this._startThread)
}
