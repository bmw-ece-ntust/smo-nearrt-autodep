#!/bin/bash

# Capture start time
start_time=$(date +%s)

workspace=$(pwd)

host_name="smo-nearrt-i"

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check internet connectivity
check_internet() {
  echo "Checking internet connection..."
  if ping -q -c 1 -W 1 google.com &>/dev/null; then
    echo "Internet connection is active."
  else
    echo "Error: No internet connection. Please ensure your system has access to the internet."
    exit 1
  fi
}

# Function to disable swap
disable_swap() {
  echo "Disabling swap..."
  sudo swapon --show > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    sudo swapoff -a
    sudo rm /swapfile
    sudo sed -i 's/\/swap.img/#\/swap.img/' /etc/fstab
  else
    echo "No swap is currently enabled."
  fi
}

# Function to check Ubuntu version
check_ubuntu_version() {
  os_version=$(lsb_release -rs)
  if [ "$os_version" != "20.04" ] && [ "$os_version" != "22.04" ]; then
    echo "Error: Unsupported Ubuntu version. This script supports Ubuntu 20.04 and 22.04 only."
    exit 1
  fi
}

# Function to handle errors
handle_error() {
  echo "Error occurred at step $1. Exiting..."
  exit 1
}

# Function to check if namespace exists
check_namespace_not_exists() {
    local namespace="$1"
    if kubectl get namespace "$namespace" &> /dev/null; then
        echo "Namespace '$namespace' exists. Skipping steps..."
        return 0  # Namespace exists
    else
        echo "Namespace '$namespace' does not exist."
        return 1  # Namespace does not exist
    fi
}

# Check for sudo privilege
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Check Ubuntu version
echo "Checking Ubuntu version..."
check_ubuntu_version

# Check internet connection
check_internet

# Disable swap
disable_swap

export DEBIAN_FRONTEND=noninteractive
# Update package repository and install aptitude
echo "Updating package repository and installing aptitude..."
apt-get update || { echo "Failed to update package repository. Exiting..."; exit 1; }
apt-get -y install aptitude || { echo "Failed to install aptitude. Exiting..."; exit 1; }
aptitude update || { echo "Failed to update package repository using aptitude. Exiting..."; exit 1; }
aptitude -y safe-upgrade || { echo "Failed to perform safe-upgrade using aptitude. Exiting..."; exit 1; }


# Step 1: Check Python version
echo "==========================================================="
echo "Step 1: Checking Python version"
echo "==========================================================="
python_version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:3])))')
required_version="3.10"

if [ "$(printf '%s\n' "$python_version" "$required_version" | sort -V | head -n 1)" != "$required_version" ]; then
    echo "Python version is less than 3.10. Updating Python to version 3.10..."
    add-apt-repository ppa:deadsnakes/ppa -y
    apt-get update
    apt-get install -y python3.10 python3.10-venv python3.10-dev
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1
else
    echo "Python version is $python_version, which is greater than or equal to 3.10."
fi 

# Step 2: Check if pip3 is installed
echo "==========================================================="
echo "Step 2: Checking pip3 installation"
echo "==========================================================="

if command_exists pip3; then
    echo "pip3 is already installed."
else
    echo "pip3 is not installed. Installing pip3..."
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10
fi

# Reset DEBIAN_FRONTEND
unset DEBIAN_FRONTEND

# Step x: Edit /etc/sysctl.conf to add fs.inotify.max_user_watches and fs.inotify.max_user_instances
echo "==========================================================="
echo "Step 2.1: Editing /etc/sysctl.conf..."
echo "==========================================================="
sysctl fs.inotify.max_user_watches=524288
sysctl fs.inotify.max_user_instances=512

bash -c 'echo "fs.inotify.max_user_watches=524288" >> /etc/sysctl.conf'
bash -c 'echo "fs.inotify.max_user_instances=512" >> /etc/sysctl.conf'

