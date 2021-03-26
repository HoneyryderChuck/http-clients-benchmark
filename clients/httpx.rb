# frozen_string_literal: true

module Clients
  module HTTPXClient
    module_function

    def boot
      require "httpx"
    end

    def single(url, _, options)
      response = HTTPX.get(url, ssl: { alpn_protocols: %w[http/1.1]})
      response.status
    end

    def persistent(url, calls, options)
      pipelined(url, calls, options.merge(http_options: {max_concurrent_requests: 1}))
    end

    def pipelined(url, calls, options)
      http_options = options.fetch(:http_options, {})
      # httpx tries to pipeline, so we have to limit it to 1 concurrent request on initialization.
      # force usage of http/1.1, for apples-to-apples comparison.
      responses = HTTPX.get(*([url] * calls), ssl: { alpn_protocols: %w[http/1.1]}, **http_options)
      
      responses.map(&:status)
    end

    def concurrent(url, calls, options)
      responses = HTTPX.get(*([url] * calls), ssl: { alpn_protocols: %w[http/1.1]})
     
      responses.map(&:status)
    end
  end

  register "httpx", HTTPXClient
end
