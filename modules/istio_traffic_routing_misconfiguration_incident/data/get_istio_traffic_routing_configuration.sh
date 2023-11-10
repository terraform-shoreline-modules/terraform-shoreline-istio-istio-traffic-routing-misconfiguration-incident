#!/bin/bash

# Get the Istio traffic routing configuration
istioctl get virtualservices -n ${NAMESPACE} > virtualservices.yaml

# Check for errors or inconsistencies in the configuration
if grep -q "error" virtualservices.yaml; then
    echo "ERROR: Istio traffic routing configuration contains errors"
    exit 1
fi

# Verify that the routing rules are correctly defined and applied to the relevant services and workloads
if ! grep -q "${SERVICE_NAME}" virtualservices.yaml || ! grep -q "${WORKLOAD_NAME}" virtualservices.yaml; then
    echo "ERROR: Istio traffic routing configuration is missing relevant services or workloads"
    exit 1
fi