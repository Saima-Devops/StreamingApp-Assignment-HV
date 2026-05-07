#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-ap-south-1}"
ECR_PREFIX="${ECR_PREFIX:-streamingapp}"
IMAGE_TAG="${IMAGE_TAG:-$(git rev-parse --short=12 HEAD 2>/dev/null || date +%Y%m%d%H%M%S)}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-$(aws sts get-caller-identity --query Account --output text)}"
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

services=(frontend auth streaming admin chat)
contexts=(frontend backend/authService backend backend backend)
dockerfiles=(Dockerfile Dockerfile streamingService/Dockerfile adminService/Dockerfile chatService/Dockerfile)

aws ecr get-login-password --region "${AWS_REGION}" \
  | docker login --username AWS --password-stdin "${ECR_REGISTRY}"

./scripts/create-ecr-repos.sh

for i in "${!services[@]}"; do
  service="${services[$i]}"
  context="${contexts[$i]}"
  dockerfile="${dockerfiles[$i]}"
  image="${ECR_REGISTRY}/${ECR_PREFIX}/${service}:${IMAGE_TAG}"

  docker build -t "${image}" -f "${context}/${dockerfile}" "${context}"
  docker push "${image}"
  echo "Pushed ${image}"
done

echo "IMAGE_TAG=${IMAGE_TAG}"
