# frozen_string_literal: true

module Clients
  module TyphoeusClient
    module_function

    def boot
      require "typhoeus"
    end

    def single(url, _, options)
      response = Typhoeus::Request.get(url, ssl_verifyhost: 0, ssl_verifypeer: false, http_version: :httpv1_1)

      response.code
    end

    def persistent(url, calls, options)
      concurrent(url, calls, options.merge(http_options: {http_version: :httpv1_1}))
    end

    def concurrent(url, calls, options)
      http_options = options.fetch(:http_options, {})
      hydra = Typhoeus::Hydra.new(max_concurrency: 3)

      requests = calls.times.map do
        request = Typhoeus::Request.new(url, ssl_verifyhost: 0, ssl_verifypeer: false, **http_options)
        hydra.queue(request)
        request
      end
      hydra.run

      requests.map(&:response).map(&:code)
    end
  end

  register "typhoeus", TyphoeusClient
end
