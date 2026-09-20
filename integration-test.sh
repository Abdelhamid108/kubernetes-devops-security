#!/usr/bin/env bash
set -euo pipefail
sleep 5

# Retrieve the NodePort for the service
PORT=$(kubectl -n default get svc "${serviceName}" -o jsonpath='{.spec.ports[0].nodePort}')

if [[ -z "$PORT" ]]; then
  echo "Error: Service ${serviceName} has no NodePort."
  exit 1
fi

URL="${applicationURL}:${PORT}${applicationURI}"
echo "Testing endpoint: $URL"

# Validate payload increments 99 to 100
response=$(curl -s "$URL")
if [[ "$response" != "100" ]]; then
  echo "Payload Test Failed: expected 100, got $response"
  exit 1
else
  echo "Payload Test Passed"
fi

# Check HTTP status code 200
http_code=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
if [[ "$http_code" != "200" ]]; then
  echo "HTTP Status Test Failed: expected 200, got $http_code"
  exit 1
else
  echo "HTTP Status Test Passed"
fi