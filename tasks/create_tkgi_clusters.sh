#!/usr/bin/env bash
set -eu

[[ -z "${DEBUG:-""}" ]] | set -x

# tkgi_api_password=$(om -t ${OPSMAN_URL} -u ${OPSMAN_USERNAME} -p ${OPSMAN_PASSWORD} -k credentials -p pivotal-container-service -c .properties.uaa_admin_password -f secret)
tkgi_api_password=$(om --env env/${ENV_FILE} -k credentials -p pivotal-container-service -c .properties.uaa_admin_password -f secret)

# printf "%s\n" "$tkgi_api_password" | tkgi get-credentials "${TKGI_CLUSTER_NAME}"
mv tkgi-cli/tkgi* ./tkgi
chmod +x tkgi
./tkgi login -a "${TKGI_API_ENDPOINT}" -u admin -p "$tkgi_api_password" -k

flags=""
if [ -z "${CLUSTER_NAME}" ]; then
    echo "CLUSTER_NAME can't be empty"
    exit 1
fi
if [ -z "${EXTERNAL_HOSTNAME}" ]; then
    echo "missing external_hostname"
    exit 1
fi

flags="${CLUSTER_NAME} --external-hostname ${EXTERNAL_HOSTNAME} --plan ${PLAN}"

if [ -n "$K8S_PROFILE" ]; then
    flags="$flags --kubernetes-profile $K8S_PROFILE"
fi
if [ -n "$NETWORK_PROFILE" ]; then
    flags="$flags --network-profile $NETWORK_PROFILE"
fi
if [ -n "$NUM_NODES" ]; then
    flags="$flags --num-nodes $NUM_NODES"
fi
if [ -n "$TAGS" ]; then
    flags="$flags --tags ${TAGS}"
fi

./tkgi create-cluster ${flags} --wait --non-interactive
if [ $? -gt 0 ]; then
    echo "failed to create cluster $CLUSTER_NAME"
    exit 1
fi
exit 0
