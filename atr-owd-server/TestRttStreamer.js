var ReSt = require('./RttStreamer')
var Its = require('its')
var Log = typeof window === 'undefined' ? require('debug')('TestRttStreamer') : console.log

var readNo = 0
var str = new ReSt('tmp', 3)
str.start()

var loop = setInterval(function () {
  Log("Reading stream with try number: %d", readNo)
  try {
    Its(str._readyToR)
  } catch (e) {
    Log("RttStreamer is not ready to read")
    return
  }
  var current = str._buff[readNo]
  try {
    Its.defined(current)
    Log("Buffer of index [%d] is: " + current.toString(), readNo)
    delete str._buff[readNo]
    Log("Current buffer in RttSteamer instance: " + Object.keys(str._buff).toString())
    readNo++
  } catch (e) {
    Log("ERROR: there is no entry for index: %d", readNo)
  }
}, 5 * 1000)

setTimeout(function () {
  Log("End of unit test of RttStreamer")
  clearInterval(loop)
  str.stop()
}, 40 * 1000)

//function arrayToStr (array) {
//  var str = ''
//  for (var i = 0; i < array.length; i++) {
//    try {
//      Its.defined(array[i])
//      if (i < array.length - 1) {
//        str += array[i].toString() + ', '
//      } else {
//        str += array[i].toString()
//      }
//    } catch (e) {
//      Log("Entry [%d] of array is not defined", i)
//    }
//  }
//  return str
//}
