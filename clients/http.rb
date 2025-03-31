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
      response = client(options).get(url)
      response.to_s
      response.status
    end

    def persistent(url, calls, options)
      client(options).persistent(url) do |client|
        calls.times.map {
          response = client.get(url)
          # force the whole response to be read, otherwise you'll break the persistent loop
          response.to_s
          response.status
        }
      end
    end

    def client(options)
      http = HTTP
      if options[:debug]
        require "logger"
        logger = Logger.new(STDOUT)
        http = http.use(logging: {logger: logger})
      end
      http
    end
  end

  # httprb hangs in jruby benchmarks
  register "http", HTTPClient unless RUBY_PLATFORM == "java"
end
