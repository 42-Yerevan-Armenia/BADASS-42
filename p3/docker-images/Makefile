ALPINE_IMAGE=alpine-arakhurs
FRR_IMAGE=frr-arakhurs

ALPINE_CONTAINER=alpine-arakhurs-container
FRR_CONTAINER=frr-arakhurs-container

.PHONY: all build run configure-gns3 stop down remove

all: build run

build:
	docker build -t $(ALPINE_IMAGE) ./alpine-arakhurs
	docker build -t $(FRR_IMAGE) ./frr-arakhurs

run:
	docker run -dit --name $(ALPINE_CONTAINER) --hostname $(ALPINE_CONTAINER) --network none $(ALPINE_IMAGE)
	docker run -dit --name $(FRR_CONTAINER) --hostname $(FRR_CONTAINER) --network none --privileged $(FRR_IMAGE)

configure-gns3:
	@set -eu; \
	for hostname in router-arakhurs-1 router-arakhurs-2 router-arakhurs-3 router-arakhurs-4 host-arakhurs-1 host-arakhurs-2 host-arakhurs-3; do \
		container=$$(docker ps --format '{{.ID}} {{.Names}}' | awk -v target="GNS3.$$hostname." '$$2 ~ ("^" target) { print $$1; exit }'); \
		if [ -z "$$container" ]; then echo "GNS3 node $$hostname is not running." >&2; exit 1; fi; \
		case "$$hostname" in \
			router-arakhurs-1) interfaces='eth0 eth1 eth2' ;; \
			router-arakhurs-2|router-arakhurs-3) interfaces='eth0 eth1' ;; \
			router-arakhurs-4) interfaces='eth0 eth2' ;; \
			host-arakhurs-1) interfaces='eth1' ;; \
			host-arakhurs-[2-3]) interfaces='eth0' ;; \
		esac; \
		for interface in $$interfaces; do \
			if ! docker exec "$$container" ip link show dev "$$interface" >/dev/null 2>&1; then echo "GNS3 node $$hostname is missing $$interface." >&2; exit 1; fi; \
		done; \
	done; \
	for hostname in router-arakhurs-1 router-arakhurs-2 router-arakhurs-3 router-arakhurs-4 host-arakhurs-1 host-arakhurs-2 host-arakhurs-3; do \
		container=$$(docker ps --format '{{.ID}} {{.Names}}' | awk -v target="GNS3.$$hostname." '$$2 ~ ("^" target) { print $$1; exit }'); \
		case "$$hostname" in \
			router-arakhurs-[1-4]) script="/root/router$${hostname##*-}.sh"; shell=bash ;; \
			host-arakhurs-[1-3]) script="/root/host$${hostname##*-}.sh"; shell=sh ;; \
		esac; \
		echo "Configuring $$hostname with $$script"; \
		docker exec "$$container" "$$shell" "$$script"; \
	done

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
