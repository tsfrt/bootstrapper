#!/bin/bash -euo pipefail

#these vars are not currently exposed
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
export TKG_CUSTOM_IMAGE_REPOSITORY=localhost/tkg
export TKG_CUSTOM_IMAGE_REPOSITORY_SKIP_TLS_VERIFY=true
export WK_NODE_MEM_MIB=4096

get_insecure_registry() {
cat <<EOF
{
  "insecure-registries": ["$DEST_REG"]
}
EOF
}

tkg_install () {
  mkdir -p /etc/docker/certs.d/${DEST_REG}/  
  
  echo $(get_insecure_registry) > /etc/docker/daemon.json
  systemctl restart docker

  openssl s_client \
  -showcerts \
  -connect $DEST_REG:443  2>/dev/null </dev/null | \
  sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /etc/docker/certs.d/${DEST_REG}/ca.crt

  envsubst < "${BOOTSTRAP_DIR}/${TKG_CONFIG}" > ${BOOTSTRAP_DIR}/config.yaml
  timeout 8s tanzu management-cluster create -f ${BOOTSTRAP_DIR}/config.yaml || true
  mv -f ~/.config/tanzu/tkg/bom ~/.config/tanzu/tkg/bom-old
  mv -f ~/.config/tanzu/tkg/compatibility ~/.config/tanzu/tkg/compatibility-old
  tanzu management-cluster create -f ${BOOTSTRAP_DIR}/config.yaml -v9
}

run_registry () {

  sudo docker run -d \
  -p 8888:5000 \
  --restart=always \
  --name temp_registry \
  -v ${BOOTSTRAP_DIR}/registry:/var/lib/registry \
  registry:2

}

copy_images () {
  crane auth login $DEST_REG -u $HARBOR_USER -p $HARBOR_PASSWORD

  #only src requires auth
  list_of_repos=$(crane catalog "$SRC_REG")

  while read i
     do
       images=$(crane ls ${SRC_REG}/${i})

       while read j
       do
         crane copy --insecure "${SRC_REG}/$i:$j" "${DEST_REG}/tkg/$i:$j"
           
      done <<< ${images}

  done <<< ${list_of_repos}
}

create_project () {
curl -X POST \
-u "${HARBOR_USER}:${HARBOR_PASSWORD}" \
-H "Content-Type: application/json" \
-ki "https://localhost/api/v2.0/projects" \
-d "$(project_create_request)"
}

create_tkg_folder () {
  export GOVC_URL=$VSPHERE_HOST
  export GOVC_USERNAME=$VSPHERE_USER
  export GOVC_PASSWORD=$VSPHERE_PASSWORD
  export GOVC_INSECURE=true
  govc folder.create $VM_DATACENTER/vm/$VM_FOLDER
}

project_create_request ()
{
  cat <<EOF
{
  "project_name": "tkg",
  "public": true,
  "storage_limit": 0
}
EOF
}

upload_ova () {

/usr/bin/vmware-ovftool/ovftool \
--acceptAllEulas \
--allowAllExtraConfig \
--datastore=$VM_DATASTORE \
--network=$VM_NETWORK \
--overwrite \
--noSSLVerify \
--vmFolder=$VM_FOLDER \
--importAsTemplate \
${BOOTSTRAP_DIR}/tkg.ova \
"vi://${VSPHERE_USER}:${VSPHERE_PASSWORD}@${VSPHERE_HOST}/${VM_DATACENTER}/host/${VM_CLUSTER}"

}

create_project

create_tkg_folder || true

upload_ova 

run_registry

copy_images

tkg_install
