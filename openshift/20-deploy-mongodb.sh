#!/bin/bash

MONGODB_NAMESPACE=mongodb

echo "Deploying MongoDB database ..."
oc new-project ${MONGODB_NAMESPACE}
oc new-app --name mongodb  -n ${MONGODB_NAMESPACE} \
 -e MONGO_INITDB_ROOT_USERNAME=root \
 -e MONGO_INITDB_ROOT_PASSWORD=mypassword \
 --image docker.io/library/mongo:latest

echo "MongoDB resources have been created: wait for the services to be ready..."

