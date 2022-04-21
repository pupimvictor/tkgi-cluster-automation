#!/usr/bin/env bash
cat /var/version && echo ""
set -eux

curl -L0 https://github.com/cloudfoundry-incubator/uaa-cli/releases/download/0.10.0/uaa-linux-amd64-0.10.0 --output uaac

chmod +x uaac

uaa_management_client_secret=$(om --env env/${ENV_FILE} -k credentials -p pivotal-container-service -c .properties.pks_uaa_management_admin_client -f secret)
./uaac target "${TKGI_API_ENDPOINT}":8443 -k 

./uaac get-client-credentials-token admin -s "$uaa_management_client_secret"

for ad_group in "${ADMIN_ROLE_GROUPS[@]}"; do
    ./uaac map-group "$ad_group"  'pks.clusters.admin'
done

for ad_group in "${ADMIN_READ_ROLE_GROUPS[@]}"; do
    ./uaac map-group "$ad_group"  'pks.clusters.admin.read'
done

for ad_group in "${MANAGE_ROLE_GROUPS[@]}"; do
    ./uaac map-group "$ad_group"  'pks.clusters.manage'
done

