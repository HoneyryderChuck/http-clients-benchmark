# frozen_string_literal: true

module Clients
  module PatronClient
    module_function

    def boot
      require "patron"
    end

    def version
      Patron::VERSION
    end

    def single(url, _, options)
      uri = URI.parse(url)
      endpoint_without_path = begin
        point = uri.dup
        point.path = ""
        point.to_s
      end
      client = Patron::Session.new(base_url: endpoint_without_path, http_version: "HTTPv1_1")
      client.insecure = true
      response = client.get(uri.path)

      response.status
    end

    def persistent(url, calls, options)
      http_options = options.fetch(:http_options, {http_version: "HTTPv1_1"})
      uri = URI.parse(url)
      endpoint_without_path = begin
        point = uri.dup
        point.path = ""
        point.to_s
      end
      client = Patron::Session.new(base_url: endpoint_without_path, **http_options)
      client.insecure = true
      calls.times.map {
        response = client.get(uri.path)
        response.status
      }
    end
  end

  register "patron", PatronClient
end
