#!/bin/bash -eux
docker-compose run --rm web-src /host_sync/tools/precopy_appsync
docker-compose up