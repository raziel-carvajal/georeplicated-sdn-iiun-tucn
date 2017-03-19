var AtrOwdServer = require('./AtrOwdServer')

var rttStreams = {
  'rtt-clu-neu': '../datasets/rtt-clu-neu',
  'rtt-clu-bor': '../datasets/rtt-clu-bor',
  'rtt-clu-lan': '../datasets/rtt-clu-lan'
}

var atrStreams = {
  'atr-clu-neu': '../datasets/atr-clu-neu',
  'atr-clu-bor': '../datasets/atr-clu-bor',
  'atr-clu-lan': '../datasets/atr-clu-lan'
}

var server = new AtrOwdServer(3001, "index.html", rttStreams, atrStreams, 5)
server.listen()
