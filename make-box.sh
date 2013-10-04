#!/bin/bash

if [ -z "$1" ]
then
    echo "FSDIR not provided"
    exit 1
fi

FSDIR=$1

if [ ! -d $FSDIR/rootfs ]
then
    echo "FSDIR must have a rootfs directory"
    exit 2
fi

DIR=$(mktemp -d)

# Compress container's rootfs
sudo tar -C $FSDIR --numeric-owner -czf $DIR/rootfs.tar.gz ./rootfs/*

# Prepare package contents
cd $DIR
sudo chown $USER:`id -gn` rootfs.tar.gz
wget https://raw.github.com/fgrehm/vagrant-lxc/master/boxes/common/lxc-template
wget https://raw.github.com/fgrehm/vagrant-lxc/master/boxes/common/lxc.conf
wget https://raw.github.com/fgrehm/vagrant-lxc/master/boxes/common/metadata.json
chmod +x lxc-template

# Vagrant box!
tar -czf vagrant-lxc.box ./*
