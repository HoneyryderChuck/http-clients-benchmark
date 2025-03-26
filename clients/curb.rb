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
      curl = Curl::Easy.new(url)
      curl.set(:HTTP_VERSION, Curl::HTTP_1_1)
      curl.ssl_verify_peer = false
      curl.ssl_verify_host = 0
      curl.http_get

      curl.status
    end

    def persistent(url, calls, options)
      multi = Curl::Multi.new
      status = []

      calls.times.each do
        easy = Curl::Easy.new(url)
        easy.set(:HTTP_VERSION, Curl::HTTP_1_1)
        easy.ssl_verify_peer = false
        easy.ssl_verify_host = 0
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
        easy = Curl::Easy.new(url)
        easy.set(:PIPEWAIT, Curl::CURLOPT_PIPEWAIT)
        easy.verbose = true if options[:debug]
        easy.ssl_verify_peer = false
        easy.ssl_verify_host = 0
        easy.on_success { |b| statuses << b.status }
        multi.add(easy)
      end
      multi.perform
      statuses
    end
  end

  register "curb", CurbClient
end
