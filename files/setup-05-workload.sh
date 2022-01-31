#!/bin/bash 

kubectl apply -f /root/setup/cluster-management.yaml

if [ -z "${GIT_REPO}" ]
#if no repo is set then use imgpkg config
then
   cat /root/setup/imgpkg-config.yaml | envsubst - |  kubectl apply -f -
else
    cat /root/setup/git-config.yaml | envsubst - |  kubectl apply -f -
fi