ALPINE_IMAGE=alpine-arakhurs
FRR_IMAGE=frr-arakhurs

ALPINE_CONTAINER=alpine-arakhurs-container
FRR_CONTAINER=frr-arakhurs-container

.PHONY: all build run stop down remove

all: build run

build:
	docker build -t $(ALPINE_IMAGE) ./alpine-arakhurs
	docker build -t $(FRR_IMAGE) ./frr-arakhurs

run:
	docker run -dit --name $(ALPINE_CONTAINER) --hostname $(ALPINE_CONTAINER) --network none $(ALPINE_IMAGE)
	docker run -dit --name $(FRR_CONTAINER) --hostname $(FRR_CONTAINER) --network none --privileged $(FRR_IMAGE)

start:
	docker start $(ALPINE_CONTAINER) || true
	docker start $(FRR_CONTAINER) || true

stop:
	docker stop $(ALPINE_CONTAINER) || true
	docker stop $(FRR_CONTAINER) || true

down:
	docker rm -f $(ALPINE_CONTAINER) || true
	docker rm -f $(FRR_CONTAINER) || true

remove: down
	docker rmi -f $(ALPINE_IMAGE) || true
	docker rmi -f $(FRR_IMAGE) || true
