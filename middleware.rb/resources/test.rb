module Middleware

  class Application < Sinatra::Base
    
    get '/test' do
      json db['tests'].find.collect { |i|
        i[:open_attempts] = db['attempts'].count :query => { :test_id => i['_id'], :state => { "$ne" => "CLOSED" } }
        i
      }.to_a
    end
    
    post '/test' do
      id = db['tests'].insert(@params)
      
      status 201
      headers \
        'Location' => '/test/' + id.to_s
      json({ '_id' => id.to_s })
    end

    get '/test/available' do
      a = {}
      db['services'].find.each { |i| 
        response = RestClient.get i['url']+'/test'
        t = JSON::parse(response)
        
        a[i['_id']] = { :title => i['title'], tests: t }
      }
      
      json a
    end
    
    get '/test/:id' do
      check_id!
      json db['tests'].find_one({:_id => BSON::ObjectId(params[:id])})
    end
    
    put '/test/:id' do
      check_id!
      id = @params.delete('id')
      @params.delete('commit')
      db['tests'].update({'_id'=>BSON::ObjectId(id)}, {"$set" => @params})
      "{}"
    end
    
    delete '/test/:id' do
      check_id!
      db['tests'].remove({'_id' => BSON::ObjectId(@params[:id])})
      "{}"
    end
  
  
  end

end