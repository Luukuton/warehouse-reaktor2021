# backend.rb
require 'sinatra'
require_relative 'helper.rb'

set :port, 4567

helper = Helper.new

get '/:category' do
    content_type :json
    response = helper.handle_response(params['category'])

    # Category doesn't exist
    if response.nil?
        status 404
        return
    end

    response
end
