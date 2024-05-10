#!/bin/bash

SR_OPERATOR_NAMESPACE=openshift-operators
AMQ_STREAMS_CLUSTER_NAMESPACE=amqstreams

echo "Installing cluster-wide Service Registry operator ..."
oc apply -f service-registry/service-registry-operator.yaml -n ${SR_OPERATOR_NAMESPACE}

# Wait for K8s to create the operator deployment before checking status
# while empty var ...
while [ -z "$SR_DEPLOYMENT_NAME" ]
do
  sleep 2
  SR_DEPLOYMENT_NAME=$(oc get deployments.apps -n ${SR_OPERATOR_NAMESPACE} -o json | jq -r '.items[] | select(.metadata.name | startswith ("apicurio-registry-operator-")) | .metadata.name')
done

echo "Checking Service Registry operator POD is ready..."
available_replicas="0"
while [ "$available_replicas" != "1" ]
do
  available_replicas=$(oc get deployment "$SR_DEPLOYMENT_NAME" --template='{{.status.availableReplicas}}' -n ${SR_OPERATOR_NAMESPACE})
  echo "Waiting for Service Registry operator ... "
  sleep 5
done

echo "AMQ Service Registry operator is ready. Deploying a Service Registry instance into the AMQ Streams namespace..."
oc apply -f service-registry/demo-apicurioregistry.yaml -n ${AMQ_STREAMS_CLUSTER_NAMESPACE}


echo "Service Registry resources have been created: the POD might be still starting up."

