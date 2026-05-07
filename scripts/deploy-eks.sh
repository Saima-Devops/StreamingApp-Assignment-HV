#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-ap-south-1}"
ECR_PREFIX="${ECR_PREFIX:-streamingapp}"
IMAGE_TAG="${IMAGE_TAG:?Set IMAGE_TAG to the tag you pushed to ECR}"
RELEASE_NAME="${RELEASE_NAME:-streamingapp}"
NAMESPACE="${NAMESPACE:-streamingapp}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-$(aws sts get-caller-identity --query Account --output text)}"
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

helm upgrade --install "${RELEASE_NAME}" charts/streamingapp \
  --namespace "${NAMESPACE}" \
  --create-namespace \
  --set services.frontend.image.repository="${ECR_REGISTRY}/${ECR_PREFIX}/frontend" \
  --set services.auth.image.repository="${ECR_REGISTRY}/${ECR_PREFIX}/auth" \
  --set services.streaming.image.repository="${ECR_REGISTRY}/${ECR_PREFIX}/streaming" \
  --set services.admin.image.repository="${ECR_REGISTRY}/${ECR_PREFIX}/admin" \
  --set services.chat.image.repository="${ECR_REGISTRY}/${ECR_PREFIX}/chat" \
  --set global.imageTag="${IMAGE_TAG}"
