require 'sinatra'
require 'sinatra/flash'
require 'json'
require '../myrestclient' # my own non-follow-3xx-instance 

require 'open-uri'

enable :sessions


this_url = "http://localhost:3000"

mw = RestClient::Resource.new(
    "http://localhost:9393",
    # :verify_ssl => OpenSSL::SSL::VERIFY_NONE,
    #:max_redirects => 0
)

helpers do
  def mw_url (path)
    "http://localhost:9393" + path
  end
  
  def current?(path='')
    request.path_info.start_with? path
  end
end

get '/' do
  @title = "Welcome"
  erb :home
end

get '/service/:sid/items' do
  # ...
end

get '/service/:sid/item/:id' do
  # ...
end

get '/service/:sid/item/:id/edit' do
  # ...
end

post '/service/:sid/item/:id/edit' do
  # ...
end

post '/service/:sid/items/create' do
  #...
end



get '/test' do
  # json = URI.parse('https://localhost:3000/test').read

  json = open(mw_url("/test")).read

  @tests = JSON.parse(json)
  
  @resume = false;
  @tests.each do |t|
    if (t['open_attempts'] > 0)
      @resume = true
      break
    end
  end
  
  @title = "Tests"
  erb :test
end

get '/test/create' do
  @title = "Create New Test"
  @available = JSON.parse(mw["test/available"].get.body)
  erb :test_form
end

post '/test/create' do
  response = mw["/test"].post({
    'title' => params[:title]
  })
                                  
  t = JSON.parse(response.body)
  
  flash[:notice] = {
    :message => 'Test ' + t['_id'] + ' created.',
    :class => 'success'
  }
  
  redirect '/test'
end

get '/test/:id/edit' do
  response = mw["test/#{params[:id]}"].get
  @t = JSON.parse(response.body)
  @title = "Edit test " + @t['title']
  
  @available = JSON.parse(mw["test/available"].get.body)
  
  erb :test_form
end

post '/test/:id/edit' do
  response = mw["test/#{params[:id]}"].put @params
  
  if response.code == 200
    flash[:notice] = {
      :class => 'success',
      :message => 'Test updated.'
    }
  else
    flash[:notice] = {
      :class => 'error',
      :message => '<strong>Error:</strong> '+response.description + '</p><p>'+ response.body
    }
  end
  
  redirect '/test'
end

get '/test/:id/delete' do
  response = mw["test/#{params[:id]}"].delete
  if response.code == 200
    flash[:notice] = {
      :class => 'success',
      :message => 'Test deleted.'
    }
    redirect '/test'
  else
    flash[:notice] = {
      :class => 'error',
      :message => '<strong>Error:</strong> '+response.description + '</p><p>'+ response.body
    }
    redirect '/test'
  end
end

get '/test/:id/attempt' do
  response = mw['attempt'].post({
    'test_id' => params[:id],
    'asset_url'=>this_url + "/asset?service=%{service}&path=",
    'form_url'=>this_url + "/test/#{params[:id]}/form", 
    'user_id' => '4f0f1c92ab1c042e9237cb7a' # hardcoded dummy user for now...
  })

  body = JSON.parse(response.body)
  
  case response.code
  when 201, 303 # created or found
    redirect "/attempt/#{body['_id']}"
  when 403
    erb :attempt_error, :locals => { :error_msg => body['msg'] }
  else
    erb :attempt_error, :locals => { :error_msg => 'An unknown error has occured: '+response.code.to_s  }
  end
end

get '/attempt/:id' do
  response = mw["attempt/#{params[:id]}"].get
  
  @attempt = JSON.parse(response.body)
  
  case @attempt["state"]
  when "CREATED", "PROCESSING"
    @url = this_url + "/attempt/#{params[:id]}"
    erb :attempt_wait
  when "READY", "OPEN"
    if @attempt['cursor'] > 0
      @title = @attempt['test']['title']
    
      # ... fetch content ...
      content_req = mw["attempt/#{params[:id]}/page/#{@attempt['cursor']}"].get
      #q = JSON.parse(content_req.body)
      
      erb :attempt, :locals => { :content => content_req.body }
    else 
      status 500
    end
  when "CLOSED"
    erb :attempt_error, :locals => { :error_msg => 'Attempt is already closed.' }
  else
    erb :attempt_error, :locals => { :error_msg => 'Illegal attempt state encountered.' }
  end
end

get '/attempt/:id/goto/:cursor' do
  response = mw["attempt/#{params[:id]}"].put({
    :cursor => @params[:cursor]
  })
  
  if (response.code == 200) 
    redirect "/attempt/#{params[:id]}"
  else
    p response
  end
end

get '/attempt/:id/cancel' do
  response = mw["attempt/#{params[:id]}"].put({
    'state' => 'CLOSED',
    'resolution' => 'USER_CANCELLED'
  })
  
  if response.code == 200
    flash[:notice] = {
      :class => 'success',
      :message => "Attempt #{params[:id]} cancelled."
    }
    redirect '/test'
  else
    flash[:notice] = {
      :class => 'error',
      :message => '<strong>Error:</strong> '+response.description + '</p><p>'+ response.body
    }
    redirect '/test'
  end
end

post '/attempt/:id/submit' do
  id = @params.delete('id')
  page = @params.delete('z__page')
  
  @params.delete('splat')
  @params.delete('captures')
  
  response = mw["/attempt/#{id}/page/#{page}"].put(@params)
  
  redirect "/attempt/#{id}"
end

get '/asset' do
  begin
    open(mw_url("/service/#{params[:service]}/asset/#{params[:path]}")).read
  rescue Errno::ECONNREFUSED
    status 504
    "Gateway Timeout"
  end
end


get '/service' do
  json = open(mw_url("/service")).read

  @title = "Services"
  @services = JSON.parse(json)
  erb :service
end

get '/service/create' do
  @title = "Create New Service"
  erb :service_form
end

post '/service/create' do
  response = mw["/service"].post(@params)
  @service = JSON.parse(response.body)
  
  flash[:notice] = {
    :message => 'Service ' + @service['_id'] + ' created.',
    :class => 'success'
  }
  
  redirect '/service'
end

get '/service/:id/edit' do
  response = mw["service/#{params[:id]}"].get
  @s = JSON.parse(response.body)
  
  @title = "Edit service " + @s['title']
  erb :service_form
end

post '/service/:id/edit' do
  response = mw["service/#{params[:id]}"].put @params
  
  if response.code == 200
    flash[:notice] = {
      :class => 'success',
      :message => 'Service updated.'
    }
    redirect '/service'
  else
    flash[:notice] = {
      :class => 'error',
      :message => '<strong>Error:</strong> '+response.description + '</p><p>'+ response.body
    }
    redirect '/service'
  end
  
end

get '/service/:id/delete' do
  response = mw["service/#{params[:id]}"].delete
  if response.code == 200
    flash[:notice] = {
      :class => 'success',
      :message => 'Service deleted.'
    }
    redirect '/service'
  else
    flash[:notice] = {
      :class => 'error',
      :message => '<strong>Error:</strong> '+response.description + '</p><p>'+ response.body
    }
    redirect '/service'
  end
end

get '/service/:id' do
  response = mw["service/#{params[:id]}"].get
  @s = JSON.parse(response.body)
  
  @title = "Service: "+ @s['title']
  erb :service_show
end

get '/service/:id/tests' do
  @s = JSON.parse(mw["service/#{params[:id]}"].get.body)

  response = mw["service/#{params[:id]}/test"].get
  @tests = JSON.parse(response.body)
  
  @title = "Tests for Service " + @s['title']
  erb :service_tests
end