# CECG Reference Application - GoLang

## P2P Interface

The P2P interface is how the generated pipelines interact with the repo.
For the CECG reference this follows the [3 musketeers pattern](https://3musketeers.io/) of using:

* Make
* Docker
* Compose

These all need to be installed.

## Structure

### Service

Service source code, using Go.

### Functional

Functional Tests using [Cucumber Godog](https://github.com/cucumber/godog)

Please refer to the [docker compose](./docker-compose.yml) file for instructions on how to do that.

### NFT

Load tests using [K6](https://k6.io/).

## Running the application locally

### Application

```
make run-local
```

This application is exposed locally on port 8080 as well as being available to the tests when run with make.
This is as they are in the same docker network.

### Functional Tests

```
make stubbed-functional
```

You should see:

```
Feature: Greeting
  It's polite to greet someone

  Scenario: hello world returns ok       # functional.feature:4
    Given a rest service                 # functional_test.go:15 -> aRestService
INFO[0000] Hitting endpoint http://localhost:8080       
    When I call the hello world endpoint # functional_test.go:20 -> iCallTheHelloWorldEndpoint
    Then an ok response is returned      # functional_test.go:32 -> anOkResponseIsReturned

1 scenarios (1 passed)
3 steps (3 passed)

```

### Non-Functional Tests

```
make stubbed-nft
```

You should see:

```
     ✓ status was 200
     
     checks.........................: 100.00% ✓ 6590       ✗ 0    
     data_received..................: 850 kB  14 kB/s
     data_sent......................: 560 kB  9.2 kB/s
     http_req_blocked...............: avg=22.7µs  min=0s    med=4µs    max=2.9ms   p(90)=10µs   p(95)=29µs   
     http_req_connecting............: avg=11.99µs min=0s    med=0s     max=1.87ms  p(90)=0s     p(95)=0s     
     http_req_duration..............: avg=2.86ms  min=649µs med=2.02ms max=25.18ms p(90)=4.91ms p(95)=7.27ms 
       { expected_response:true }...: avg=2.86ms  min=649µs med=2.02ms max=25.18ms p(90)=4.91ms p(95)=7.27ms 
     http_req_failed................: 0.00%   ✓ 0          ✗ 6590 
     http_req_receiving.............: avg=40.32µs min=5µs   med=23µs   max=8.7ms   p(90)=63µs   p(95)=93.54µs
     http_req_sending...............: avg=32.3µs  min=2µs   med=13µs   max=5.17ms  p(90)=41µs   p(95)=74.54µs
     http_req_tls_handshaking.......: avg=0s      min=0s    med=0s     max=0s      p(90)=0s     p(95)=0s     
     http_req_waiting...............: avg=2.79ms  min=631µs med=1.96ms max=25ms    p(90)=4.81ms p(95)=7.12ms 
     http_reqs......................: 6590    108.135663/s
     iteration_duration.............: avg=1s      min=1s    med=1s     max=1.02s   p(90)=1s     p(95)=1.01s  
     iterations.....................: 6590    108.135663/s
     vus............................: 52      min=10       max=199
     vus_max........................: 200     min=200      max=200

```

## Running in minikube

### Prereqs

* A minikube cluster i.e. you've run `minikube start`
    * You need to enable the ingress addon by executing: `minikube addons enable ingress` and then follow the instructions from the output e.g. if on mac run `minikube tunnel`
* Kubectl or use `minikube kubectl`
* [Godog binary](https://github.com/cucumber/godog#step-2---install-godog) installed and in your $PATH

### Registries

You'll need a registry. Register for a [Docker hub](https://hub.docker.com/) account and create a private registry e.g.
`savvasm1/reference-service-go-pub`.

If using Docker Desktop then [login](https://www.docker.com/blog/using-docker-desktop-and-docker-hub-together-part-1/)

Update the Makefile `registry` variable with your newly created registry.

### Pushing the image

```
make docker-build
make docker-push
```

### Deploying the service

```
kubectl apply -f k8s-manifests/namespace.yml
kubectl apply -f k8s-manifests/deployment.yml
```

The service should be running:

```
kubectl get pods -n reference-service-showcase
NAME                                 READY   STATUS    RESTARTS   AGE
reference-service-7cff68d485-q8mw5   1/1     Running   0          142m
```

Deploy the ingress and service:

```
kubectl apply -f k8s-manifests/expose.yml
```

```
kubectl get ingress -n reference-service-showcase
NAME                CLASS   HOSTS   ADDRESS        PORTS   AGE
reference-service   nginx   *       192.168.49.2   80      144m
```

If on Linux or MacOS you can now access the service on the IP address (which is the minikube IP).

```
curl localhost/hello
Hello World!%
```

If this doesn't work ensure you followed the instructions when enabling the minikube ingress addon.

### Run the functional tests against deployed application

This shows how you can run the same tests locally and on a deployed version.

`cd into functional/godogs`
```
SERVICE_ENDPOINT="http://localhost:8080/service" godog run
```

### Run the non-functional tests against deployed application

`cd into the root dir (core-reference-application-go)`
```
SERVICE_ENDPOINT="http://localhost:8080/service" k6 run ./nft/ramp-up/test.js
```