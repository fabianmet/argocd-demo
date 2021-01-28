#!/bin/bash

# Get release for version

# Current dir
DIR="$( cd "$( dirname "$0" )" && pwd )"

# Check input
if [ -z ${1+x} ]
then
  echo "Please provide version"
  exit 1
else
  VERSION=${1}
  URL="https://raw.githubusercontent.com/argoproj/argo-cd/${VERSION}/manifests/ha/install.yaml"
fi

Test if url exists
if ! curl --head --silent --fail ${URL} > /dev/null;
 then
  echo "Version ${VERSION} does not exist"
  exit 1
fi

# Create directory
mkdir -p ${DIR}/releases/${VERSION}

wget -O ${DIR}/releases/${VERSION}/bundle.yaml ${URL}
cd ${DIR}/releases/${VERSION} && kustomize create --autodetect