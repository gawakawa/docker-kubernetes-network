#!/usr/bin/env bash

docker run -it -d --name="curl-container" test-image
docker run -it -d --name="api-container" test-image

docker exec -it curl-container hostname -i >/dev/null && echo "curl-container is up"
docker exec -it api-container hostname -i >/dev/null && echo "api-container is up"
docker exec -it curl-container curl 172.17.0.3:5000 >/dev/null && echo "connection ok"

docker exec curl-container apk add tcpdump
docker exec api-container apk add tcpdump

docker exec curl-container tcpdump -h >/dev/null && echo "tcpdump installed on curl-container"
docker exec api-container tcpdump -h >/dev/null && echo "tcpdump installed on api-container"
