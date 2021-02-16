# frozen_string_literal: true

module Clients
  module NetHTTPClient
    module_function

    def boot
      require 'net/http'
	    require 'net/https'
	    require 'net/http/persistent'
    end

    def single(url, _, options)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)
      response.body
      response.code
    end

    def persistent(url, calls, options)
      http = Net::HTTP::Persistent.new
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      status = calls.times.map {
        uri = URI.parse(url)
        response = http.request(uri)
        response.code
      }
      http.shutdown
      status
    end
  end

  register "net-http", NetHTTPClient
end
