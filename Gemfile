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
end

gem "pry", :require => false

if RUBY_ENGINE == "jruby"
  # transitive dep rmagick4j
  gem "gruff", github: "topfunky/gruff", branch: "master"
else
  # transitive dep rmagick
  gem "gruff"
end

platform :jruby do
  gem 'manticore'
end

# clients
gem 'net-http-persistent'
gem 'excon'
gem 'http'
gem 'httpx'
