#!/bin/bash -x

[ -e "$(dirname $0)/functions.sh" ] && source $(dirname $0)/functions.sh || { echo "could not find functions.sh to source"; exit 5; }

if [ "$__BASE__" == "/etc/puppet" ]; then
	echo "you need to bootstrap from a svn checkout from a home directory and not /etc/puppet.  /etc/puppet should not exist or be empty or be default system"
	exit 1
fi

if [ -e "/etc/puppet" ]; then
	if [ -e "/etc/puppet/.svn" ]; then
		echo "will not remove /etc/puppet because its an svn checkout.  please delete it yourself"
		exit 1
	fi
	
	rm -rf /etc/puppet
fi


rpm -Uvh $__BASE__/modules/shared/files/all/tmp/epel-release-5-4.noarch.rpm
yum -y install puppet
rm -rf /etc/puppet

iptables -I RH-Firewall-1-INPUT -p tcp --dport 8140 -m state --state NEW -j ACCEPT

svn checkout $(svn info $__BASE__ | grep URL: | cut -d: -f2-) /etc/puppet

cat $__BASE__/modules/shared/manifests/defines/*.pp > /tmp/puppetBootstrap.pp

perl -i -ple "s#puppet://puppet#$__BASE__#ig" /tmp/puppetBootstrap.pp
perl -i -ple "s#(modules/[^/]+)#\1/files#ig" /tmp/puppetBootstrap.pp
perl -i -ple "s#\\\$prefix#$__BASE__#ig" /tmp/puppetBootstrap.pp
perl -i -ple 's#\$realEnvironment#production#ig' /tmp/puppetBootstrap.pp
perl -i -ple 's#files/files#files#ig' /tmp/puppetBootstrap.pp

cat >> /tmp/puppetBootstrap.pp <<-BOOTSTRAP

filebucket{"client": path=>"/var/lib/puppet/clientbucket" }

Exec { path=>"/bin:/usr/bin:/sbin:/usr/sbin" }

File{ backup=>"client" }

\$realEnvironment="production"
\$prefix="/etc/puppet"

import "$__BASE__/modules/shared/manifests/classes/epel.pp"
import "$__BASE__/modules/shared/manifests/classes/base.pp"
import "$__BASE__/modules/shared/manifests/classes/mysql.pp"
import "$__BASE__/modules/shared/manifests/classes/puppet.pp"
import "$__BASE__/modules/shared/manifests/classes/puppetmaster.pp"

node "$(hostname)" {
	 dir{"/data": }
	 dir{"/data/logs": }
	 dir{"/data/config": }
	 rDir{
	 	"/data/bin":
	 		sourceselect=>all,
	 		purge=>true,
	 		force=>true,
	 }

	 include shared::epel
	 include shared::puppet
	 include shared::mysql
	 include shared::puppetmaster
}

BOOTSTRAP

puppet --verbose /tmp/puppetBootstrap.pp

#rm /tmp/puppetBootstrap.pp
