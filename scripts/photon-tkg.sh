#!/bin/bash -eux

curl -o /etc/pki/rpm-gpg/GOOGLE-RPM-GPG-KEY https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
chmod 644 /etc/pki/rpm-gpg/GOOGLE-RPM-GPG-KEY
rpm --import /etc/pki/rpm-gpg/GOOGLE-RPM-GPG-KEY

repo=W2t1YmVybmV0ZXNdCm5hbWU9S3ViZXJuZXRlcwpiYXNldXJsPWh0dHBzOi8vcGFja2FnZXMuY2xvdWQuZ29vZ2xlLmNvbS95dW0vcmVwb3Mva3ViZXJuZXRlcy1lbDcteDg2XzY0CmVuYWJsZWQ9MQpncGdjaGVjaz0xCnJlcG9fZ3BnY2hlY2s9MQpncGdrZXk9ZmlsZTovLy9ldGMvcGtpL3JwbS1ncGcvR09PR0xFLVJQTS1HUEctS0VZCg==

echo $repo | base64 -d > /etc/yum.repos.d/kubernetes.repo 

echo '> Installing TKG Depends...'
tdnf install -y \
  kubectl \
  jq

echo '> Pull down yq'
curl -L -o yq https://github.com/mikefarah/yq/releases/download/v4.16.2/yq_linux_amd64
install yq /usr/local/bin/yq

echo '> Pull down fips ovs'
curl -L -o tkg-fips.ova https://tkg-install.s3.us-east-2.amazonaws.com/ubuntu-2004-kube-v1.21.2%2Bvmware.1-fips.1-tkg.1-13104814112952456924.ova

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

echo '> Pull down crane'
curl -L -o crane.tar.gz https://github.com/google/go-containerregistry/releases/download/v0.8.0/go-containerregistry_Linux_x86_64.tar.gz
tar -xvf crane.tar.gz
install crane /usr/local/bin
