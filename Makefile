projectDir := $(realpath $(dir $(firstword $(MAKEFILE_LIST))))
os := $(shell uname)
VERSION ?= $(shell git rev-parse --short HEAD)
registry = nzacharia/reference-service-go-pub

# P2P tasks

.PHONY: local
local: build local-stubbed-functional local-stubbed-nft

.PHONY: build
build:
	cd cmd/service && go build -o reference-app-go main.go && cd ../../ && go test ./...

.PHONY: local-stubbed-functional
local-stubbed-functional:
	docker compose build service --no-cache
	docker compose up -d service
	docker compose run --rm godog sh -c 'cd functional/godogs; godog run'
	docker compose down

.PHONY: local-stubbed-nft
local-stubbed-nft:
	docker compose build service --no-cache
	docker compose up -d service
	docker compose run --rm k6 run ./nft/ramp-up/test.js
	docker compose down

.PHONY: stubbed-functional
stubbed-functional:
	docker compose run --rm godog sh -c 'cd functional/godogs; godog run'

.PHONY: stubbed-nft
stubbed-nft:
	docker compose run --rm k6 run ./nft/ramp-up/test.js

.PHONY: extended-stubbed-nft
extended-stubbed-nft:
	@echo "Not implemented!"

.PHONY: integrated
integrated:
	@echo "Not implemented!"

# Custom tasks
.PHONY: run-local
run-local:
	docker compose build service --no-cache
	docker compose run --service-ports --rm service

# Minikube local tasks
.PHONY: docker-build
docker-build:
	docker build --file Dockerfile.service --tag $(registry) .

.PHONY: enable-ingress
enable-ingress:
	minikube addons enable ingress
	minikube tunnel &

.PHONY: docker-push
docker-push:
	docker push $(registry)

.PHONY: docker-build-minikube
docker-build-minikube:
	docker build --file Dockerfile.service --tag $(registry) .
	echo -n "verifying images:"
	docker images

.PHONY: deploy-manifests
deploy-manifests:
	kubectl apply -f k8s-manifests/namespace.yml
	kubectl apply -f k8s-manifests/deployment.yml
	kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
	kubectl apply -f k8s-manifests/expose.yml

.PHONY: check-resources
check-resources:
	sleep 40
	kubectl get po -n reference-service-showcase
	kubectl get ingress -n reference-service-showcase
	kubectl get svc -A
