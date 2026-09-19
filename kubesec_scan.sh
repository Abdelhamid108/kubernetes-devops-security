#!/usr/bin/env bash
set -euo pipefail

scan_result=$(curl -sSX POST --data-binary @"k8s_deployment_service.yaml" https://v2.kubesec.io/scan)
scan_score=$(jq -r '.[0].score' <<<"$scan_result")
scan_message=$(jq -r '.[0].message' <<<"$scan_result")

echo "Scan Score: $scan_score"
if [[ "$scan_score" -ge 5 ]]; then
  echo "Kubesec Scan Passed: $scan_message"
else
  echo "Kubesec Scan Failed: $scan_message (score $scan_score < 5)"
  exit 1
fi