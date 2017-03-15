
module.exports = AtrOwdServer

var Express  = require('express')
var Http     = require('http')
var SocketIO = require('socket.io')

function AtrOwdServer (port) {
  if (!(this instanceof AtrOwdServer)) return new AtrOwdServer(port)
  this._port = port
  this._app = Express()
  this._app.use('/', Express.static(__dirname + '/'))
  this._http = Http.Server(this._app);
  this._io = SocketIO(this._http);

  this._app.get('/', function(req, res){
    res.sendFile(__dirname + '/index.html');
  });
  
  this._io.on('connection', function(socket){
    console.log('a user connected');
    //socket.on('?', function(msg){
    //  console.log('message: ' + msg);
    //});
  });
  
  this._http.listen(this._port, function(){
    console.log('listening on *:'+port);
  });
}

test = new AtrOwdServer(3000)
