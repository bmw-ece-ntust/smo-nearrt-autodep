# SMO Installation Troubleshooting

## General Information

* **Date:** Apr 30, 2025
* **SMO Version:** 
    - K rel - [Commit: dfcfdbc9b540b3e6d401b8c09379e5a8b6267848](https://gerrit.o-ran-sc.org/r/gitweb?p=it/dep.git;a=commit;h=dfcfdbc9b540b3e6d401b8c09379e5a8b6267848)
* **Installation Environment:** 
    - Kubernetes 1.32.4
    - Docker v.24
* **Hardware Requirements:**
    - vCPU 8
    - Memory 24GB
    - Storage 250GB

## Problem Details
### 1.  **Some error output during installation**
*  Description 
    *  There are errors encountered during SMO installation using script execution. They are about permission and script bug. But they dont affect the installation outcome. 
* Expected Outcome 
    * No Error
* Steps to reproduce
    * Follow [Installation Guide - Dev Mode Installation](https://gerrit.o-ran-sc.org/r/gitweb?p=it/dep.git;a=blob;f=smo-install/README.md;h=5db20e2460a8bc101d6cabc8f83d9dd83858c547;hb=HEAD)
    * Modify dep/smo-install/helm-override/default/oran-override.yaml
    ````
    # Copyright © 2017 Amdocs, Bell Canada
    # Mofification Copyright © 2021 AT&T
    # Modifcation Copyright (C) 2024-2025 OpenInfra Foundation Europe. All rights reserved.
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
      installControlpanel: false
      installInformationservice: true
      installNonrtricgateway: true
      installKong: true
      installTopology: true
      installDmaapadapterservice: true
      installDmeparticipant: true
      installrAppmanager: true
      installCapifcore: true
      installServicemanager: true
      installRanpm: true
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
      # List of secrets to be copied from ONAP namespace to NONRTRIC
      # Based on the dependsOn value, the secrets will be copied to the SMO namespace
      secrets:
        - name: dmeparticipant-ku
          dependsOn: nonrtric.installDmeparticipant

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
      kongpv:
        # This enables/disables the PV creation for kong
        # PV creation is necessary when there is no default storage class
        # This should be set to false when there is a default storage class, Which lets the PVC provisions the PV dynamically.
        enabled: true

    controlpanel:
      ingress:
        enabled: false

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



    ######### SMO #########
    smo:
      installTeiv: true
      # List of secrets to be copied from ONAP namespace to SMO
      # Based on the dependsOn value, the secrets will be copied to the SMO namespace
      secrets:
        - name: topology-exposure-ku
          dependsOn: smo.installTeiv
        - name: topology-ingestion-ku
          dependsOn: smo.installTeiv
        - name: redpanda-console-ku
          dependsOn: nonrtric.installRanpm
    ```

- Installing ORAN NONRTRIC part
```
Error: open ../../helm-override/default/oran-override.yaml: permission denied
../sub-scripts/install-nonrtric.sh: line 100: [: : integer expression expected
````

- Installing ORAN SMO part

```
namespace/smo created
Installing SMO in release mode
Error: INSTALLATION FAILED: failed pre-install: 1 error occurred:
	* timed out waiting for the condition


Error: open ../../helm-override/default/oran-override.yaml: permission denied
../sub-scripts/install-smo.sh: line 61: [: : integer expression expected
```
- Complete logs
````
Pre configuring SMO ...
Error from server (AlreadyExists): namespaces "mariadb-operator" already exists
"mariadb-operator" already exists with the same configuration, skipping
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "local" chart repository
...Successfully got an update from the "strimzi" chart repository
...Successfully got an update from the "mariadb-operator" chart repository
...Successfully got an update from the "onap" chart repository
Update Complete. ⎈Happy Helming!⎈
Error: INSTALLATION FAILED: cannot re-use a name that is still in use
Error: INSTALLATION FAILED: cannot re-use a name that is still in use
deployment.apps/mariadb-operator condition met
persistentvolume/mariadb-galera-pv unchanged
SMO pre configuration done.
Starting ONAP & NONRTRIC namespaces ...
### Installing Strimzi Kafka Operator (Release Mode) ###
"strimzi" already exists with the same configuration, skipping
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "local" chart repository
...Successfully got an update from the "strimzi" chart repository
...Successfully got an update from the "mariadb-operator" chart repository
...Successfully got an update from the "onap" chart repository
Update Complete. ⎈Happy Helming!⎈
Error: INSTALLATION FAILED: cannot re-use a name that is still in use
Waiting for Strimzi Kafka Operator to be ready...
deployment.apps/strimzi-cluster-operator condition met
### Installing ONAP part (Release Mode) ###
"onap" already exists with the same configuration, skipping
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "local" chart repository
...Successfully got an update from the "strimzi" chart repository
...Successfully got an update from the "mariadb-operator" chart repository
...Successfully got an update from the "onap" chart repository
Update Complete. ⎈Happy Helming!⎈
v3.12.3
Use cache dir: /root/.local/share/helm/plugins/deploy/cache
0
0
0
0
fetching onap/onap
history.go:56: [debug] getting history for release onap
install.go:200: [debug] Original chart version: ""
install.go:217: [debug] CHART PATH: /root/.local/share/helm/plugins/deploy/cache/onap

release "onap" deployed
release "onap-roles-wrapper" deployed
release "onap-repository-wrapper" deployed
release "onap-strimzi" deployed
waiting for onap-strimzi-entity-operator to be deployed
onap-strimzi-entity-operator not found. Retry 1/60
onap-strimzi-entity-operator not found. Retry 2/60
onap-strimzi-entity-operator not found. Retry 3/60
onap-strimzi-entity-operator not found. Retry 4/60
onap-strimzi-entity-operator not found. Retry 5/60
onap-strimzi-entity-operator not found. Retry 6/60
onap-strimzi-entity-operator not found. Retry 7/60
onap-strimzi-entity-operator not found. Retry 8/60
onap-strimzi-entity-operator not found. Retry 9/60
onap-strimzi-entity-operator not found. Retry 10/60
onap-strimzi-entity-operator not found. Retry 11/60
onap-strimzi-entity-operator not found. Retry 12/60
onap-strimzi-entity-operator not found. Retry 13/60
onap-strimzi-entity-operator not found. Retry 14/60
onap-strimzi-entity-operator not found. Retry 15/60
onap-strimzi-entity-operator not found. Retry 16/60
onap-strimzi-entity-operator found. Waiting for pod intialisation
release "onap-strimzi" deployed
release "onap-mariadb-galera" deployed
release "onap-postgres" deployed
release "onap-cps" deployed
release "onap-dcaegen2-services" deployed
release "onap-policy" deployed
release "onap-repository-wrapper" deployed
release "onap-roles-wrapper" deployed
release "onap-sdnc" deployed
Error from server (AlreadyExists): namespaces "nonrtric" already exists
### Installing ORAN NONRTRIC part ###
Installing NONRTRIC in release mode
Error: INSTALLATION FAILED: cannot re-use a name that is still in use
Error: open ../../helm-override/default/oran-override.yaml: permission denied
../sub-scripts/install-nonrtric.sh: line 100: [: : integer expression expected
/home/ubuntu/dep/nonrtric/servicemanager-preload /home/ubuntu/dep/smo-install/scripts/layer-2
Preloading Service Manager from config-nonrtric.yaml
Waiting for capifcore deployment
Waiting for servicemanager deployment
Waiting for kong deployment
Find running services
Service Manager preload completed for config-nonrtric.yaml
Preloading Service Manager from config-smo.yaml
Waiting for capifcore deployment
Waiting for servicemanager deployment
Waiting for kong deployment
Find running services
Service Manager preload completed for config-smo.yaml
/home/ubuntu/dep/smo-install/scripts/layer-2
### Installing ORAN SMO part ###
namespace/smo created
Installing SMO in release mode
Error: INSTALLATION FAILED: failed pre-install: 1 error occurred:
	* timed out waiting for the condition


Error: open ../../helm-override/default/oran-override.yaml: permission denied
../sub-scripts/install-smo.sh: line 61: [: : integer expression expected
NAME                                                READY   STATUS            RESTARTS   AGE
mariadb-galera-0                                    1/1     Running           0          9m17s
onap-cps-core-c86f49ccc-5sq6q                       1/1     Running           0          8m42s
onap-cps-postgres-init-config-job-kcz67             0/1     Completed         0          8m42s
onap-cps-temporal-5bb5654b67-vjcwf                  1/1     Running           0          8m42s
onap-cps-temporal-db-0                              1/1     Running           0          8m42s
onap-dcae-ves-collector-66f4dcb7d6-gr2n6            1/1     Running           0          8m38s
onap-ncmp-dmi-plugin-577c47d5f5-6rnfb               0/1     PodInitializing   0          8m42s
onap-nengdb-init-config-job-h9vz8                   0/1     PodInitializing   0          5m37s
onap-network-name-gen-86b7d85754-fxkc9              0/1     Init:0/1          0          5m37s
onap-policy-apex-pdp-5b44db6f4f-pz767               1/1     Running           0          7m6s
onap-policy-api-747965d889-jkj7f                    0/1     Init:1/4          0          7m5s
onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-nmwzs    1/1     Running           0          7m6s
onap-policy-clamp-ac-http-ppnt-65f55f8fb4-4g966     1/1     Running           0          7m5s
onap-policy-clamp-ac-k8s-ppnt-6f96fc449-zzdl9       1/1     Running           0          7m5s
onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-rsc66   1/1     Running           0          7m6s
onap-policy-clamp-ac-pf-ppnt-556bc4c5b9-qss87       1/1     Running           0          7m5s
onap-policy-clamp-runtime-acm-57d4c7bd9c-dvqpl      0/1     Init:0/2          0          7m6s
onap-policy-opa-pdp-5ddb5d7b5-b5qrv                 0/1     Init:0/1          0          7m5s
onap-policy-pap-6f94d8b78b-4lkb7                    0/1     Init:0/2          0          7m5s
onap-policy-postgres-primary-7989878f4b-7c5xl       1/1     Running           0          7m6s
onap-policy-postgres-replica-7496d54d7b-h8h2w       1/1     Running           0          7m5s
onap-postgres-primary-5d6c89896d-clht7              1/1     Running           0          9m14s
onap-postgres-replica-5488bb7f5d-tdsgt              1/1     Running           0          9m14s
onap-sdnc-0                                         0/1     Init:1/3          0          5m37s
onap-sdnc-ansible-server-5f7dcbc96c-pb7t9           0/1     Init:1/2          0          5m37s
onap-sdnc-dbinit-job-cqmkl                          0/1     PodInitializing   0          5m37s
onap-sdnc-dgbuilder-b5b498d75-976zx                 0/1     PodInitializing   0          5m37s
onap-sdnc-sdnrdb-init-job-vdh2g                     0/1     Init:0/1          0          5m37s
onap-sdnc-web-79b7874bd6-zx92v                      0/1     Init:0/1          0          5m37s
onap-sdnrdb-coordinating-only-84b5c88677-ccm45      0/2     Init:1/3          0          5m37s
onap-sdnrdb-master-0                                0/1     Init:1/2          0          5m37s
onap-strimzi-entity-operator-7df978c897-z9rwf       2/2     Running           0          9m41s
onap-strimzi-kafka-0                                1/1     Running           0          10m
onap-strimzi-zookeeper-0                            1/1     Running           0          12m
No resources found in nonrtric namespace.
NAME                              READY   STATUS              RESTARTS   AGE
keycloak-7db5c4dc7b-kr4lx         0/1     ContainerCreating   0          5m5s
keycloak-init-hr488               0/1     ContainerCreating   0          5m4s
keycloak-proxy-6c654c4bdc-dw6wz   0/1     ContainerCreating   0          5m5s
NAME               STATUS   AGE
default            Active   44m
kube-flannel       Active   40m
kube-node-lease    Active   44m
kube-public        Active   44m
kube-system        Active   44m
mariadb-operator   Active   33m
nonrtric           Active   30m
onap               Active   12m
smo                Active   5m22s
strimzi-system     Active   32m
`````

### 2. No TEIV installed
*  Description 
    *  TEIV is not installed eventhough its enabled in helm-override.yaml 
    ```
    NAMESPACE          NAME                                                READY   STATUS       RESTARTS       AGE
    kube-flannel       kube-flannel-ds-w74hm                               1/1     Running      0              150m
    kube-system        coredns-668d6bf9bc-44shv                            1/1     Running      1 (155m ago)   3h44m
    kube-system        coredns-668d6bf9bc-wjhsm                            1/1     Running      1 (155m ago)   3h44m
    kube-system        etcd-smolite                                        1/1     Running      2 (155m ago)   3h44m
    kube-system        kube-apiserver-smolite                              1/1     Running      2 (155m ago)   3h44m
    kube-system        kube-controller-manager-smolite                     1/1     Running      2 (155m ago)   3h44m
    kube-system        kube-proxy-89rkf                                    1/1     Running      1 (155m ago)   3h44m
    kube-system        kube-scheduler-smolite                              1/1     Running      2 (155m ago)   3h44m
    mariadb-operator   mariadb-operator-5d4cb9794b-qxws2                   1/1     Running      1 (155m ago)   3h33m
    mariadb-operator   mariadb-operator-cert-controller-b979df4db-gqg2n    1/1     Running      1 (155m ago)   3h33m
    mariadb-operator   mariadb-operator-webhook-cd9c7fffb-98s8l            1/1     Running      1 (155m ago)   3h33m
    onap               mariadb-galera-0                                    1/1     Running      1              3h9m
    onap               onap-cps-core-c86f49ccc-5sq6q                       1/1     Running      1 (155m ago)   3h8m
    onap               onap-cps-postgres-init-config-job-kcz67             0/1     Completed    0              3h8m
    onap               onap-cps-temporal-5bb5654b67-vjcwf                  1/1     Running      3 (146m ago)   3h8m
    onap               onap-cps-temporal-db-0                              1/1     Running      1 (155m ago)   3h8m
    onap               onap-dcae-ves-collector-66f4dcb7d6-gr2n6            1/1     Running      3 (147m ago)   3h8m
    onap               onap-ncmp-dmi-plugin-577c47d5f5-6rnfb               1/1     Running      4 (140m ago)   3h8m
    onap               onap-nengdb-init-config-job-h9vz8                   0/1     Completed    0              3h5m
    onap               onap-network-name-gen-86b7d85754-fxkc9              1/1     Running      1 (155m ago)   3h5m
    onap               onap-policy-apex-pdp-5b44db6f4f-pz767               1/1     Running      3 (147m ago)   3h7m
    onap               onap-policy-api-747965d889-jkj7f                    1/1     Running      1 (155m ago)   3h7m
    onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-nmwzs    1/1     Running      6 (139m ago)   3h7m
    onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-4g966     1/1     Running      6 (139m ago)   3h7m
    onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-zzdl9       1/1     Running      6 (139m ago)   3h7m
    onap               onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-rsc66   1/1     Running      6 (139m ago)   3h7m
    onap               onap-policy-clamp-ac-pf-ppnt-556bc4c5b9-qss87       1/1     Running      6 (139m ago)   3h7m
    onap               onap-policy-clamp-runtime-acm-57d4c7bd9c-dvqpl      1/1     Running      2 (142m ago)   3h7m
    onap               onap-policy-opa-pdp-5ddb5d7b5-b5qrv                 1/1     Running      0              3h7m
    onap               onap-policy-pap-6f94d8b78b-4lkb7                    1/1     Running      3 (141m ago)   3h7m
    onap               onap-policy-postgres-primary-7989878f4b-7c5xl       1/1     Running      1 (155m ago)   3h7m
    onap               onap-policy-postgres-replica-7496d54d7b-h8h2w       1/1     Running      1 (155m ago)   3h7m
    onap               onap-postgres-primary-5d6c89896d-clht7              1/1     Running      1 (155m ago)   3h9m
    onap               onap-postgres-replica-5488bb7f5d-tdsgt              1/1     Running      1              3h9m
    onap               onap-sdnc-0                                         1/1     Running      1              3h5m
    onap               onap-sdnc-ansible-server-5f7dcbc96c-pb7t9           1/1     Running      0              3h5m
    onap               onap-sdnc-dbinit-job-cqmkl                          0/1     Completed    0              3h5m
    onap               onap-sdnc-dgbuilder-b5b498d75-976zx                 1/1     Running      1 (155m ago)   3h5m
    onap               onap-sdnc-sdnrdb-init-job-8hrp5                     0/1     Completed    0              175m
    onap               onap-sdnc-sdnrdb-init-job-vdh2g                     0/1     Init:Error   0              3h5m
    onap               onap-sdnc-web-79b7874bd6-zx92v                      1/1     Running      0              3h5m
    onap               onap-sdnrdb-coordinating-only-84b5c88677-ccm45      2/2     Running      7 (146m ago)   3h5m
    onap               onap-sdnrdb-master-0                                1/1     Running      6 (146m ago)   172m
    onap               onap-strimzi-entity-operator-7df978c897-z9rwf       2/2     Running      8 (147m ago)   3h9m
    onap               onap-strimzi-kafka-0                                1/1     Running      1 (155m ago)   3h10m
    onap               onap-strimzi-zookeeper-0                            1/1     Running      2 (148m ago)   3h12m
    smo                keycloak-7db5c4dc7b-kr4lx                           1/1     Running      1 (155m ago)   3h5m
    smo                keycloak-init-hr488                                 0/1     Completed    0              3h5m
    smo                keycloak-proxy-6c654c4bdc-dw6wz                     1/1     Running      3 (149m ago)   3h5m
    strimzi-system     strimzi-cluster-operator-686599c45d-p7ks8           1/1     Running      2 (147m ago)   3h32m
    ```
* Expected Outcome 
    * Has TEIV components installed and pods show within K8S cluster.
* Steps to reproduce.
    * Same as [here](#1-Some-error-output-during-installation)

### 3. Evicted Pod for 

```
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.857+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.858+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.858+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.859+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.859+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.860+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.860+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.861+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.861+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.862+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.862+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.862+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.862+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.863+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.863+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.864+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.864+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.864+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.864+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.865+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.865+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.866+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.866+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.866+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.866+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.867+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.867+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.868+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.868+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.869+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.869+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.870+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.870+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.873+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.873+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.877+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.877+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.878+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.878+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.879+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.879+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.879+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.879+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.880+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.880+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.881+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.881+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.883+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.883+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.884+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.884+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.884+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.884+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.887+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.887+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.890+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.890+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.890+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.890+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.891+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.891+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.891+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.891+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.893+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.893+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.894+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.895+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.896+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.896+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.897+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.897+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.897+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.897+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.898+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.898+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.899+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.899+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.900+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.900+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.900+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.900+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.901+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.901+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.903+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.904+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.905+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.905+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.905+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.905+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.906+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.906+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.906+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.906+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.908+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.908+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.909+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.910+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.911+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.911+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.911+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.912+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.912+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.912+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.913+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.913+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.915+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.915+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.916+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.916+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.919+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.919+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.920+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.921+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.921+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.921+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.922+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.922+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.923+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator request hit fatal exception
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.923+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=cb06db04-42bf-4859-bb6b-15e309620561, consumerInstance=onap-policy-clamp-ac-k8s-ppnt-6f96fc449-n46n5, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: cb06db04-42bf-4859-bb6b-15e309620561
[2025-05-01T02:00:08.924+00:00|INFO|ConsumerCoordinator|KAFKA-source-acm-ppnt-sync] [Consumer clientId=consumer-cb06db04-42bf-4859-bb6b-15e309620561-3, groupId=cb06db04-42bf-4859-bb6b-15e309620561] FindCoordinator reques
```
## Environment Details

* Operating System: Ubuntu 22.04
* Kernel Version: `5.15.0-138-generic`
* Kubernetes Version (if applicable): 
    * `Client Version: v1.32.3`
    * `Kustomize Version: v5.5.0`
    * `Server Version: v1.32.4`
* Helm Version (if applicable): `v3.12.3`
* Network Configuration: CNI Flannel

## Resolution

N/A

