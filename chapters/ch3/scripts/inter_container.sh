#!/usr/bin/env bash

# 事前に setup.sh を実行すること

# ARP キャッシュをクリアする
docker restart curl-container
docker exec curl-container arp -n

# 1. ARP で送信先 MAC アドレスを取得する
sudo tcpdump arp -i docker0 -n -e -q -c 4 &
docker exec curl-container curl 172.17.0.3:5000
MAC_DST=$(docker exec curl-container arp -n 172.17.0.3 | awk '{print $4}')

# 2. curl-container 内のルーティングテーブルを見て、curl-container の eth0 に向かう
docker exec -it curl-container ip route

# 3. eth0 の veth ペアをルックアップし、もう一方の veth デバイスに向かう
IFINDEX=$(docker exec curl-container cat /sys/class/net/eth0/iflink)
ip address | grep "^$IFINDEX"

# 4. veth は docker0 に属しているので、docker0 に到達した
brctl show docker0

# 5. docker0 内で forwading database を見て、宛先 MAC アドレスに紐づくデバイス (veth) に流す
bridge fdb show | grep "${MAC_DST}"

# 6. veth ペアを通して api-container に到達する
