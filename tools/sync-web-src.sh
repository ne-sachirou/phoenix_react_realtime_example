#!/bin/bash -eux
docker-compose stop web-src
docker-compose run --rm web-src /host_sync/tools/precopy_appsync
docker-compose start web-src