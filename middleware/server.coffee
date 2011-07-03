console.log require.paths
sys    = require "sys"
net    = require "net"
url    = require "url"
fs     = require "fs"
crypto = require "crypto"
https  = require "https"
ws     = require "webservice"
demoModule = require "./demoModule"
colors = require "colors"

oauth_key = fs.readFileSync('oauth.key').toString('utf-8')

server = https.createServer({
    key: fs.readFileSync('ssl-key.pem')
    cert: fs.readFileSync('ssl-cert.pem')
}, ws.createHandler demoModule).listen 8000

console.log ' > api server started on port 8000'.cyan

io     = (require "socket.io").listen(8001)

io.on 'connection', (client) ->
  console.log 'Logging Client connected';
  tail = spawn("tail", ["-f", 'server.log']);
  tail.stdout.on "data", data -> client.send data.toString('utf-8')

