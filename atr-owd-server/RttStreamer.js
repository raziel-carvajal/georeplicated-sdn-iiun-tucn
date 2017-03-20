module.exports = RttStreamer

var Its = require('its')
var Sh = require('shelljs')

try {
  Its.defined(window)
  RttStreamer.prototype._Log = console.info.bind(console)
  RttStreamer.prototype._Err = console.error.bind(console)
  RttStreamer.prototype.log = function (logMsg) {
    RttStreamer.prototype._Log("RttStreamer " + logMsg)
  }
  RttStreamer.prototype.err = function (errMsg) {
    RttStreamer.prototype._Err("RttStreamer " + errMsg)
  }
} catch (e) {
  RttStreamer.prototype.log = require('debug')('RttStreamer:INFO')
  RttStreamer.prototype.err = require('debug')('RttStreamer:ERROR')
}

//TODO Ideally, you have to implement one lock (in JS code and in RTT/ATR bash scripts)
//  to avoid discarting values from the stream. Currently a "negligible" set of values
//  might be lost from the stream. On the other hand, this is the price to pay while
//  streaming

function RttStreamer (file, timeout, measureType) {
  if (!(this instanceof RttStreamer)) return new RttStreamer(file, timeout, measureType)
  try {
    Its.string(file)
    Its.number(timeout)
    Its.string(measureType)
  } catch (e) {
    this.err("At least one argument hasn't the appropiate type. Aborting...")
    return undefined
  }
  var okMeasureType = measureType === 'rtt' || measureType === 'atr' || measureType === 'zk_r' || measureType === 'zk_w' ? true : false
  try {
    Its(okMeasureType)
  } catch (e) {
    this.err("Unknown measure type [%s]. Aborting...", measureType)
    return undefined    
  }
  this._initTryNo = 0
  this._measureType = measureType
  this._src = file //full path of file to read
  this._srcBaseName = file.split("../datasets/")[1]
  try {
    Its(this._srcBaseName !== '')
  } catch (e) {
    this.err("Source file hasn't the appropiate format. Aborting...")
    return undefined
  }
  this._latr = undefined
  this._readyToR = false
  this._buffId = 0
  this._buff = {}
  this._readTimeout = timeout * 1000
  this._startThread = undefined
  this._readsBefStart = 2
  this._initTimeout = 3000
  this._maxFails = 5
  this._failedTries = 0
  this.initialize()
}

RttStreamer.prototype.initialize = function () {
  var line = this.choseLine()
  var map = this.parseLine(line)
  try {
    Its.defined(map)
    this.log("Init went well, first index: %d", this._latr)
    try {
      Its.defined(this._latr)
    } catch (e) {
      this._latr = map.indx
    }
  } catch(e) {
    this._initTryNo++
    this.err("RTT file is not ready for reading [%d]", this._initTryNo)
    var self = this
    setTimeout(function () {
      self.initialize()
    }, this._initTimeout)
  }
}

RttStreamer.prototype.parseLine = function (line) {
  var l
  switch (this._measureType) {
    case 'rtt':
      l = this.parseRttline(line)
    break
    case 'atr':
      l = this.parseAtrline(line)
    break
    case 'zk_w':
      l = this.parseZkline(line)
    break
    case 'zk_r':
      l = this.parseZkline(line)
    break
    default:
      //XXX this case can't take place!
      this.err("Measure [%s] is not recognized", this._measureType)
    break
  }
  return l
}

RttStreamer.prototype.parseZkline = function (line) {
  try {
    Its.defined(line)
    var array = line.split(" ")
    Its(array.length !== 1)
  } catch (e) {
    this.err("Current line doesn't contain any data")
    return undefined
  }
  var ind =   parseInt(array[0])
  var val = parseFloat(array[2])
  try {
    Its.number(ind)
    Its.number(val)
    //this.log("ZK: Current indx=%d && val=", ind, val)
    return { 'indx': ind, 'val': val }
  } catch (e) {
    this.err("Pair: (" + ind + ", " + val + ") is not numeric")
    return undefined  
  }
}

