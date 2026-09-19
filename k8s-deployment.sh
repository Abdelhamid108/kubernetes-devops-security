#!/bin/bash
# Replace placeholder with real image name
sed -i "s|replace|${imageName}|g" k8s_deployment_service.yaml

# Check if deployment exists
if ! kubectl -n default get deployment "${deploymentName}" > /dev/null; then
    echo "Creating deployment ${deploymentName}"
    kubectl -n default apply -f k8s_deployment_service.yaml
else
    echo "Updating image for ${deploymentName} to ${imageName}"
    kubectl -n default set image deploy "${deploymentName}" "${containerName}"="${imageName}" --record=true
fi
