#!/bin/bash

set -eu

export DEBIAN_FRONTEND=noninteractive

UPGRADE_PACKAGES=${1:-no}
CREATE_USER=${2:-no}
CERTBOT=${3:-no}
CERTBOT_DOMAIN=${4:-example.org}
CERTBOT_EMAIL=${5:-admin@example.org}

# upgrade the machine
if [ "${UPGRADE_PACKAGES}" != "no" ]; then
  echo "==> Updating packages ..."

  # Add third party repositories
  sudo add-apt-repository ppa:keithw/mosh-dev -y
  sudo add-apt-repository ppa:jonathonf/vim -y
  sudo add-apt-repository ppa:certbot/certbot -y

  sudo apt-get update
fi

echo "==> Creating temp dir ..."

# create a temp  dir
TMP_DIR=$(mktemp -d)
cd $TMP_DIR

# Bail out if the temp directory wasn't created successfully.
if [ ! -e $TMP_DIR ]; then
    >&2 echo "Failed to create temp directory"
    exit 1
fi

sudo apt-get install -qq \
  apache2-utils \
  apt-transport-https \
  build-essential \
  bzr \
  ca-certificates \
  clang \
  cmake \
  curl \
  direnv \
  dnsutils \
  fakeroot-ng \
  gdb \
  git \
  gnupg \
  gnupg2 \
  htop \
  ipcalc \
  jq \
  less \
  libclang-dev \
  liblzma-dev \
  libpq-dev \
  libprotoc-dev \
  libsqlite3-dev \
  libssl-dev \
  lldb \
  locales \
  man \
  mosh \
  mtr-tiny \
  musl-tools \
  ncdu \
  netcat-openbsd \
  pkg-config \
  protobuf-compiler \
  pwgen \
  python \
  python3 \
  python3-flake8 \
  python3-pip \
  python3-setuptools \
  python3-venv \
  python3-wheel \
  qrencode \
  quilt \
  shellcheck \
  silversearcher-ag \
  socat \
  software-properties-common \
  sqlite3 \
  stow \
  tig \
  tmate \
  tmux \
  tree \
  unzip \
  wget \
  zgen \
  zip \
  zlib1g-dev \
  zsh \
  certbot \
  python-certbot-nginx \
  --no-install-recommends

rm -rf /var/lib/apt/lists/*

# install code server
if ! [ -x "$(command -v code-server)" ]; then
  export CODE_VERSION="1.1156-vsc1.33.1"
  curl -L https://github.com/cdr/code-server/releases/download/${CODE_VERSION}/code-server${CODE_VERSION}-linux-x64.tar.gz | tar -xzv
  mv code-server${CODE_VERSION}-linux-x64/code-server /usr/local/bin
  chmod +x /usr/local/bin/code-server
fi

# install Go
if ! [ -x "$(command -v go)" ]; then
  export GO_VERSION="1.12.6"
  wget "https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz"
  tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
  rm -f "go${GO_VERSION}.linux-amd64.tar.gz"
  export PATH="/usr/local/go/bin:$PATH"
fi

# install protobuf
if ! [ -x "$(command -v protoc)" ]; then
  export PROTOBUF_VERSION="3.8.0"
  mkdir -p protobuf_install
  pushd protobuf_install
  wget https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protoc-${PROTOBUF_VERSION}-linux-x86_64.zip
  unzip protoc-${PROTOBUF_VERSION}-linux-x86_64.zip
  mv bin/protoc /usr/local/bin
  mv include/* /usr/local/include/
  popd
  rm -rf protobuf_install
fi

# install 1password
if ! [ -x "$(command -v op)" ]; then
  export OP_VERSION="v0.5.7"
  curl -sS -o 1password.zip https://cache.agilebits.com/dist/1P/op/pkg/${OP_VERSION}/op_linux_amd64_${OP_VERSION}.zip
  unzip 1password.zip op -d /usr/local/bin
  rm -f 1password.zip
fi

# upgrade the machine
if [ "${CERTBOT}" != "no" ]; then
  echo "==> Creating certificate ..."
  sudo certbot --nginx -n --agree-tos --email ${CERTBOT_EMAIL} -d ${CERTBOT_DOMAIN}
  sudo certbot enhance --nginx -n --redirect -d ${CERTBOT_DOMAIN} --cert-name ${CERTBOT_DOMAIN}
  sudo sed -i "s/try_files.*/proxy_pass http:\/\/localhost:8443;\nproxy_http_version 1.1;\nproxy_set_header Upgrade \$http_upgrade;proxy_set_header Connection \"Upgrade\";/g" /etc/nginx/sites-available/default
  sudo service nginx restart
fi

# upgrade the machine
if [ "${CREATE_USER}" != "no" ]; then
  echo "==> Create user ..."
  sudo useradd -U -m -s /bin/false coder
fi

if [ ! -f "/lib/systemd/system/coder-server.service" ]; then
  echo "==> Creating coder service"

  PASS=$(pwgen -s1 32)

cat > coder-server.service <<EOL
[Unit]
Description=VSCode on the web pog
After=network.target

[Service]
User=coder
Group=coder

WorkingDirectory=/home/coder
Environment="PASSWORD=${PASS}"
ExecStart=/usr/local/bin/code-server -p 8443 --allow-http --user-data-dir /home/coder
Restart=always

[Install]
WantedBy=multi-user.target
EOL

  echo "==> Generated password: ${PASS}"

sudo mv coder-server.service /lib/systemd/system
sudo systemctl daemon-reload
sleep 10s
sudo systemctl start coder-server
fi

# set correct timezone
timedatectl set-timezone Europe/Berlin

echo ""
echo "==> Done!"

exit
