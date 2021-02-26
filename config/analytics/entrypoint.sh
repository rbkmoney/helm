#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/analytics/analytics.jar \
    --logging.config=/opt/analytics/logback.xml \
    --spring.application.name=analytics \
    --kafka.bootstrap.servers=kafka-headless:9092 \
    --kafka.topic.event.sink.initial=mg-events-invoice \
    --kafka.topic.payout.initial=payout \
    --kafka.topic.party.initial=mg-events-party \
    --kafka.consumer.concurrency=7 \
    --kafka.consumer.prefix=analytics-v10 \
    --kafka.max.poll.records=200 \
    --kafka.max.poll.interval.ms=300000 \
    --kafka.max.session.timeout.ms=300000 \
    --spring.datasource.hikari.data-source-properties.prepareThreshold=0 \
    --spring.datasource.hikari.leak-detection-threshold=5300 \
    --spring.datasource.hikari.max-lifetime=300000 \
    --spring.datasource.hikari.idle-timeout=30000 \
    --spring.datasource.hikari.minimum-idle=2 \
    --spring.datasource.hikari.maximum-pool-size=20 \
    --spring.flyway.schemas=analytics \
    --postgres.db.schema=analytics \
    --flyway.schemas=analytics \
    --columbus.url=http://columbus.default.svc.cluster.local:8022/repo \
    --columbus.networkTimeout=60000 \
    --service.invoicing.url=http://hellgate.default.svc.cluster.local:8022/v1/processing/invoicing \
    --service.invoicing.networkTimeout=60000 \
    --service.payouter.url=http://payouter.default.svc.cluster.local:8022/payout/management \
    --service.payouter.networkTimeout=60000 \
    --service.dominant.url=http://dominant.default.svc.cluster.local:8022/v1/domain/repository_client \
    --service.dominant.networkTimeout=60000 \
    --service.dominant.scheduler.enabled=true \
    --service.dominant.scheduler.pollingDelay=10000 \
    --service.dominant.scheduler.querySize=10 \
    --logging.level.com.rbkmoney.analytics.service.PartyService=DEBUG \
    --logging.level.com.rbkmoney.analytics.listener.handler.party.PartyMachineEventHandler=DEBUG \
    --logging.level.com.rbkmoney.analytics.listener.mapper.party.ContractorCreatedHandler=DEBUG \
    ${@} \
    --spring.config.additional-location=/vault/secrets/application.properties \

