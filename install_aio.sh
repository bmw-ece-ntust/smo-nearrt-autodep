#!/bin/bash

# Capture start time
start_time=$(date +%s)

workspace=$(pwd)

# Check for sudo privilege
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

host_name="smo-nearrt-i"
read -p "Enter option (1.SMO Only; 2. NearRT Only; 3. SMO+NearRT ): " option
if ! [[ $option =~ ^-?[0-9]+$ ]]; then
    echo "Error: Argument is not an integer."
    echo "Usage: $0 <integer>"
    exit 1
fi

read -p "Enter IP address: " ip

KUBEVERSION="1.28.10-1.1"
HELMVERSION="3.14.2"


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
swapon --show > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    swapoff -a
    rm /swapfile
    sed -i 's/\/swap.img/#\/swap.img/' /etc/fstab
  else
    echo "No swap is currently enabled."
  fi
}

# Function to check Ubuntu version
check_ubuntu_version() {
  os_version=$(lsb_release -rs)
  if [ "$os_version" != "20.04" ] && [ "$os_version" != "22.04" ] && [ "$os_version" != "24.04" ]; then
    echo "Error: Unsupported Ubuntu version. This script supports Ubuntu 20.04 , 22.04 and 24.04 only."
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


# Check Ubuntu version
echo "Checking Ubuntu version..."
check_ubuntu_version

# Check internet connection
check_internet

# # Disable swap
# disable_swap

# # Script for Installing Docker,Kubernetes and Helm

wait_for_pods_running () {
  NS="$2"
  CMD="kubectl get pods --all-namespaces "
  if [ "$NS" != "all-namespaces" ]; then
    CMD="kubectl get pods -n $2 "
  fi
  KEYWORD="Running"
  if [ "$#" == "3" ]; then
    KEYWORD="${3}.*Running"
  fi

  CMD2="$CMD | grep \"$KEYWORD\" | wc -l"
  NUMPODS=$(eval "$CMD2")
  echo "waiting for $NUMPODS/$1 pods running in namespace [$NS] with keyword [$KEYWORD]"
  while [  $NUMPODS -lt $1 ]; do
    sleep 5
    NUMPODS=$(eval "$CMD2")
    echo "> waiting for $NUMPODS/$1 pods running in namespace [$NS] with keyword [$KEYWORD]"
  done
}

option_1() {
# Uninstalling existing Docker, Kubernetes
echo "Uninstalling Docker,Kubernetes"
kubeadm reset -f
apt-get -y remove docker.io 
 apt-get -y purge kubeadm kubectl kubelet kubernetes-cni kube* docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
 apt-get -y autoremove
 rm -rf ~/.kube
apt-get -y autoremove

rm -rf /var/lib/docker
rm -rf /var/lib/containerd
rm -rf /etc/containerd

# # Installing Docker
echo "****************************************************************************************************************"
echo "						Installing CRI						"
echo "****************************************************************************************************************"
# apt-get install -y --allow-downgrades --allow-change-held-packages --allow-unauthenticated --ignore-hold docker.io=${DOCKERVERSION}
# cat > /etc/docker/daemon.json <<EOF
# {
#   "exec-opts": ["native.cgroupdriver=systemd"],
#   "log-driver": "json-file",
#   "log-opts": {
#     "max-size": "100m"
#   },
#   "storage-driver": "overlay2"
# }
# EOF
# mkdir -p /etc/systemd/system/docker.service.d
# systemctl enable docker.service
# systemctl daemon-reload
# systemctl restart docker

# Installing containerd
    modprobe overlay
    modprobe br_netfilter

cat <<EOF |  tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

cat <<EOF |  tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Add Docker's official GPG key:
 apt-get update
 apt-get install ca-certificates curl
 install -m 0755 -d /etc/apt/keyrings
 curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
 chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
   tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update

    sysctl --system
    apt-get update 
    apt-get install -y docker-ce docker-ce-cli containerd.io 
    mkdir -p /etc/containerd
    containerd config default |  tee /etc/containerd/config.toml
    sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
    systemctl restart containerd

    # Helm Installation
    echo "****************************************************************************************************************"
    echo "						Installing Helm							"
    echo "****************************************************************************************************************"
    wget https://get.helm.sh/helm-v${HELMVERSION}-linux-amd64.tar.gz
    tar -xvf helm-v${HELMVERSION}-linux-amd64.tar.gz
    mv linux-amd64/helm /usr/local/bin/helm
    helm version
    rm  helm-v${HELMVERSION}-linux-amd64.tar.gz


    # Installing Kubernetes Packages
    echo "***************************************************************************************************************"
    echo "						Installing Kubernetes						"
    echo "***************************************************************************************************************"

    rm /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key |  gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg 
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' |  tee /etc/apt/sources.list.d/kubernetes.list 
    apt update



# Installing Kubectl, Kubeadm and kubelet

apt install -y kubeadm=${KUBEVERSION} kubelet=${KUBEVERSION} kubectl=${KUBEVERSION}
kubeadm init --apiserver-advertise-address=${ip} --pod-network-cidr=10.244.0.0/16 --v=5

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl taint nodes --all node.kubernetes.io/not-ready-

kubectl get pods -A
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

wait_for_pods_running 1 kube-flannel
wait_for_pods_running 7 kube-system

echo "***************************************************************************************************************"

kubectl get pods -A

echo "***************************************************************************************************************"




# Step x: Edit /etc/sysctl.conf to add fs.inotify.max_user_watches and fs.inotify.max_user_instances
echo "==========================================================="
echo "Step 2.1: Editing /etc/sysctl.conf..."
echo "==========================================================="
sysctl fs.inotify.max_user_watches=524288
sysctl fs.inotify.max_user_instances=512

bash -c 'echo "fs.inotify.max_user_watches=524288" >> /etc/sysctl.conf'
bash -c 'echo "fs.inotify.max_user_instances=512" >> /etc/sysctl.conf'

# Step 5: Configure kubeconfig
echo "==========================================================="
echo "Step 5: Configuring kubeconfig"
echo "==========================================================="
mkdir -p "$HOME"/.kube/config
cp /etc/kubernetes/admin.conf "$HOME"/.kube/config || handle_error 5
}

option_2(){
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

}

option_3(){

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
# Assuming the IP address is passed as the first argument to the script
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


}

option_4(){
echo "==========================================================="
echo "Step 17: Execute script to install O-RAN chart..."
echo "==========================================================="
cd $workspace  || handle_error 17.1
helm repo add kong https://charts.konghq.com  || handle_error 17.2
helm repo update  || handle_error 17.3
helm install kong kong/kong -n ricplt -f patch/values.yaml  || handle_error 17.4
}

case $option in
    1)
        option_1
        option_2
        option_4
        ;;
    2)
        option_1
        option_3
        option_4
        ;;
    3)
        option_1
        option_2
        option_3
        option_4
        ;;
    *)
        echo "Invalid option: $option"
        echo "Valid options are: 1, 2, 3"
        exit 1
        ;;
esac



end_time=$(date +%s)
elapsed=$(( end_time - start_time ))
minutes=$(( elapsed / 60 ))
seconds=$(( elapsed % 60 ))
echo "Installation time: ${minutes} minutes and ${seconds} seconds"