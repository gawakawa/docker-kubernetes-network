#!/usr/bin/env bash

# netns を作成する
sudo ip netns add netns0
ip netns show

# netns0 がホストのネットワークと独立した環境にあることを確認する
sudo ip netns exec netns0 ip link show
HOST_IP=$(ip route get 1 | awk '{print $7; exit}')
sudo ip netns exec netns0 ping -c 1 "$HOST_IP"
sudo ip netns exec netns0 ping -c 1 www.google.com

# veth ペアを作成する
sudo ip link add name veth0_container type veth peer name veth0_br
sudo ip link add name veth1_host type veth peer name veth1_br
ip link

# veth0_container を netns0 に移す
sudo ip link set dev veth0_container netns netns0
ip link
sudo ip netns exec netns0 ip link show

# 仮想ブリッジ bridge0 を作成する
sudo ip link add name bridge0 type bridge
ip link show bridge0

# bridge0 に veth0_br と veth1_br を接続する
sudo ip link set dev veth0_br master bridge0
sudo ip link set dev veth1_br master bridge0
ip link

# veth0_container, veth1_host, bridge0 に IP アドレスを設定する
sudo ip netns exec netns0 ip address add 192.168.0.1/24 dev veth0_container
sudo ip netns exec netns0 ip address show veth0_container
sudo ip address add 192.168.0.2/24 dev veth1_host
ip address show veth1_host
sudo ip address add 192.168.0.254/24 broadcast 192.168.0.255 label bridge0 dev bridge0
ip address show bridge0

# デバイスを起動する
sudo ip link set bridge0 up
sudo ip link set veth0_br up
sudo ip link set veth1_host up
sudo ip link set veth1_br up
sudo ip netns exec netns0 ip link set veth0_container up

# netns0 から veth1_host( ホストのnetns) に通信できるか確認する
sudo ip netns exec netns0 ping -c 1 192.168.0.2

# netns0 から bridge0( ホストの netns) に通信できるか確認する
sudo ip netns exec netns0 ping -c 1 192.168.0.254

# ホストの netns から veth0_container(netns0) に通信できるか確認する
ping -c 1 192.168.0.1

# クリーンアップする
sudo ip netns delete netns0
sudo ip link delete dev bridge0
sudo ip link delete dev veth1_br
