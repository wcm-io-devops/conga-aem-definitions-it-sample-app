#!/bin/bash

function error_log {
  echo ""
  echo -e "[\033[0;31mERROR\033[0m] [$(date -R)] $1"
}

# Build dispatcher config via CONGA
mvn -Pfast -Dconga.environments=local-aem65 -Dconga.nodes=aem-dispatcher clean package

if [[ $? != 0 ]]; then
  error_log "Dispatcher config build failed"
  exit 1
fi

# Copy Docker compose + image together with generated CONGA configuration
rm -rf target/docker-dispatcher-aem65
cp -R src/docker-dispatcher-aem65 target/docker-dispatcher-aem65
mkdir target/docker-dispatcher-aem65/images/aem-dispatcher-publish/conf
cp -R target/configuration/local-aem65/aem-dispatcher/*.d target/docker-dispatcher-aem65/images/aem-dispatcher-publish/conf

# Build and start docker container
docker-compose -f target/docker-dispatcher-aem65/docker-compose.yml build

if [[ $? != 0 ]]; then
  error_log "docker-compose build failed"
  exit 1
fi

docker-compose -f target/docker-dispatcher-aem65/docker-compose.yml up --abort-on-container-exit --exit-code-from aem-dispatcher-publish
docker-compose -f target/docker-dispatcher-aem65/docker-compose.yml down
