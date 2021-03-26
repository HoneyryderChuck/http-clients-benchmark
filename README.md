# Ruby HTTP Client Benchmarks

This repository stores comparative benchmarks for known Ruby HTTP clients.

## What's being benchmarked?

The current benchmarks are collected and compared:

* Single: A single GET request to a peer (HTTP/1.1);
* Persistent: Requests sent to the peer one after the other (HTTP/1.1 Keep-Alive);
* Pipelined: Requests sent to the peer at once (HTTP/1.1 Pipelining);
* Concurrent: Requests multiplexed to the peer (HTTP/2);

(Clients may skip benchmarks if they do not supported the required functionality).

The benchmarks run inside a docker-compose cluster and perform requests against an [httpbin](https://httpbin.org/) instance behind an [nghttpx](https://nghttp2.org/documentation/nghttpx-howto.html) proxy. This makes the benchmarks less affected by network instability or peer delays/rate-limiting, so we get a better feel of the real performance of each option.


## Ruby Clients

The current http clients are being tested:

* httpx
* net-http
* excon
* http
* curb
* patron
* typhoeus

## Benchmarks


### Single

![single benchmark chart](https://honeyryderchuck.gitlab.io/http-clients-benchmark/snapshots/http-single-bench.png)

### Persistent

![persistent benchmark chart](https://honeyryderchuck.gitlab.io/http-clients-benchmark/snapshots/http-persistent-bench.png)

### Pipelined 

![pipelined benchmark chart](https://honeyryderchuck.gitlab.io/http-clients-benchmark/snapshots/http-pipelined-bench.png)

### Concurrent

![concurrent benchmark chart](https://honeyryderchuck.gitlab.io/http-clients-benchmark/snapshots/http-concurrent-bench.png)


## Would you like to test another HTTP client?


* Fork this repository;
* Add a [new module for the http client](https://gitlab.com/honeyryderchuck/http-clients-benchmark/-/tree/master/clients);
* Add a function for each supported module (i.e.: `.single`, `pipelined`, follow [this example](https://gitlab.com/honeyryderchuck/http-clients-benchmark/-/blob/master/clients/httpx.rb));
* Make sure it works (run `ruby benchmarks/clients --help`);
* Submit an MR with your changes;

## FAQ

* Q.: How often are the benchmarks updated?

Once a month. My CI minutes are limited.

* Q.: Which benchmark is the most important?

It depends of your workload. If you need to support concurrent requests, look at those. If you perform a request at a time not too often, probably you'd want to look at the single benchmark. However, you should take other parameters into consideration, such as API, maintainability, ease of integration, etc. .

* Q.: What about memory usage, POST requests...?

Still in the works. But feel free to make suggestions in the issues box.
