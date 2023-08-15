#!/bin/bash

read -p "Digite o nome seu domínio: " seudominio
read -p "Digite o ip do servidor: " ip
read -p "Digite a senha do administrator: " senhaadmin
read -p "Digite o nome do servidor: " suamaquina
read -p "Digite o link para baixar a versão do samba: " samba

dominio_realm=$seudominio".local"
dominio=$seudominio
ip=$ip
adminpass=$senhaadmin
nomedamaquina=$suamaquina"_dc"

# Instalação de dependências CentOS7
yum install -y attr bind-utils docbook-style-xsl gcc gdb krb5-workstation        libsemanage-python libxslt perl perl-ExtUtils-MakeMaker        perl-Parse-Yapp perl-Test-Base pkgconfig policycoreutils-python        python2-crypto gnutls-devel libattr-devel keyutils-libs-devel        libacl-devel libaio-devel libblkid-devel libxml2-devel openldap-devel        pam-devel popt-devel python-devel readline-devel zlib-devel systemd-devel        lmdb-devel jansson-devel gpgme-devel pygpgme libarchive-devel
yum remove nettle-devel gnutls-devel

set -xueo pipefail

yum update -y
yum install -y epel-release
yum install -y yum-plugin-copr
yum copr enable -y sergiomb/SambaAD
yum update -y

yum install -y \
    "@Development Tools" \
    acl \
    attr \
    autoconf \
    avahi-devel \
    bind-utils \
    binutils \
    bison \
    ccache \
    chrpath \
    compat-gnutls37-devel \
    cups-devel \
    curl \
    dbus-devel \
    docbook-dtds \
    docbook-style-xsl \
    flex \
    gawk \
    gcc \
    gdb \
    git \
    glib2-devel \
    glibc-common \
    gpgme-devel \
    gzip \
    hostname \
    htop \
    jansson-devel \
    jq \
    keyutils-libs-devel \
    krb5-devel \
    krb5-server \
    krb5-workstation \
    lcov \
    libacl-devel \
    libarchive-devel \
    libattr-devel \
    libblkid-devel \
    libbsd-devel \
    libcap-devel \
    libicu-devel \
    libpcap-devel \
    libtasn1-devel \
    libtasn1-tools \
    libtirpc-devel \
    libunwind-devel \
    libuuid-devel \
    libxslt \
    lmdb \
    lmdb-devel \
    make \
    mingw64-gcc \
    ncurses-devel \
    openldap-devel \
    pam-devel \
    patch \
    perl-Archive-Tar \
    perl-ExtUtils-MakeMaker \
    perl-JSON \
    perl-JSON-Parse \
    perl-Parse-Yapp \
    perl-Test-Base \
    perl-core \
    perl-generators \
    perl-interpreter \
    pkgconfig \
    popt-devel \
    procps-ng \
    psmisc \
    python3-libsemanage \
    python3-policycoreutils \
    python36 \
    python36-cryptography \
    python36-devel \
    python36-dns \
    python36-gpg \
    python36-iso8601 \
    python36-markdown \
    python36-pyasn1 \
    python36-requests \
    python36-setproctitle \
    quota-devel \
    readline-devel \
    redhat-lsb \
    rng-tools \
    rpcgen \
    rsync \
    sed \
    sudo \
    systemd-devel \
    tar \
    tree \
    wget \
    which \
    xfsprogs-devel \
    xz \
    yum-utils \
    zlib-devel

yum clean all

# Começo do Script
cd /opt
wget $samba -P /opt/

tar zxvf samba-4.* -C /opt/
cd /opt/samba-4.*/

./configure
make -j 2
make -j 2 install 
export PATH=/usr/local/samba/bin/:/usr/local/samba/sbin/:$PATH

sudo tee /etc/systemd/system/samba4.service <<EOF
[Unit]
Description=Samba Active Directory Domain Controller
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
ExecStart=/usr/local/samba/sbin/samba -D
PIDFile=/usr/local/samba/var/run/samba.pid
ExecReload=/bin/kill -HUP $MAINPID

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload


systemctl enable samba4

systemctl restart samba4

echo "$ip   $nomedamaquina.$dominio_realm $nomedamaquina" >> /etc/hosts

sudo tee /etc/resolv.conf <<EOF
domain $dominio_realm
search $dominio_realm
nameserver $ip
nameserver 1.1.1.1
EOF

samba-tool domain provision --server-role=dc --use-rfc2307 --dns-backend=SAMBA_INTERNAL --realm=$dominio_realm --domain=$dominio --adminpass=$adminpass

systemctl enable samba4

systemctl restart samba4

systemctl mask smbd nmbd winbind

systemctl disable smbd nmbd winbind

/usr/local/samba/sbin/samba_dnsupdate --verbose

mv /etc/krb5.conf /etc/krb5.conf.old 
cp /usr/local/samba/private/krb5.conf /etc/krb5.conf

sleep 2
smbclient -L localhost -N
sleep 2
host -t SRV _ldap._tcp.$dominio_realm.
sleep 2
host -t SRV _kerberos._udp.$dominio_realm.
sleep 2
host -t A $nomedamaquina.$dominio_realm.
sleep 2

echo -e "$adminpass" | kinit administrator
sleep 2
klist