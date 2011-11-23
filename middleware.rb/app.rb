require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'
require 'json'
require 'mongo' 
require 'pp'

base = File.dirname(__FILE__)
# Dir.glob(base + '/lib/*.rb'             ).each { |f| require f }
Dir.glob(base + '/resources/*.rb'       ).each { |f| require f }


# define json helper
module BSON
  class ObjectId
    def to_json(*a)
      "\"#{to_s}\""
    end
  end
end

module Middleware
  class Application < Sinatra::Base

    configure do
      set :db, Mongo::Connection.new.db('etestmw')
    end
    
    helpers do
      def json(content)
        JSON.pretty_generate content
      end
      
      def db
        settings.db
      end
      
      def check_id!
        p @params
        if @params.has_key?('id') and not BSON::ObjectId.legal?(@params['id'])
          p "inside if"
          halt 500, '{"msg":"Invalid ID provided"}'
        end
      end
        
    end
    
    before do
      content_type :json
    end
    
    not_found do
      content_type :json
      
      '{msg: "Not found"}'
    end
  end
end
