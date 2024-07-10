# frozen_string_literal: true

require 'optparse'

require_relative "../clients"

host = ENV.fetch("HTTPBIN_HOST", "nghttp2.org/httpbin")
$url = "https://#{host}/get"
$modes = %w[single persistent concurrent pipelined]
$clients = Clients.all
$calls = 5000

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

  opts.on("-m MODE", "--mode=MODE", String, "select mode (#{$modes.join(", ")})") do |mode|
    modes = mode.split(/ *, */)
    $modes = $modes.select { |m| modes.include?(m) }
  end

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

  opts.on("-g", "--graph", "build graphs") do |g|
    options[:graph] = g
  end

  opts.on("-h", "--help", "print options") do
    puts opts
    exit
  end
end.parse!

COLOR_CODES_MODE = {
  "single" => 32,
  "concurrent" => 33,
  "persistent" => 34,
  "pipelined" => 35
}

TITLE_MODE = {
  "single" => "Single HTTP/1.1 GET request",
  "concurrent" => "%d Concurrent HTTP/2 GET requests",
  "persistent" => "%d Persistent HTTP/1.1 GET requests",
  "pipelined" => "%d Pipelined HTTP/1.1 GET requests"
}

require 'benchmark'


def run_benchmark
  GC.start
  GC.disable

  yield

  GC.enable
  GC.start
end

$clients.select! do |nm|
  client = Clients.fetch(nm)
  begin
    client.boot
    true
  rescue LoadError
    $stderr.puts "Could not load #{nm}, skipping benchmarks"
    false
  end
end


combinations = $modes.product($clients).select do |mode, nm|
  Clients.fetch(nm).respond_to?(mode)
end

tms = Benchmark.bmbm do |bm|
  combinations.each do |mode, nm|
    client = Clients.fetch(nm)

    tty_color = COLOR_CODES_MODE[mode]

    begin
      run_benchmark do
        bm.report("#{nm}\t\t\e[#{tty_color}m#{mode}\e[0m") do
          statuses = client.__send__(mode, $url, $calls, options)
          if options[:verbose]
            pr = Array(statuses).tally.map { |st, ct| "#{st} (#{ct})" }.join(", ")
            print("\t#{pr}\n")
          end
        rescue => error
          $stderr.puts error.message
        end
      end
    rescue RuntimeError => e
      $stderr.puts "error running benchmark."
      $stderr.puts e.full_message
    end
  end
end

tms.each_with_index do |tm, idx|
  combinations[idx] << tm
end

by_mode = combinations.group_by(&:first)

if options[:graph]
  require "fileutils"
  require "gruff"
  require "time"

  now = Time.now.utc

  nowstr = now.strftime("%d/%m/%Y %H:%M")

  FileUtils.mkdir_p("snapshots")

  by_mode.each do |mode, combinations|
    g = Gruff::Bar.new(800)
    g.title = "HTTP Client Benchmarks - #{sprintf(TITLE_MODE[mode], $calls)} (#{nowstr})\n"
    g.x_axis_label = "(#{RUBY_DESCRIPTION})"
    g.y_axis_label = 'Time (seconds)'
    g.minimum_value = 0
    g.group_spacing = 20
    g.font = File.join(__dir__, "..", "fixtures", 'Roboto-Light.ttf')

    combinations.each do |mode, nm, bm|
      next unless bm # failed to require client

      client = Clients.fetch(nm)

      label = if client.respond_to?(:"name_#{mode}")
        client.__send__(:"name_#{mode}")
      else
        nm
      end
      g.data("#{label} (#{client.version})", [bm.real])
    end

    g.write("snapshots/#{RUBY_ENGINE}-http-#{mode}-bench.png")
  end
end
