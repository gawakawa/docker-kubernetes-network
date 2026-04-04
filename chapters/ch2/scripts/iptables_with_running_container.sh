#!/usr/bin/env bash

# コンテナを起動する
docker run -dti -p 8888:80 alpine /bin/sh

# filter テーブルを確認する
# DOCKER チェインに、 docker0 以外から docker0 への通信のうち、172.17.0.2:80 への TCP パケットが許可されるルールが追加される
sudo iptables -L -nv

# nat テーブルを確認する
# 送信元も送信先も 172.17.0.2 であるようなルール ( つまり通ることがない ) と
# docker0  以外の送信元から 8888 番ポートにアクセスがきたときに 172.17.0.2:80 にアドレス変換されるルールが追加される
sudo iptables -L -nv -t nat

# クリーンアップ
docker rm -f "$(docker ps -q --filter "publish=8888")"