# Step 2: Clone kubespray repository and edit k8s-cluster.yml
echo "==========================================================="
echo "Step 2: Cloning kubespray repository and editing k8s-cluster.yml"
echo "==========================================================="
git clone https://github.com/kubernetes-sigs/kubespray -b release-2.24 || handle_error 2
cd kubespray || handle_error 2.1
sed -i 's/node1/'"$host_name"'/g' ./inventory/local/hosts.ini || handle_error 2.2
sed -i 's/kube_network_plugin: calico/kube_network_plugin: flannel/' ./inventory/local/group_vars/k8s_cluster/k8s-cluster.yml || handle_error 2.3


# Additional edit in Step 2
echo "==========================================================="
echo "Step 2.2: Editing all.yml"
echo "==========================================================="
sed -i 's/#\ upstream_dns_servers/upstream_dns_servers/g' ./inventory/sample/group_vars/all/all.yml || handle_error 2.3
sed -i 's/#\ \ \ -\ 8.8.8.8/ \ \ - 8.8.8.8/g' ./inventory/sample/group_vars/all/all.yml || handle_error 2.4
sed -i 's/#\ \ \ -\ 8.8.4.4/ \ \ - 8.8.4.4/g' ./inventory/sample/group_vars/all/all.yml || handle_error 2.5

# Step 3: Install requirements
echo "==========================================================="
echo "Step 3: Installing requirements"
echo "==========================================================="
pip install -r requirements.txt || handle_error 3

# Step 4: Run ansible playbook to deploy Kubernetes cluster
echo "==========================================================="
echo "Step 4: Running ansible playbook"
echo "==========================================================="
ansible-playbook -i inventory/local/hosts.ini --become --become-user=root cluster.yml || handle_error 4

# Step 5: Configure kubeconfig
echo "==========================================================="
echo "Step 5: Configuring kubeconfig"
echo "==========================================================="
mkdir -p "$HOME"/.kube/config
cp /etc/kubernetes/admin.conf "$HOME"/.kube/config || handle_error 5

# Step 6: Clone dep repository
echo "==========================================================="
echo "Step 6: Cloning dep repository"
echo "==========================================================="
cd "$workspace" || handle_error 6.1
git clone https://gerrit.o-ran-sc.org/r/it/dep.git -b master --recursive || handle_error 6.2


# Step 7: Setup charts museum
echo "==========================================================="
echo "Step x: Replace oran-override.yaml"
echo "==========================================================="

cd dep || handle_error 7.1
patch_dir="$workspace/patch"
if [ -d "$patch_dir" ]; then
  cp "$patch_dir/oran-override.yaml" smo-install/helm-override/default/ || handle_error 13.1
else
  echo "Error: Patch directory not found. Make sure you have the patched files in the 'patch' directory."
  exit 1
fi

# Step 7: Setup charts museum
echo "==========================================================="
echo "Step 7: Setting up charts museum"
echo "==========================================================="
./smo-install/scripts/layer-0/0-setup-charts-museum.sh || handle_error 7

# Step 8: Setup Helm3
echo "==========================================================="
echo "Step 8: Setting up Helm3"
echo "==========================================================="
./smo-install/scripts/layer-0/0-setup-helm3.sh || handle_error 8

# Step 9: Build all charts
echo "==========================================================="
echo "Step 9: Building all charts"
echo "==========================================================="
./smo-install/scripts/layer-1/1-build-all-charts.sh || handle_error 9

# Step 10: Install ORAN
echo "==========================================================="
echo "Step 10: Installing ORAN"
echo "==========================================================="
./smo-install/scripts/layer-2/2-install-oran.sh || handle_error 10

# Step 11: Check pod status
echo "==========================================================="
echo "Step 11: Checking pod status"
echo "==========================================================="
echo "Pods in ONAP namespace:"
kubectl get pods -n onap
echo "Pods in nonrtric namespace:"
kubectl get pods -n nonrtric


