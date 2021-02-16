# frozen_string_literal: true

module Clients
  module PatronClient
    module_function

    def boot
      require "patron"
    end

    def single(url, _, options)
      uri = URI.parse(url)
      endpoint_without_path = begin
        point = uri.dup
        point.path = ""
        point.to_s
      end
      client = Patron::Session.new(base_url: endpoint_without_path)
      client.insecure = true
      response = client.get(uri.path)

      response.status
    end

    def concurrent(url, calls, options)
      uri = URI.parse(url)
      endpoint_without_path = begin
        point = uri.dup
        point.path = ""
        point.to_s
      end
      client = Patron::Session.new(base_url: endpoint_without_path)
      client.insecure = true
      calls.times.map {
        response = client.get(uri.path)
        response.status
      }
    end
  end

  register "patron", PatronClient
end
