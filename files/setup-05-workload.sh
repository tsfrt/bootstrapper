#!/bin/bash 

kubectl apply -f /root/setup/cluster-management.yaml

if [ -z "${GIT_REPO}" ]
#if no repo is set then use imgpkg config
then
  envsubst < <(cat /root/setup/imgpkg-config.yaml) | kubectl apply -f - 
else
  envsubst < <(cat /root/setup/git-config.yaml) | kubectl apply -f - 
fi