# Step 6: Install RIC PLT
echo "==========================================================="
echo "Step 12: Installing RIC PLT..."
echo "==========================================================="
cd $workspace || handle_error 12.1
git clone "https://gerrit.o-ran-sc.org/r/ric-plt/ric-dep" || handle_error 12.2
cd ric-dep || handle_error 12.3
find -type f -print0 | xargs -0 sed -i 's\v1beta1\v1\g' || handle_error 12.4

# Step 7: Replace files with patched versions
echo "==========================================================="
echo "Step 13: Replacing files with patched versions..."
echo "==========================================================="
patch_dir="$workspace/patch"
if [ -d "$patch_dir" ]; then
  cp "$patch_dir/ingress-a1mediator.yaml" helm/a1mediator/templates/ || handle_error 13.1
  cp "$patch_dir/ingress-appmgr.yaml" helm/appmgr/templates/ || handle_error 13.2
  cp "$patch_dir/ingress-e2mgr.yaml" helm/e2mgr/templates/ || handle_error 13.3
else
  echo "Error: Patch directory not found. Make sure you have the patched files in the 'patch' directory."
  exit 1
fi

# Step 8: Replace occurrences of $ip in example_recipe_oran_i_release.yaml with the provided IP
echo "==========================================================="
echo "Step 14: Updating example_recipe_oran_i_release.yaml with provided IP..."
echo "==========================================================="
ip="$1"  # Assuming the IP address is passed as the first argument to the script
if [ -z "$ip" ]; then
  echo "Error: No IP address provided."
  exit 1
fi

echo "Provided IP address: $ip"

cd $workspace
# Replace existing ricip and auxip values with provided IP
sed -i "s/^ *ricip:.*$/  ricip: \"$ip\"/" ric-dep/RECIPE_EXAMPLE/example_recipe_oran_i_release.yaml || handle_error 14.1
sed -i "s/^ *auxip:.*$/  auxip: \"$ip\"/" ric-dep/RECIPE_EXAMPLE/example_recipe_oran_i_release.yaml || handle_error 14.2


export DEBIAN_FRONTEND=noninteractive

# Step 15: Install nfs-common
echo "==========================================================="
echo "Step 15: Install nfs-common..."
echo "==========================================================="
# Check if namespace 'ric-infra' exists
namespace="ricinfra"
if kubectl get namespace "$namespace" &> /dev/null; then
    echo "Namespace '$namespace' exists. Skipping steps..."
else
    kubectl create ns ricinfra  || handle_error 15.1
fi
helm repo add stable https://charts.helm.sh/stable   || handle_error 15.2
helm install nfs-release-1 stable/nfs-server-provisioner --namespace ricinfra    || handle_error 15.3
kubectl patch storageclass nfs -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'   || handle_error 15.4 
apt install -y nfs-common  || handle_error 15.5

# Reset DEBIAN_FRONTEND
unset DEBIAN_FRONTEND

echo "==========================================================="
echo "Step 16: Execute script to install O-RAN chart..."
echo "==========================================================="

cd $workspace/ric-dep
sed -i '/kong:/,/^[[:space:]]*[^[:space:]]/{s/^\([[:space:]]*enabled:[[:space:]]*\)true$/\1false/}' helm/infrastructure/values.yaml || handle_error 16.1
cd bin || handle_error 16.2
./install_common_templates_to_helm.sh || handle_error 16.2
./install -f  ../RECIPE_EXAMPLE/example_recipe_oran_i_release.yaml -c "jaegeradapter influxdb"  || handle_error 16.3

echo "==========================================================="
echo "Step 17: Execute script to install O-RAN chart..."
echo "==========================================================="
cd $workspace  || handle_error 17.1
helm repo add kong https://charts.konghq.com  || handle_error 17.2
helm repo update  || handle_error 17.3
helm install kong kong/kong -n ricplt -f patch/values.yaml  || handle_error 17.4
