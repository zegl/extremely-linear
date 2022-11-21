#!/bin/bash

docker buildx build \
    --platform linux/amd64,linux/arm/v7,linux/arm/v8,linux/arm64 \
    --target runner \
    -t zegl/extremely-linear:latest \
    --push .