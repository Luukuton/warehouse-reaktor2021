require 'json'
require 'net/http'

class Helper 
    URL_API = 'https://bad-api-assignment.reaktor.com/v2/'
    PRODUCT_API = 'products/'
    STATUS_API = 'availability/'
    CATEGORIES = %w(gloves facemasks beanies)

    def initialize
        # Very simple runtime cache
        @cache = Hash.new

        # Initial cache, can take some time (1-2min depending on the Bad API)
        puts 'Setting up cache..'
        parse_responses(true)
        puts 'Ready to go! Frontend can now be built.'

        # Refresing cache every minute
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
        @cache[category] = [products, Time.now.to_i]
    end

    # Gets the JSON data.
    # 
    # @param category [String] the name of the product category
    # @return [JSON] cached data
    def get_cache(category)
        @cache[category.to_sym][0]
    end

    # Handles the respond. Returns nil if category doesn't exist.
    # 
    # @param category [String] the name of the product category
    # @return [JSON] cached data as JSON
    def handle_response(category)
        return nil unless CATEGORIES.include? category
        get_cache(category).to_json
    end

    # Parses JSON to Hash
    # 
    # @param json [String] JSON representation
    # @return [Boolean] true if product type and false if availability/status type
    def json_to_hash(json, product)
        hash = Hash.new
        if product
            JSON.parse(json).each do |p|
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
            JSON.parse(json)['response'].each do |p|
                hash[p['id'].downcase] = p['DATAPAYLOAD'].match(/.*<INSTOCKVALUE>(.*)<\/INSTOCKVALUE>.*/i).captures[0]
            end
        end

        hash
    end

    # Gets and parses responses from the *Bad* API
    #
    # @param debug [Boolean] debug messages on or off
    def parse_responses(debug)
        puts "Refreshing cache.." if debug

        responses = {}
        CATEGORIES.each do |c|
            response = get_response(URL_API + PRODUCT_API + c, true)
            responses[c.to_sym] = json_to_hash(response, true)
        end
        current = 0

        manufacturers = get_manufacturers(responses)
        manufacturers.each do |m|
            response = get_response(URL_API + STATUS_API + m, false)
            statuses = json_to_hash(response, false)
            responses.keys.each do |category|
                products = responses[category]
                products.keys.each do |id|
                    products[id][:status] = statuses[id] unless products[id].nil? || statuses[id].nil?
                end
            end

            # Current progress
            puts "#{current += 1}/#{manufacturers.length} manufacturers: #{m}" if debug
        end
        
        CATEGORIES.each do |c|
            set_cache(c.to_sym, responses[c.to_sym].map { |k, v| {
                    id: k,
                    type: v[:type], 
                    name: v[:name], 
                    color: v[:color], 
                    price: v[:price], 
                    manufacturer: v[:manufacturer], 
                    status: v[:status]
                }
            })
        end
    end
    
    # Gets all unique manufacturers from given lists
    # 
    # @param product_lists [Hash] lists of products
    # @return [Array] an array of manufacturer names as Strings
    def get_manufacturers(product_lists)
        manufacturers = []
        product_lists.keys.each do |category|
            products = product_lists[category]
            products.keys.each do |key|
                manufacturers << products[key][:manufacturer] unless manufacturers.include? products[key][:manufacturer]
            end
        end
        manufacturers
    end

    # Gets the respond with error checks
    #
    # @param url [String] URL where to get the response
    # @param product [Boolean]  true if product type and false if availability/status type
    # @return [String] response
    def get_response(url, product)
        response = Net::HTTP.get(URI(url))
        json = product ? JSON.parse(response) : JSON.parse(response)['response']
        until json != '[]'
            response = Net::HTTP.get(URI(url))
            json = product ? JSON.parse(response) : JSON.parse(response)['response']
            puts 'Built-in intentional failure. Trying again..'
        end
        response
    end 
end
