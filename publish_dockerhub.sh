#!/usr/bin/env bash
set -euo pipefail
: "${DOCKERHUB_NAMESPACE:?Set DOCKERHUB_NAMESPACE}"
IMAGE_NAME=${IMAGE_NAME:-spark411-centos6-runtime}
IMAGE_TAG=${IMAGE_TAG:-4.1.1-py312-java21-glibc228}
FULL_REF="${DOCKERHUB_NAMESPACE}/${IMAGE_NAME}:${IMAGE_TAG}"

docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${FULL_REF}"
docker push "${FULL_REF}"
echo "Pushed ${FULL_REF}"
