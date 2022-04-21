#!/usr/bin/env bash

cat /var/version && echo ""
set -eu

if [ -z "${CLUSTER_NAME}" ]; then
  { printf "\nError: 'CLUSTER_NAME' parameter is required"; } 2>/dev/null
  exit 1
fi


tkgi_api_password=$(om --env env/${ENV_FILE} -k credentials -p pivotal-container-service -c .properties.uaa_admin_password -f secret)

# printf "%s\n" "$tkgi_api_password" | tkgi get-credentials "${TKGI_CLUSTER_NAME}"
mv tkgi-cli/tkgi* ./tkgi
chmod +x tkgi
./tkgi login -a "${TKGI_API_ENDPOINT}" -u admin -p "$tkgi_api_password" -k


# exported for use in other tasks
export DEPLOYMENT_NAME
DEPLOYMENT_NAME=service-instance_$(./tkgi cluster "$CLUSTER_NAME" | grep UUID | awk '{ print $2 }' )

# shellcheck source=./setup-bosh-env.sh
source ./platform-automation-tasks/tasks/setup-bosh-env.sh

set -x

pushd tkgi-clusters-backup
  bbr deployment \
      --deployment "${DEPLOYMENT_NAME}" \
    backup-cleanup

  bbr deployment \
      --deployment "${DEPLOYMENT_NAME}" \
    backup --with-manifest

  tar -zcvf cluster_"${CLUSTER_NAME}"_"$( date +"%Y%m%d%H%M" )".tgz --remove-files -- */*
popd