#!/bin/bash

set -ex

GITDIR="/tmp/isucon12-final"

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends ansible curl git make sudo wget

rm -rf ${GITDIR}
git clone --depth=1 https://github.com/isucon/isucon12-final.git ${GITDIR}
(
  cd ${GITDIR}/dev
  make initial-data
)
(
  cd ${GITDIR}/provisioning/packer/ansible
  sed -i -e "/go-install/s/$/ `uname -s | tr 'A-Z' 'a-z'` `dpkg --print-architecture`/" roles/xbuild/tasks/main.yml
  ansible-playbook -i standalone, -c local base.yml application.yml benchmarker.yml
)
rm -rf ${GITDIR}
apt-get purge -y ansible
apt-get autoremove -y
systemctl restart nginx
systemctl restart isuconquest.go

cat > /etc/wsl.conf <<EOF
[boot]
command = /usr/libexec/wsl-systemd

[user]
default = isucon
EOF
#
