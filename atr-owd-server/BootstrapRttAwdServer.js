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

var zkReStreams = {
  'zk-clu-lan-reads': '../datasets/zk-clu-lan-reads'
}

var zkWrStreams = {
  'zk-clu-lan-writes': '../datasets/zk-clu-lan-writes'
}

var server = new AtrOwdServer(3001, "index.html", rttStreams, atrStreams, zkReStreams, zkWrStreams, 7)
server.listen()
