#!/bin/bash
# Copyright 2019 VMware, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-2

set -euo pipefail

#source ./env.sh
## functions.sh sources env.sh
source ./functions.sh

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
