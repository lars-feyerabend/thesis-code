sys    = require "sys"
net    = require "net"
url    = require "url"
fs     = require "fs"
crypto = require "crypto"
https  = require "https"

options = {
  key: fs.readFileSync('ssl-key.pem')
  cert: fs.readFileSync('ssl-cert.pem')
}

callback = (req, res) ->
  res.writeHead 200
  res.end "Hello, World!\n"

https.createServer(options, callback).listen 8000

console.log ' > server started on port 8000'