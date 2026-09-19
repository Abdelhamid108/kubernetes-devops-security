#!/usr/bin/env bash
set -o errexit
echo "Scanning image: $imageName"

# 1. Report LOW, MEDIUM, HIGH (non-blocking)
docker run --rm \
  -v trivy-cache:/root/.cache/ \
  aquasec/trivy:0.74.0 \
  -q image \
  --exit-code 0 \
  --severity LOW,MEDIUM,HIGH \
  --light "$imageName"

# 2. Fail on CRITICAL
docker run --rm \
  -v trivy-cache:/root/.cache/ \
  aquasec/trivy:0.74.0 \
  -q image \
  --exit-code 1 \
  --severity CRITICAL \
  --light "$imageName"

exit_code=$?
echo "Exit Code: $exit_code"

if [[ $exit_code -ne 0 ]]; then
  echo 'Image scanning failed: Critical vulnerabilities found'
  exit 1
else
  echo 'Image scanning passed: No critical issues'
fi