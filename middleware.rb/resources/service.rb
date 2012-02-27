require '../myrestclient'

module Middleware

  class Application < Sinatra::Base
    
    get '/service' do
      json db['services'].find.to_a
    end
    
    post '/service' do
      id = db['services'].insert(@params)
      
      status 201
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
    
    get '/service/:id/asset/*' do
      check_id!

      s = db['services'].find_one({'_id' => BSON::ObjectId(@params['id'])})
      raise Sinatra::NotFound unless s

      url = s['asset_base'] + "/" + params[:splat].join("")

      #fetch and deliver data
      open(url).read
    end
    
    get '/service/:id/test' do
      check_id!
      
      s = db['services'].find_one({:_id => BSON::ObjectId(params['id'])})
      raise Sinatra::NotFound unless s
      
      response = RestClient.get s['url']+'/test'
      
      response.body
    end
    
  end

end