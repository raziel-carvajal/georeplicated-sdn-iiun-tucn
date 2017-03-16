module.exports = RttStreamer

var Its = require('its')
var Sh = require('shelljs')
var Log = typeof window === 'undefined' ? require('debug')('RttStreamer') : console.log

//TODO implement one lock (in JS code and in RTT/ATR bash scripts) to avoid 
//  discarting values from the stream. Currently a "negligible" set of
//  values might be lost from the stream.

function RttStreamer (file, timeout) {
  //full path of file to read
  this._readsNo = 0
  this._iniTryNo = 0
  this._src = file
  this._latr = -1
  this._readyToR = false
  this._buffId = 0
  this._buff = {}
  this._readTimeout = timeout
  this.initialize()
}

RttStreamer.prototype.parseLine = function (line) {
  try {
    Its.defined(line)
    var array = line.split("icmp_seq=")
    Its(array.length !== 1)
  } catch (e) {
    Log("Given line doesn't contain any data")
    return undefined
  }
  // one unit is added to get the line number of source file
  var ind = parseInt(array[1].split(" ")[0]) + 1
  // RTT/2 in milliseconds
  var val = parseFloat(array[1].split(" ")[2].split("=")[1]) * (0.5)
  return { 'indx': ind, 'val': val }
}

RttStreamer.prototype.initialize = function () {
  var map = parseLine( Sh.tail({ '-n': 1 } , this._src) )
  try {
    Its.defined(map)
  } catch(e) {
    var self = this
    this._iniTryNo++
    Log("RTT file is not ready for reading [%d]", this._iniTryNo)
    //TODO call periodically initialize() until the first line is ready.
    //  You must wait a while (5 to 8 sec) to let t
  }
  this._latr = map.indx
}

RttStreamer.prototype.start = function () {
  var self = this
  setInterval(function () {
    self._readsNo++
    var go = self.readLatest()
    try {
      Its(go)
    } catch (e) {
      //TODO how many of this cases are you planning to allow to set
      //  this._readyToR <- false ?
      Log("Read [%d]. Probably, source file is not being updated anymore", self._readsNo)
      return
    }
    if (self._bufId == 0) {
      self._readyToR = true
    } else {
      self._buffId++
    }
  }, this._readTimeout)
}

RttStreamer.prototype.readLatest = function () {
  var map = parseLine( Sh.tail({ '-n': 1 } , this._src) )
  try {
    Its.defined(map)
  } catch(e) {
    Log("WARNING: the latest line from source file is empty")
    return false
  }
  var linesToRead = map.indx - this._latr
  if (linesToRead <= 0) {
    Log("WARNING: any new line was found")
    return false
  }
  this._latr = map.indx
  var latestLines = Sh.tail({ '-n': linesToRead } , this._src)
  
  return true
}
