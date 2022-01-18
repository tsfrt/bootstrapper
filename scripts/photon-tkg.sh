#!/bin/bash -eux

echo '> Installing TKG Depends...'
tdnf install -y \
  kubectl \
  yq \
  jq \
  tar


echo '> Pull down registry images'
curl -L -o fips_images.tar https://tkg-install.s3.us-east-2.amazonaws.com/fips-regisrty.tar

echo '> Pull down registry image'
curl -L -o registry_image.tar https://tkg-install.s3.us-east-2.amazonaws.com/registry-image.tar

echo '> Pull down cli'
curl -L -o tanzu-cli.tar https://tkg-install.s3.us-east-2.amazonaws.com/tanzu-cli-bundle-linux-amd64-bs.tar

echo '> Pull down govc'
curl -L -o govc_Linux_x86_64.tar.gz https://github.com/vmware/govmomi/releases/download/v0.27.2/govc_Linux_x86_64.tar.gz

echo '> Pull down config template'
curl -L -o noavi-template.yaml https://tkg-install.s3.us-east-2.amazonaws.com/noavi-template.yaml