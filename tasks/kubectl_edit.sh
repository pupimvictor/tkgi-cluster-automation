#!/bin/bash
set -e
[[ -z "${DEBUG:-""}" ]] | set -x

tkgi_api_password=$(om --env env/${ENV_FILE} -k credentials -p pivotal-container-service -c .properties.uaa_admin_password -f secret)

mv tkgi-cli/tkgi* ./tkgi
chmod +x tkgi

mv kubectl-cli/kubectl* ./kubectl
chmod +x kubectl

./tkgi login -a "${TKGI_API_ENDPOINT}" -u admin -p "$tkgi_api_password" -k

## TODO: Change to get-kubeconfig
printf "%s\n" "$tkgi_api_password" | ./tkgi get-credentials "${TKGI_CLUSTER_NAME}"

./kubectl edit "${KUBECTL_EDIT}"