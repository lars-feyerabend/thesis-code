sys    = require "sys"
net    = require "net"
url    = require "url"
fs     = require "fs"
crypto = require "crypto"
https  = require "https"
ws     = require "webservice"
demoModule = require "./demoModule"
colors = require "colors"
connect = require "connect"

oauth_key = fs.readFileSync('oauth.key').toString('utf-8')

router = connect.router (app) ->
  app.get '/user/:id', (req, res, next) ->
    return
  
  app.put '/user/:id', (req, res, next) ->
    return


connect(
    { key: fs.readFileSync('ssl-key.pem'), cert: fs.readFileSync('ssl-cert.pem') }
  , connect.logger()
  , router
  , connect.static(__dirname + '/public')
).listen 3000

console.log ' > api server started on port 3000'.cyan

# io     = (require "socket.io").listen(8001)
# 
# io.on 'connection', (client) ->
#   console.log 'Logging Client connected';
#   tail = spawn("tail", ["-f", 'server.log']);
#   tail.stdout.on "data", data -> client.send data.toString('utf-8')
# 
