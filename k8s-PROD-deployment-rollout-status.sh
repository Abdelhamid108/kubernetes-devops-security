#!/bin/bash
# Wait for pods to start
sleep 60s

if ! kubectl -n prod rollout status deploy ${deploymentName} --timeout=5s | grep -q "successfully rolled out"; then
  echo "Deployment ${deploymentName} rollout has failed"
  kubectl -n prod undo deploy ${deploymentName}
  exit 1
else
  echo "Deployment ${deploymentName} rollout is successful"
fi