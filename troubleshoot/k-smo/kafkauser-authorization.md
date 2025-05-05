# SMO Installation Troubleshooting

## General Information

* **Date:** May 5, 2025
* **SMO Version:** 
    - K rel - [Commit: dfcfdbc9b540b3e6d401b8c09379e5a8b6267848](https://gerrit.o-ran-sc.org/r/gitweb?p=it/dep.git;a=commit;h=dfcfdbc9b540b3e6d401b8c09379e5a8b6267848)
* **Installation Environment:** 
    - Kubernetes 1.32.4
    - Docker v.24
* **Hardware Requirements:**
    - vCPU 32
    - Memory 128GB
    - Storage 1TB

## Problem Details
###  1. High CPU and Memory Usage after installation
![image](/troubleshoot/k-smo/images/htop.png)
**Figure: htop shows high CPU and memory usage in VM after SMO installation**

This may caused by java applications that consume too much CPU. The reason is due to error on onap-policy-clamp pods for authorization groups for all of onap-policy-clamp pods.

#### 1.1 Step to reproduce
- Install K8S vanilla
- Install  K rel - [Commit: dfcfdbc9b540b3e6d401b8c09379e5a8b6267848](https://gerrit.o-ran-sc.org/r/gitweb?p=it/dep.git;a=commit;h=dfcfdbc9b540b3e6d401b8c09379e5a8b6267848)
- Inspect `htop` or `top` after all pods deployed

#### 1.2 Check pod logs
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
### 1.3 Get kafkaUser
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

## Workaround
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

