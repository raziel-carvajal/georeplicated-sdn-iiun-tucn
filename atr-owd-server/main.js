var lineCfg = {lineWidth:2,strokeStyle:'#19ff00'}

var rttChartCfg = {millisPerPixel:42,maxValueScale:0.8,interpolation:'step',scaleSmoothing:0.205,grid:{sharpLines:true,millisPerLine:2000,verticalSections:6},labels:{fontSize:18},timestampFormatter:SmoothieChart.timeFormatter,minValue:0,maxValue:100,horizontalLines:[{color:'#ffffff',lineWidth:1,value:0},{color:'#880000',lineWidth:2,value:3333},{color:'#880000',lineWidth:2,value:-3333}]}

var atrChartCfg = {millisPerPixel:42,maxValueScale:0.8,interpolation:'step',scaleSmoothing:0.205,grid:{sharpLines:true,millisPerLine:2000,verticalSections:6},labels:{fontSize:18},timestampFormatter:SmoothieChart.timeFormatter,minValue:0,maxValue:300,horizontalLines:[{color:'#ffffff',lineWidth:1,value:0},{color:'#880000',lineWidth:2,value:3333},{color:'#880000',lineWidth:2,value:-3333}]}

var rttCharts = ['rtt-clu-neu', 'rtt-clu-bor', 'rtt-clu-lan']
var atrCharts = ['atr-clu-neu', 'atr-clu-bor', 'atr-clu-lan']

window.Its = require('its')
window.SmoothieChart = require('smoothie').SmoothieChart
window.AtrRttMonitor = require('./AtrRttMonitor.js')

// MAIN()
document.addEventListener('DOMContentLoaded', function (event) {
  var socket = io()
  //var monitor = new AtrRttMonitor(rttCharts, atrCharts, socket, rttChartCfg,
  //   atrChartCfg, lineCfg)
  // Fetching ATR/RTT/ZK streams in a periodic way
  //monitor.fetchStreams()
})
