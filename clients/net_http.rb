# frozen_string_literal: true

module Clients
  module NetHTTPClient
    module_function

    def boot
      require 'net/http'
      require 'net/https'
      require 'net/http/persistent'
      require 'net/http/pipeline'
    end

    def version
      Net::HTTP::VERSION
    end

    def name_persistent
      "net-http-persistent"
    end

    def single(url, _, options)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.set_debug_output(STDOUT) if options[:debug]
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)
      response.body
      response.code
    end

    def persistent(url, calls, options)
      uri = URI.parse(url)
      http = Net::HTTP::Persistent.new
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.set_debug_output(STDOUT) if options[:debug]
      statuses = calls.times.map {
        response = http.request(uri)
        response.code
      }
      http.shutdown
      statuses
    end
  end

  register "net-http", NetHTTPClient
end
