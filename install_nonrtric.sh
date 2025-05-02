#!/bin/bash

# Capture start time
start_time=$(date +%s)

workspace=$(pwd)

# Check for sudo privilege
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Function to handle errors
handle_error() {
  echo "Error occurred at step $1. Exiting..."
  exit 1
}


# Step 6: Clone dep repository
echo "==========================================================="
echo "Step 6: Cloning dep repository"
echo "==========================================================="
cd "$workspace" || handle_error 6.1
git clone https://gerrit.o-ran-sc.org/r/it/dep.git -b master --recursive || handle_error 6.2

# # Step 7: Setup charts museum
# echo "==========================================================="
# echo "Step x: Replace oran-override.yaml"
# echo "==========================================================="

# cd dep || handle_error 7.1
# patch_dir="$workspace/patch"
# if [ -d "$patch_dir" ]; then
#   cp "$patch_dir/oran-override.yaml" smo-install/helm-override/default/ || handle_error 13.1
# else
#   echo "Error: Patch directory not found. Make sure you have the patched files in the 'patch' directory."
#   exit 1
# fi

# Step 7: Setup charts museum
echo "==========================================================="
echo "Step 7: Setting up charts museum"
echo "==========================================================="
./dep/smo-install/scripts/layer-0/0-setup-charts-museum.sh || handle_error 7

# Step 7.5: Check running museum
echo "==========================================================="
echo "Step 7: Setting up charts museum"
echo "==========================================================="
ss -lptn 'sport = :18080' 

# Step 8: Setup Helm3
echo "==========================================================="
echo "Step 8: Setting up Helm3"
echo "==========================================================="
./dep/smo-install/scripts/layer-0/0-setup-helm3.sh || handle_error 8

# Step 9: Build all charts
echo "==========================================================="
echo "Step 9: Building all charts"
echo "==========================================================="
./dep/smo-install/scripts/layer-1/1-build-all-charts.sh || handle_error 9

# Step 10: Install ORAN
echo "==========================================================="
echo "Step 10: Installing ORAN"
echo "==========================================================="
./dep/smo-install/scripts/layer-2/2-install-oran.sh || handle_error 10

# Step 11: Check pod status
echo "==========================================================="
echo "Step 11: Checking pod status"
echo "==========================================================="
echo "Pods in ONAP namespace:"
kubectl get pods -n onap
echo "Pods in nonrtric namespace:"
kubectl get pods -n nonrtric

