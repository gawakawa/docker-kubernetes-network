#!/usr/bin/env bash

# ホストのグローバル IP アドレス
HOST_A_IP=$(tofu -chdir=terraform output -json instance_public_ips | jq -r '."host-a"')
HOST_B_IP=$(tofu -chdir=terraform output -json instance_public_ips | jq -r '."host-b"')

# 各ホストで vxlan デバイスを作成する
hst a <<EOF
sudo ip link add vxlan0 type vxlan id 10 dstport 4789 dev enX0
sudo ip address add 192.168.1.1/24 broadcast 192.168.1.255 dev vxlan0
sudo ip link set vxlan0 up
ip address
EOF
hst b <<EOF
sudo ip link add vxlan0 type vxlan id 10 dstport 4789 dev enX0
sudo ip address add 192.168.1.2/24 broadcast 192.168.1.255 dev vxlan0
sudo ip link set vxlan0 up
ip address
EOF

# ホスト A からホスト B に ping する
echo "ping -c 1 192.168.1.2" | hst a

# vxlan0 に宛先ホストの情報を設定し、ホスト間通信を可能にする
hst a <<EOF
sudo bridge fdb append 00:00:00:00:00:00 dev vxlan0 dst $HOST_B_IP
bridge fdb show | grep vxlan0
EOF
hst b <<EOF
sudo bridge fdb append 00:00:00:00:00:00 dev vxlan0 dst $HOST_A_IP
bridge fdb show | grep vxlan0
EOF

# ホスト A からホスト B に ping する
echo "ping -c 1 192.168.1.2" | hst a

# ホスト A でホスト B からの通信をキャプチャする
echo "sudo tcpdump -n host $HOST_B_IP" | hst a -d
hst b <<EOF
ping -c 1 $HOST_A_IP
ping -c 1 192.168.1.1
EOF
hst a <<EOF
sudo pkill tcpdump
cat /tmp/detached.out
EOF

# vxlan0 のインターフェースを削除する
echo "sudo ip link delete vxlan0" | hst a
echo "sudo ip link delete vxlan0" | hst b
