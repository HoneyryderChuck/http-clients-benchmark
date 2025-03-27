# frozen_string_literal: true


module Clients
  module ManticoreClient
    module_function

    def boot
      require "manticore"
    end

    def version
      Manticore::VERSION
    end

    def single(url, _, options)
      http_options(options)
      response = Manticore::Client.new(ssl: { verify: false }).get(url)

      response.code
    end

    # can't use the #requests feature from excon because if the servers
    # does "Connection: close", excon still tries to write to the socket,
    # and EPIPEs.
    def persistent(url, calls, options)
      http_options(options)
      client = Manticore::Client.new(ssl: { verify: false })
      calls.times.map {
        response = client.get(url)
        response.code
      }
    end

    def http_options(options)
      if options[:debug]
        Manticore.disable_httpcomponents_logging!
      end
    end
  end

  register "manticore", ManticoreClient
end
