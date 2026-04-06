#!/usr/bin/env bash

hst a <<EOF
# api-container を起動する
docker stop api-container
docker rm api-container
docker run -it -d --name="api-container" -p 5000:5000 test-image

# iptables のチェインにログを設定する
sudo iptables -t nat -I PREROUTING 1 -j LOG --log-prefix "PREROUTING: "
sudo iptables -t nat -I DOCKER 1 -j LOG --log-prefix "NAT DOCKER: "
sudo iptables -t nat -I POSTROUTING 1 -j LOG --log-prefix "POSTROUTING: "
sudo iptables -I FORWARD 1 -j LOG --log-prefix "FORWARD: "
sudo iptables -I DOCKER 1 -j LOG --log-prefix "FILTER DOCKER: "

sudo iptables -L -t nat
sudo iptables -L
EOF
