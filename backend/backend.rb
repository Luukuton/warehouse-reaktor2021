# frozen_string_literal: true

require 'sinatra'
require_relative 'helper'

set :port, 4755

helper = Helper.new

get '/' do
  '<a href="/gloves">Gloves JSON</a> </br>'\
  '<a href="/facemasks">Facemasks JSON</a> </br>'\
  '<a href="/beanies">Beanies JSON</a> </br>'
end

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
