# frozen_string_literal: true

ruby RUBY_VERSION

source "https://rubygems.org"

platform :mri do
  gem "benchmark-ips", require: false
  gem "pry-byebug", require: false
  gem "ruby-prof"
  gem "stackprof"

  gem 'curb'
  gem 'typhoeus'
  gem 'patron'
end

gem "pry", :require => false

gem "gruff"

platform :jruby do
  gem 'manticore'
end

# clients
gem 'net-http-persistent'
gem 'net-http-pipeline'
gem 'excon'
gem 'http'
gem 'httpx'
