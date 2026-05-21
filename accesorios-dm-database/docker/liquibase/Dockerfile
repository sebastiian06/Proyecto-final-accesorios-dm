FROM liquibase/liquibase:4.25-alpine

USER root
RUN apk add --no-cache postgresql16-client

USER liquibase

WORKDIR /liquibase/changelog

# Liquibase usará las variables de entorno automáticamente:
# LIQUIBASE_URL, LIQUIBASE_USERNAME, LIQUIBASE_PASSWORD, LIQUIBASE_CHANGELOG