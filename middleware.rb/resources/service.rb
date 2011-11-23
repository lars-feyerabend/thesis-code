module Middleware

  class Application < Sinatra::Base
    
    get '/service' do
      json db['tests'].find.to_a
    end
    
    post '/service' do
      id = db['services'].insert(@params)
      
      status_code 201
      headers \
        'Location' => '/service/' + id.to_s
      json({ '_id' => id.to_s })
    end
    
    get '/service/:id' do
      check_id!
      
      s = db['services'].find_one({:_id => BSON::ObjectId(params['id'])})
      raise Sinatra::NotFound unless s
      json s
    end
    
    put '/service/:id' do
      check_id!
      id = @params.delete('id')
      @params.delete('commit')
      db['services'].update({'_id'=>BSON::ObjectId(id)}, {"$set" => @params})
      "{}"
    end
    
    delete '/service/:id' do
      check_id!
      db['services'].remove({'_id' => BSON::ObjectId(@params[:id])})
      "{}"
      
    end
    
    get '/test' do
      json db['tests'].find.collect { |i|
        i[:open_attempts] = db['attempts'].count :query => { :test_id => i['_id'], :state => { "$ne" => "CLOSED" } }
        i
      }.to_a
    end

  end

end