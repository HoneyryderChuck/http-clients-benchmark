# frozen_string_literal: true

require 'optparse'


$modes = %w[single persistent concurrent]
$clients = %w[httpx net-http typhoeus excon curb patron http rest-client]
$calls = 10

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby #{__FILE__} [options]"

  opts.on("-o CLIENTS", "--only=CLIENTS", String, "select client benchmarks (ex: httpx,curb...)") do |clients|
    clients = clients.split(/ *, */)
    $clients = $clients.select { |client| clients.include?(client) }
  end

  opts.on("-e CLIENTS", "--exclude=CLIENTS", String, "exclude client benchmarks (ex: httpx,curb...)") do |clients|
    clients = clients.split(/ *, */)
    $clients = $clients.reject { |client| clients.include?(client) }
  end

  opts.on("-n NUMBER", "--number=NUMBER", Integer, "number of requests for concurrent mode") do |number|
    $calls = number
  end

  opts.on("-m MODE", "--mode=MODE", String, "select mode (single, concurrent...)") do |mode|
    $modes = $modes.select { |m| m == mode }
  end

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

  opts.on("-h", "--help", "print options") do
    puts opts
    exit
  end
end.parse!


require 'benchmark'

URL = "https://nghttp2.org/httpbin/get"

Benchmark.bm do |bm|
  if $clients.include?("net-http")
    require 'net/http'
    require 'net/https'
    require 'net/http/persistent'

    bm.report("net/http        \e[33msingle\e[0m") do
      uri = URI.parse(URL)
      response = Net::HTTP.get_response(uri)
      print response.code if options[:verbose]
    end

    bm.report("net/http        \e[34mpersistent\e[0m") do
      http = Net::HTTP::Persistent.new
      status = $calls.times.map {
        uri = URI.parse(URL)
        response = http.request(uri)
        response.code
      }.uniq
      http.shutdown
      print status if options[:verbose]
    end
  end


  if $clients.include?("typhoeus")
    require "typhoeus"

    bm.report("typhoeus        \e[33msingle\e[0m") do
      response = Typhoeus::Request.get(URL)

      print response.code if options[:verbose]
    end if $modes.include?("single")

    bm.report("hydra           \e[32mconcurrent\e[0m") do
      hydra = Typhoeus::Hydra.new(max_concurrency: 3)

      requests = $calls.times.map do
        request = Typhoeus::Request.new(URL)
        hydra.queue(request)
        request
      end
      hydra.run

      print requests.map(&:response).map(&:code).uniq if options[:verbose]
    end if $modes.include?("concurrent")

    bm.report("hydra          \e[34mpersistent\e[0m memoize") do
      hydra = Typhoeus::Hydra.new(max_concurrency: 3)
      Typhoeus::Config.memoize = true
      requests = $calls.times.map do
        request = Typhoeus::Request.new(URL)
        hydra.queue(request)
        request
      end
      hydra.run

      print requests.map(&:response).map(&:code).uniq if options[:verbose]
      Typhoeus::Config.memoize = false
    end if $modes.include?("concurrent")
  end

  if $clients.include?("excon")
    require 'excon'

    bm.report("excon         \e[33msingle\e[0m") do
      response = Excon.get(URL)

      print response.status if options[:verbose]
    end if $modes.include?("single")

    bm.report("excon         \e[32mconcurrent\e[0m") do
      client = Excon.new(URL, persistent: true)
      status = $calls.times.map {
        response = client.get
        response.status
      }.uniq

      print status if options[:verbose]
    end if $modes.include?("persistent")
  end

  if $clients.include?("curb")
    require 'curb'

    bm.report("curb          \e[33msingle\e[0m") do
      curl = Curl::Easy.new(URL)
      curl.http_get

      print curl.status if options[:verbose]
    end if $modes.include?("single")

    bm.report("curb          \e[32mconcurrent\e[0m") do
      multi = Curl::Multi.new
      status = []
      $calls.times do
        curl = Curl::Easy.new(URL)
        curl.on_complete { |easy| status << easy.status }
        multi.add(curl)
      end
      multi.perform

      print status.uniq if options[:verbose]
    end if $modes.include?("concurrent")
  end

  if $clients.include?("http")
    require 'http'

    bm.report("httprb          \e[33msingle\e[0m") do
      response = HTTP.get(URL)

      print response.status if options[:verbose]
    end if $modes.include?("single")

    bm.report("httprb          \e[34mpersistent\e[0m") do
      client = HTTP.persistent(URL)
      status = $calls.times.map {
        response = client.get(URL)
        response.status
      }.uniq

      print status if options[:verbose]
    end if $modes.include?("persistent")
  end

  if $clients.include?("patron")

    bm.report("patron          \e[33msingle\e[0m") do
      require 'patron'

      uri = URI.parse(URL)
      endpoint_without_path = begin
        point = uri.dup
        point.path = ""
        point.to_s
      end
      client = Patron::Session.new(base_url: endpoint_without_path)
      response = client.get(uri.path)

      print response.status if options[:verbose]
    end if $modes.include?("single")

    bm.report("patron          \e[34mpersistent\e[0m") do
      uri = URI.parse(URL)
      endpoint_without_path = begin
        point = uri.dup
        point.path = ""
        point.to_s
      end
      client = Patron::Session.new(base_url: endpoint_without_path)
      status = $calls.times.map {
        response = client.get(uri.path)
        response.status
      }.uniq

      print status if options[:verbose]
    end if $modes.include?("concurrent")
  end

  if $clients.include?("rest-client")
    require 'rest-client'

    bm.report("rest-client      \e[33msingle\e[0m") do
      response = RestClient::Resource.new(URL).get

      print response.code if options[:verbose]
    end if $modes.include?("single")
  end

  if $clients.include?("httpx")
    require 'httpx'

    bm.report("httpx         \e[33msingle\e[0m") do
      response = HTTPX.get(URL)

      print response.status if options[:verbose]
    end if $modes.include?("single")

    bm.report("httpx         \e[32mconcurrent\e[0m") do
      responses = HTTPX.get(*([URL] * $calls))
      
      print responses.map(&:status).uniq if options[:verbose]
    end if $modes.include?("concurrent")
  end
end
