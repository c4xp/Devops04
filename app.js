const http = require('http');
const hostname = '0.0.0.0';
const port = process.env.PORT || 8080;

const os = require("os");
const node = os.hostname();

const server = http.createServer((req, res) => {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end('Hello, World! I\'m container ' + node + '\n');
});

server.listen(port, hostname, () => {
    console.log('Server running at http://%s:%s/', hostname, port);
});

process.on('SIGINT', function() {
    console.log('Caught interrupt signal and will exit');
    process.exit();
});