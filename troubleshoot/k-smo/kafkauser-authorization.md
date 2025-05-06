# SMO Installation Troubleshooting

## General Information

* **Date:** May 5, 2025
* **SMO Version:** 
    - K rel - [Commit: dfcfdbc9b540b3e6d401b8c09379e5a8b6267848](https://gerrit.o-ran-sc.org/r/gitweb?p=it/dep.git;a=commit;h=dfcfdbc9b540b3e6d401b8c09379e5a8b6267848)
  
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
###  High CPU and Memory Usage after installation
####  Description 

![image](/troubleshoot/k-smo/images/htop.png)
**Figure: htop shows high CPU and memory usage in VM after SMO installation**

This may caused by java applications that consume too much CPU. The reason is due to error on onap-policy-clamp pods for authorization groups for all of onap-policy-clamp pods.

##### Check pods status
````
NAMESPACE          NAME                                                READY   STATUS                   RESTARTS     AGE
kube-flannel       kube-flannel-ds-7sskj                               1/1     Running                  0            4d2h
kube-system        coredns-668d6bf9bc-kbhpb                            1/1     Running                  0            4d2h
kube-system        coredns-668d6bf9bc-p2t45                            1/1     Running                  0            4d2h
kube-system        etcd-smolite-k                                      1/1     Running                  0            4d2h
kube-system        kube-apiserver-smolite-k                            1/1     Running                  0            4d2h
kube-system        kube-controller-manager-smolite-k                   1/1     Running                  0            4d2h
kube-system        kube-proxy-lhq49                                    1/1     Running                  0            4d2h
kube-system        kube-scheduler-smolite-k                            1/1     Running                  0            4d2h
kube-system        metrics-server-756b6cdf4d-sqwd2                     1/1     Running                  0            3d19h
mariadb-operator   mariadb-operator-5d4cb9794b-mv8m4                   1/1     Running                  0            4d1h
mariadb-operator   mariadb-operator-cert-controller-b979df4db-lf7gz    1/1     Running                  0            4d1h
mariadb-operator   mariadb-operator-webhook-cd9c7fffb-8v8gn            1/1     Running                  0            4d1h
nonrtric           capifcore-ccbfbff56-2dvlh                           1/1     Running                  0            4d1h
nonrtric           controlpanel-56cf48cb74-gzplb                       1/1     Running                  0            4d1h
nonrtric           dmaapadapterservice-0                               1/1     Running                  0            4d1h
nonrtric           dmeparticipant-6556fc85d9-zxqvr                     1/1     Running                  0            4d1h
nonrtric           informationservice-0                                1/1     Running                  0            4d1h
nonrtric           nonrtricgateway-86d47b667c-h8w7b                    1/1     Running                  0            4d1h
nonrtric           oran-nonrtric-kong-7cdb469668-cdz7v                 2/2     Running                  0            4d1h
nonrtric           oran-nonrtric-kong-init-migrations-k7wtk            0/1     Completed                0            4d1h
nonrtric           oran-nonrtric-postgresql-0                          1/1     Running                  0            4d1h
nonrtric           policymanagementservice-0                           1/1     Running                  0            4d1h
nonrtric           rappmanager-0                                       1/1     Running                  0            4d1h
nonrtric           servicemanager-5ccb4b745-4vxmm                      1/1     Running                  0            4d1h
nonrtric           topology-78975dc7c7-xn6tq                           1/1     Running                  0            4d1h
onap               mariadb-galera-0                                    1/1     Running                  0            4d1h
onap               onap-cps-core-c86f49ccc-ddf97                       1/1     Running                  0            4d1h
onap               onap-cps-postgres-init-config-job-z2pg7             0/1     Completed                0            4d1h
onap               onap-cps-temporal-5bb5654b67-xbkf8                  1/1     Running                  0            4d1h
onap               onap-cps-temporal-db-0                              1/1     Running                  0            4d1h
onap               onap-dcae-ves-collector-66f4dcb7d6-96pwg            0/1     ContainerStatusUnknown   1            3d22h
onap               onap-dcae-ves-collector-66f4dcb7d6-nn9h9            0/1     Error                    0            4d1h
onap               onap-dcae-ves-collector-66f4dcb7d6-xtrlk            1/1     Running                  0            3d22h
onap               onap-ncmp-dmi-plugin-577c47d5f5-blt9t               1/1     Running                  0            4d1h
onap               onap-nengdb-init-config-job-pmfsq                   0/1     Completed                0            4d1h
onap               onap-network-name-gen-86b7d85754-cgwrr              1/1     Running                  0            4d1h
onap               onap-policy-apex-pdp-5b44db6f4f-slrv4               1/1     Running                  0            4d1h
onap               onap-policy-api-747965d889-6gggm                    1/1     Running                  0            4d1h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-2jqcc    0/1     Error                    0            2d1h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-56xtn    1/1     Running                  0            27h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-65c8z    0/1     Error                    0            4d1h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-6llkh    0/1     Error                    0            3d19h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-728hf    0/1     Error                    0            2d16h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-7rgqk    0/1     Error                    0            3d6h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-7z4v8    0/1     Error                    0            2d4h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-8fsc8    0/1     Error                    0            3d1h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-8jk8p    0/1     Error                    0            2d22h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-b2fcv    0/1     Error                    0            35h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-dtgj6    0/1     Error                    0            46h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-gr9nr    0/1     Error                    0            31h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-hmdsq    0/1     Error                    0            3d16h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-j9n8d    0/1     Error                    0            2d19h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-jtwhx    0/1     Error                    0            2d6h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-k42lz    0/1     Error                    0            41h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-kknpj    0/1     Error                    0            3d22h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-kr7fv    0/1     Error                    0            29h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-lmz7t    0/1     Error                    0            2d11h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-lxv8z    0/1     Error                    0            33h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-mxvxs    0/1     Error                    0            3d9h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-nwlwz    0/1     Error                    0            2d9h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-qfsjh    0/1     Error                    0            43h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-txshx    0/1     Error                    0            2d14h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-v7dhv    0/1     Error                    0            38h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-vkz95    0/1     Error                    0            3d13h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-wq2lt    0/1     Error                    0            3d11h
onap               onap-policy-clamp-ac-a1pms-ppnt-7f684486ff-wr6q8    0/1     Error                    0            3d3h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-22sxg     0/1     Error                    0            39h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-685jp     0/1     Error                    0            30h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-69jlb     0/1     Error                    0            32h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-6s4f6     1/1     Running                  0            28h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-757b8     0/1     Error                    0            42h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-7zbmb     0/1     Error                    0            2d4h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-7zdh7     0/1     Error                    0            2d7h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-89ch7     0/1     Error                    0            2d12h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-8xbl9     0/1     Error                    0            2d9h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-8zbl5     0/1     Error                    0            34h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-c59w2     0/1     Error                    0            36h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-c79md     0/1     Error                    0            2d2h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-czbzd     0/1     Error                    0            3d2h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-ddvzr     0/1     Error                    0            3d16h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-gs25f     0/1     Error                    0            3d13h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-hgrqd     0/1     Error                    0            3d4h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-js9xl     0/1     Error                    0            2d23h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-kfzln     0/1     Error                    0            2d17h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-klls5     0/1     Error                    0            3d22h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-lbdjv     0/1     Error                    0            3d7h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-lgsxx     0/1     Error                    0            47h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-mtp64     0/1     Error                    0            4d1h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-nxdrt     0/1     Error                    0            3d19h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-r674d     0/1     Error                    0            3d9h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-ss5kc     0/1     ContainerStatusUnknown   1            44h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-w5xgh     0/1     Error                    0            2d15h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-ww566     0/1     Error                    0            3d11h
onap               onap-policy-clamp-ac-http-ppnt-65f55f8fb4-wxtnz     0/1     Error                    0            2d20h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-2mgx7       0/1     Error                    0            2d14h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-568fs       0/1     Error                    0            3d22h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-5bp26       0/1     ContainerStatusUnknown   1            2d3h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-5p8bc       0/1     Error                    0            2d19h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-6jqc6       0/1     Error                    0            46h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-6mds4       0/1     Error                    0            33h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-7447v       0/1     Error                    0            2d1h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-7r6t7       0/1     Error                    0            4d1h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-84s6h       0/1     ContainerStatusUnknown   1            3d8h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-fpkt6       0/1     Error                    0            3d6h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-g97t8       0/1     Error                    0            43h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-hjrh8       0/1     Error                    0            3d16h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-hznrf       0/1     Error                    0            3d13h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-krxdm       0/1     Error                    0            2d9h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-l5ms4       0/1     Error                    0            37h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-mfsfx       0/1     Error                    0            35h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-nl64b       0/1     Error                    0            2d11h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-nqlz8       0/1     Error                    0            2d6h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-pjngn       0/1     ContainerStatusUnknown   1            3d11h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-pq6l4       0/1     Error                    0            3d19h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-qdsr6       0/1     Error                    0            3d1h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-rlkk4       0/1     Error                    0            31h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-s5ksp       0/1     Error                    0            3d3h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-sk62f       0/1     Error                    0            2d22h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-ss54w       1/1     Running                  0            29h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-x6g72       0/1     Error                    0            40h
onap               onap-policy-clamp-ac-k8s-ppnt-6f96fc449-x8hvb       0/1     Error                    0            2d16h
onap               onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-6mpdd   0/1     ContainerStatusUnknown   1            2d16h
onap               onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-84vlh   0/1     Error                    0            43h
onap               onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-99wlp   0/1     Error                    0            2d14h
onap               onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-bqspw   0/1     Error                    0            2d9h
onap               onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-csl4d   0/1     Error                    0            2d4h
onap               onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-d78rb   0/1     Error                    0            41h
onap               onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-dftkf   0/1     Error                    0            3d19h
onap               onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-dgt7k   0/1     Error                    0            3d22h
onap               onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-dpwtv   0/1     ContainerStatusUnknown   1            3d3h
onap               onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-h8lmb   0/1     Error                    0            2d22h
onap               onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-jh65m   0/1     Error                    0            3d1h
onap               onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-l5lbf   0/1     Error                    0            3d16h
onap               onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-ld74b   0/1     Error                    0            3d6h
onap               onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-ldw4t   1/1     Running                  0            35h
onap               onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-m8wbx   0/1     ContainerStatusUnknown   1            46h
onap               onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-p4fwn   0/1     Error                    0            2d6h
onap               onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-pmtsj   0/1     Error                    0            2d1h
onap               onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-qbsfq   0/1     ContainerStatusUnknown   1            3d11h
onap               onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-qpjsm   0/1     Error                    0            3d9h
onap               onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-slwqw   0/1     Error                    0            3d13h
onap               onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-t6sxs   0/1     Error                    0            2d11h
onap               onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-vgrlx   0/1     Error                    0            2d19h
onap               onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-z2pgz   0/1     Error                    0            38h
onap               onap-policy-clamp-ac-kserve-ppnt-7dc85f5c77-zpsqd   0/1     Error                    0            4d1h
onap               onap-policy-clamp-ac-pf-ppnt-556bc4c5b9-2t8tw       0/1     Error                    0            2d17h
onap               onap-policy-clamp-ac-pf-ppnt-556bc4c5b9-4gtw7       0/1     Error                    0            2d9h
onap               onap-policy-clamp-ac-pf-ppnt-556bc4c5b9-4kz2k       0/1     ContainerStatusUnknown   1            2d6h
onap               onap-policy-clamp-ac-pf-ppnt-556bc4c5b9-56l28       0/1     Error                    0            38h
onap               onap-policy-clamp-ac-pf-ppnt-556bc4c5b9-596dz       0/1     Error                    0            3d9h
onap               onap-policy-clamp-ac-pf-ppnt-556bc4c5b9-5dbxb       0/1     Error                    0            2d1h
onap               onap-policy-clamp-ac-pf-ppnt-556bc4c5b9-5w9lr       0/1     Error                    0            2d14h
onap               onap-policy-clamp-ac-pf-ppnt-556bc4c5b9-7mw7m       0/1     Error                    0            2d23h
onap               onap-policy-clamp-ac-pf-ppnt-556bc4c5b9-8d677       0/1     Error                    0            3d4h
onap               onap-policy-clamp-ac-pf-ppnt-556bc4c5b9-bvpt5       0/1     Error                    0            41h
onap               onap-policy-clamp-ac-pf-ppnt-556bc4c5b9-g8mdj       0/1     Error                    0            46h
onap               onap-policy-clamp-ac-pf-ppnt-556bc4c5b9-gpr8l       0/1     ContainerStatusUnknown   1            3d22h
onap               onap-policy-clamp-ac-pf-ppnt-556bc4c5b9-hnljv       0/1     Error                    0            3d13h
onap               onap-policy-clamp-ac-pf-ppnt-556bc4c5b9-j9xhs       0/1     Error                    0            3d16h
onap               onap-policy-clamp-ac-pf-ppnt-556bc4c5b9-l75hd       0/1     Error                    0            2d11h
onap               onap-policy-clamp-ac-pf-ppnt-556bc4c5b9-l8m87       0/1     Error                    0            3d2h
onap               onap-policy-clamp-ac-pf-ppnt-556bc4c5b9-m8d5c       0/1     Error                    0            43h
onap               onap-policy-clamp-ac-pf-ppnt-556bc4c5b9-mv5h2       0/1     Error                    0            2d4h
onap               onap-policy-clamp-ac-pf-ppnt-556bc4c5b9-qpsqm       0/1     Error                    0            3d11h
onap               onap-policy-clamp-ac-pf-ppnt-556bc4c5b9-sg89h       0/1     Error                    0            3d19h
onap               onap-policy-clamp-ac-pf-ppnt-556bc4c5b9-tncv7       0/1     Error                    0            2d20h
onap               onap-policy-clamp-ac-pf-ppnt-556bc4c5b9-vdcvn       0/1     Error                    0            4d1h
onap               onap-policy-clamp-ac-pf-ppnt-556bc4c5b9-wm9p4       0/1     Error                    0            3d7h
onap               onap-policy-clamp-ac-pf-ppnt-bfc679875-pjblm        1/1     Running                  0            24h
onap               onap-policy-clamp-runtime-acm-57d4c7bd9c-psdnl      1/1     Running                  0            4d1h
onap               onap-policy-opa-pdp-5ddb5d7b5-flbmj                 1/1     Running                  0            4d1h
onap               onap-policy-pap-6f94d8b78b-jgb8q                    1/1     Running                  0            4d1h
onap               onap-policy-postgres-primary-7989878f4b-rtnmk       1/1     Running                  0            4d1h
onap               onap-policy-postgres-replica-7496d54d7b-xmb52       1/1     Running                  0            4d1h
onap               onap-postgres-primary-5d6c89896d-cgrkq              1/1     Running                  0            4d1h
onap               onap-postgres-replica-5488bb7f5d-mmrqn              1/1     Running                  0            4d1h
onap               onap-sdnc-0                                         1/1     Running                  0            4d1h
onap               onap-sdnc-ansible-server-5f7dcbc96c-8qbjf           1/1     Running                  0            4d1h
onap               onap-sdnc-dbinit-job-qsps9                          0/1     Completed                0            4d1h
onap               onap-sdnc-dgbuilder-b5b498d75-2hqph                 1/1     Running                  0            4d1h
onap               onap-sdnc-sdnrdb-init-job-dcm4z                     0/1     Completed                0            4d1h
onap               onap-sdnc-sdnrdb-init-job-nl5sv                     0/1     Init:Error               0            4d1h
onap               onap-sdnc-web-79b7874bd6-dpvf4                      1/1     Running                  0            4d1h
onap               onap-sdnrdb-coordinating-only-84b5c88677-77b8n      2/2     Running                  0            4d1h
onap               onap-sdnrdb-master-0                                1/1     Running                  0            4d1h
onap               onap-strimzi-entity-operator-5467887b68-b79x7       2/2     Running                  1 (4d ago)   4d1h
onap               onap-strimzi-kafka-0                                1/1     Running                  0            4d1h
onap               onap-strimzi-zookeeper-0                            1/1     Running                  0            4d1h
smo                bundle-server-68b6b4fd44-nwrvm                      1/1     Running                  0            4d1h
smo                dfc-0                                               2/2     Running                  0            4d1h
smo                ics-init-vbhns                                      0/1     Completed                0            4d1h
smo                influxdb2-0                                         1/1     Running                  0            4d1h
smo                influxdb2-init-drmqs                                0/1     Completed                0            4d1h
smo                kafka-client                                        1/1     Running                  0            4d1h
smo                kafka-producer-pm-json2influx-0                     1/1     Running                  0            4d1h
smo                kafka-producer-pm-json2kafka-0                      1/1     Running                  0            4d1h
smo                kafka-producer-pm-xml2json-0                        1/1     Running                  0            4d1h
smo                keycloak-7db5c4dc7b-2jvnh                           1/1     Running                  0            4d1h
smo                keycloak-init-rjcx8                                 0/1     Completed                0            4d1h
smo                keycloak-proxy-6c654c4bdc-645f7                     1/1     Running                  0            4d1h
smo                minio-0                                             1/1     Running                  0            4d1h
smo                minio-client                                        1/1     Running                  0            4d1h
smo                opa-545ccb9958-zf8wn                                1/1     Running                  0            4d1h
smo                oran-smo-postgresql-0                               1/1     Running                  0            4d1h
smo                pm-producer-json2kafka-0                            2/2     Running                  0            4d1h
smo                pmlog-0                                             2/2     Running                  0            4d1h
smo                redpanda-console-7ccc45cccd-zfp29                   1/1     Running                  0            4d1h
smo                strimzi-patch-sv8t8                                 0/1     Completed                0            4d1h
smo                topology-exposure-858d9c6f57-vkbdc                  1/1     Running                  0            4d1h
smo                topology-ingestion-6f8cf86c5-7cjhw                  1/1     Running                  0            4d1h
strimzi-system     strimzi-cluster-operator-686599c45d-2zspx           1/1     Running                  0            4d1h
````
##### Check pod logs
Within the error shows in logs, the pods are generating error message infinitely until the ephemeral storage full and caused pod to crash and error, then generated a new pod. This cycle loops infinitely.
```
k logs onap-policy-clamp-ac-pf-ppnt-bfc679875-pjblm
```

```
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: 08e96294-64b4-45a3-95c1-145649ea5f57
[2025-05-05T06:22:52.691+00:00|ERROR|SingleThreadedBusTopicSource|KAFKA-source-acm-ppnt-sync] SingleThreadedKafkaTopicSource [getTopicCommInfrastructure()=KAFKA, toString()=SingleThreadedBusTopicSource [consumerGroup=08e96294-64b4-45a3-95c1-145649ea5f57, consumerInstance=onap-policy-clamp-ac-pf-ppnt-bfc679875-pjblm, fetchTimeout=15000, fetchLimit=-1, consumer=KafkaConsumerWrapper [fetchTimeout=15000], alive=true, locked=false, uebThread=Thread[KAFKA-source-acm-ppnt-sync,5,main], topicListeners=1, toString()=BusTopicBase [apiKey=null, apiSecret=null, useHttps=false, allowSelfSignedCerts=false, toString()=TopicBase [servers=[onap-strimzi-kafka-bootstrap:9092], topic=acm-ppnt-sync, effectiveTopic=acm-ppnt-sync, #recentEvents=0, locked=false, #topicListeners=1]]]]: cannot fetch
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: 08e96294-64b4-45a3-95c1-145649ea5f57

```
And this issue happens for pod `onap-policy-clamp-ac-pf-ppnt` `onap-policy-clamp-ac-kserve-ppnt` ` onap-policy-clamp-ac-a1pms-ppnt` `onap-policy-clamp-ac-http-ppnt` 
##### Get kafkaUser
Since its authorization for group, we check kafkaUser 
````
kg ku policy-clamp-ac-pf-ppnt-ku  -o yaml
````
````
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaUser
metadata:
  annotations:
    meta.helm.sh/release-name: onap-policy
    meta.helm.sh/release-namespace: onap
  creationTimestamp: "2025-05-02T03:59:13Z"
  generation: 6
  labels:
    app: policy-clamp-ac-pf-ppnt
    app.kubernetes.io/instance: onap
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: policy-clamp-ac-pf-ppnt
    helm.sh/chart: policy-clamp-ac-pf-ppnt-16.0.1
    strimzi.io/cluster: onap-strimzi
    version: 16.0.1
  name: policy-clamp-ac-pf-ppnt-ku
  namespace: onap
  resourceVersion: "609004"
  uid: 39096fa9-0cad-4496-bc11-13d21b479ce3
spec:
  authentication:
    type: scram-sha-512
  authorization:
    acls:
    - operations:
      - Read
      resource:
        name: policy-clamp-ac-pf-ppnt
        patternType: literal
        type: group
    - operations:
      - Read
      - Write
      resource:
        name: policy-acruntime-participant
        patternType: literal
        type: topic
    - operations:
      - Read
      - Write
      resource:
        name: acm-ppnt-sync
        patternType: literal
        type: topic
    type: simple
status:
  conditions:
  - lastTransitionTime: "2025-05-05T03:52:23.119221937Z"
    status: "True"
    type: Ready
  observedGeneration: 6
  secret: policy-clamp-ac-pf-ppnt-ku
  username: policy-clamp-ac-pf-ppnt-ku
````
## Expected Outcome 
All pods are in state **Running**/**Completed**

## Steps to reproduce
- Install K8S vanilla
- Install  K rel - [Commit: dfcfdbc9b540b3e6d401b8c09379e5a8b6267848](https://gerrit.o-ran-sc.org/r/gitweb?p=it/dep.git;a=commit;h=dfcfdbc9b540b3e6d401b8c09379e5a8b6267848)
- Inspect `htop` or `top` after all pods deployed

## Resolution
Below is temprary resolution/workaround:

### 1. Add group into kafkaUser
#### 1.1 Edit kafkaUser
As shown above there is no `topic` correspondent with `08e96294-64b4-45a3-95c1-145649ea5f57`. We will add it into kafkaUser

````
...
spec:
  authentication:
    type: scram-sha-512
  authorization:
    acls:
    - operations:
      - Read
      resource:
        name: policy-clamp-ac-pf-ppnt
        patternType: literal
        type: group
    - operations:
      - Read
      resource:
        name: 08e96294-64b4-45a3-95c1-145649ea5f57
        patternType: literal
        type: group
    - operations:
      - Read
      - Write
      resource:
        name: policy-acruntime-participant
        patternType: literal
        type: topic
    - operations:
      - Read
      - Write
      resource:
        name: acm-ppnt-sync
        patternType: literal
        type: topic
    type: simple

````

#### 1.2 Check Pod logs after modify
Pods immediately stops generating error logs and have new lines showing participant status:
````
Defaulted container "policy-clamp-ac-pf-ppnt" out of: policy-clamp-ac-pf-ppnt, policy-clamp-ac-pf-ppnt-update-config (init)
[2025-05-05T06:26:29.968+00:00|INFO|network|KAFKA-source-policy-acruntime-participant] [IN|KAFKA|policy-acruntime-participant]
{"state":"ON_LINE","participantDefinitionUpdates":[],"automationCompositionInfoList":[],"participantSupportedElementType":[{"id":"bfcb8ef1-ab7d-43b8-85b2-234dd62219a4","typeName":"org.onap.policy.clamp.acm.A1PMSAutomationCompositionElement","typeVersion":"1.0.1"}],"messageType":"PARTICIPANT_STATUS","messageId":"afbe8889-f8d2-4c14-bf66-ee9d738fe509","timestamp":"2025-05-05T06:26:29.964041213Z","participantId":"101c62b3-8918-41b9-a747-d21eb79c6c00","replicaId":"af145d2d-3f9f-41b4-861a-43a312e3280a"}
[2025-05-05T06:26:29.968+00:00|INFO|MessageTypeDispatcher|KAFKA-source-policy-acruntime-participant] discarding event of type PARTICIPANT_STATUS
[2025-05-05T06:26:30.218+00:00|INFO|network|KAFKA-source-policy-acruntime-participant] [IN|KAFKA|policy-acruntime-participant]
{"state":"ON_LINE","participantDefinitionUpdates":[],"automationCompositionInfoList":[],"participantSupportedElementType":[{"id":"a5eff97e-72f6-43af-8d4f-7c5ce882c0e0","typeName":"org.onap.policy.clamp.acm.HttpAutomationCompositionElement","typeVersion":"1.0.0"}],"messageType":"PARTICIPANT_STATUS","messageId":"b2a7bca6-7415-40ae-89da-6345346dde33","timestamp":"2025-05-05T06:26:30.214183839Z","participantId":"101c62b3-8918-41b9-a747-d21eb79c6c01","replicaId":"9eeb60a3-4e5f-4e62-84ff-9347b391f539"}
[2025-05-05T06:26:30.218+00:00|INFO|MessageTypeDispatcher|KAFKA-source-policy-acruntime-participant] discarding event of type PARTICIPANT_STATUS
[2025-05-05T06:26:48.205+00:00|INFO|network|KAFKA-source-policy-acruntime-participant] [IN|KAFKA|policy-acruntime-participant]
{"state":"ON_LINE","participantDefinitionUpdates":[],"automationCompositionInfoList":[],"participantSupportedElementType":[{"id":"2efe518d-eb9c-43b6-86af-cdb93057761d","typeName":"org.onap.policy.clamp.acm.KserveAutomationCompositionElement","typeVersion":"1.0.1"},{"id":"ebdd9c84-d02f-43ef-95ec-81cb6fb5a7d6","typeName":"org.onap.policy.clamp.acm.AutomationCompositionElement","typeVersion":"1.0.0"}],"messageType":"PARTICIPANT_STATUS","messageId":"e67e376e-24f5-42c4-9c76-307b99a1ca71","timestamp":"2025-05-05T06:26:48.201209464Z","participantId":"101c62b3-8918-41b9-a747-d21eb79c6c04","replicaId":"2f27c289-ae33-4393-82b5-01853b85189c"}
[2025-05-05T06:26:48.205+00:00|INFO|MessageTypeDispatcher|KAFKA-source-policy-acruntime-participant] discarding event of type PARTICIPANT_STATUS
````

#### 1.3 Check htop
We did steps above for all pods that have the issue and it solve resources starvation issue 

![image](/troubleshoot/k-smo/images/htop-after.png)
**Figure: htop shows high CPU and memory usage in Baremetal after workaround**

NB: we use different machine due to assumption that resource starvation caused by insufficient HW resources. After we tried using baremetal, the symptom of problem is the same although its not as severe as when using VM where high CPU and memory usage without any external operation that consume SMO services. 

