document.addEventListener('DOMContentLoaded', function (event) {
  console.log("Hola")
  var smoothie = new SmoothieChart();
  console.log("After constructor");
  var cnv = document.getElementById("mycanvas");
  smoothie.streamTo(cnv);
});

