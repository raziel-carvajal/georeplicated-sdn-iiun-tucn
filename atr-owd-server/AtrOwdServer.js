module.exports = AtrOwdServer

var RttStreamer = require('./RttStreamer')
var Its = require('its')
var Express  = require('express')
var Http     = require('http')
var SocketIO = require('socket.io')

try {
  Its.defined(window)
  AtrOwdServer.prototype._Log = console.info.bind(console)
  AtrOwdServer.prototype._Err = console.error.bind(console)
  AtrOwdServer.prototype.log = function (logMsg) {
    AtrOwdServer.prototype._Log("AtrOwdServer " + logMsg)
  }
  AtrOwdServer.prototype.err = function (errMsg) {
    AtrOwdServer.prototype._Err("AtrOwdServer " + errMsg)
  }
} catch (e) {
  AtrOwdServer.prototype.log = require('debug')('AtrOwdServer:log')
  AtrOwdServer.prototype.err = require('debug')('AtrOwdServer:err')
}

function AtrOwdServer (port, webPage, rttStreams, atrStreams, readFreq) {
  if (!(this instanceof AtrOwdServer)) return new AtrOwdServer(port, webPage, rttStreams, atrStreams, readFreq)
  try {
    Its.number(port)
    Its.string(webPage)
    Its.object(rttStreams)
    Its.object(atrStreams)
    Its.number(readFreq)
  } catch (e) {
    this.err("At least one argument has a non expected type. Aborting...")
    return undefined
  }
  var rttKeys = Object.keys(rttStreams), atrKeys = Object.keys(atrStreams)
  this._streamsNo = rttKeys.length === atrKeys.length ? rttKeys.length : Math.max(rttKeys.length, atrKeys.length)
  this._webDst = webPage
  this._port = port
  this._app = Express()
  this._app.use('/', Express.static(__dirname + '/'))
  this._http = Http.Server(this._app)
  this._io = SocketIO(this._http)
  this._rttStreams = {} ; this._rttReadsNo = {}
  this._atrStreams = {} ; this._atrReadsNo = {}
  this._zkStreams = {}  ; this._zkReadsNo = {}
  for (var i = 0; i < this._streamsNo; i++) {
    this.log("New RTT stream with key [%s]", rttKeys[i])
    this._rttReadsNo[ rttKeys[i] ] = 0
    this._rttStreams[ rttKeys[i] ] = new RttStreamer(rttStreams[ rttKeys[i] ], readFreq)
    this.bootStream( this._rttStreams[ rttKeys[i] ], rttKeys[i] )
    this.log("New ATR stream with key [%s]", atrKeys[i])
    this._atrReadsNo[ atrKeys[i] ] = 0
    this._atrStreams[ atrKeys[i] ] = new RttStreamer(atrStreams[ atrKeys[i] ], readFreq)
    this.bootStream( this._atrStreams[ atrKeys[i] ], atrKeys[i] )

  }
  /*
  //TODO do the same for ZK streams
  var zkKeys = Object.keys(ZK_VAR)
  for (var i = 0; i < zkKeys.length; i++) {
    this.log("New ZK stream with key [%s"], zkKeys[i])
    this._zkReadsNo[ zkKeys[i] ] = 0
    this._zkStreams[ zkKeys[i] ] = new RttStreamer(ZK_VAR[ zkKeys[i] ], readFreq)
    this.bootStream( this._zkStreams[ zkKeys[i] ], zkKeys[i] )
  }
  */
}

AtrOwdServer.prototype.bootStream = function (stream, streamId) {
  try {
    Its.defined(stream)
    Its.defined(streamId)
    this.log("Starting stream [%s]", streamId)
    stream.start()
  } catch (e) {
    this.err("Stream [%s] wasn't initialize", streamId)
  }
}

AtrOwdServer.prototype.listen = function () {
  var self = this
  
  this._http.listen(this._port, function () {
    self.log("Listening on *:%d", self._port)
  })
  
  this._app.get('/', function (req, res) {
    res.sendFile(__dirname + '/' + self._webDst)
  })
  
  //TODO how to answer on each catch() that the message is empty?
  this._io.on('connection', function (socket) {
    socket.on('get-rtt', function (msg) {
      try {
        Its.defined(msg)
      } catch (e) {
        self.err("Undefined message was received in RttHandler")
        return
      }
      self.log("Handling request to get RTT stream")
      self.streamsHandler(msg, 'get-rtt')
    })
    socket.on('get-atr', function (msg) {
      try {
        Its.defined(msg)
      } catch (e) {
        self.err("Undefined message was received in AtrHandler")
        return
      }
      self.log("Handling request to get ATR stream")
      self.streamsHandler(msg, 'get-atr')
    })
    socket.on('get-zk', function (msg) {
      try {
        Its.defined(msg)
      } catch (e) {
        self.err("Undefined message was received in ZkHandler")
        return
      }
      self.log("Handling request to get ZK stream")
      self.streamsHandler(msg, 'get-zk')
    })
  })
}


AtrOwdServer.prototype.streamsHandler = function (msg, eventId) {
  var eventAnswId = undefined, stream = undefined, streamNo = undefined
  var okMsg = { 'status': 'ok', payload: undefined }
  var koMsg = { 'status': 'ko', payload: undefined }
  switch (eventId) {
    case 'get-rtt':
      eventAnswId = 'rtt-answer'
      stream = this._rttStreams
      streamNo = this._rttReadsNo
    break
    case 'get-atr':
      eventAnswId = 'atr-answer'
      stream = this._atrStreams
      streamNo = this._atrReadsNo
    break
    case  'get-zk':
      eventAnswId = 'zk-answer'
      stream = this._zkStreams
      streamNo = this._zkReadsNo
    break
    default:
      this.err("This call shouldn't take place")
    break
  }
  try {
    Its.defined(msg.header); var streamId = msg.payload.streamId
    Its.defined(streamId) ; Its.string(streamId)
  } catch (e) {
    this.err("Message header OR streamId is not defined")
    koMsg.payload = "Error: Message header is undefined"
    this._io.emit(eventAnswId, koMsg) ; return
  }
  try {
    Its.defined( stream[streamId] )
    Its.number( streamNo[streamId] )
    var payload = this.getStream(stream[streamId], streamId, streamNo)
    try {
      Its.defined(payload)
    } catch (e) {
      this.err("Read result is undefined for readNo [%d]", streamNo[streamId])
    }
    this.log("OK message as response")
    okMsg.payload = {
      dataId: stream[streamId]._srcBaseName,
      okPayl: payload
    }
    this._io.emit(eventAnswId, okMsg)
  } catch (e) {
    this.err("Stream [%s] doesn't exist", streamId)
    koMsg.payload = "Error: stream [" + streamId + "] doesn't exist"
    this._io.emit(eventAnswId, koMsg)
  }
}


AtrOwdServer.prototype.getStream = function (stream, streamId, streamNo) {
  var readNo = streamNo[streamId]
  this.log("Reading stream with try number: %d", readNo)
  try {
    Its(stream._readyToR)
  } catch (e) {
    this.err("RttStreamer is not ready to read")
    return undefined
  }
  var current = stream._buff[readNo]
  try {
    Its.defined(current)
    this.log("Buffer of index [%d] is: " + current.toString(), readNo)
    delete stream._buff[readNo]
    readNo++
    streamNo[streamId] = readNo
  } catch (e) {
    this.err("ERROR: there is no entry for index: %d", readNo)
    return undefined
  }
  return current
}
