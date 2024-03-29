#!/bin/bash

set -ex

GITDIR="/tmp/isucon12-qualify"
MYARCH=`uname -m`

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends ca-certificates curl gcc git golang libc6-dev locales-all make rsync sudo tzdata

localectl set-locale LANG=ja_JP.UTF-8

rm -rf ${GITDIR}
git clone --depth=1 https://github.com/isucon/isucon12-qualify.git ${GITDIR}
(
  cd ${GITDIR}/bench
  find . -name '*.go' -type f -exec sed -i -e "s/t\.isucon\.dev/t.isucon.local/g" {} +
  make
)
(
  cd ${GITDIR}/blackauth
  go build -o ../provisioning/mitamae/cookbooks/blackauth/blackauth .
)
(
  cd ${GITDIR}/provisioning/mitamae
  curl -L https://github.com/itamae-kitchen/mitamae/releases/download/v1.13.0/mitamae-${MYARCH}-linux.tar.gz | tar xvz

  sed -i -e "s/x86_64/${MYARCH}/" cookbooks/users/isucon.rb
  sed -i -e "s/192\.168/127.0/" cookbooks/common/default.rb
  sed -i -e "/^file.*ssh/,/^end/d" cookbooks/common/default.rb
  if [ "${MYARCH}" != "x86_64" ] ; then
    sed -i -e "s/mysql-client/default-mysql-client/" ${GITDIR}/webapp/*/Dockerfile
  fi
  # devドメインはHSTSが強制有効でブラウザでの動作確認が難しいためドメインを書き換える
  sed -i -e "s/t\.isucon\.dev/t.isucon.local/g" ${GITDIR}/docker-compose.yml ${GITDIR}/frontend/src/views/admin/AdminView.vue
  sed -i -e "s/powawa\.net/t.isucon.local/g" ${GITDIR}/frontend/vue.config.js
  find ${GITDIR}/provisioning -type f -exec sed -i -e "s/\([^ ]*\)\.t\.isucon\.dev/& \1.t.isucon.local/g" {} +
  find ${GITDIR}/public -type f -exec sed -i -e "s/t\.isucon\.dev/t.isucon.local/g" {} +
  find ${GITDIR}/webapp -type f -exec sed -i -e "s/t\.isucon\.dev/t.isucon.local/g" {} +
  sed -i -e "s/mysql-client/default-mysql-client/" ${GITDIR}/webapp/*/Dockerfile
  openssl req -subj '/CN=*.t.isucon.local' -nodes -newkey rsa:2048 -keyout cookbooks/nginx/tls/key.pem -out cookbooks/nginx/tls/csr.pem
  echo "subjectAltName=DNS.1:*.t.isucon.local, DNS.2:*.t.isucon.dev" > cookbooks/nginx/tls/extfile.txt
  openssl x509 -in cookbooks/nginx/tls/csr.pem -req -signkey cookbooks/nginx/tls/key.pem -sha256 -days 3650 -out cookbooks/nginx/tls/fullchain.pem -extfile cookbooks/nginx/tls/extfile.txt

  ./mitamae-${MYARCH}-linux local roles/default.rb

  rsync -a ${GITDIR}/webapp/ /home/isucon/webapp/
  rsync -a ${GITDIR}/public/ /home/isucon/public/
  rsync -a ${GITDIR}/bench/ /home/isucon/bench/
  rsync -a ${GITDIR}/data/ /home/isucon/data/
  curl -sL https://github.com/isucon/isucon12-qualify/releases/download/data%2F20220712_1505-745a3fdfb5783afc048ecaebd054acd20151872d/initial_data.tar.gz | tar zxC /home/isucon/
  chown -R isucon:isucon /home/isucon

  systemctl restart mysql
  mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';"
  cat /home/isucon/webapp/sql/admin/*.sql | mysql -uroot -proot
  ./mitamae-${MYARCH}-linux local roles/webapp.rb
  sudo -u isucon /home/isucon/webapp/sql/init.sh
  update-alternatives --set iptables /usr/sbin/iptables-legacy
  update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
)
rm -rf ${GITDIR}
apt-get purge -y golang
apt-get autoremove -y

cat > /etc/wsl.conf <<EOF
[boot]
systemd = true

[user]
default = isucon
EOF
#
