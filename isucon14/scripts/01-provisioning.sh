#!/bin/bash

set -ex

export HOME="/root"
GITDIR="/tmp/isucon14"

export DEBIAN_FRONTEND=noninteractive
apt-get install -y --no-install-recommends ansible apt-utils curl make sudo
snap install go --classic
snap install node --classic
# pnpm >=10 turns ignored build scripts into a hard error, and isucon14's
# frontend needs @swc/core and esbuild to run theirs.
npm install -g pnpm@9

rm -rf ${GITDIR}
git clone --depth=1 https://github.com/isucon/isucon14.git ${GITDIR}

sed -i -e "s/_linux_amd64//" ${GITDIR}/provisioning/ansible/roles/bench/tasks/main.yaml
sed -i -e "/isuadmin-user/d" -e "/envcheck/d" ${GITDIR}/provisioning/ansible/application.yml
mkdir -p /etc/ssh/sshd_config.d

# 同梱の証明書は2025-02-01で期限切れとなるため自己署名証明書に差し替える
TLSDIR="${GITDIR}/provisioning/ansible/roles/nginx/files/etc/nginx/tls"
openssl req -subj '/CN=*.xiv.isucon.net' -nodes -newkey rsa:2048 -keyout ${TLSDIR}/_.xiv.isucon.net.key -out ${TLSDIR}/_.xiv.isucon.net.csr
echo "basicConstraints=critical,CA:true,pathlen:0" > ${TLSDIR}/extfile.txt
echo "subjectAltName=DNS.1:*.xiv.isucon.net, DNS.2:xiv.isucon.net" >> ${TLSDIR}/extfile.txt
openssl x509 -in ${TLSDIR}/_.xiv.isucon.net.csr -req -signkey ${TLSDIR}/_.xiv.isucon.net.key -sha256 -days 3650 -out ${TLSDIR}/_.xiv.isucon.net.crt -extfile ${TLSDIR}/extfile.txt

(
  cd ${GITDIR}/frontend
  make
  cp -r ./build/client ../webapp/public/
)
(

  cd ${GITDIR}/bench
  go build -buildvcs=false -ldflags "-s -w" -o ../provisioning/ansible/roles/bench/files/bench
)
(
  cd ${GITDIR}
  tar zcf provisioning/ansible/roles/webapp/files/webapp.tar.gz webapp
)

npm uninstall -g pnpm
snap remove node
snap remove go

(
  cd ${GITDIR}/provisioning/ansible
  ansible-playbook -i inventory/localhost application-base.yml
  ansible-playbook -i inventory/localhost application.yml
  ansible-playbook -i inventory/localhost benchmark.yml
)

# isuride-matcherがcurlで https://isuride.xiv.isucon.net へアクセスするため
# 自己署名証明書をCA証明書として信頼させる
mkdir -p /usr/share/ca-certificates/isucon
cp /etc/nginx/tls/_.xiv.isucon.net.crt /usr/share/ca-certificates/isucon/
sed -i -e '$a isucon/_.xiv.isucon.net.crt' /etc/ca-certificates.conf
update-ca-certificates

rm -rf ${GITDIR}
apt-get purge -y ansible
apt-get autoremove -y

cat > /etc/wsl.conf <<EOF
[boot]
systemd = true

[user]
default = isucon

[network]
generateHosts = false
EOF
#
