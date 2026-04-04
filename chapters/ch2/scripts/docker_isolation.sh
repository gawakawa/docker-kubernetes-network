#!/usr/bin/env bash

# iptables を確認する
sudo iptables -L -nv

# Docker のブリッジを追加する
docker network create --opt "com.docker.network.bridge.name"=br0 test-nw

# 再度 iptables を確認する
sudo iptables -L -nv

# test-nw を削除する
docker network rm test-nw
