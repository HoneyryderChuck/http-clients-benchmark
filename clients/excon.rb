# frozen_string_literal: true


module Clients
  module ExconClient
    module_function

    def boot
      require "excon"
      Excon.defaults[:ssl_verify_peer] = false
    end

    def single(url, _, options)
      response = Excon.get(url)

      response.status
    end

    # can't use the #requests feature from excon because if the servers
    # does "Connection: close", excon still tries to write to the socket,
    # and EPIPEs.
    def persistent(url, calls, options)
      client = Excon.new(url, persistent: true)
      calls.times.map {
        response = client.get
        response.status
      }
    end
  end

  register "excon", ExconClient
end
