#!/bin/bash

set -e

RUBY_PLATFORM=`ruby -e 'puts RUBY_PLATFORM'`
RUBY_ENGINE=`ruby -e 'puts RUBY_ENGINE'`

apt-get update && apt-get install --no-install-recommends -y build-essential git libmagickwand-dev

if [[ "$RUBY_PLATFORM" = "java" ]]; then
  apt-get update && apt-get install -y build-essential
fi

cd /home
bundle install

CABUNDLEDIR=/home/certs
if [[ "$RUBY_PLATFORM" = "java" ]]; then
  keytool -import -cacerts -alias nghttp2 -file $CABUNDLEDIR/nghttp2.cert \
    -storepass changeit -noprompt
else
  export SSL_CERT_FILE=$CABUNDLEDIR/nghttp2.cert
fi


bundle exec ruby benchmarks/requests.rb --url=https://nghttp2/get --graph
