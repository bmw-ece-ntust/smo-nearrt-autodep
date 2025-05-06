# SMO Integration - AIMLFW Installation

## General Information

* **Date:** May 6, 2025
* **AIMLFW Version:** 
    - K rel - [Tag: k-release](https://gerrit.o-ran-sc.org/r/gitweb?p=aiml-fw/aimlfw-dep.git;a=shortlog;h=refs/heads/k-release)
## Environment Details

* Operating System: Ubuntu 22.04
* Kernel Version: `5.15.0-138-generic`
* Kubernetes Version (if applicable): 
    * `Client Version: v1.32.3`
    * `Kustomize Version: v5.5.0`
    * `Server Version: v1.32.4`
* Helm Version (if applicable): `v3.12.3`
* Network Configuration: CNI Flannel

## Hardware Specification
* vCPU 32
* Memory 128GB
* Storage 1TB
  
## Problem Details
###  Incompatible with existing kubernetes cluster 
#### Description
Installation script will install kubernetes vanilla. Therefore this cannot be used to install on existing kubernetes cluster.

At least 2 components that are conflicted: **kubernetes cluster** and **chartmuseum**.

````
root@smolite-k:/home/ubuntu/aimlfw-dep# bin/install_traininghost.sh
Hit:1 http://tw.archive.ubuntu.com/ubuntu noble InRelease
Hit:2 http://tw.archive.ubuntu.com/ubuntu noble-updates InRelease                 
Hit:3 http://tw.archive.ubuntu.com/ubuntu noble-backports InRelease               
Hit:4 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.28/deb  InRelease
Get:5 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]
Get:6 http://security.ubuntu.com/ubuntu noble-security/main amd64 Packages [815 kB]
Get:7 http://security.ubuntu.com/ubuntu noble-security/main Translation-en [152 kB]
Get:8 http://security.ubuntu.com/ubuntu noble-security/universe amd64 Packages [836 kB]
Get:9 http://security.ubuntu.com/ubuntu noble-security/universe Translation-en [182 kB]
Fetched 2111 kB in 11s (197 kB/s)      
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
64 packages can be upgraded. Run 'apt list --upgradable' to see them.
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
nfs-kernel-server is already the newest version (1:2.6.4-3ubuntu5.1).
0 upgraded, 0 newly installed, 0 to remove and 64 not upgraded.
Configuring NFS server complete
"nfs-subdir-external-provisioner" has been added to your repositories
NAME: nfs-subdir-external-provisioner
LAST DEPLOYED: Tue May  6 08:23:37 2025
NAMESPACE: traininghost
STATUS: deployed
REVISION: 1
TEST SUITE: None
Installing servecm (Chart Manager) and common templates to helm3
Installed plugin: servecm
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 15.0M  100 15.0M    0     0  46.2M      0 --:--:-- --:--:-- --:--:-- 46.1M
linux-386/
linux-386/chartmuseum
linux-386/LICENSE
linux-386/README.md
cp: cannot create regular file '/usr/local/bin/chartmuseum': Text file busy
/root/.cache/helm/repository
servecm not yet running. sleeping for 2 seconds
2025-05-06T08:23:40.484Z	INFO	Starting ChartMuseum	{"host": "0.0.0.0", "port": 8879}
2025-05-06T08:23:42.402Z	INFO	[1] Request served	{"path": "/charts", "comment": "", "clientIP": "127.0.0.1", "method": "GET", "statusCode": 200, "latency": "80.353µs", "reqID": "a5db3ea1-6d84-4ee4-9dac-aea30e1bf1b2"}
servcm up and running
/root/.cache/helm/repository
Successfully packaged chart and saved it to: /tmp/aimlfw-common-1.0.0.tgz
"local" has been removed from your repositories
2025-05-06T08:23:42.578Z	INFO	[2] Request served	{"path": "/charts/index.yaml", "comment": "", "clientIP": "127.0.0.1", "method": "GET", "statusCode": 200, "latency": "1.72125ms", "reqID": "fb709bb7-0090-432f-bfa7-7f8b977309bb"}
"local" has been added to your repositories
checking that aimlfw-common templates were added
NAME               	CHART VERSION	APP VERSION	DESCRIPTION                                   
local/aimlfw-common	1.0.0        	           	Common templates for inclusion in other charts
sudo: buildctl: command not found
sudo: nerdctl: command not found
namespace/kubeflow created
secret/leofs-secret created
sudo: buildctl: command not found
sudo: nerdctl: command not found
Hang tight while we grab the latest from your chart repositories...
2025-05-06T08:23:55.488Z	INFO	[3] Request served	{"path": "/charts/index.yaml", "comment": "", "clientIP": "127.0.0.1", "method": "GET", "statusCode": 200, "latency": "99.367µs", "reqID": "3c949790-a64e-4d81-aa42-2277c034581b"}
...Successfully got an update from the "local" chart repository
...Successfully got an update from the "nfs-subdir-external-provisioner" chart repository
...Successfully got an update from the "strimzi" chart repository
...Successfully got an update from the "mariadb-operator" chart repository
...Successfully got an update from the "onap" chart repository
...Successfully got an update from the "bitnami" chart repository
Update Complete. ⎈Happy Helming!⎈
Saving 1 charts
Downloading aimlfw-common from repo http://127.0.0.1:8879/charts
2025-05-06T08:24:03.854Z	INFO	[4] Request served	{"path": "/charts/charts/aimlfw-common-1.0.0.tgz", "comment": "", "clientIP": "127.0.0.1", "method": "GET", "statusCode": 200, "latency": "374.67µs", "reqID": "1e86b812-f3d6-484e-917a-1dee8b85f38f"}
Deleting outdated charts
Error: INSTALLATION FAILED: 1 error occurred:
	* Service "leofs" is invalid: spec.ports[0].nodePort: Invalid value: 32080: provided port is already allocated


waiting for leofs pod
````

#### Expected Outcome 
Installation script should independent with kubernetes deployment. 

#### Steps to reproduce
- Follow [Installation Guide](https://docs.o-ran-sc.org/projects/o-ran-sc-aiml-fw-aimlfw-dep/en/latest/installation-guide.html#software-installation-and-deployment)
- ctrl-c to stop the installation (due to error).
- Check the script log

## Resolution
- Separate the deployment of AIMLFW with kubernetes