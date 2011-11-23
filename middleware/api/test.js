var mongoose = require('mongoose'),
//    _ = require('underscore'),
    async = require('async');

var Test = mongoose.model('Test'),
    Attempt = mongoose.model('Attempt');

exports.setupRoutes = function (server, pre, post) {
  server.get(null, '/test', pre, function(req, res, next) {
    Test.find({}, function(err, docs) {
      if (err) {
        res.send(500, err);
        return next();
      }
      
      var attachAttemptCount = function(el, cb) {
        var d = el.toObject();
        
        Attempt.count({"test_id": d._id.toString(), "state": { "$ne": "CLOSED" } }, function(err, count) {
          if (err) {
            cb(err);
          } else {
            if (count > 0) has_open_attempts = true;
            d.open_attempts = count;
            cb(null, d);
          }
        });
      };
      
      async.map(docs, attachAttemptCount, function(err, results) {
        if (err) {
          res.send(500, err);
        } else {
          res.send(200, results);
        }
        return next();
      });
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
    
    res.send(201, t, {'Location': '/test/'+t._id}); // created
    return next();
  }, post);
  
  server.get(null, '/test/:id', pre, function(req, res, next) {
    Test.findById(req.uriParams.id, function(err, t) {
      if (err) {
        res.send(500, err);
      } else {
        if (t) {
          res.send(200, t);
        } else {
          res.send(404, '');
        }
      }
      return next();
    });
  }, post);
  
  server.put(null, '/test/:id', pre, function(req, res, next) {
    delete req.params.id;
    delete req.params.commit;
    Test.update({ _id: req.uriParams.id }, { $set: req.params }, function(err) {
      if (err) {
        res.send(500, err);
      } else {
        res.send(200, {});
      }
      return next();
    });
  }, post);
  
  server.del(null, '/test/:id', pre, function(req, res, next) {
    Test.remove({ _id: req.uriParams.id }, function (err) {
      if (err) {
        res.send(500, err);
      } else {
        res.send(200, '');
      }
      return next();
    })
  }, post);
}