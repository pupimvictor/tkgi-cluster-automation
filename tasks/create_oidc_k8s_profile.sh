#!/usr/bin/env bash
set -eu

[[ -z "${DEBUG:-""}" ]] | set -x

# tkgi_api_password=$(om -t ${OPSMAN_URL} -u ${OPSMAN_USERNAME} -p ${OPSMAN_PASSWORD} -k credentials -p pivotal-container-service -c .properties.uaa_admin_password -f secret)
tkgi_api_password=$(om --env env/${ENV_FILE} -k credentials -p pivotal-container-service -c .properties.uaa_admin_password -f secret)

# printf "%s\n" "$tkgi_api_password" | tkgi get-credentials "${TKGI_CLUSTER_NAME}"
mv tkgi-cli/tkgi* ./tkgi
chmod +x tkgi
./tkgi login -a "${TKGI_API_ENDPOINT}" -u admin -p "$tkgi_api_password" -k

mv config/config/platform-management/tkgi-api-ca.yml /tmp/oidc-ca.pem
# formatting certificate
sed -i 's/\\r\\n/\
/g' /tmp/oidc-ca.pem

sed -i 's/\"//g' /tmp/oidc-ca.pem

cat <<EOF > /tmp/k8s_oidc_profile.json
{
    "name": "oidc-config",
    "description": "Kubernetes profile with OIDC configuration",
    "customizations": [
       {
          "component": "kube-apiserver",
          "arguments": {
             "oidc-client-id": "pks_cluster_client",
             "oidc-issuer-url": "https://TKGI_API_ENDPOINT:8443/oauth/token",
             "oidc-username-claim": "user_name",
             "oidc-groups-claim": "roles"
            
          },
          "file-arguments": {
             "oidc-ca-file": "/tmp/oidc-ca.pem"
          }
       }
    ]
 }
EOF
sed -i "s/TKGI_API_ENDPOINT/${TKGI_API_ENDPOINT}/g" /tmp/k8s_oidc_profile.json
./tkgi create-kubernetes-profile /tmp/k8s_oidc_profile.json

