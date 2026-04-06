#!/usr/bin/env bash

# ホストのネットワークデバイスを確認する
ip address

# ホストのルーティングテーブルを確認する
ip route

# Docker のネットワーク情報を確認する
docker network ls

# bridge ネットワークの詳細を確認する
docker network inspect bridge

# コンテナを起動する
docker run -d --name=test-container alpine:latest tail -f /dev/null
docker ps

# ホストのネットワークデバイスを確認する
# docker0 が up になり、docker0 とリンクしている veth が作成されている
ip address

# netns を確認する
PID=$(docker inspect test-container --format '{{.State.Pid}}')
sudo ls -la /proc/"${PID}"/ns/net
sudo mkdir /var/run/netns
sudo ln -s /proc/"${PID}"/ns/net /var/run/netns/test-ns
ip netns

# test-ns を確認する
sudo ip netns exec test-ns ip address

# netns を確認する
sudo ip netns exec test-ns ip address
sudo ip netns exeec test-ns cat /sys/class/net/eth0/iflink
ip address

# bridge ネットワークの詳細を確認する
docker network inspect bridge

# クリーンアップ
docker stop test-container
docker rm test-container
