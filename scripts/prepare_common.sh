#!/usr/bin/env bash

set -e

yum -y install epel-release centos-release-openshift-origin39
yum -y install origin origin-clients vim-enhanced atomic-openshift-utils NetworkManager python-rhsm-certificates
systemctl enable NetworkManager --now


sleep 3

cat <<EOF > /etc/NetworkManager/NetworkManager.conf
[main]
dns=none

[logging]
EOF

cat <<EOF > /etc/resolv.conf
search nip.io
nameserver 8.8.8.8
EOF

systemctl restart NetworkManager

sleep 2

echo "VERIFY /etc/resolv.conf "
cat /etc/resolv.conf

setsebool -P virt_use_nfs 1
setsebool -P virt_sandbox_use_nfs 1
