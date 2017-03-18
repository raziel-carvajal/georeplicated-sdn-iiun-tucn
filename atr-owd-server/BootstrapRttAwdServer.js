var AtrOwdServer = require('./AtrOwdServer')

var rttStreams = {
  'rtt-clu-neu': '../datasets/rtt-clu-neu'
}
var atrStreams = {}
//var atrStreams = {
//  'atr-clu-neu': '../datasets/atr-clu-neu'
//}

var server = new AtrOwdServer(3000, "index.html", rttStreams, atrStreams, 3)
server.listen()
