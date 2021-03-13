# frozen_string_literal: true

require 'json'
require 'net/http'

# Helper class for the backend
class Helper
  URL_API = 'https://bad-api-assignment.reaktor.com/v2/'
  PRODUCT_API = "#{URL_API}products/"
  STATUS_API = "#{URL_API}availability/"
  CATEGORIES = %w[gloves facemasks beanies].freeze

  def initialize
    # Very simple runtime cache
    @cache = {}

    # Initial cache, can take some time (1-2min depending on the Bad API)
    puts 'Setting up cache..'
    parse_responses(true)
    puts 'Ready to go! Frontend can now be built.'

    # Refreshing cache every minute
    Thread.new do
      loop do
        sleep(60)
        parse_responses(false)
      end
    end
  end

  # Populates the cache.
  #
  # @param category [Symbol] the name of the product category
  # @param products [String] filename of the reply file to the trigger
  def set_cache(category, products)
    @cache[category] = [{ updated_at: Time.at(Time.now) }]
    @cache[category] << products
  end

  # Gets the JSON data.
  #
  # @param category [String] the name of the product category
  # @return [JSON] cached data
  def get_cache(category)
    @cache[category.to_sym]
  end

  # Handles the respond. Returns nil if category doesn't exist.
  #
  # @param category [String] the name of the product category
  # @return [JSON] cached data as JSON
  def handle_response(category)
    return nil unless CATEGORIES.include? category

    get_cache(category).to_json
  end

  # Gets and parses responses from the *Bad* API
  #
  # @param debug [Boolean] debug messages on or off
  def parse_responses(debug)
    puts 'Refreshing cache..' if debug

    responses = {}
    CATEGORIES.each do |c|
      response = get_response_as_json(PRODUCT_API + c, true, debug)
      responses[c.to_sym] = json_to_hash(response, true)
    end

    current = 0
    manufacturers = get_manufacturers(responses)
    manufacturers.each do |m|
      response = get_response_as_json(STATUS_API + m, false, debug)
      statuses = json_to_hash(response, false)

      responses.each_key do |c|
        responses[c].each_key do |id|
          responses[c][id][:status] = statuses[id] unless responses[c][id].nil? || statuses[id].nil?
        end
      end

      # Current progress
      puts "#{current += 1}/#{manufacturers.length} manufacturers: #{m}" if debug
    end

    CATEGORIES.each do |c|
      set_cache(
        c.to_sym,
        responses[c.to_sym].map do |k, v|
          {
            id: k,
            type: v[:type],
            name: v[:name],
            color: v[:color],
            price: v[:price],
            manufacturer: v[:manufacturer],
            status: v[:status]
          }
        end
      )
    end
  end

  # Gets all unique manufacturers from given lists
  #
  # @param product_lists [Hash] lists of products
  # @return [Array] an array of manufacturer names as Strings
  def get_manufacturers(product_lists)
    manufacturers = []
    product_lists.each_key do |category|
      products = product_lists[category]
      products.each_key do |key|
        manufacturers << products[key][:manufacturer] unless manufacturers.include? products[key][:manufacturer]
      end
    end
    manufacturers
  end

  # Gets the response as JSON with error checks
  #
  # @param url [String] URL where to get the response
  # @param product [Boolean] true if product type and false if availability/status type
  # @param debug [Boolean] debug messages
  # @return [String] response
  def get_response_as_json(url, product, debug)
    json = '[]'
    response = ''
    until json != '[]' && response.length > 3
      response = Net::HTTP.get(URI(url))
      begin
        json = product ? JSON.parse(response, quirks_mode: true) : JSON.parse(response, quirks_mode: true)['response']
      rescue JSON::ParserError
        # Ignored
      end
      puts 'Built-in intentional failure. Trying again..' if debug && json == '[]'
    end
    json
  end

  # Parses JSON to Hash
  #
  # @param json [String] JSON representation
  # @param product [Boolean] if product (true) or status (false)
  # @return [Hash] products as a hash
  def json_to_hash(json, product)
    hash = {}
    if product
      json.each do |p|
        hash[p['id'].downcase] = {
          type: p['type'],
          name: p['name'],
          color: p['color'],
          price: p['price'],
          manufacturer: p['manufacturer'],
          status: p['status']
        }
      end
    else
      json.each do |p|
        hash[p['id'].downcase] = p['DATAPAYLOAD'].match(%r{.*<INSTOCKVALUE>(.*)</INSTOCKVALUE>.*}i).captures[0]
      end
    end

    hash
  end
end
