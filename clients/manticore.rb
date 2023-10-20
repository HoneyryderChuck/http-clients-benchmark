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
      response = Manticore.get(url)

      response.code
    end

    # can't use the #requests feature from excon because if the servers
    # does "Connection: close", excon still tries to write to the socket,
    # and EPIPEs.
    def persistent(url, calls, options)
      client = Manticore::Client.new
      calls.times.map {
        response = client.get(url)
        response.code
      }
    end
  end

  register "manticore", ManticoreClient
end
