var mongoose = require('mongoose');

var async = require('async');

var Service = mongoose.model('Service');


exports.setupRoutes = function (server, pre, post) {
  server.get(null, '/service', pre, function(req, res, next) {
    Service.find({}, function(err, docs) {
      if (err) {
        res.send(500, err);
      } else {
        res.send(200, docs);
      }
      return next();
    });
  }, post);
  
  server.get(null, '/service/:id', pre, function(req, res, next) {
    Service.findById(req.uriParams.id, function(err, s) {
      if (err) {
        res.send(500, err);
      } else {
        if (s) {
          res.send(200, s);
        } else {
          res.send(404, '');
        }
      }
      return next();
    });
  }, post);
  
  server.del(null, '/service/:id', pre, function(req, res, next) {
    Service.remove({ _id: req.uriParams.id }, function (err) {
      if (err) {
        res.send(500, err);
      } else {
        res.send(200, '');
      }
      return next();
    })
  }, post);
  
  server.put(null, '/service/:id', pre, function(req, res, next) {
    delete req.params.id;
    delete req.params.commit;
    Service.update({ _id: req.uriParams.id }, { $set: req.params }, function(err) {
      if (err) {
        res.send(500, err);
      } else {
        res.send(200, {});
      }
      return next();
    });
  }, post);
  
  server.post(null, '/service', pre, function(req, res, next) {
    var s = new Service({
      title: req.params.title,
      url: req.params.url,
      extra_js: req.params.extra_js
    });
    
    s.save(function(err){
      res.send(500, err);
      return next();
    });
    
    res.send(201, s, {'Location': '/service/'+s._id}); // created
    return next();
  }, post);
  
  
  server.get(null, '/your/:param/:id', pre, function(req, res, next) {
    res.send(200, {
      id: req.uriParams.id,
      message: 'You sent ' + req.uriParams.param,
      sent: req.params
    });
    return next();
  }, post);
  
}

// service schema: filter_js = array, extra_js = string;