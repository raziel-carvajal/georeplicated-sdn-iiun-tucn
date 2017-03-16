document.addEventListener('DOMContentLoaded', function (event) {
  function sleep(milliseconds) {
    var start = new Date().getTime()
    for (var i = 0; i < 1e7; i++) {
      if ((new Date().getTime() - start) > milliseconds){
        break
      }
    }
  }
  
  var socket = io()
  var ts = new TimeSeries();
  var smoothie = new SmoothieChart()
  smoothie.addTimeSeries(ts);
  var cnv = document.getElementById("mycanvas")
  smoothie.streamTo(cnv, 2000)
  var i = 1; var j = 1 ; var go = true
  

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
  
  socket.on('RttHandler', function (msg) {
    console.log("Message reception [%d] with status [%s]", i, msg['status'])
    if (msg['status'] === 'ok') {
      go = false
      var arr = msg.payload
      var dateMs = new Date().getTime()
      for (var k = 0; k < arr.length; k++) {
        ts.append(dateMs + k * 1000, arr[k])
      }
      i++
      setTimeout(function () {
        console.log("Doing GO=TRUE")
        go = true
      }, arr.length * 1000)
    }
  })


})

