module.exports = AtrRttMonitor
try {
  Its.defined(window)
  AtrRttMonitor.prototype._Log = console.info.bind(console)
  AtrRttMonitor.prototype._Err = console.error.bind(console)
  AtrRttMonitor.prototype.log = function (logMsg) {
    AtrRttMonitor.prototype._Log("AtrRttMonitor " + logMsg)
  }
  AtrRttMonitor.prototype.err = function (errMsg) {
    AtrRttMonitor.prototype._Err("AtrRttMonitor " + errMsg)
  }
} catch (e) {
  AtrRttMonitor.prototype.log = require('debug')('AtrRttMonitor:log') 
  AtrRttMonitor.prototype.err = require('debug')('AtrRttMonitor:err') 
}

function AtrRttMonitor (rttCharts, atrCharts, socket, rttChartCfg, 
  atrChartCfg, lineCfg) {
  if (!(this instanceof AtrRttMonitor)) {
    return new AtrRttMonitor(rttCharts, atrCharts, socket, rttChartCfg,
     atrChartCfg, lineCfg)
  }
  this.log("new AtrRttMonitor()")
  try {
    Its.array(rttCharts)
    Its.array(atrCharts)
    Its.defined(socket)
    Its.defined(rttChartCfg)
    Its.defined(atrChartCfg)
    Its.defined(lineCfg)
  } catch (e) {
    this.err("At least one argument is undefined. Aborting...")
    return undefined
  }
  this._timeout = 3
  this._rttCharts = rttCharts
  this._atrCharts = atrCharts
  var maX = Math.max(rttCharts.length, atrCharts.length)
  this._chartsLen = rttCharts.length === atrCharts.length ? rttCharts.length : maX
  this._socket = socket
  this._go = { rtt: true, atr: true, zk: true }
  this._threads = { rtt: undefined, atr: undefined, zk: undefined }
  this._tsPerChart = {}
  this._charts = {} ; var set = undefined
  var dataIds = Object.keys(this._threads)
  for (var i = 0; i < this._chartsLen; i++) {
    for (var j = 0; j < dataIds.length; j++) {
      set = this.setAttributes(i, atrChartCfg, rttChartCfg, lineCfg, dataIds[j])
      try {
        Its(set)
      } catch (e) {
        this.err("Item [" + j + "] to init an RTT/ATR/ZK chart will be empty.")
        this.err("To avoid it, be sure that all RTT/ATR/ZK arrys has the same length")
      }
    } 
  }
  this.setEvents()
  this.log("End of new AtrRttMonitor()")
}

AtrRttMonitor.prototype.setEvents = function () {
  var self = this ; var eventId = undefined
  var dataIds = Object.keys(this._threads)
  for (var i = 0; i < dataIds.length; i++) {
    eventId = dataIds[i] + '-answer'
    this._socket.on(eventId, function (msg) { self.handleMsgReception(msg) })
  } 
}

AtrRttMonitor.prototype.setAttributes = function (i, 
  atrChartCfg, rttChartCfg, lineCfg, dataId) {
  switch (dataId) {
    // ATR
    case "atr":
      if (typeof(this._atrCharts[i]) === 'undefined') return false
      this._tsPerChart[ this._atrCharts[i] ] = new TimeSeries()
      this._charts[ this._atrCharts[i] ] = new SmoothieChart(atrChartCfg)
      this._charts[ this._atrCharts[i] ].addTimeSeries (
       this._tsPerChart[ this._atrCharts[i] ], lineCfg
      )
      var atrCnvs = document.getElementById(this._atrCharts[i])
      this._charts[ this._atrCharts[i] ].streamTo(atrCnvs, 325) 
    break
    // RTT
    case "rtt":
      if (typeof(this._rttCharts[i]) === 'undefined') return false
      this._tsPerChart[ this._rttCharts[i] ] = new window.TimeSeries()
      this._charts[ this._rttCharts[i] ] = new SmoothieChart(rttChartCfg)
      this._charts[ this._rttCharts[i] ].addTimeSeries (
        this._tsPerChart[ this._rttCharts[i] ], lineCfg
      )
      var rttCnvs = document.getElementById(this._rttCharts[i])
      this._charts[ this._rttCharts[i] ].streamTo(rttCnvs, 325) 
    break
    // ZK
    case "zk":
      this.log("ZK case to be filled...")
    break
    default:
      this.err("Option ["+i+"] isn't recognized to set attributes")
    break
  }
  return true
}

