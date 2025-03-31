# frozen_string_literal: true

module Clients
  module HTTPXClient
    module_function

    def boot
      require "httpx"
    end

    def version
      HTTPX::VERSION
    end

    def single(url, _, options)
      response = HTTPX.get(url, ssl: { alpn_protocols: %w[http/1.1]}, **http_options(options))
      response.status
    end

    def persistent(url, calls, options)
      # httpx tries to pipeline, so we have to limit it to 1 concurrent request on initialization.
      pipelined(url, calls, options.merge(http_options: {max_concurrent_requests: 1}))
    end

    def pipelined(url, calls, options)
      requests = [url] * calls
      # force usage of http/1.1, for apples-to-apples comparison.
      responses = HTTPX.get(*requests, ssl: { alpn_protocols: %w[http/1.1] }, **http_options(options))
      responses.map(&:status)
    end

    def concurrent(url, calls, options)
      requests = [url] * calls
      responses = HTTPX.get(*requests, **http_options(options))
      responses.map(&:status)
    end

    def http_options(options)
      http_options = options.fetch(:http_options, {})
      if options[:debug]
        http_options[:debug_level] = 2
        http_options[:debug] = $stderr
      end
      http_options
    end
  end

  register "httpx", HTTPXClient
end
