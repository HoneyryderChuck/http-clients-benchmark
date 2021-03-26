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

    def pipelined(url, calls, options)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      statuses = http.start do
        requests = calls.times.map { Net::HTTP::Get.new(uri.path) }
        http.pipeline(requests) do |res|
          res.code
        end
      end
      statuses
    end

    def persistent(url, calls, options)
      uri = URI.parse(url)
      http = Net::HTTP::Persistent.new
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
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
