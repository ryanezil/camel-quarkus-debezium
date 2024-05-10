#!/bin/bash

AMQ_STREAMS_CLUSTER_NAMESPACE=amqstreams

echo "Installing Debezium connector ..."
oc apply -f amq-streams/db-mysql-dbz-connector-avro.yaml -n ${AMQ_STREAMS_CLUSTER_NAMESPACE}

echo "Debezium connector resource created."

