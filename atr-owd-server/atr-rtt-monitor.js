var rttChartCfg = {millisPerPixel:42,maxValueScale:0.8,interpolation:'step',scaleSmoothing:0.205,grid:{sharpLines:true,millisPerLine:2000,verticalSections:6},labels:{fontSize:18},timestampFormatter:SmoothieChart.timeFormatter,minValue:0,maxValue:100,horizontalLines:[{color:'#ffffff',lineWidth:1,value:0},{color:'#880000',lineWidth:2,value:3333},{color:'#880000',lineWidth:2,value:-3333}]}

var atrChartCfg = {millisPerPixel:42,maxValueScale:0.8,interpolation:'step',scaleSmoothing:0.205,grid:{sharpLines:true,millisPerLine:2000,verticalSections:6},labels:{fontSize:18},timestampFormatter:SmoothieChart.timeFormatter,minValue:0,maxValue:300,horizontalLines:[{color:'#ffffff',lineWidth:1,value:0},{color:'#880000',lineWidth:2,value:3333},{color:'#880000',lineWidth:2,value:-3333}]}

var lineCfg = {lineWidth:2,strokeStyle:'#19ff00'}

var rttCharts = ['rtt-clu-neu', 'rtt-clu-bor', 'rtt-clu-lan']
var atrCharts = ['atr-clu-neu', 'atr-clu-bor', 'atr-clu-lan']

document.addEventListener('DOMContentLoaded', function (event) {
  var socket = io()
  var tsPerChart = {}, charts = {}, atrCnvs = undefined, rttCnvs = undefined
  for (var i = 0; i < atrCharts.length; i++) {
    tsPerChart[ rttCharts[i] ] = new TimeSeries()
    tsPerChart[ atrCharts[i] ] = new TimeSeries()
    charts[ rttCharts[i] ] = new SmoothieChart(rttChartCfg)
    charts[ atrCharts[i] ] = new SmoothieChart(atrChartCfg)
    charts[ rttCharts[i] ].addTimeSeries(tsPerChart[ rttCharts[i] ], lineCfg) 
    charts[ atrCharts[i] ].addTimeSeries(tsPerChart[ atrCharts[i] ], lineCfg)
    rttCnvs = document.getElementById(rttCharts[i])
    atrCnvs = document.getElementById(atrCharts[i])
    charts[ rttCharts[i] ].streamTo(rttCnvs, 325) 
    charts[ atrCharts[i] ].streamTo(atrCnvs, 325) 
  }
  var h = 1, j = 1, go = true
  socket.on('RttHandler', function (msg) {
    console.log("Message reception [%d] with status [%s]", h, msg['status'])
    if (msg['status'] === 'ok') {
      go = false
      var arr = msg.payload
      var dateMs = new Date().getTime()
      for (var i = 0; i < atrCharts.length; i++) {
        for (var k = 0; k < arr.length; k++) {
          tsPerChart[ rttCharts[i] ].append(dateMs + k * 1000, arr[k])
          tsPerChart[ atrCharts[i] ].append(dateMs + k * 1000, arr[k])
        }
      }
      h++
      setTimeout(function () {
        console.log("Doing GO=TRUE")
        go = true
      }, arr.length * 1000)
    } else {
      console.log("Msg received with status KO")
    }
  })
  setInterval(function () {
    if (go) {
      console.log("Request [%d]", j)
      var msg = {
        header: 'getRtt',
        payload: { streamId: 'tmpStream' }
      }
      socket.emit('RttHandler', msg)
      j++
    } else {
      console.log("Still waiting for GO to be true")
    }
  }, 3 * 1000)
})

