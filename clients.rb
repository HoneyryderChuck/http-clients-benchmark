# frozen_string_literal: true

require "openssl"

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
