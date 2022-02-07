#!/bin/bash 

set -x

source ./env.sh

### bash functions

get_insecure_registry() {
  cat <<EOF
{
  "insecure-registries": ["$DEST_REG"]
}
EOF
}

tkg_install () {
  echo $(get_insecure_registry) > /etc/docker/daemon.json
  systemctl stop iptables
  systemctl stop docker
  sleep 5
  systemctl start docker
  sleep 5
  docker-compose -f /root/harbor/docker-compose.yml stop
  sleep 5
  docker-compose -f /root/harbor/docker-compose.yml start
  sleep 60

  envsubst < "${BOOTSTRAP_DIR}/${TKG_CONFIG}" > ${BOOTSTRAP_DIR}/config.yaml
  
  timeout 15s tanzu management-cluster create -f ${BOOTSTRAP_DIR}/config.yaml -v9 -e || true
  rm -Rf /root/.config/tanzu/tkg/bom
  rm -Rf /root/.config/tanzu/tkg/compatibility
  
  tanzu management-cluster create -f ${BOOTSTRAP_DIR}/config.yaml -v9
  systemctl start iptables
}

run_registry () {
  tar -xvf ${BOOTSTRAP_DIR}/images.tar

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

push_fips_compat () {
  crane push \
    ${BOOTSTRAP_DIR}/fips_compat.tar \
    ${DEST_REG}/tkg/fips/tkg-compatibility:v1 --insecure
}

create_project () {
  curl -X POST \
    -u "${HARBOR_USER}:${HARBOR_PASSWORD}" \
    -H "Content-Type: application/json" \
    -ki "https://localhost/api/v2.0/projects" \
    -d "$(project_create_request)"
}

create_tkg_folder () {
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
