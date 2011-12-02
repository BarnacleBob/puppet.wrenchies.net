#!/bin/bash

echo "<<INSERT PUPPET MASTER IP HERE>>	puppet.$(hostname -d) puppet" >> /etc/hosts
nano /etc/hosts

rpm -Uvh "http://download.fedora.redhat.com/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm"

rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL

yum -y update

yum -y install puppet

puppetd --test 1>/dev/null 2>&1

read -p "please sign $(hostname) key on the puppetmaster. press enter to continue"

puppetd --test
