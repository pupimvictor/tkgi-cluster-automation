#!/bin/bash
set -ex
[[ -z "${DEBUG:-""}" ]] | set -x

PLACEHOLDERS_CONFIG=../config/platform-management/tkgi-config-placeholders.yml
TARGET_CONFIG=../config/platform-management/pivotal-container-service.yml

if [ -z "$PLACEHOLDERS_CONFIG" ]; then
    echo "Requered param PLACEHOLDERS_CONFIG" 
    exit 1
fi

if [ -z "$TARGET_CONFIG" ]; then
    echo "Requered param TARGET_CONFIG" 
    exit 1
fi

wget https://github.com/mikefarah/yq/releases/download/3.4.1/yq_linux_amd64 -o yq
chmod +x yq

./yq r file-source/$PLACEHOLDERS_CONFIG -X '*.**' -p p > /tmp/placeholders.yml
cat /tmp/placeholders.yml | while read line; do
    key=$(echo "$line" | awk '{print $1}')
    # echo $key
    val=$(./yq r file-source/$PLACEHOLDERS_CONFIG "$key")
    # echo $val
    

    ./yq w generated-config/$TARGET_CONFIG "$key" $val 
done
cat generated-config/$TARGET_CONFIG


if [ $? == 0 ]; then
echo  body
fi


rm yq