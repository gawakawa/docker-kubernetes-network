#!/usr/bin/env bash

docker network create --subnet 172.18.0.0/16 --attachable=true -o "com.docker.network.bridge.name"="test-net" test-net
docker network ls

docker run -d --network test-net --ip 172.18.0.2 --name test-container test-image

docker network inspect test-net -f '{{json .Containers}}' | jq .
ip address
brctl show test-net

docker stop test-container
docker rm test-container
docker network rm test-net
