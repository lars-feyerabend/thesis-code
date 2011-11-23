var mongoose = require('mongoose');

var async = require('async');

var Attempt = mongoose.model('Attempt');
var Test = mongoose.model('Test');

exports.setupRoutes = function (server, pre, post) {
  server.post(null, '/attempt', pre, function(req, res, next) {
    
    // // pre-check: user may start test? user has test running?
    //     async.parallel([
    //       
    //       // pre-check: another attempt running?
    //       function(callback) {
    //         Attempt.find({'user': req.params.user}, ['_id'], function(err, docs) {
    //           if (err) {
    //             res.send(500, err);
    //           } else {
    //             res.send(200, docs);
    //           }
    //           return next();
    //         });
    //         
    //       },
    //       
    //       // pre-check: user allowed to attempt?
    //       function(callback) {
    //         
    //       },
    //       
    //       // pre-check: test allows attempt/mode
    //       
    //     ], function(err, res) {
    //       
    //     });
    //         
    //     var a = new Attempt({
    //       title: req.params.title,
    //       date: Date.now()
    //     });
    //     
    //     t.save(function(err){
    //       res.send(500, err);
    //       return next();
    //     });
    
    var isnew;
    
    // Attempt.find({'user': req.params.user_id, 'test'}, ['_id'], function(err, docs) {
    //           if (err) {
    //             res.send(500, err);
    //           } else {
    //             res.send(200, docs);
    //           }
    //           return next();
    //         });
    // 
    // 
    // res.send(isnew ? 201 : 303, '', {'Location': '/attempt/'+t._id}); // created / see other
    
    Attempt.findOne({'user': req.params.user_id, 'test_id': req.params.test_id, 'state': { $ne : 'CLOSED' }}, ['_id'], function(err, doc) {
      
      if (err) {
        res.send(500, err);
      } else {
        
        if (doc) {
          console.log('sending 303 because attempt already open');
          res.send(303, {_id:doc._id}, {'Location': '/attempt/'+doc._id});
          return next();
          
        } else {
          
          // another attempt open for user?
          Attempt.findOne({'user': req.params.user_id, 'state': { $ne : 'CLOSED' }}, ['_id'], function(err, doc) {
            
            if (err) {
              res.send(500, err);
              return next();
            } else {
              
              if (doc) {
                
                res.send(403, {msg: "User already has a running attempt."});
                return next();
                
              } else {
                
                // no existing or running attempts found... safe to create a new one...
                // IF!! user is allowed to and test allows it... (TODO)
                
                Test.findById(req.params.test_id, function(err, tdoc) {
                  if (err) {
                    res.send(500, err);
                    return next();
                  }
                  
                  if (tdoc) {
                    var a = new Attempt({
                      user: req.params.user_id,
                      test_id: req.params.test_id,
                      state: 'CREATED',
                      date: Date.now(),
                      form_url: req.params.form_url,
                      asset_url: req.params.asset_url
                    });
                    
                    a.test.push(tdoc);

                    a.save(function(err){
                      res.send(500, err);
                      return next();
                    });

                    res.send(201, {_id:a._id}, {'Location': '/attempt/'+a._id});
                    return next();
                    
                  } else {
                    res.send(404, {msg: 'Test does not exist'});
                    return next();
                  }
                });
                
              }
              
            }
            
          });          
        }
        
      }
    
    
    });
    
    
  }, post);
  
  server.get(null, '/attempt/:id/page/:num', pre, function(req, res, next) {
    var jsdom = require('jsdom');

    jsdom.env("http://localhost:9006/test/1/page/1", [
      'http://code.jquery.com/jquery.min.js'
    ],
    function(errors, window) {
      if (errors) {
        console.log('error fetching remote resource');
        res.send(500, {
          msg: 'error fetching remote resource'
        });
        return next();
      }

      var css = [], js = [];
      window.$('link[rel=stylesheet]').each(function() { css.push(this.href); });
      window.$('script[src]').each(function() { js.push(this.src); });

      res.send(200, {
        javascripts: js,
        stylesheets: css,
        content: window.$('body').html()
      });
      return next();

    });
  });
  
  server.get(null, '/attempt/:id', pre, function(req, res, next) {
    Attempt.findById(req.uriParams.id, function(err, doc){
      if (err) {
        res.send(500, err);
        return next();
      } else {
        if (doc) {
          var a = {
            _id: doc._id,
            state: 'READY',
            form_url: doc.form_url,
            asset_url: doc.asset_url,
            user: doc.user,
            test: doc.test,
            cursor: 1
          };
          res.send(200, a);
        } else {
          res.send(404, {});
        }
      }
    });
  });
  
  server.put(null, '/attempt/:id', pre, function(req, res, next) {
    delete req.params.id;
    Attempt.update({ _id: req.uriParams.id }, { $set: req.params }, function(err) {
      if (err) {
        res.send(500, err);
      } else {
        res.send(200, {});
      }
      return next();
    });
  }, post);

  server.get(null, '/attempt', pre, function(req, res, next){
    
  });
}