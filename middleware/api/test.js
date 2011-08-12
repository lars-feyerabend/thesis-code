var mongoose = require('mongoose');

var Schema = mongoose.Schema
  , ObjectId = Schema.ObjectId;

var Test = new Schema({
    author    : ObjectId
  , title     : String
  , body      : String
  , date      : Date
});

mongoose.model('Test', Test);
var Test = mongoose.model('Test');

exports.setupRoutes = function (server, pre, post) {
  server.get(null, '/test', pre, function(req, res, next) {
    Test.find({}, ['title', 'date'], function(err, docs) {
      if (err) {
        res.send(500, err);
      } else {
        res.send(200, docs);
      }
      return next();
    });
  }, post);
  
  server.post(null, '/test', pre, function(req, res, next) {
    var t = new Test({
      title: req.params.title,
      date: Date.now()
    });
    
    t.save(function(err){
      res.send(500, err);
      return next();
    });
    
    res.send(201, '', {'Location': '/test/'+t._id}); // created
    return next();
  }, post);
}