require 'open-uri'

  def shellescape(str)
    # An empty argument will be skipped, so return empty quotes.
    return "''" if str.empty?

    str = str.dup

    # Process as a single byte sequence because not all shell
    # implementations are multibyte aware.
    str.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1")

    # A LF cannot be escaped with a backslash because a backslash + LF
    # combo is regarded as line continuation and simply ignored.
    str.gsub!(/\n/, "'\n'")

    return str
  end

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
        status 303 # See Other
        headers \
          'Location' => '/attempt/'+ea['_id'].to_s
        return json({'_id'=>ea['_id'].to_s})
      end
      
      # User has another attempt running?

      eua = db['attempts'].find_one({
        'user_id' => BSON::ObjectId(@params[:user_id]),
        'state' => { '$ne' => 'CLOSED' }        
      })
      
      if eua
        status 403 # Forbidden
        return json({'msg' => 'User already has a running attempt.'})
      end
      
      # Check preconditions, then safe to create a new attempt
      
      t = db['tests'].find_one({'_id' => BSON::ObjectId(@params[:test_id])})
      
      unless t
        status 404
        return json({"msg"=>"Test does not exist"})
      end

      a = []
      
      t['content'].each do |remotetest|
        service = db.dereference(remotetest['service'])

        url = service['url'] + "/attempt"

        response = RestClient.post(url, {
          :user_id => 0,
          :test_id => remotetest['test']
        })
        
        r = JSON.parse(response.body)
        
        a << r['id']
      end


      aid = db['attempts'].insert({
        'attempts' => a,
        'user_id' => BSON::ObjectId(@params[:user_id]),
        'test_id' => BSON::ObjectId(@params[:test_id]),
        'test' => t,
        'state' => 'CREATED',
        'cursor' => 1,
        'date' => '',
        'form_url' => @params[:form_url],
        'asset_url' => @params[:asset_url]
      })
      
      status 201 # Created
      headers 'Location' => '/attempt/'+(aid.to_s)
      json({"_id" => aid.to_s})
    end
              
    get '/attempt/:id/page/:n' do
      check_id!
      
      a = db['attempts'].find_one({'_id' => BSON::ObjectId(@params['id'])})
      raise Sinatra::NotFound unless a
      
      page = a['test']['content'][@params[:n].to_i-1]
      attempt = a['attempts'][@params[:n].to_i-1]
      
      #determine service
      service = db.dereference(page['service'])
      
      #determine url
      url = service['url'] + "/attempt/#{attempt}/page/#{page['page']}"
      
      response = RestClient.get(url)
      r = JSON.parse(response.force_encoding("UTF-8").gsub("\xEF\xBB\xBF".force_encoding("UTF-8"), ''))
      
      asset_base = a['asset_url'] % { :service => service['_id'] }
      
      o, s = Open3.capture2("./lib/assetize/assetize.js #{shellescape(asset_base)}", :stdin_data=>r['content'])

      #fetch and deliver data
      o
    end
    

    
    
    get '/attempt/:id' do
      check_id!
      a = db['attempts'].find_one({'_id' => BSON::ObjectId(@params['id'])})
      
      raise Sinatra::NotFound unless a

      # a['cursor'] = 1
      a['state']  = 'READY'
      
      json a
    end
    
    put '/attempt/:id' do
      check_id!
      
      id = @params.delete('id')
      #@params.delete('commit')
      db['attempts'].update({'_id'=>BSON::ObjectId(id)}, {"$set" => {
        :cursor => @params[:cursor].to_i
      }})
      
      "{}"
    end
    
    put '/attempt/:id/page/:cursor' do
      check_id!
      
      id = @params.delete('id')
      cursor = @params.delete('cursor')
      a = db['attempts'].find_one({'_id' => BSON::ObjectId(id)})
      
      raise Sinatra::NotFound unless a
      
      page = a['test']['content'][cursor.to_i-1]
      attempt = a['attempts'][cursor.to_i-1]
      
      #determine service
      service = db.dereference(page['service'])
      
      #determine url
      url = service['url'] + "/attempt/#{attempt}/page/#{page['page']}"
      
      response = RestClient.post(url, @params)
      
      # save status from response to database...
      r = JSON.parse(response.body.gsub!("\xEF\xBB\xBF".force_encoding("UTF-8"), ''))
      
      
      
      # then redirect to feedback (optional: if feedback is enabled)
      
    end
    
    
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