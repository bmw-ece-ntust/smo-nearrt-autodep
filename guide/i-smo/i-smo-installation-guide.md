###### tags: `osc` `k8s` `infra` `ric`

[toc]

# <center> Installation Guide SMO+NonRT RIC Rel. I (Kubernetes 1.28) on Ubuntu 22.04 </center>

## Prerequisites
:::warning

1. Kubernetes 1.28 (tested using 1.28)
2. Helm 3.14

:::

## Deployment steps


### 1. Cloning dep repository IT/dep repository from gerrit
```bash=
# Latest version
cd ~
git clone https://gerrit.o-ran-sc.org/r/it/dep.git -b master --recursive
```

:::warning
:bulb: **Note:** You need to ==add the recurse sub modules flag== as some parts are git submodules pointing to existing related charts (ONAP)
:::

### 2. Edit oran-override.yaml

```bash=
cd dep
vi smo-install/helm-override/default/oran-override.yaml 
```

```
# smo-install/helm-override/default/oran-override.yaml 

# Copyright © 2017 Amdocs, Bell Canada
# Mofification Copyright © 2021 AT&T
# Modifcation Copyright (C) 2024 OpenInfra Foundation Europe. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#################################################################
# Global configuration overrides.
#
# These overrides will affect all helm charts (ie. applications)
# that are listed below and are 'enabled'.
#################################################################

##### ORAN #####

######### NONRTRIC #########

nonrtric:
  installPms: true
  installA1controller: false
  installA1simulator: false
  installControlpanel: true
  installInformationservice: true
  installRappcatalogueservice: true
  installNonrtricgateway: true
  installKong: false
  installORUApp: false
  installODUSMOApp: true
  installODUICSApp: true
  installTopology: true
  installDmaapadapterservice: true
  installDmaapmediatorservice: true
  installHelmmanager: true
  installrAppmanager: true
  installCapifcore: true
  # override default mount path root directory
  # referenced by persistent volumes and log files
  persistence:
    mountPath: /dockerdata-nfs
  volume1:
    # Set the size to 0 if you do not need the volume (if you are using Dynamic Volume Provisioning)
    size: 2Gi
    storageClassName: pms-storage
  volume2:
     # Set the size to 0 if you do not need the volume (if you are using Dynamic Volume Provisioning)
    size: 2Gi
    storageClassName: ics-storage
  volume3:
    size: 1Gi
    storageClassName: helmmanager-storage

common:
  releasePrefix: r3-dev-nonrtric
  ingressClassName: kong

informationservice:
  persistence:
    # Either refer to a volume created under the nonrtric by storageClassName. Then the claimed size should be the same.
    # The alternative use a dynamic volume provisioner in the cluster. Storage class can then be for instance 'standard' or 'gluster-fs' (depeneds on which classes that are available)
    size: 2Gi
    storageClassName: ics-storage
  ingress:
    enabled: true


# Need to check the external port Availability
policymanagementservice:
  persistence:
    # Either refer to a volume created under the nonrtric by storageClassName. Then the claimed size should be the same.
    # The alternative use a dynamic volume provisioner in the cluster. Storage class can then be fon instance 'standard' or 'gluster-fs' (depeneds on which classes that are available)
    size: 2Gi
    storageClassName: pms-storage
  ingress:
    enabled: true

kong:
  ingressController:
    installCRDs: false
  admin:
    enabled: true

helmmanager:
  persistence:
    # Either refer to a volume created under the nonrtric by storageClassName. Then the claimed si>
    # The alternative use a dynamic volume provisioner in the cluster. Storage class can then be f>
    storageClassName: helmmanager-storage

controlpanel:
  ingress:
    enabled: false

oru-app:
  simulators:
    - simRu: o-ru-11221
      simDu: o-du-1122
    - simRu: o-ru-11222
      simDu: o-du-1122
    - simRu: o-ru-11223
      simDu: o-du-1122
    - simRu: o-ru-11211
      simDu: o-du-1121

a1simulator:
  a1Sims:
    - name: a1-sim-osc-0
      a1Version: OSC_2.1.0
      allowHttp: true
    - name: a1-sim-osc-1
      a1Version: OSC_2.1.0
      allowHttp: true
    - name: a1-sim-std-0
      a1Version: STD_1.1.3
      allowHttp: true
    - name: a1-sim-std-1
      a1Version: STD_1.1.3
      allowHttp: true
    - name: a1-sim-std2-0
      a1Version: STD_2.0.0
      allowHttp: true
    - name: a1-sim-std2-1
      a1Version: STD_2.0.0
      allowHttp: true


######### RIC_AUX #########
dashboard:
  cipher:
    enc:
      key: AGLDdG4D04BKm2IxIWEr8o==
  portalapi:
    security: false
    appname: RIC-Dashboard
    username: Default
    password: password
    ecomp_redirect_url: https://portal.api.simpledemo.onap.org:30225/ONAPPORTAL/login.htm
    ecomp_rest_url: http://portal-app:8989/ONAPPORTAL/auxapi
    ueb_app_key: uebkey
  # instances are passed as string and reformatted into YAML
  ricinstances: |
    regions:
      -
        name: Region PIZ-R4
        instances:
          -
            key: i1
            name: RIC
            appUrlPrefix: http://ric-entry
            caasUrlPrefix: http://caas-ingress-is-REC-only
            pltUrlPrefix: http://ric-entry


```


### 3. Setup Helm Charts
- Execute the following commands ==being logged as root==:
```bash=
##Setup ChartMuseum
./smo-install/scripts/layer-0/0-setup-charts-museum.sh

##Setup HELM3
./smo-install/scripts/layer-0/0-setup-helm3.sh

## Build ONAP/ORAN charts
./smo-install/scripts/layer-1/1-build-all-charts.sh
```

### 4. Deploy components
- Execute the following commands ==being logged as root==:
```bash=
./smo-install/scripts/layer-2/2-install-oran.sh
```

### 5. Checking pod deployment status
```bash=
echo "Pods in ONAP namespace:"
kubectl get pods -n onap
echo "Pods in nonrtric namespace:"
kubectl get pods -n nonrtric
```