#!/bin/bash
set -ex
[[ -z "${DEBUG:-""}" ]] | set -x

# shellcheck source=./setup-bosh-env.sh
source ./platform-automation-tasks/tasks/setup-bosh-env.sh

mv tkgi-cli/tkgi* ./tkgi
chmod +x tkgi

# get cluster UUID
cluster_id=$(./tkgi cluster ${CLUSTER_NAME} | aws UUID)

# Get current runtime config
bosh runtime-config > /tmp/runtime-config.yml



# todo check if runtime-config is correct

mv yq-cli/yq* ./yq
chmod +x yq

addon_config=$(cat ${CONFIG_FILE})
# append new addon
./yq eval "addons += ${addon_config}" /tmp/runtime-config.yml

bosh update-runtime-config /tmp/runtime-config






