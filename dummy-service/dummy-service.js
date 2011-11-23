function rand(from, to){
  return Math.floor(Math.random() * (to - from + 1) + from);
}

var fs       = require("fs"),
    restify  = require("restify"),
    log      = restify.log,
    body     = fs.readFileSync('dynexite-dummy.html').toString();
    
var argv = require('optimist')
    .usage('Run dummy test service.\nUsage: node(mon) $0')
    .alias('c', 'contentset')
    .describe('c', 'Which dummy content set to use [1-3]')
    .default('c', 1)
    .argv
;

var json     = JSON.parse(fs.readFileSync('content/content'+argv.c+'.json').toString());
    
log.level('Debug');
server = restify.createServer({
  version: null
});

server.get('/test', function(req, res) {
  res.send(200, json);
});

server.get('/test/:id', function(req, res) {
  res.send(200, json[req.uriParams.id-1]);
});

server.get('/test/:id/page/:num', function(req, res) {
  res.send({
    code: 200,
    headers: {
      'Content-Type': 'text/html',
      'Content-Encoding': 'UTF-8',
      'Trailer': 'Content-MD5',
    },
    noEnd: true
  });

  var crypto = require('crypto'), hash = crypto.createHash('md5');

  res.write(body);
  hash.update(body);
  
  res.addTrailers({'Content-MD5': hash.digest('base64')});
  res.end();
});

server.listen(9006);