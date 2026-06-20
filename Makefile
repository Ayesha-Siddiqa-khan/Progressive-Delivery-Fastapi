.PHONY: install test lint run docker-build docker-run helm-template deploy-staging deploy-production rollout-status smoke-test simulate-traffic

IMAGE_NAME ?= progressive-delivery-fastapi
IMAGE_TAG ?= local
NAMESPACE ?= progressive-delivery-staging
HOST ?= http://localhost:8000

install:
	pip install -r requirements.txt

test:
	pytest

lint:
	ruff check .

run:
	uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

docker-build:
	docker build -f docker/Dockerfile -t $(IMAGE_NAME):$(IMAGE_TAG) .

docker-run:
	docker run --rm -p 8000:8000 -e APP_VERSION=v1 -e RELEASE_MODE=good $(IMAGE_NAME):$(IMAGE_TAG)

helm-template:
	helm template progressive-app ./helm/progressive-app --namespace $(NAMESPACE) --set namespace.name=$(NAMESPACE)

deploy-staging:
	helm upgrade --install progressive-app ./helm/progressive-app --namespace progressive-delivery-staging --create-namespace -f helm/progressive-app/values.yaml -f helm/progressive-app/values-staging.yaml --set namespace.name=progressive-delivery-staging

deploy-production:
	helm upgrade --install progressive-app ./helm/progressive-app --namespace progressive-delivery-production --create-namespace -f helm/progressive-app/values.yaml -f helm/progressive-app/values-production.yaml --set namespace.name=progressive-delivery-production

rollout-status:
	bash scripts/rollout-status.sh $(NAMESPACE)

smoke-test:
	bash scripts/smoke-test.sh $(HOST)

simulate-traffic:
	bash scripts/simulate-traffic.sh $(HOST)
