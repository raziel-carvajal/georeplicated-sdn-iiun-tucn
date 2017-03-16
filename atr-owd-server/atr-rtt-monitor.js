document.addEventListener('DOMContentLoaded', function (event) {
  var socket = io();
  var smoothie = new SmoothieChart();
  var cnv = document.getElementById("mycanvas");
  smoothie.streamTo(cnv);
});

