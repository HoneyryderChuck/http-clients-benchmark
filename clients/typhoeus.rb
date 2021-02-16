# frozen_string_literal: true

module Clients
  module TyphoeusClient
    module_function

    def boot
      require "typhoeus"
    end

    def single(url, _, options)
      response = Typhoeus::Request.get(url, ssl_verifyhost: 0, ssl_verifypeer: false)

      response.code
    end

    def persistent(url, calls, options)
      hydra = Typhoeus::Hydra.new(max_concurrency: 3)
      Typhoeus::Config.memoize = true
      requests = calls.times.map do
        request = Typhoeus::Request.new(url, ssl_verifyhost: 0, ssl_verifypeer: false)
        hydra.queue(request)
        request
      end
      hydra.run

      requests.map(&:response).map(&:code)
    ensure
      Typhoeus::Config.memoize = false
    end

    def concurrent(url, calls, options)
      hydra = Typhoeus::Hydra.new(max_concurrency: 3)

      requests = calls.times.map do
        request = Typhoeus::Request.new(url, ssl_verifyhost: 0, ssl_verifypeer: false)
        hydra.queue(request)
        request
      end
      hydra.run

      requests.map(&:response).map(&:code)
    end
  end

  register "typhoeus", TyphoeusClient
end
