#!/usr/bin/bash
set -e
[[ -z "${DEBUG:-""}" ]] | set -x

tkgi_api_password=`om -t ${ENV_NAME}host.com -u ${OM_USERNAME} -p ${OM_PASSWORD} -k credentials -p pivotal-container-service -c .properties.uaa_admin_password -f secret`

tkgi login -a ${TKGI_API_ENDPOINT} -u admin -p $tkgi_api_password -k
printf "%s\n" "$tkgi_api_password" | tkgi get-credentials ${TKGI_CLUSTER_NAME}

export TMC_CLUSTER=${ENV_NAME}${TKGI_CLUSTER_NAME}
export TMC_CLUSTER_GROUP=${ENV_NAME}-tkg-clusters

tmc login --no-configure --name automation

cluster_count=$(tmc cluster list -o json --name $TMC_CLUSTER | jq -r 'if .totalCount then .totalCount else .total_count end')
if [[ cluster_count -eq 0 ]]; then
	echo "Attaching cluster $TMC_CLUSTER to TMC in cluster group $TMC_CLUSTER_GROUP."
	tmc cluster attach \
		--name $TMC_CLUSTER \
		--labels origin=automation \
		--group $TMC_CLUSTER_GROUP \
		--output tmc-svc-cluster-attach.yaml

	kubectl apply -f tmc-svc-cluster-attach.yaml
else
	echo "Cluster $TMC_CLUSTER is already attached to TMC."
fi
