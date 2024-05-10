#!/bin/bash

MARIADB_CLUSTER_NAMESPACE=mariadb

echo "Installing MariaDB demo database into namespace: ${MARIADB_CLUSTER_NAMESPACE}"
oc new-project ${MARIADB_CLUSTER_NAMESPACE}

oc create configmap country-users-table-schemas --from-file=mariadb/table-ddl/ -n ${MARIADB_CLUSTER_NAMESPACE}
oc create configmap mariadb-config --from-file=mariadb/config/primary.cnf -n ${MARIADB_CLUSTER_NAMESPACE}

# Deploy MariaDB
oc apply -f mariadb/mariadb-msusers.yaml -n ${MARIADB_CLUSTER_NAMESPACE}

echo "MariaDB resources have been created: some of them might be still starting up."
