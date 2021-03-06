##
# Send With Us Ruby API Client
#
# Copyright sendwithus 2013
# Author: matt@sendwithus.com
# See: http://github.com/sendwithus for more

require 'net/http'
require 'net/https'
require 'uri'
require 'rubygems'
require 'json'

module SendWithUs
    VERSION = "0.1"
    ##
    # API object
    #
    # Currently only supports send
    # API instance requires your sendiwthus API_KEY
    class API

        attr_accessor :api_key
        DEFAULT_URL = "https://beta.sendwithus.com"

        def initialize(api_key, options = {})
            @api_key = api_key
            default_source = URI.parse(options[:url] || DEFAULT_URL)
            @api_proto = options[:api_proto] || default_source.scheme
            @api_host = options[:api_host] || default_source.host
            @api_version = options[:api_version] || 0
            @api_port = options[:api_port] || default_source.port
            @debug = options[:debug]
            @base_url = URI.parse("#{@api_proto}://#{@api_host}:#{@api_port}/api/v#{@api_version}")
        end

        ##
        # send a templated email!

        def send(email_name, email_to, data = {})
            payload = {
                :email_name => email_name,
                :email_to => email_to,
                :email_data => data
            }
            return api_request("send", payload)
        end

        private

        ##
        # used to build the request path

        def request_path(end_point)
            "/api/v#{@api_version}/#{end_point}"
        end

        ##
        # used to send the actual http request
        # ignores response and sends synchronously atm

        def api_request(end_point, payload = {})

            request = Net::HTTP::Post.new(request_path(end_point), 
                        initheader = {'Content-Type' =>'application/json'})
            http = Net::HTTP.new(@base_url.host, @base_url.port)
            http.use_ssl = (@base_url.scheme == 'https')
            request.add_field('X-SWU-API-KEY', @api_key)
            request.body = payload.to_json

            response = http.request(request)
            case response
            when Net::HTTPNotFound
                raise "Invalid API end point: #{end_point} (#{request_path(end_point)})"
            when Net::HTTPSuccess
                # TODO: do something intelligent with response.body
                if @debug
                    puts response.body
                end
                return response
            else
                raise "Unknown error! #{response.code}"
            end

        rescue Errno::ECONNREFUSED
            raise "Could not connect to #{@base_url.host}!"  
        end
    end
end

