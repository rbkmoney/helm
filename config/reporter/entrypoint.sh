#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/reporter/reporter.jar \
    --logging.config=/opt/reporter/logback.xml \
    --management.security.flag=false \
    --management.metrics.export.statsd.flavor=etsy \
    --management.metrics.export.statsd.enabled=true \
    --management.metrics.export.prometheus.enabled=true \
    --management.endpoint.health.show-details=always \
    --management.endpoint.metrics.enabled=true \
    --management.endpoint.prometheus.enabled=true \
    --management.endpoints.web.exposure.include=health,info,prometheus \
    --spring.datasource.hikari.data-source-properties.prepareThreshold=0 \
    --spring.datasource.hikari.leak-detection-threshold=5300 \
    --spring.datasource.hikari.max-lifetime=300000 \
    --spring.datasource.hikari.idle-timeout=30000 \
    --spring.datasource.hikari.minimum-idle=2 \
    --spring.datasource.hikari.maximum-pool-size=20 \
    --spring.output.ansi.enabled=never \
    --spring.quartz.jdbc.initialize-schema=never \
    --spring.flyway.table=schema_version \
    --partyManagement.url=http://party-management:8022/v1/processing/partymgmt \
    --partyManagement.timeout=30000 \
    --magista.url=http://magista:8022/stat \
    --magista.timeout=700000 \
    --domainConfig.url=http://dominant:8022/v1/domain/repository \
    --domainConfig.timeout=30000 \
    --storage.endpoint=eu-central-1.linodeobjects.com \
    --storage.signingRegion=EU \
    --storage.bucketName=files \
    --storage.accessKey=YOUR_S3_ACCESS_KEY \
    --storage.secretKey=YOUR_S3_SECRET_KEY \
    --storage.client.protocol=HTTP \
    --payouter.polling.enabled=true \
    --payouter.polling.url=http://payouter:8022/repo \
    --hellgate.invoicing.url=http://hellgate:8022/v1/processing/invoicing \
    --hellgate.invoicing.timeout=60000 \
    --kafka.bootstrap-servers=kafka:9092 \
    --kafka.topics.invoicing.enabled=true \
    --kafka.topics.invoicing.id=mg-events-invoice \
    --kafka.topics.invoicing.concurrency=10 \
    --kafka.topics.invoicing.throttling-timeout-ms=0 \
    --kafka.topics.invoicing.error-throttling-timeout-ms=1000 \
    --kafka.topics.party-management.id=mg-events-party \
    --kafka.topics.party-management.enabled=true \
    --kafka.topics.party-management.concurrency=1 \
    --kafka.client-id=reporter \
    --kafka.consumer.group-id=ReporterGroup \
    --kafka.consumer.max-poll-records=350 \
    --kafka.consumer.max-poll-interval-ms=300000 \
    --kafka.consumer.session-timeout-ms=300000 \
    --kafka.consumer.auto-offset-reset=earliest \
    ${@} \
    --spring.config.additional-location=/vault/secrets/application.properties \
