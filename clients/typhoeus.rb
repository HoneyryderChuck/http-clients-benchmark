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
      concurrent(url, calls, options.merge( http_options: {http_version: :httpv1_1}))
    end

    def concurrent(url, calls, options)
      hydra_options = options.delete(:hydra_options) || {}
      http_options = http_options(options)
      hydra = Typhoeus::Hydra.new(hydra_options)
      # hack to set this, as there's no way to set this defined option via public API
      Ethon::Curl.set_option(:max_host_connections, 1, hydra.multi.handle, :multi)

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
      http_options[:pipewait] = 237 # CURLOPT_PIPEWAIT
      if options[:debug]
        http_options[:verbose] = true
      end
      http_options
    end
  end

  register "typhoeus", TyphoeusClient
end
