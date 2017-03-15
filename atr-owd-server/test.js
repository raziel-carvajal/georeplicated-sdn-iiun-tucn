const WebSocket = require('ws');

const ws = new WebSocket('ws://127.0.0.1/path', {
  perMessageDeflate: false
});

ws.on('open', function open() {
    ws.send('something');
});
