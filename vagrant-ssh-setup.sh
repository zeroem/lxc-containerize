#!/bin/bash

if [ -z "$1" ]
then
    echo "No Root Filesystem Specified"
    exit 1
fi

ROOTFS=$1

# Configure SSH access
sudo mkdir -p ${ROOTFS}/home/vagrant/.ssh
sudo wget https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub -O ${ROOTFS}/home/vagrant/.ssh/authorized_keys
sudo chroot ${ROOTFS} chown -R vagrant:vagrant /home/vagrant/.ssh

# Enable passwordless sudo for users under the "sudo" group
sudo cp ${ROOTFS}/etc/sudoers{,.orig}
sudo sed -i -e \
      's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' \
      ${ROOTFS}/etc/sudoers
