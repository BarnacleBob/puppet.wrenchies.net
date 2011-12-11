#!/bin/bash -x

[ -e "$(dirname $0)/functions.sh" ] && source $(dirname $0)/functions.sh || { echo "could not find functions.sh to source"; exit 5; }

if [ "$__BASE__" == "/etc/puppet" ]; then
	echo "you need to bootstrap from a svn checkout from a home directory and not /etc/puppet.  /etc/puppet should not exist or be empty or be default system"
	exit 1
fi

if [ "$EUID" != 0 ]; then
	echo "Please run as root"
	exit 1
fi

echo "installing puppet"
#dpkg -i $__BASE__/puppet.wrenchies.net/packages/ubuntu/10.04/bootstrap/*.deb

#apt-get -yy -f install


rm -rf /etc/puppet

echo "cloning this git repo to /etc/puppet.  this is almost certainly not what you want especially if you have the concept of a central repo.  you will want to clone from that, but you can fix that after this script finishes"
pause
git clone $__BASE__ /etc/puppet

echo "lauching puppet master"
PUPPET_DIR=$(mktemp -d)
mkdir "$PUPPET_DIR/logs"
chown -R puppet:root "$PUPPET_DIR"
chmod -R 750 "$PUPPET_DIR"

(
	puppet master \
		--verbose \
		--debug \
		--no-daemonize \
		--color=false \
		--masterport=8880 \
		--autosign=true \
		--filetimeout=2 \
		--dns_alt_names="localhost" \
		--vardir="$PUPPET_DIR" \
		--ssldir="$PUPPET_DIR/ssl" \
		--confdir="$PUPPET_DIR/conf" \
		--config="/dev/null" \
		--logdir="$PUPPET_DIR/logs" \
		--modulepath="$__BASE__/puppet.wrenchies.net/modules:$__BASE__/puppet.wrenchies.net/environments/production/modules" \
		--manifest="$__BASE__/puppet.wrenchies.net/environments/production/bootstrap.pp"
) > $PUPPET_DIR/logs/forkedmaster.log 2>&1 &

MASTER_PID="$!"

echo "Puppet master launched $MASTER_PID with log $PUPPET_DIR/logs/forkedmaster.log"

echo puppet agent \
	--test \
	--server=localhost \
	--masterport=8880 \
	--vardir="$PUPPET_DIR" \
	--ssldir="$PUPPET_DIR/ssl" \
	--confdir="$PUPPET_DIR/conf" \
	--config="/dev/null" \

sleep 1

tail -F $PUPPET_DIR/logs/forkedmaster.log
pause

echo -n "killing puppetmaster"
while [ -e "/proc/$MASTER_PID" ]; do
	echo -n "."
	kill $MASTER_PID
	sleep 1
done

echo "removing puppet temp dir"
rm -rf $PUPPET_DIR
