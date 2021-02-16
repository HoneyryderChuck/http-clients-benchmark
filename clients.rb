# frozen_string_literal: true

require "openssl"

# As many times we're testing against a local server with an handmade cert, let's skip verification
OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:verify_mode] = OpenSSL::SSL::VERIFY_NONE

module Clients
  @clients = {}

  module_function

  def all
    @clients.keys
  end

  def fetch(sym)
    @clients.fetch(sym)
  end

  def register(sym, client)
    @clients[sym] = client 
  end
end


Dir[File.join(".", "clients", "*.rb")].sort.each { |f| require f }

