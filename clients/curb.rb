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

    def concurrent(url, calls, options)
      multi = Curl::Multi.new
      status = []
      Curl::Multi.get([url] * calls, ssl_verify_peer: false, ssl_verify_host: 0) do |easy|
        status << easy.status
      end
      status
    end
  end

  register "curb", CurbClient
end
