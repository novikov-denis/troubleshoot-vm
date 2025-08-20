.ONESHELL:
SHELL = /bin/bash

GOBASE=$(shell pwd)
GOBIN=$(GOBASE)/ansible/files/bin
SOURCE=$(GOBASE)/trouble-apps-go
ECHO_SOURCE=$(GOBASE)/trouble-apps-go/cmd/echo
WATCHER_SOURCE=$(GOBASE)/trouble-apps-go/cmd/watcher
TROUBLE_SOURCE=$(GOBASE)/trouble-apps-go/cmd/trouble
CGO_ENABLED=1

default: build

.PHONY: packer-validate
packer-validate:
	@packer validate packer

.PHONY: build
build: compile packer-build

.PHONY: packer-build
packer-build: packer-validate
	@echo "  >  Start packer build..."
	@packer build packer

.PHONY: clean
clean:
	@rm "${PLAINTEXT_FILE}"

compile: go-clean go-tidy go-vet go-build

go-clean:
	@echo "  >  Cleaning build cache"
	@cd $(SOURCE); GOBIN=$(GOBIN) go clean
	@rm -rf $(GOBIN)

go-tidy:
	@echo "  >  Update modules..."
	@cd $(SOURCE); go mod tidy

go-vet:
	@echo "  >  Vet project..."
	@cd $(SOURCE); go vet ./...

go-build:
	@echo "  >  Building binaries..."
	@cd $(ECHO_SOURCE); GOOS=linux GOARCH=amd64 go build -o $(GOBIN)/echo main.go
	@cd $(WATCHER_SOURCE); GOOS=linux GOARCH=amd64 go build -o $(GOBIN)/watcher main.go
	@cd $(TROUBLE_SOURCE); GOOS=linux GOARCH=amd64 go build -o $(GOBIN)/trouble main.go
