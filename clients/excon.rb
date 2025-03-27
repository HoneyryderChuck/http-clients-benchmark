# frozen_string_literal: true


module Clients
  module ExconClient
    module_function

    def boot
      require "excon"
    end

    def version
      Excon::VERSION
    end

    def single(url, _, options)
      response = Excon.get(url, http_options(options))

      response.status
    end

    # can't use the #requests feature from excon because if the servers
    # does "Connection: close", excon still tries to write to the socket,
    # and EPIPEs.
    def persistent(url, calls, options)
      client = Excon.new(url, persistent: true, **http_options(options))
      calls.times.map {
        response = client.get
        response.status
      }
    end

    # can't use the #requests feature from excon because if the servers
    # does "Connection: close", excon still tries to write to the socket,
    # and EPIPEs.
    def pipelined(url, calls, options)
      url = URI(url)
      client = Excon.new(url.to_s, persistent: true, **http_options(options))
      requests = calls.times.map { { method: :get, path: url.path} }
      client.batch_requests(requests, 1000).map(&:status)
    end

    def http_options(options)
      http_options = options.fetch(:http_options, {})
      http_options[:ssl_verify_peer] = false
      http_options[:debug] = options[:debug]
      http_options
    end
  end

  register "excon", ExconClient
end
