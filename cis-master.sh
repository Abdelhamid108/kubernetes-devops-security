#!/bin/bash

# Run specific Kubelet tests
total_fail=$(kube-bench run --targets master \
  --check 1.1.12,1.2.1 \
  --json | jq -r '.Totals.total_fail')

if [[ "$total_fail" -ne 0 ]]; then
  echo "CIS Benchmark Failed: Master checks 1.1.12,1.2.1"
  exit 1
else
  echo "CIS Benchmark Passed: Master checks 1.1.12,1.2.1"
fi