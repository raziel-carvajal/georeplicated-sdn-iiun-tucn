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
  atrChartCfg, lineCfg, zkReCharts, zkWrCharts, zkReChartCfg, zkWrChartCfg) {
  if (!(this instanceof AtrRttMonitor)) {
    return new AtrRttMonitor(rttCharts, atrCharts, socket, rttChartCfg,
     atrChartCfg, lineCfg, zkReCharts, zkWrCharts, zkReChartCfg, zkWrChartCfg)
  }
  this.log("new AtrRttMonitor()")
  try {
    Its.array(rttCharts)
    Its.array(atrCharts)
    Its.array(zkReCharts)
    Its.array(zkWrCharts)
    Its.defined(socket)
    Its.defined(rttChartCfg)
    Its.defined(atrChartCfg)
    Its.defined(lineCfg)
  } catch (e) {
    this.err("At least one argument is undefined. Aborting...")
    return undefined
  }
  this._timeout = 5
  this._rttCharts = rttCharts
  this._atrCharts = atrCharts
  this._zkReCharts = zkReCharts
  this._zkWrCharts = zkWrCharts
  this._chartsLen = Math.max(rttCharts.length, atrCharts.length, zkReCharts.length, zkWrCharts.length)
  this.log("MAX: " + this._chartsLen)
  this._socket = socket
  this._measureTypes = ['rtt', 'atr', 'zk']
  this._go = {}, this._threads = {}, this._tsPerChart = {}, this._charts = {}
  var set = undefined
  for (var i = 0; i < this._chartsLen; i++) {
    for (var j = 0; j < this._measureTypes.length; j++) {
      set = this.setAttributes(i, zkReChartCfg, zkWrChartCfg, atrChartCfg,
        rttChartCfg, lineCfg, this._measureTypes[j])
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
  var dataIds = this._measureTypes
  for (var i = 0; i < dataIds.length; i++) {
    eventId = dataIds[i] + '-answer'
    this._socket.on(eventId, function (msg) {
      self.handleMsgReception(msg)
    })
  } 
}

AtrRttMonitor.prototype.setAttributes = function (i, 
  zkReChartCfg, zkWrChartCfg, atrChartCfg, rttChartCfg, lineCfg, dataId) {
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
      this.log("SetAttrs for: " + this._atrCharts[i])
      this._go[ this._atrCharts[i] ] = true
      this._threads[ this._atrCharts[i] ] = undefined 
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
      this.log("SetAttrs for: " + this._rttCharts[i])
      this._go[ this._rttCharts[i] ] = true
      this._threads[ this._rttCharts[i] ] = undefined 
    break
    // ZK writes
    case "zk":
      if (typeof(this._zkReCharts[i]) !== 'undefined') {
        this._tsPerChart[ this._zkReCharts[i] ] = new window.TimeSeries()
        this._charts[ this._zkReCharts[i] ] = new SmoothieChart(zkReChartCfg)
        this._charts[ this._zkReCharts[i] ].addTimeSeries (
          this._tsPerChart[ this._zkReCharts[i] ], lineCfg
        )
        var rttCnvs = document.getElementById(this._zkReCharts[i])
        this._charts[ this._zkReCharts[i] ].streamTo(rttCnvs, 325) 
        this.log("SetAttrs for: " + this._zkReCharts[i])
        this._go[ this._zkReCharts[i] ] = true
        this._threads[ this._zkReCharts[i] ] = undefined 
      }

      if (typeof(this._zkWrCharts[i]) !== 'undefined') {            
        this._tsPerChart[ this._zkWrCharts[i] ] = new window.TimeSeries()
        this._charts[ this._zkWrCharts[i] ] = new SmoothieChart(zkWrChartCfg)
        this._charts[ this._zkWrCharts[i] ].addTimeSeries (
          this._tsPerChart[ this._zkWrCharts[i] ], lineCfg
        )
        var rttCnvs = document.getElementById(this._zkWrCharts[i])
        this._charts[ this._zkWrCharts[i] ].streamTo(rttCnvs, 325) 
        this.log("SetAttrs for: " + this._zkWrCharts[i])
        this._go[ this._zkWrCharts[i] ] = true
        this._threads[ this._zkWrCharts[i] ] = undefined
      }
    default:
      this.err("Option ["+i+"] isn't recognized to set attributes")
    break
  }
  return true
}

AtrRttMonitor.prototype.appendInTimeSeries = function (okPayl, streamId) {
  try {
    Its.defined(okPayl)
    this.log("Payload [" + okPayl.toString() + "] of strem [" + streamId + "]")
  } catch (e) {
    this.err("Received paylod is empty, any series will be drawn")
    return
  }
  var dateMs = new Date().getTime()
  for (var j = 0; j < okPayl.length; j++) {
    this._tsPerChart[ streamId ].append(dateMs + j * 1000, okPayl[j])
  }
}

AtrRttMonitor.prototype.fillTimeSeries = function (streamId, okPayl) {
  var id = streamId.split("-")[0]
  this.log("ID: " + id)
  var r = id === "rtt" || id === "atr" || id === "zk" ? true : false
  try {
    Its(r)
    this.appendInTimeSeries(okPayl, streamId)
  } catch (e) {
    this.err("Dataset [" + streamId + "] will be ignored")  
  } finally {
    return r
  }
}

AtrRttMonitor.prototype.handleMsgReception = function (msg) {
  this.log("Message reception with status [" + msg.status + "]")
  try {
    Its(msg.status === 'ok')
    var dataId = msg.payload.dataId
    var okPayl = msg.payload.okPayl
    try {
      this.log("FILE: " + dataId)
      Its(this._go[ dataId ])
      this._go[dataId] = false
      var resu = this.fillTimeSeries(dataId, okPayl)
      try {
        Its(resu)
        var self = this
        this._go[dataId] = false
        this.log("Go[" + dataId + "] = FALSE, set to true after [" + okPayl.length + "] seconds")
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

AtrRttMonitor.prototype.doRequest = function (streamId) {
  this.log("Is Go[" + streamId + "] true?")
  if (this._go[ streamId ]) {
    this.log("Go[" + streamId + "] is TRUE. Getting its stream")
    //XXX be sure that streamId has the format (rtt||atr||zk)-*
    var dataId = streamId.split("-")[0]
    var msg = {
      header: 'get-' + dataId,
      payload: { 'streamId': undefined }
    }
    this.log("HEADER: " + msg.header)
    var r = dataId === "rtt" || dataId === "atr" || dataId === "zk" ? streamId : undefined
    msg.payload['streamId'] = r
    this._socket.emit(msg.header, msg) 
  } else {
    this.log("Still waiting for Go[" + streamId + "] to be true")
  }
}

AtrRttMonitor.prototype.getStreams = function () {
  var self = this
  var dataIds = Object.keys(this._threads)
  for (var i = 0; i < dataIds.length; i++) {
    this._threads[ dataIds[i] ] = setInterval(function (dataId) {
      self.log("Doing request for: " + dataId)
      self.doRequest(dataId)
    }, this._timeout * 1000, dataIds[i])  
  }
}

AtrRttMonitor.prototype.stopGettingStreams = function () {
  var dataIds = Object.keys(this._threads)
  for (var i = 0; i < dataIds.length; i++) {
    this.log("Stop stream [" + dataIds[i] + "]")
    clearInterval( this._threads[ dataIds[i] ] )
  }
}
