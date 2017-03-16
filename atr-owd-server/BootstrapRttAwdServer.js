
var Log = typeof window === 'undefined' ? require('debug')('BootstrapRttAwdServer') : console.log
var AtrOwdServer = require('./AtrOwdServer')
var Its = require('its')

var rttStreams = {
  'tmpStream': 'tmp'
}

var server = new AtrOwdServer(3000, "index.html", rttStreams, {}, 3)
server.listen()
