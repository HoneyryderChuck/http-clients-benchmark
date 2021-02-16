# frozen_string_literal: true

module Clients
  module HTTPClient
    module_function

    def boot
      require "http"
    end

    def single(url, _, options)
      response = HTTP.get(url)

      response.status
    end

    def persistent(url, calls, options)
      client = HTTP.persistent(url)
      calls.times.map {
        response = client.get(url)
        response.status
      }
    end
  end

  register "http", HTTPClient
end
