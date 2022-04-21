#!/usr/bin/env bash
set -eu

[[ -z "${DEBUG:-""}" ]] | set -x

# tkgi_api_password=$(om -t ${OPSMAN_URL} -u ${OPSMAN_USERNAME} -p ${OPSMAN_PASSWORD} -k credentials -p pivotal-container-service -c .properties.uaa_admin_password -f secret)
tkgi_api_password=$(om --env env/${ENV_FILE} -k credentials -p pivotal-container-service -c .properties.uaa_admin_password -f secret)

# printf "%s\n" "$tkgi_api_password" | tkgi get-credentials "${TKGI_CLUSTER_NAME}"
mv tkgi-cli/tkgi* ./tkgi
chmod +x tkgi
./tkgi login -a "${TKGI_API_ENDPOINT}" -u admin -p "$tkgi_api_password" -k

./tkgi delete-cluster "$CLUSTER_NAME" --wait --non-interactive
if [ $? -gt 0 ]; then
    echo "failed to DELETE cluster $CLUSTER_NAME"
    exit 1
fi
exit 0
