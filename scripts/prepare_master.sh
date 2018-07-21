#!/usr/bin/env bash

set -e

yum -y install httpd-tools gcc python-devel python-pip
pip -v install ansible

git clone https://github.com/openshift/openshift-ansible.git ~/openshift-ansible
(cd ~/openshift-ansible/ && git checkout openshift-ansible-3.9.37-1)

yum -y install nfs-utils
mkfs.ext4 /dev/sdb
mkdir /var/nfs-data/
uuid=$(blkid | grep sdb | cut -d \" -f 2)
echo "UUID=${uuid} /var/nfs-data  ext4 defaults 0 0" >> /etc/fstab
mount -a
echo "VERIFY mkfs.ex4 and mount"
lsblk
mount

mkdir -p /var/nfs-data/{pv01,pv02,pv03,pv04,pv05}

cat <<EOF > /etc/exports
/var/nfs-data/pv01 *(rw,root_squash)
/var/nfs-data/pv02 *(rw,root_squash)
/var/nfs-data/pv03 *(rw,root_squash)
/var/nfs-data/pv04 *(rw,root_squash)
/var/nfs-data/pv05 *(rw,root_squash)
EOF

chown -R nfsnobody:nfsnobody /var/nfs-data/
chmod -R 0770 /var/nfs-data/
ls -al /var/nfs-data/

echo "VERIFY: Check firewall"
iptables -L -v -n | grep 2049
iptables -I INPUT -p tcp --dport 2049 -j ACCEPT
iptables -L -v -n | grep 2049
service iptables save

for i in rpcbind nfs-server nfs-lock nfs-idmap;do systemctl enable $i;systemctl start $i;done
for i in rpcbind nfs-server nfs-lock nfs-idmap;do systemctl restart $i;done
echo "VERIFY: exportfs"
exportfs

# from repo
#ansible-playbook -i /root/hosts /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml
#ansible-playbook -i /root/hosts /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml

# from github
#ansible-playbook -i /root/hosts ~/openshift-ansible/playbooks/prerequisites.yml
#ansible-playbook -i /root/hosts ~/openshift-ansible/playbooks/deploy_cluster.yml