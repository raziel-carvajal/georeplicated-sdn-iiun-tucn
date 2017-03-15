module.exports = RttStreamer

var Its = require('its')
var Sh = require('shelljs')
var Log = typeof window === 'undefined' ? require('debug')('RttStreamer') : console.log

//TODO implement one lock (in JS code and in RTT/ATR bash scripts) to avoid 
//  discarting values from the stream. Currently a "negligible" set of
//  values might be lost from the stream.

function RttStreamer (file) {
  //full path of file to read
  this._iniTryNo = 0
  this._src = file
  this._latr = -1
  this._readyToR = false
  this._buffId = 0
  this._buff = {}
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
    this._iniTryNo = this._iniTryNo + 1
    Log("RTT file is not ready for reading [%d]", this._iniTryNo)
    //TODO call periodically initialize() until the first line is ready.
    //  You must wait a while (5 to 8 sec) to let t
  }
  this._buff.push(map.val)
  this._latr = map.indx
  this._readyToR = true
}

RttStreamer.prototype.pop = function () {
  var resu = this._buff.pop()
  try {
    Its.defined(resu)
  } catch(e) {
  } finally {
    return resu
  }

}
