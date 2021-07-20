#!/bin/sh
set -o errexit

# create local registry container
reg_name='kind-registry'
reg_port='5000'
running="$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)"
if [ "${running}" != 'true' ]; then
  docker run \
    -d --restart=always -p "127.0.0.1:${reg_port}:5000" --name "${reg_name}" \
    registry:2
fi

## create cluster
cluster_name="cluster01"
kind create cluster --config cluster.yaml --name $cluster_name

## connect the registry to the cluster network
docker network connect "kind" "${reg_name}" || true

## apply dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml

## apply user & RBA
kubectl apply -f manifests/
