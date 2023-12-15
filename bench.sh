#!/bin/bash

set -e

RUBY_PLATFORM=`ruby -e 'puts RUBY_PLATFORM'`
RUBY_ENGINE=`ruby -e 'puts RUBY_ENGINE'`

apt-get update && apt-get install --no-install-recommends -y libmagickwand-dev

if [[ "$RUBY_PLATFORM" = "java" ]]; then
  apt-get update && apt-get install -y build-essential
fi

cd /home
bundle install

bundle exec ruby benchmarks/requests.rb --url=https://nghttp2/get --graph
