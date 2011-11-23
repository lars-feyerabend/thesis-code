ENV['RACK_ENV'] = "development"
require './app'

run Middleware::Application