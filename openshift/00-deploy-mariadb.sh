#!/bin/bash

MARIADB_CLUSTER_NAMESPACE=mariadb

echo "Installing MariaDB demo database into namespace: ${MARIADB_CLUSTER_NAMESPACE}"
oc new-project ${MARIADB_CLUSTER_NAMESPACE}
oc apply -f mariadb/mariadb-config-cm.yaml -n ${MARIADB_CLUSTER_NAMESPACE}
oc apply -f mariadb/mariadb-msusers.yaml -n ${MARIADB_CLUSTER_NAMESPACE}

echo "MariaDB resources have been created: some of them might be still starting up."
