#!/usr/bin/env bash

set -euxo pipefail

if ! command -v k3d ; then
    printf "Failed to find k3d binary\n"
    exit 1
fi



set +x
if [ -z "$(k3d cluster list --no-headers primary)" ]; then
    set -x
    k3d cluster create primary   --k3s-server-arg "--disable=servicelb,traefik" --network argocd --no-lb --wait
else
    printf "Primary cluster already exists, skipping creation\n"
fi

set +x
if [ -z "$(k3d cluster list --no-headers secondary)" ]; then
    set -x
    k3d cluster create secondary --k3s-server-arg "--disable=servicelb,traefik" --network argocd --no-lb --wait --switch-context=false
else
    printf "Secondary cluster already exists, skipping creation\n"
fi

kubectl --context k3d-primary wait --for=condition=Ready nodes --all  
kubectl --context k3d-secondary wait --for=condition=Ready nodes --all  

SECONDARY_MASTER_IP=$(kubectl get node --context k3d-secondary -o jsonpath='{.items[0].status.addresses[0].address}')

# overwrite the secondary cluster's server ip to use the container's ip. This way
# argocd can reach the other cluster after we add it using argocd cluster add.
kubectl config set clusters.k3d-secondary.server https://${SECONDARY_MASTER_IP}:6443