AtrRttMonitor.prototype.appendInTimeSeries = function (okPayl, chart) {
  try {
    Its.defined(okPayl)
  } catch (e) {
    this.err("Received paylod is empty, any series will be drawn")
    return
  }
  var dateMs = new Date().getTime()
  for (var i = 0; i < this._chartsLen; i++) {
    for (var j = 0; j < okPayl.length; j++) {
      this._tsPerChart[ chart[i] ].append(dateMs + j * 1000, okPayl[j])
    }
  }
}

AtrRttMonitor.prototype.fillTimeSeries = function (dataId, okPayl) {
  switch (dataId) {
    case "rtt":
      this.appendInTimeSeries(okPayl, this._rttCharts)
    break
    case "atr":
      this.appendInTimeSeries(okPayl, this._atrCharts)
     break
    case "zk":
      this.log("TODO: Fill TimeSeries of ZK dataset")
    break
    default:
      this.err("Dataset [" + dataId + "] will be ignored")
      return false
    break
  }
  return true
}

AtrRttMonitor.prototype.handleMsgReception = function (msg) {
  this.log("Message reception with status [" + msg.status + "]")
  try {
    Its(msg.status === 'ok')
    var dataId = msg.payload.dataId
    var okPayl = msg.payload.okPayl
    try {
      Its.defined(this._go[ dataId ])
      var resu = this.fillTimeSeries(dataId, okPayl)
      try {
        Its(resu)
        var self = this
        this._go[dataId] = false
        this.log("Go[" + dataId + "] = FALSE, set to true after [" + okPayl + "] seconds")
        setTimeout(function () {
          self.log("Doing: Go[" + dataId + "] = TRUE")
          self._go[ dataId ] = true
        }, okPayl.length * 1000)
      } catch (e) {
        this.log("Letting: Go[" + dataId + "] = TRUE")
        this._go[dataId] = true
      }
    } catch (e) {
      this.err("Dataset [" + dataId + "] isn't recognized")
    }
  } catch (e) {
    this.err("KoMsg received: " + msg.payload)
  }
}

AtrRttMonitor.prototype.getStreams = function () {
  var dataIds = Object.keys(this._threads)
  var self = this
  for (var i = 0; i < dataIds.length; i++) {
    this._threads[ dataIds[i] ] = setInterval(function () {
      self.log("Is Go[" + dataIds[i] + "] true?")
      if (this._go[ dataIds[i] ]) {
        self.log("Go[" + dataIds[i] + "] is TRUE")
        self.log("Getting streams of [" + dataIds[i] + "]")
        var msg = {
          header: 'get-' + dataIds[i],
          payload: { streamId: undefined }
        }
        for (var j = 0; j < this._chartsLen; j++) {
          switch (dataIds[i]) {
            case "rtt":
              msg.payload.streamId = self._rttCharts[j]
            break
            case "atr":
              msg.payload.streamId = self._atrCharts[j]
            break
            case "zk":
              self.log("Set request ot get ZK stream")
            break
            default:
            break
          }
          self._socket.emit(msg.header, msg) 
        }
      } else {
        self.log("Still waiting for GO to be true")
      }
    }, this._timeout * 1000)
  }
}

AtrRttMonitor.prototype.stopGettingStreams = function () {
  var dataIds = Object.keys(this._threads)
  for (var i = 0; i < dataIds.length; i++) {
    this.log("Stop stream [" + dataIds[i] + "]")
    clearInterval( this._threads[ dataIds[i] ] )
  }
}
