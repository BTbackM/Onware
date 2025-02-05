#!/bin/bash

SERVICE_NAME=$1
VERSION=$2

# Config git
git config --global user.name "BTbackM"
git config --global user.email "felix.blanco@utec.edu.pe"
git fetch --all && git checkout main

# Install protoc
sudo apt-get install -y protobuf-compiler golang-goprotobuf-dev
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

mkdir -p ./proto/${SERVICE_NAME}
# Generate proto files
protoc \
  --go_out=paths=source_relative:./proto\
  --go-grpc_out=paths=source_relative:./proto\
  ./${SERVICE_NAME}/*.proto

# Generate go mod
cd ./proto/${SERVICE_NAME}
go mod init github.com/BTbackM/Onware/src/shared/proto/${SERVICE_NAME} || true
go mod tidy

# Commit and push changes
git add .
git commit -m "chore: Generate proto files for ${SERVICE_NAME}"
git push origin HEAD:main
git tag -fa proto/${SERVICE_NAME}/${VERSION} -m "chore: Release ${SERVICE_NAME} ${VERSION}"
git push origin refs/tags/proto/${SERVICE_NAME}/${VERSION}
