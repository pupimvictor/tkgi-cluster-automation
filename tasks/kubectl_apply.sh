#!/bin/bash
set -ex
[[ -z "${DEBUG:-""}" ]] | set -x

tkgi_api_password=$(om --env env/${ENV_FILE} -k credentials -p pivotal-container-service -c .properties.uaa_admin_password -f secret)

vars_files_args=("")
for vf in vars/${VARS_FILES}; do
  vars_files_args+=("--vars-file ${vf}")
done

rec_flag=""
if [ -n "$DIR_TO_APPLY" ]; then
  FILE_TO_APPLY="$DIR_TO_APPLY"
  rec_flag="-R"
elif [ -z "$vars_files_args" ]; then
    om interpolate --config "${FILE_TO_APPLY}"  ${vars_files_args}
    cat "${FILE_TO_APPLY}"
fi

mv tkgi-cli/tkgi* ./tkgi
chmod +x tkgi

mv kubectl-cli/kubectl* ./kubectl
chmod +x kubectl

./tkgi login -a "${TKGI_API_ENDPOINT}" -u admin -p "$tkgi_api_password" -k

printf "%s\n" "$tkgi_api_password" | ./tkgi get-credentials "${TKGI_CLUSTER_NAME}"

./kubectl apply "${rec_flag}" -f "${FILE_TO_APPLY}"