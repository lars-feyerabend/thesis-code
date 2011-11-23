require 'sinatra'
require 'rack-flash'
require 'json'
require './myrestclient' # my own non-follow-3xx-instance 

require 'open-uri'

enable :sessions
use Rack::Flash

this_url = "http://localhost:4567"
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
    'asset_url'=>this_url + "/test/#{params[:id]}/asset/",
    'form_url'=>this_url + "/test/#{params[:id]}/form", 
    'user_id' => 0    
  })

  body = JSON.parse(response.body)
  
  case response.code
  when 201, 303 # created or found
    redirect "/attempt/#{body['_id']}"
  when 403
    erb :attempt_error, :locals => { :error_msg => body['msg'] }
  else
    erb :attempt_error, :locals => { :error_msg => 'An unknown error has occured.' }
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
      @title = @attempt['test'][0]['title']
    
      # ... fetch content ...
      content_req = mw["attempt/#{params[:id]}/page/#{@attempt['cursor']}"].get
      q = JSON.parse(content_req.body)
      
      erb :attempt, :locals => { :content => q['content'], :js => q['js'], :css => q['css'] }
    else 
      status_code 500
    end
  when "CLOSED"
    erb :attempt_error, :locals => { :error_msg => 'Attempt is already closed.' }
  else
    erb :attempt_error, :locals => { :error_msg => 'Illegal attempt state encountered.' }
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

get '/test/:id/asset/*' do
  begin
    remote_resource = open(mw_url("/test/#{params[:id]}/asset/#{params[:splat].first}"))
    if (remote_resource.status[0] == 404) then
      status_code 404
      return "File not found."
    end
    remote_resource.read
  rescue Errno::ECONNREFUSED
    status_code 504
    "Gateway Timeout"
  end
end


get '/service' do
  json = open(mw_url("/service"), :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE).read

  @title = "Services"
  @services = JSON.parse(json)
  erb :service
end

get '/service/create' do
  @title = "Create New Service"
  erb :service_form
end

post '/service/create' do
  require "net/http"

  http = Net::HTTP.new("localhost", 3000)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  
  
  request = Net::HTTP::Post.new("/service")
  request.set_form_data(@params)
  response = http.request(request)
                                  
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

