# frozen_string_literal: true

module Clients
  module RestCliClient
    module_function

    def boot
      require "rest-client"
    end

    def version
      RestClient::VERSION
    end

    def single(url, _, options)
      response = RestClient::Resource.new(url, verify_ssl: OpenSSL::SSL::VERIFY_NONE).get

      response.code
    end
  end

  register "rest-client", RestCliClient
end
