#!/usr/bin/env bash

HOST_A_IP=$(tofu -chdir=terraform output -json instance_public_ips | jq -r '."host-a"')
HOST_B_IP=$(tofu -chdir=terraform output -json instance_public_ips | jq -r '."host-b"')

cpy a -r chapters/ch3/chatapp
cpy b -r chapters/ch3/chatapp

hst a <<EOF
sed -i 's/HOST_IP/$HOST_A_IP/' ~/chatapp/templates/chat.html
docker build -t chat-app ~/chatapp
docker run -d --name redis --net vxlan-net --ip 172.18.0.100 redis
docker run -d --name chat-a --net vxlan-net --ip 172.18.0.11 -p 5000:5000 chat-app
EOF

hst b <<EOF
sed -i 's/HOST_IP/$HOST_B_IP/' ~/chatapp/templates/chat.html
docker build -t chat-app ~/chatapp
docker run -d --name chat-b --net vxlan-net --ip 172.18.0.22 -p 5000:5000 chat-app
EOF
