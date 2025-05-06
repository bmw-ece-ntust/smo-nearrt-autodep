# smo-nearrt-autodep

These scripts will deploy Kuberenetes vanilla, ~~Near-RT RIC~~, SMO functions: Non-RT RIC and OAM components with default settings. 

## Minimum Requirements
- OS: Ubuntu 22.04 or above
- vCPU: 8
- Memory: 40GB
- Storage: 100GB

## Installation

This script is not stable since its still ongoing development. Not for production. 
They should work on fresh OS installation with no existing kubernetes. The script deploys kubernetes with configuration optimized for O-RAN SMO functionality. 


### Work directory
Please make sure you use `root` user with superuser permission. 

### Kubernetes deployment

````
install_k8s.sh
````
After execute this script, you will asked to provide your VM/Baremetal IP. 

After installation finished, check if `kubectl` command works using `kubectl get node`

### SMO deployment
````
install_nonrtric.sh
````

After installation finished, wait until all pods status are running/complete.