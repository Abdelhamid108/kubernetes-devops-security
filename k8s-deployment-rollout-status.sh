#!/bin/bash

# Monitor rollout with a 5-second timeout
if ! kubectl -n default rollout status deploy "${deploymentName}" --timeout=5s | grep -q "successfully rolled out"; then
    echo "Rollout FAILED; rolling back ${deploymentName}"
    kubectl -n default rollout undo deploy "${deploymentName}"
    exit 1
else
    echo "Rollout SUCCESSFUL for ${deploymentName}"
fi
