#!/bin/bash
# Copyright 2019 VMware, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-2

set -euo pipefail

# Extract all OVF Properties
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

if [ -e /root/ran_customization ]; then
    exit
else
	HARBOR_LOG_FILE=/var/log/bootstrap.log
	if [ ${DEBUG} == "True" ]; then
		HARBOR_LOG_FILE=/var/log/bootstrap-debug.log
		set -x
		exec 2>> ${HARBOR_LOG_FILE}
		echo
        echo "### WARNING -- DEBUG LOG CONTAINS ALL EXECUTED COMMANDS WHICH INCLUDES CREDENTIALS -- WARNING ###"
        echo "### WARNING --             PLEASE REMOVE CREDENTIALS BEFORE SHARING LOG            -- WARNING ###"
        echo
	fi

	echo -e "\e[92mStarting Customization ..." > /dev/console

	echo -e "\e[92mStarting OS Configuration ..." > /dev/console
	. /root/setup/setup-01-os.sh

	echo -e "\e[92mStarting Network Configuration ..." > /dev/console
	. /root/setup/setup-02-network.sh

	echo -e "\e[92mStarting Harbor Configuration ..." > /dev/console
	. /root/setup/setup-03-harbor.sh

	echo -e "\e[92mStarting TKG Configuration ..." > /dev/console
	. /root/setup/setup-04-tkg.sh

	echo -e "\e[92mStarting workload Configuration ..." > /dev/console
	. /root/setup/setup-05-workload.sh || true

	echo -e "\e[92mCustomization Completed ..." > /dev/console

	# Clear guestinfo.ovfEnv
	vmtoolsd --cmd "info-set guestinfo.ovfEnv NULL"

	# Ensure we don't run customization again
	touch /root/ran_customization
fi
