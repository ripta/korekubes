#!/bin/bash

download_kube() {
  DIR="$1"
  FILE="$2"
  curl -L -o $DIR/$FILE "https://storage.googleapis.com/kubernetes-release/release/v$KUBERNETES_VERSION/bin/linux/amd64/$FILE"
  chmod +x $DIR/$FILE
}

download_url() {
  DIR="$1"
  FILE="$2"
  URL="$3"
  curl -L -o $DIR/$FILE "$URL"
  chmod +x $DIR/$FILE
}

TMPDIR=`mktemp -d`
download_kube $TMPDIR kube-apiserver
download_kube $TMPDIR kube-controller-manager
download_kube $TMPDIR kube-scheduler
download_kube $TMPDIR kube-proxy
download_kube $TMPDIR kubelet
download_url $TMPDIR setup-network-environment "https://github.com/kelseyhightower/setup-network-environment/releases/download/v1.0.0/setup-network-environment"

sudo mkdir -p /opt/bin
sudo cp -p $TMPDIR/* /opt/bin/
sudo chown root:root -R /opt/bin
