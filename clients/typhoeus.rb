# frozen_string_literal: true

module Clients
  module TyphoeusClient
    module_function

    def boot
      require "typhoeus"
    end

    def version
      Typhoeus::VERSION
    end

    def single(url, _, options)
      http_options = http_options(options)
      response = Typhoeus::Request.get(url, http_version: :httpv1_1, **http_options)

      response.code
    end

    def persistent(url, calls, options)
      concurrent(url, calls, options.merge(hydra_options: {max_concurrency: 1}, http_options: {http_version: :httpv1_1}))
    end

    def concurrent(url, calls, options)
      hydra_options = options.delete(:hydra_options) || {}
      http_options = http_options(options)
      hydra = Typhoeus::Hydra.new(hydra_options)

      requests = calls.times.map do
        request = Typhoeus::Request.new(url, **http_options)
        hydra.queue(request)
        request
      end
      hydra.run

      requests.map(&:response).map(&:code)
    end

    def http_options(options)
      http_options = options.fetch(:http_options, {})
      http_options[:ssl_verifyhost] = 0
      http_options[:ssl_verifypeer] = false
      if options[:debug]
        http_options[:verbose] = true
      end
      http_options
    end
  end

  register "typhoeus", TyphoeusClient
end
