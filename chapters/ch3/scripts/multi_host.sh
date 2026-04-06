#!/usr/bin/env bash
#
#      ┌─────────────┐                          ┌─────────────┐
#      │    enX0     │◄────────────────────────►│    enX0     │
#      └──────┬──────┘                          └──────┬──────┘
#             │ VXLAN (UDP 4789)                       │
#      ┌──────┴──────┐                          ┌──────┴──────┐
#      │   vxlan0    │                          │   vxlan0    │
#      │ 172.100.0.1 │                          │ 172.100.0.1 │
#      └──────┬──────┘                          └──────┬──────┘
#             │                                        │
#      ┌──────┴──────┐                          ┌──────┴──────┐
#      │  vxlan-net  │                          │  vxlan-net  │
#      │172.18.0.0/16│                          │172.18.0.0/16│
#      └──────┬──────┘                          └──────┬──────┘
#             │ veth                                   │ veth
#   ┌─────────┼───────────────────────────────────────┼───────────────┐
#   │         │ eth0                                  │ eth0          │
#   │  ┌──────┴──────┐                         ┌──────┴──────┐        │
#   │  │   test-a    │                         │   test-b    │        │
#   │  │ 172.18.0.11 │                         │ 172.18.0.22 │        │
#   │  └─────────────┘                         └─────────────┘        │
#   │                                                                 │
#   └─────────────────────────────────────────────────────────────────┘
#                        Overlay Network (172.18.0.0/16)
#

HOST_A_IP=$(tofu -chdir=terraform output -json instance_public_ips | jq -r '."host-a"')
HOST_B_IP=$(tofu -chdir=terraform output -json instance_public_ips | jq -r '."host-b"')

# vxlan 用のデバイス vxlan0 を作成し、起動する
hst a <<EOF
sudo ip link add vxlan0 type vxlan id 10 remote "$HOST_B_IP" dstport 4789 dev enX0
sudo ip address add 172.100.0.1/16 broadcast 172.100.255.255 dev vxlan0
sudo ip link set vxlan0 up
EOF

hst b <<EOF
sudo ip link add vxlan0 type vxlan id 10 remote "$HOST_A_IP" dstport 4789 dev enX0
sudo ip address add 172.100.0.1/16 broadcast 172.100.255.255 dev vxlan0
sudo ip link set vxlan0 up
EOF

# コンテナネットワーク vxlan-net を作成する
echo 'docker network create --attachable=true --subnet 172.18.0.0/16 -o "com.docker.network.bridge.name"="vxlan-net" vxlan-net' | hst a
echo 'docker network create --attachable=true --subnet 172.18.0.0/16 -o "com.docker.network.bridge.name"="vxlan-net" vxlan-net' | hst b

# vxlan-net のデバイスとして vxlan0 を登録する
echo "sudo ip link set vxlan0 master vxlan-net" | hst a
echo "sudo ip link set vxlan0 master vxlan-net" | hst b

# コンテナを立ち上げる
echo "docker run -d --rm --name test-a --net vxlan-net --ip 172.18.0.11 alpine sleep 3600" | hst a
echo "docker run -d --rm --name test-b --net vxlan-net --ip 172.18.0.22 alpine sleep 3600" | hst b

# パケットをキャプチャし、 enX0 以外ではプライベート IP で通院していることを確認する
echo "sudo tcpdump icmp -i vxlan-net -c 6 -n" | hst -d b
echo "sudo tcpdump icmp -i vxlan0 -c 6 -n" | hst -d b
echo "sudo tcpdump -i enX0 -c 6 -n | grep VXLAN" | hst -d b

# クリーンアップ
echo "docker stop test-a" | hst a
echo "docker stop test-b" | hst b
