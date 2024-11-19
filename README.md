# Ruby HTTP Client Benchmarks

This repository stores comparative benchmarks for known Ruby HTTP clients.

## What's being benchmarked?

The current benchmarks are collected and compared:

* Single: A single GET request to a peer (HTTP/1.1);
* Persistent: Requests sent to the peer one after the other (HTTP/1.1 Keep-Alive);
* Pipelined: Requests sent to the peer at once (HTTP/1.1 Pipelining);
* Concurrent: Requests multiplexed to the peer (HTTP/2);

(Clients may skip benchmarks if they do not supported the required functionality).

The benchmarks run inside a docker-compose cluster and perform requests against an [httpbin](https://httpbin.org/) instance (in go) behind an [nghttpx](https://nghttp2.org/documentation/nghttpx-howto.html) proxy. This makes the benchmarks less affected by network instability or peer delays/rate-limiting, so we get a better feel of how much overhead each option has.

## Ruby Clients

The current http clients are being tested:

* httpx
* net-http
* excon
* http
* curb
* patron
* typhoeus

The most recent release for each will be used.

## Benchmarks

### Single Request (HTTP/1.1)

Measures the overhead of a single HTTP/1.1 GET request.

#### CRuby

![single benchmark chart](https://gitlab.com/os85/http-clients-benchmark/-/jobs/artifacts/master/raw/snapshots/ruby-http-single-bench.png?job=benchmark)

#### JRuby

![single benchmark chart](https://gitlab.com/os85/http-clients-benchmark/-/jobs/artifacts/master/raw/snapshots/jruby-http-single-bench.png?job=benchmark+jruby)

### Persistent (HTTP/1.1 Keep-Alive)

Measures the overhead of 200 HTTP/1.1 GET requests, sent sequentially over the same TCP connection.

#### CRuby

![persistent benchmark chart](https://gitlab.com/os85/http-clients-benchmark/-/jobs/artifacts/master/raw/snapshots/ruby-http-persistent-bench.png?job=benchmark)

#### JRuby

![persistent benchmark chart](https://gitlab.com/os85/http-clients-benchmark/-/jobs/artifacts/master/raw/snapshots/jruby-http-persistent-bench.png?job=benchmark+jruby)

### Pipelined (HTTP/1.1)

Measures the overhead of 5000 HTTP/1.1 GET requests, sent simultaneously over the same TCP connection.

#### CRuby

![pipelined benchmark chart](https://gitlab.com/os85/http-clients-benchmark/-/jobs/artifacts/master/raw/snapshots/ruby-http-pipelined-bench.png?job=benchmark)

#### JRuby

![pipelined benchmark chart](https://gitlab.com/os85/http-clients-benchmark/-/jobs/artifacts/master/raw/snapshots/jruby-http-pipelined-bench.png?job=benchmark+jruby)

### Concurrent (HTTP/2)

Measures the overhead of 5000 HTTP/2 GET requests, multiplexed over the same TCP connection.

#### CRuby

![concurrent benchmark chart](https://gitlab.com/os85/http-clients-benchmark/-/jobs/artifacts/master/raw/snapshots/ruby-http-concurrent-bench.png?job=benchmark)

#### JRuby

![concurrent benchmark chart](https://gitlab.com/os85/http-clients-benchmark/-/jobs/artifacts/master/raw/snapshots/jruby-http-concurrent-bench.png?job=benchmark+jruby)

## How do you run the benchmark locally?

Using `docker`, you should just clone the project, and run:

```bash
$ docker-compose run benchmark
```

You can alternatively run the benchmark script with different input:

```bash
# once you bundle install, and have everything in place:
> bundle exec ruby benchmarks/requests.rb --help
```

## Would you like to test another HTTP client?


* Fork this repository;
* Add a [new module for the http client](https://gitlab.com/os85/http-clients-benchmark/-/tree/master/clients);
* Add a function for each supported module (i.e.: `.single`, `pipelined`, follow [this example](https://gitlab.com/os85/http-clients-benchmark/-/blob/master/clients/httpx.rb));
* Make sure it works (run `ruby benchmarks/clients --help`);
* Submit an MR with your changes;

## FAQ

### Why?

As the maintainer of `httpx`, I'm interested in how well it measures against other popular `ruby` alternatives, specifically in:

#### Performance

In `ruby`, it's very common to hear that one should "drop down to C" in order to get more performance. `httpx` being pure `ruby`, I don't think, at least with modern `ruby`, that the implementation complexity is worth the cost; and `httpx` can perform as well or better as any other alternative. This benchmark keeps my assumptions honest.

#### Feature completeness

Not all clients support all features, so this chart can also be informative to anyone looking for feature coverage.

#### API

I also want to compare how "friendly" APIs are, when it comes to performing requests (disclaimer: `net-http` is as hard as it sounds).

### Q.: How often are the benchmarks updated?

Once a month. My CI minutes are limited.

### Q.: Which benchmark is the most important?

It depends of your workload. If you need to support concurrent requests, look at those. If you perform a request at a time not too often, probably you'd want to look at the single benchmark. However, you should take other parameters into consideration, such as API, maintainability, ease of integration, etc. .

### Q.: What about memory usage, POST requests...?

Still in the works. But feel free to make suggestions in the issues box.
