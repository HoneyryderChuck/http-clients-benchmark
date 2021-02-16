# Ruby HTTP Client Benchmarks

This repository stores comparative benchmarks for known Ruby HTTP clients.


## What's being benchmarked?

The current benchmarks are collected and compared:

* Single: A single GET request to a peer;
* Persistent: The same request sent to the peer multiple times one after the other (HTTP/1.1 Keep-Alive);
* Concurrent: The same request sent to the peer multiple times (HTTP/2 or HTTP/1.1 pipelining);

Clients may not run all benchmarks if they do not supported the required functionality.

## Ruby Clients

The current http clients are being tested:

* httpx
* net-http
* rest-client
* excon
* http
* curb
* patron
* typhoeus

## Benchmarks

TBD

## Would you like to test another HTTP client?

Please submit an MR with the benchmark implementation.

