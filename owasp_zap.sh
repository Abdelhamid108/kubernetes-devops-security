#!/bin/bash

# Fetch the NodePort that exposes our service
PORT=$(kubectl -n default get svc ${serviceName} -o json | jq .spec.ports[0].nodePort)

# Ensure write permissions for the report directory
chmod 777 $(pwd)

# Run the OWASP ZAP API scan against the OpenAPI spec
docker run \
  -v $HOST_WORKSPACE:/zap/wrk/:rw \
  -t ghcr.io/zaproxy/zaproxy:weekly \
  zap-api-scan.py \
    -t $applicationURL:$PORT/v3/api-docs \
    -f openapi \
    -r zap_report.html

exit_code=$?

# Move the HTML report into its own folder
mkdir -p owasp-zap-report
mv zap_report.html owasp-zap-report

echo "Exit Code: $exit_code"
if [[ $exit_code -ne 0 ]]; then
    echo "OWASP ZAP found vulnerabilities. Please check the HTML report."
    exit 1
else
    echo "No vulnerabilities detected by OWASP ZAP."
fi