module Middleware

  class Application < Sinatra::Base
    
    post '/attempt' do
      # pre-check: user may start test? user has test running?
      # pre-check: user allowed to attempt?
      # pre-check: test allows attempt/mode
      
      # Resume running attempt for this test?
      
      ea = db['attempts'].find_one({
        'user_id' => BSON::ObjectId(@params[:user_id]),
        'test_id' => BSON::ObjectId(@params[:test_id]), 
        'state' => { '$ne' => 'CLOSED' }
      })
      
      if ea
        status_code 303 # See Other
        headers \
          'Location' => '/attempt/'+ea['_id']
        json ea
        return
      end
      
      # User has another attempt running?

      eua = db['attempts'].find_one({
        'user_id' => BSON::ObjectId(@params[:user_id]),
        'state' => { '$ne' => 'CLOSED' }        
      })
      
      if eua
        status_code 403 # Forbidden
        json({'msg' => 'User already has a running attempt.'})
        return
      end
      
      # Check preconditions, then safe to create a new attempt
      
      t = db['tests'].find_one({'_id' => BSON::ObjectId(@params[:id])})
      
      unless t
        status_code 404
        json({"msg"=>"Test does not exist"})
        return
      end
      
      # var a = new Attempt({
      #   user: req.params.user_id,
      #   test_id: req.params.test_id,
      #   state: 'CREATED',
      #   date: Date.now(),
      #   form_url: req.params.form_url,
      #   asset_url: req.params.asset_url
      # });
      # 
      # a.test.push(tdoc);
      # 
      status_code 201 # Created
      headers 'Location' => '/attempt/'+aid
      json({"_id" => aid})
      
      
    end
              
    get '/attempt/:id/page/:n' do
      check_id!
      #determine service
      
      #determine url
      
      #fetch and deliver data
      
      
      
    end
    
    get '/attempt/:id' do
      check_id!
      a = db['attempts'].find_one({'_id' => BSON::ObjectId(@params['id'])})
      
      raise Sinatra::NotFound unless a

      a['cursor'] = 1
      a['state']  = 'READY'
      
      json a
    end
    
      # server.get(null, '/attempt/:id/page/:num', pre, function(req, res, next) {
      #   var jsdom = require('jsdom');
      # 
      #   jsdom.env("http://localhost:9006/test/1/page/1", [
      #     'http://code.jquery.com/jquery.min.js'
      #   ],
      #   function(errors, window) {
      #     if (errors) {
      #       console.log('error fetching remote resource');
      #       res.send(500, {
      #         msg: 'error fetching remote resource'
      #       });
      #       return next();
      #     }
      # 
      #     var css = [], js = [];
      #     window.$('link[rel=stylesheet]').each(function() { css.push(this.href); });
      #     window.$('script[src]').each(function() { js.push(this.src); });
      # 
      # 
      #   });
      # });
      # 
      # 

    #   server.put(null, '/attempt/:id', pre, function(req, res, next) {
    #     delete req.params.id;
    #     Attempt.update({ _id: req.uriParams.id }, { $set: req.params }, function(err) {
    #       if (err) {
    #         res.send(500, err);
    #       } else {
    #         res.send(200, {});
    #       }
    #       return next();
    #     });
    #   }, post);
    # 
    #   server.get(null, '/attempt', pre, function(req, res, next){
    # 
    #   });
    # }
    #     
  end

end