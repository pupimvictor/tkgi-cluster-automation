#!/usr/bin/env bash
set -eu

[[ -z "${DEBUG:-""}" ]] | set -x

# tkgi_api_password=$(om -t ${OPSMAN_URL} -u ${OPSMAN_USERNAME} -p ${OPSMAN_PASSWORD} -k credentials -p pivotal-container-service -c .properties.uaa_admin_password -f secret)
tkgi_api_password=$(om --env env/${ENV_FILE} -k credentials -p pivotal-container-service -c .properties.uaa_admin_password -f secret)

# printf "%s\n" "$tkgi_api_password" | tkgi get-credentials "${TKGI_CLUSTER_NAME}"
mv tkgi-cli/tkgi* ./tkgi
chmod +x tkgi
./tkgi login -a "${TKGI_API_ENDPOINT}" -u admin -p "$tkgi_api_password" -k

if [ -n "$NUM_NODES" ]; then
    ./tkgi update-cluster "$CLUSTER_NAME" --num-nodes "${NUM_NODES}" --tags "${TAGS}" --wait --non-interactive 
    if [ $? -gt 0 ]; then
        echo "failed to resize cluster $CLUSTER_NAME"
        exit 1
    fi
    exit 0
fi

echo "Failed to get NUM_NODES from clusters file" 
exit 1