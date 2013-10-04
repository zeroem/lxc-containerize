#!/bin/bash

# the majority of this script was taken from
# http://wiki.centos.org/HowTos/LXC-on-CentOS6

mkdir /var/lib/libvirt/lxc/centos-6-x86_64/etc/yum.repos.d/ -p  
cat /etc/yum.repos.d/CentOS-Base.repo |sed s/'$releasever'/6/g > /var/lib/libvirt/lxc/centos-6-x86_64/etc/yum.repos.d/CentOS-Base.repo
yum groupinstall core --installroot=/var/lib/libvirt/lxc/centos-6-x86_64/ --nogpgcheck -y
yum install plymouth libselinux-python --installroot=/var/lib/libvirt/lxc/centos-6-x86_64/ --nogpgcheck -y
