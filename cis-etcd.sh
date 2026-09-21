#!/bin/bash

# Run specific Kubelet tests
total_fail=$(kube-bench run --targets etcd \
  --check 2.2 \
  --json | jq -r '.Totals.total_fail')

if [[ "$total_fail" -ne 0 ]]; then
  echo "CIS Benchmark Failed: etcd checks 2.2"
  exit 1
else
  echo "CIS Benchmark Passed: etcd checks 2.2"
fi