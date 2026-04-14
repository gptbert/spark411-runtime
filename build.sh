#!/usr/bin/env bash
set -euo pipefail
IMAGE_NAME=${IMAGE_NAME:-spark411-centos6-runtime}
IMAGE_TAG=${IMAGE_TAG:-4.1.1-py312-java21-glibc228}
DOCKERFILE=${DOCKERFILE:-Dockerfile}

docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" -f "${DOCKERFILE}" .
echo "Built ${IMAGE_NAME}:${IMAGE_TAG}"
