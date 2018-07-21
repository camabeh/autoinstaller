#!/usr/bin/env bash

set -e

yum -y install docker libcgroup-tools

cat <<EOF > /etc/sysconfig/docker-storage-setup
DEVS=/dev/sdb
VG=docker-vg
EOF

docker-storage-setup
systemctl enable docker.service --now