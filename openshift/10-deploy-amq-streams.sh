#!/bin/bash

AMQ_STREAMS_OPERATOR_NAMESPACE=openshift-operators
AMQ_STREAMS_CLUSTER_NAMESPACE=amqstreams
AMQ_STREAMS_CLUSTER_SIZE=1
AMQ_STREAMS_CLUSTER_NAME="single-node-cluster"

echo "Installing cluster-wide AMQ Streams operator ..."
oc apply -f amq-streams/amq-streams-operator.yaml

# Wait for K8s to create the operator deployment before checking status
# while empty var ...
while [ -z "$AMQ_STREAMS_DEPLOYMENT_NAME" ]
do
  sleep 2
  AMQ_STREAMS_DEPLOYMENT_NAME=$(oc get deployments.apps -n ${AMQ_STREAMS_OPERATOR_NAMESPACE} -o json | jq -r '.items[] | select(.metadata.name | startswith ("amq-streams-cluster-operator-")) | .metadata.name')
done

echo "Checking AMQ Streams operator POD is ready..."
available_replicas="0"
while [ "$available_replicas" != "1" ]
do
  available_replicas=$(oc get deployment "$AMQ_STREAMS_DEPLOYMENT_NAME" --template='{{.status.availableReplicas}}' -n ${AMQ_STREAMS_OPERATOR_NAMESPACE})
  echo "Waiting for AMQ Streams operator ... "
  sleep 5
done

echo "AMQ Streams operator is ready. Installing AMQ Streams single-node cluster ..."
oc new-project ${AMQ_STREAMS_CLUSTER_NAMESPACE}
oc apply -f amq-streams/kafka-single-node.yaml -n ${AMQ_STREAMS_CLUSTER_NAMESPACE}
oc apply -f amq-streams/superuser.yaml -n ${AMQ_STREAMS_CLUSTER_NAMESPACE}

sleep 5

zookeeper_ready_replicas="0"
while [ "$zookeeper_ready_replicas" != "$AMQ_STREAMS_CLUSTER_SIZE" ]
do
  zookeeper_ready_replicas=$(oc get strimzipodset "${AMQ_STREAMS_CLUSTER_NAME}-zookeeper" --template='{{.status.readyPods}}' -n ${AMQ_STREAMS_CLUSTER_NAMESPACE})
  echo "Waiting for AMQ Streams Zookeeper node ... "
  sleep 5
done

kafka_ready_replicas="0"
while [ "$kafka_ready_replicas" != "$AMQ_STREAMS_CLUSTER_SIZE" ]
do
  kafka_ready_replicas=$(oc get strimzipodset "${AMQ_STREAMS_CLUSTER_NAME}-kafka" --template='{{.status.readyPods}}' -n ${AMQ_STREAMS_CLUSTER_NAMESPACE})
  echo "Waiting for AMQ Streams Kafka node ... "
  sleep 5
done

echo "AMQ Streams cluster is ready. Installing Kafka-Connect single-node cluster ..."
oc apply -f amq-streams/kafka-connect-is.yaml -n ${AMQ_STREAMS_CLUSTER_NAMESPACE}
oc apply -f amq-streams/kafka-connect-single-node-with-build.yaml -n ${AMQ_STREAMS_CLUSTER_NAMESPACE}

echo "All AMQ Streams resources have been created: some of them might be still starting up."

