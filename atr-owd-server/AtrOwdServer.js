module.exports = AtrOwdServer

var RttStreamer = require('./RttStreamer')
var Its = require('its')
var Express  = require('express')
var Http     = require('http')
var SocketIO = require('socket.io')
var Log = typeof window === 'undefined' ? require('debug')('AtrOwdServer') : console.log

function AtrOwdServer (port, webPage, rttStreams, atrStreams, readFreq) {
  if (!(this instanceof AtrOwdServer)) return new AtrOwdServer(port, webPage, rttStreams, atrStreams, readFreq)
  //TODO check the integrity of each argument with Its
  this._okMsg = { 'status': 'ok', payload: undefined }
  this._koMsg = { 'status': 'ko', payload: undefined }
  this._webDst = webPage
  this._port = port
  this._app = Express()
  this._app.use('/', Express.static(__dirname + '/'))
  this._http = Http.Server(this._app)
  this._io = SocketIO(this._http)
  this._rttReadNo = 0
  this._atrReadNo = 0
  this._rttStreams = {}
  this._atrStreams = {}
  var streams = Object.keys(rttStreams)
  Log("Before loop [%d]", streams.length)
  for (var i = 0; i < streams.length; i++) {
    Log("New stream for key: %s", streams[i])
    this._rttStreams[ streams[i] ] = new RttStreamer(rttStreams[ streams[i] ], readFreq)
    this._rttStreams[ streams[i] ].start()
  }
  //TODO fill this loop with streams for ATR
  //for (var i = 1; i < streams.length; i++) {
  //  this._rttStreams[ streams[i] ] = new RttStreamer(rttStreams[ streams[i] ], readFreq)
  //  this._rttStreams[ streams[i] ].start()
  //}
}

AtrOwdServer.prototype.listen = function () {
  var self = this
  this._app.get('/', function (req, res) {
    res.sendFile(__dirname + '/' + self._webDst)
  })
  
  this._io.on('connection', function (socket) {
    socket.on('RttHandler', function (msg) {
      try {
        Its.defined(msg)
        self.rttEventsHandler(msg)
      } catch (e) {
        //XXX do I have to answer the client in this case?
        Log("Warning: undefined message was received in RttHandler")
      }
    })
    socket.on('atrHandler', function (msg) {
      //TODO to fill with atrHandler
    })
  })
  
  this._http.listen(this._port, function () {
    Log("listening on *:%d", self._port)
  })
}


AtrOwdServer.prototype.rttEventsHandler = function (msg) {
  try {
    Its.defined(msg.header)
    var streamId = msg.payload.streamId
    Its.defined(streamId)
    switch (msg.header) {
      case "getRtt":
        
        try {
          var stream = this._rttStreams[streamId]
          Its.defined(stream)
          var payload = this.getReadFromStream(stream, this._rttReadNo)
          
          try {
            Its.defined(payload)
          } catch (e) {
            Log("WARNNING: read result is undefined for readNo [%d]", this._rttReadNo)
          } 
          
          this._okMsg.payload = payload
          this._io.emit('RttAnswer', okMsg)
        } catch (e) {
          Log("Stream [%s] doesn't exist", streamId)
          this._koMsg.payload = "Error: stream [" + streamId + "] doesn't exist"
          this._io.emit('RttAnswer', koMsg)
        }
        break
      default:
        Log("Unknown message [%s] for RttHandler", msg.header)
        this._koMsg.payload = "Error: Unknown mesage [" + msg.header + "]"
        this._io.emit('RttAnswer', koMsg)
        break
    }
  } catch (e) {
    Log("RttHandler: Message header OR streamId is not defined")
    this._koMsg.payload = "Error: Message header is undefined"
    this._io.emit('RttAnswer', koMsg)
  }
}


AtrOwdServer.prototype.getReadFromStream = function (stream, readNo) {
  Log("Reading stream with try number: %d", readNo)
  try {
    Its(stream._readyToR)
  } catch (e) {
    Log("RttStreamer is not ready to read")
    return undefined
  }
  var current = stream._buff[readNo]
  try {
    Its.defined(current)
    Log("Buffer of index [%d] is: " + current.toString(), readNo)
    delete stream._buff[readNo]
    readNo++
  } catch (e) {
    Log("ERROR: there is no entry for index: %d", readNo)
    return undefined
  }
  return current
}
