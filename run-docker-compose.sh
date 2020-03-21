#!/bin/bash

# default or staging
env=$(docker-compose run --rm terraform workspace show | tr -d '\r');
if [ $1 == "helmfile" ]; then
shift;
docker-compose -f docker-compose.yaml -f docker-compose.${env}.yaml run --rm helmfile --environment ${env} $@
else

docker-compose -f docker-compose.yaml -f docker-compose.${env}.yaml run --rm $@
fi
