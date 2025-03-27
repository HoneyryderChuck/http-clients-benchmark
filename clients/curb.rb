# frozen_string_literal: true

module Clients
  module CurbClient
    module_function

    def boot
      require "curb"
    end

    def version
      Curl::VERSION
    end

    def single(url, _, options)
      curl = easy_handle(url, options)
      curl.set(:HTTP_VERSION, Curl::HTTP_1_1)
      curl.http_get

      curl.status
    end

    def persistent(url, calls, options)
      multi = Curl::Multi.new
      status = []

      calls.times.each do
        easy = easy_handle(url, options)
        easy.set(:HTTP_VERSION, Curl::HTTP_1_1)
        easy.on_success{|b| status << b.status }
        multi.add(easy)
      end
      multi.perform

      status
    end

    def pipelined(url, calls, options)
      multi = Curl::Multi.new
      multi.pipeline = Curl::CURLPIPE_HTTP1
      do_multiple(multi, url, calls, options)
    end

    def concurrent(url, calls, options)
      multi = Curl::Multi.new
      multi.pipeline = Curl::CURLPIPE_MULTIPLEX
      do_multiple(multi, url, calls, options)
    end


    def do_multiple(multi, url, calls, options)
      multi.max_host_connections = 1 if multi.respond_to?(:max_host_connections=) # https://github.com/taf2/curb/pull/460
      statuses = []
      ([url] * calls).each do |url|
        easy = easy_handle(url, options)
        easy.set(:PIPEWAIT, Curl::CURLOPT_PIPEWAIT)
        easy.on_success { |b| statuses << b.status }
        multi.add(easy)
      end
      multi.perform
      statuses
    end

    def easy_handle(url, options)
      curl = Curl::Easy.new(url)
      curl.verbose = true if options[:debug]
      curl.ssl_verify_peer = false
      curl.ssl_verify_host = 0
      curl
    end
  end

  register "curb", CurbClient
end
