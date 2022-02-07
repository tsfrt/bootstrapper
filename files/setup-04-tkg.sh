#!/bin/bash -euo pipefail

set -euo pipefail

cd /root/tkg-bootstrap

create_project

create_tkg_folder || true

upload_ova 

run_registry

sleep 15

copy_images

push_fips_compat

sleep 10

tkg_install
