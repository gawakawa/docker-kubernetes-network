#!/usr/bin/env bash

# host ドライバ
# ホストのネットワークスタックを直接利用できる
docker run --rm -it --network=host alpine ip address

# none ドライバ
# コンテナにネットワーク接続を提供しない
docker run --rm -it --network=none alpine ip address
