#!/bin/bash

export DEBUG=$(/root/setup/getOvfProperty.py "guestinfo.debug")
export HOSTNAME=$(/root/setup/getOvfProperty.py "guestinfo.hostname")
export IP_ADDRESS=$(/root/setup/getOvfProperty.py "guestinfo.ipaddress")
export NETMASK=$(/root/setup/getOvfProperty.py "guestinfo.netmask" | awk -F ' ' '{print $1}')
export GATEWAY=$(/root/setup/getOvfProperty.py "guestinfo.gateway")
export DNS_SERVER=$(/root/setup/getOvfProperty.py "guestinfo.dns")
export DNS_DOMAIN=$(/root/setup/getOvfProperty.py "guestinfo.domain")
export NTP_SERVER=$(/root/setup/getOvfProperty.py "guestinfo.ntp")
export ROOT_PASSWORD=$(/root/setup/getOvfProperty.py "guestinfo.root_password")
export HARBOR_PASSWORD=$(/root/setup/getOvfProperty.py "guestinfo.harbor_password")
export DOCKER_NETWORK_CIDR=$(/root/setup/getOvfProperty.py "guestinfo.docker_network_cidr")

export VM_DATASTORE=$(/root/setup/getOvfProperty.py "guestinfo.datastore")
export VM_NETWORK=$(/root/setup/getOvfProperty.py "guestinfo.network")
export VM_FOLDER=$(/root/setup/getOvfProperty.py "guestinfo.folder")
export VM_DATACENTER=$(/root/setup/getOvfProperty.py "guestinfo.datacenter")
export DEST_REG=$(/root/setup/getOvfProperty.py "guestinfo.hostname")
export VSPHERE_PASSWORD=$(/root/setup/getOvfProperty.py "guestinfo.vsphere_password")
export VSPHERE_USER=$(/root/setup/getOvfProperty.py "guestinfo.vsphere_user")
export SSH_KEY=$(/root/setup/getOvfProperty.py "guestinfo.ssh_key")
export VSPHERE_HOST=$(/root/setup/getOvfProperty.py "guestinfo.vsphere_host")
export VM_CLUSTER=$(/root/setup/getOvfProperty.py "guestinfo.cluster")
export ENDPOINT_IP=$(/root/setup/getOvfProperty.py "guestinfo.endpoint_ip")
export CLUSTER_NAME=$(/root/setup/getOvfProperty.py "guestinfo.cluster_name")

# needed for TKG step
export CP_NODE_DISK_GIB=100
export CP_NODE_MEM_MIB=4096
export CP_NUM_OF_CPU=4
export RESOURCE_POOL=""
export WK_NODE_DISK_GIB=100
export TKG_CONFIG=noavi-template.yaml
export BOOTSTRAP_DIR=/root/tkg-bootstrap
export SRC_REG=localhost:8888
export HARBOR_USER=admin
export TKG_CUSTOM_COMPATIBILITY_IMAGE_PATH=fips/tkg-compatibility
export TKG_CUSTOM_IMAGE_REPOSITORY=${DEST_REG}/tkg
export TKG_CUSTOM_IMAGE_REPOSITORY_SKIP_TLS_VERIFY=true
export WK_NODE_MEM_MIB=4096

export GOVC_URL=$VSPHERE_HOST
export GOVC_USERNAME=$VSPHERE_USER
export GOVC_PASSWORD=$VSPHERE_PASSWORD
export GOVC_INSECURE=true

export HOME=/root
