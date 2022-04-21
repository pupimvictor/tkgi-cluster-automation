#!/usr/bin/env bash
set -eu

[[ -z "${DEBUG:-""}" ]] | set -x

if [ ! -f "$CLUSTER_CONFIG_FILE" ]; then
    echo file exists
fi

mv yq-cli/yq* ./yq
chmod +x yq

mv fly-cli/fly* ./fly
chmod +x fly

clusters=$(./yq e '.clusters[].CLUSTER_NAME' "${CLUSTER_CONFIG_FILE}")

./fly -t "$CONCOURSE_TARGET" login -c "$CONCOURSE_URL" -u "$CONCOURSE_USERNAME" -p "$CONCOURSE_PASSWORD" -n "$CONCOURSE_TEAM" -k 

for cluster_name in $clusters; do
    echo "setting $cluster_name cluster"

    ./yq e ".clusters[] | select(.CLUSTER_NAME == \"${cluster_name}\")" "${CLUSTER_CONFIG_FILE}" > /tmp/"$cluster_name".yml

    ./fly -t "$CONCOURSE_TARGET" sp -p "$cluster_name" -c pipelines/"$PIPELINE_FILE" -l pipelines/"$PIPELINE_VARS_FILE" -l /tmp/"$cluster_name".yml -n "$CONCOURSE_TEAM"
done

exit 0
