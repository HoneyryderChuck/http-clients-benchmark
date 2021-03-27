# frozen_string_literal: true

module Clients
  module HTTPClient
    module_function

    def boot
      require "http"
    end

    def version
      HTTP::VERSION
    end

    def single(url, _, options)
      response = HTTP.get(url)
      response.to_s
      response.status
    end

    def persistent(url, calls, options)
      client = HTTP.persistent(url)
      calls.times.map {
        response = client.get(url)
        # force the whole response to be read, otherwise you'll break the persistent loop
        response.to_s
        response.status
      }
    end
  end

  register "http", HTTPClient
end