RttStreamer.prototype.parseRttline = function (line) {
  try {
    Its.defined(line)
    var array = line.split("icmp_seq=")
    Its(array.length !== 1)
  } catch (e) {
    this.err("Current line doesn't contain any data")
    return undefined
  }
  var ind = parseInt(array[1].split(" ")[0])
  var val = parseFloat(array[1].split(" ")[2].split("=")[1])
  try {
    Its.number(ind)
    Its.number(val)
    //this.log("RTT: Current indx=%d && val=", ind, val)
    return { 'indx': ind, 'val': val }
  } catch (e) {
    this.err("Pair: (" + ind + ", " + val + ") is not numeric")
    return undefined  
  }
}

RttStreamer.prototype.parseAtrline = function (line) {
  try {
    Its.defined(line)
    var array = line.split(" ")
    Its(array.length !== 1)
  } catch (e) {
    this.err("Current line doesn't contain any data")
    return undefined
  }
  var ind = parseInt(array[3].split("-")[0])
  var val = parseFloat(array[ array.length - 2 ])
  //this.log("ATR: Current indx=%d && val=", ind, val)
  try {
    Its.number(ind)
    Its.number(val)
    return { 'indx': ind, 'val': val }
  } catch (e) {
    this.err("Pair: (" + ind + ", " + val + ") is not numeric")
    return undefined  
  }
}

RttStreamer.prototype.choseLine = function () {
  var l
  var r = this._measureType === 'atr' ? true : false
  try {
    Its(r)
    l = Sh.tail({ '-n': 2 }, this._src).split("\n")[0]
  } catch (e) {
    l = Sh.tail({ '-n': 1 }, this._src)
  } finally {
    return l
  }
}



RttStreamer.prototype.start = function () {
  var self = this
  this._startThread = setInterval(function () {
    try {
      Its.defined(self._latr)
      self.log("Calling start()")
    } catch (e) {
      self.err("Initialization phase of RttStreamer is not yet completed")
      return
    }
    var go = self.readLatest()
    try {
      Its(go)
      self.log("Ready to go. Failed tries variable is set to zero")
      self._failedTries = 0
    } catch (e) {
      self._failedTries++
      self.err("Fail [%d] while trying to read. Probably, source file is not being updated anymore", self._failedTries)
//      if (self._failedTries >= self._maxFails) {
//        self.log("Maximum numbers of tries to read source file was reached")
//        self.stop()
//      }
      return
    }
    self._buffId++
    if (self._buffId > self._readsBefStart) {
      self._readyToR = true
    }
  }, this._readTimeout)
}

RttStreamer.prototype.readLatest = function () {
  var line = this.choseLine()
  var map = this.parseLine(line)
  try {
    Its.defined(map)
  } catch(e) {
    this.err("WARNING: the latest line from source file is empty")
    return false
  }
  this.log("CHUNK from lines %d to %d", this._latr, map.indx)
  var linesToRead = map.indx - this._latr
  if (linesToRead <= 0) {
    this.log("WARNING: any new line was found")
    return false
  }
  this._latr = map.indx
  var buff = []
  var latestLines = ( Sh.tail({ '-n': linesToRead } , this._src) ).split("\n")
  if (this._measureType === 'atr') { latestLines.pop() }
  for (var i = 0; i < latestLines.length; i++) {
    map = this.parseLine( latestLines[i] )
    try {
      Its.defined(map)
      buff.push(map.val)
    } catch (e) {/*XXX Nothing to cath if read line hasn't PING format*/}
  }
  this._buff[this._buffId] = buff
  //this.log("Current buffer to store with index [%d]=", this._buffId, this._buff[this._buffId].toString())
  return true
}

RttStreamer.prototype.stop = function () {
  this.log("RttStreamer stops its execution")
  this._readyToR = false
  this._latr = undefined
  clearInterval(this._startThread)
}
