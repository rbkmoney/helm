#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/dark-api/dark-api.jar \
    --logging.config=/opt/dark-api/logback.xml \
    --magista.client.adapter.url=http://magista:8022/v2/stat \
    --magista.client.adapter.networkTimeout=90000 \
    --claimmanagement.client.adapter.url=http://claim-management:8022/v1/cm \
    --claimmanagement.client.adapter.networkTimeout=30000 \
    --conversations.url=http://messages:8022:/v1/messages \
    --conversations.networkTimeout=30000 \
    --questionary-aggr-proxy.url=http://questionary-aggr-proxy:8022/v1/questionary/proxy \
    --questionary-aggr-prox.networkTimeout=30000 \
    --questionary.url=http://questionary:8022/v1/questionary \
    --questionary.networkTimeout=30000 \
    --filestorage.client.adapter.url=http://file-storage:8022/file_storage \
    --filestorage.client.adapter.networkTimeout=30000 \
    --partyManagement.url=http://hellgate:8022/v1/processing/partymgmt \
    --partyManagement.networkTimeout=30000 \
    --cabi.url=http://cabi:8022/v1/cabi \
    --cabi.networkTimeout=30000 \
    --dominant.url=http://dominant:8022/v1/domain/repository_client \
    --dominant.networkTimeout=30000 \
    --dudoser.url=http://dudoser:8022/dudos \
    --dudoser.networkTimeout=30000 \
    --keycloak.auth-server-url=https://keycloak:8080/auth \
    --keycloak.realm-public-key.file-path="/opt/dark-api/secret" \
    --keycloak.realm=external \
    --keycloak.resource=common-api \
    --server.servlet.context-path=/dark-api/v1 \
    ${@} \
    --spring.config.additional-location=/vault/secrets/application.properties \
