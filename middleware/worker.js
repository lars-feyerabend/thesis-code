var fs       = require("fs"),
    restify  = require("restify"),
    log      = restify.log,
    mongoose = require('mongoose');
    
log.level('Debug');
    
var oauth_key = fs.readFileSync('oauth.key').toString('utf-8');

server = restify.createServer({
    key: fs.readFileSync('ssl-key.pem'),
    cert: fs.readFileSync('ssl-cert.pem')
});

function authenticate(req, res, next) {
  // Check the Authorization header
  return next();
}

function authorize(req, res, next) {
  // Check ownership of resource
  return next();
}

function audit(req, res, next) {
  // Log this request/response
  return next();
}

var pre = [
  authenticate,
  authorize
];

var post = [
  restify.log.w3c,
  audit
];

require('./models');

require('./api/attempt').setupRoutes(server, pre, post);
require('./api/service').setupRoutes(server, pre, post);
require('./api/test').setupRoutes(server, pre, post);
require('./api/user').setupRoutes(server, pre, post);

server.get(null, '/dummy', pre, function(req, res, next) {

}, post);

mongoose.connect('mongodb://localhost/etestmw');

module.exports = server;