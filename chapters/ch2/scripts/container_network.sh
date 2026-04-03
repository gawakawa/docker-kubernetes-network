#!/usr/bin/env bash

# 前提 : docker_network.sh を直前に実行する
# キャッシュを削除する
docker restart curl-container
docker restart api-container

# docker0 ブリッジの情報を確認する
brctl show docker0

# curl-container と api-container に割り当てられている IP アドレスと MAC アドレスを確認する
docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' curl-container
docker inspect --format='{{range .NetworkSettings.Networks}}{{.MacAddress}}{{end}}' curl-container
docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' api-container
docker inspect --format='{{range .NetworkSettings.Networks}}{{.MacAddress}}{{end}}' api-container

# 各コンテナの ARP テーブルを確認する
docker exec curl-container arp
docker exec api-container arp

# 通信が発生する前の MAC アドレステーブルを確認する
brctl showmacs docker0

# コンテナ間通信を行う
docker exec curl-container curl 172.17.0.3:5000

# 各コンテナの ARP テーブルを確認する
docker exec curl-container arp
docker exec api-container arp

# docker0 の MAC アドレステーブルを確認する
brctl showmacs docker0

# コンテナを停止、削除する
docker stop curl-container api-container
docker rm curl-container api-container
