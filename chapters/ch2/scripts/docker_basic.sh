#!/usr/bin/env bash

# コンテナイメージをビルドする
docker build -t test-image ./
docker images

# 作成したコンテナイメージを元に、コンテナを 2 つ起動する
docker run -it -d --name="curl-container" test-image
docker run -it -d --name="api-container" test-image
docker ps

# api-container の IP アドレスを取得する
API_IP=$(docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' api-container)

# コンテナにアクセスし、 API リクエストを実行する
docker exec -i curl-container sh <<EOF
curl ${API_IP}:5000
EOF
