# frozen_string_literal: true

require 'optparse'


require_relative "../clients"

$url = "https://nghttp2.org/httpbin/get"
$modes = %w[single persistent concurrent]
$clients = Clients.all
$calls = 10

options = {}

OptionParser.new do |opts|
  client_examples = $clients.take(2).join(",") << ".."

  opts.banner = "Usage: ruby #{__FILE__} [options]"

  opts.on("-u URL", "--url=URL", String, "url to send requests to (default: #{$url})") do |url|
    $url = url
  end

  opts.on("-o CLIENTS", "--only=CLIENTS", String, "select client benchmarks (ex: #{(client_examples)})") do |clients|
    clients = clients.split(/ *, */)
    $clients = $clients.select { |client| clients.include?(client) }
  end

  opts.on("-e CLIENTS", "--exclude=CLIENTS", String, "exclude client benchmarks (ex: #{client_examples})") do |clients|
    clients = clients.split(/ *, */)
    $clients = $clients.reject { |client| clients.include?(client) }
  end

  opts.on("-n NUMBER", "--number=NUMBER", Integer, "number of requests for multi mode") do |number|
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

COLOR_CODES_MODE = {
  "single" => 32,
  "concurrent" => 33,
  "persistent" => 34
}

require 'benchmark'

Benchmark.bm do |bm|
  bench_clients = $clients.each do |nm|
    client = Clients.fetch(nm)
    begin
      client.boot
    rescue LoadError
      $stderr.puts "Could not load #{nm}, skipping benchmarks"
      next
    end

    $modes.each do |mode|
      next unless client.respond_to?(mode)

      tty_color = COLOR_CODES_MODE[mode]
      bm.report("#{nm}\t\t\e[#{tty_color}m#{mode}\e[0m") do
        statuses = client.__send__(mode, $url, $calls, options)
        if options[:verbose]
          pr = Array(statuses).tally.map { |st, ct| "#{st} (#{ct})" }.join(", ")
          print("\t#{pr}\n")
        end
      end
    end
  end
end
