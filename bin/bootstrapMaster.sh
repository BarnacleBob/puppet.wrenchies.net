#!/bin/bash

[ -e "$(dirname $0)/functions.sh" ] && source $(dirname $0)/functions.sh || { echo "could not find functions.sh to source"; exit 5; }

if [ "$__BASE__" == "/etc/puppet" ]; then
	echo "you need to bootstrap from a svn checkout from a home directory and not /etc/puppet.  /etc/puppet should not exist or be empty or be default system"
	exit 1
fi

if [ "$EUID" != 0 ]; then
	echo "Please run as root"
	exit 1
fi

DELETED="FALSE"

if [ -e "/etc/puppet" ]; then
	read -p "/etc/puppet already exists.  remove it? (you should answer yes if this is the firstrun or you want to change your git checkout) yes/(no)"
	if [ "$REPLY" == "yes" ]; then
		rm -rf /etc/puppet
		DELETED="TRUE"
	fi
else
	DELETED="TRUE"
fi

PUPPET_DIR=$(mktemp -d)
mkdir "$PUPPET_DIR/logs"



if dpkg -l puppetmaster-passenger > /dev/null 2>&1 ; then
	echo "looks like you already have puppet installed"
	read -p "would you like to reinstall? yes/(no)"

	if [ "$REPLY" == "yes" ]; then
		apt-get -yy purge $(ls $__BASE__/puppet.wrenchies.net/packages/ubuntu/10.04/bootstrap/*.deb | perl -nle 'print $1 if m#/([^/]+).deb#')
	fi
fi

dpkg -l puppetmaster-passenger > /dev/null 2>&1
ret=$?

if [ "$ret" -ne 0 ]; then
	echo "installing puppet logs: $PUPPET_DIR/logs/apt.log"
	dpkg -i $__BASE__/puppet.wrenchies.net/packages/ubuntu/10.04/bootstrap/*.deb >> $PUPPET_DIR/logs/apt.log 2>&1

	apt-get -yy -f install >> $PUPPET_DIR/logs/apt.log 2>&1
fi

if [ "$DELETED" == "TRUE" ]; then

	rm -rf /etc/puppet

	echo "at this point you must setup /etc/puppet as a clone of this git repository"
	echo "depending on what your repo looks like this could be anything.  but this is a good start"
	echo "exit the subshell to contine with setup"
	echo ""
	echo "git clone $__BASE__ /etc/puppet"
	echo "cd /etc/puppet"
	echo "git submodule init"
	echo "git submodule update"
	echo "exit"
	echo ""
	bash

fi

echo "lauching puppet master"
chown -R puppet:root "$PUPPET_DIR"
chmod -R 750 "$PUPPET_DIR"

(
	puppet master \
		--verbose \
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
sleep 5

[ ! -e "/proc/$MASTER_PID" ] && { echo "puppetmaster failed to launch (a stale one running?)"; exit 1; }

echo "Puppet master launched $MASTER_PID with log $PUPPET_DIR/logs/forkedmaster.log"

i=0

while [ "$i" -lt 5 ]; do
	echo "Puppet agent running with log $PUPPET_DIR/logs/forkedagent.log"
	set -x
	puppet agent \
		--test \
		--server=localhost \
		--masterport=8880 \
		--vardir="$PUPPET_DIR" \
		--ssldir="$PUPPET_DIR/ssl" \
		--confdir="$PUPPET_DIR/conf" \
		--config="/dev/null" \
		--detailed-exitcodes >> $PUPPET_DIR/logs/forkedagent.log 2>&1
	ret=$?
	set +x

	echo "--------------------------" >> $PUPPET_DIR/logs/forkedagent.log
	echo "--------------------------" >> $PUPPET_DIR/logs/forkedagent.log
	echo "--------------------------" >> $PUPPET_DIR/logs/forkedagent.log

	echo "agent exited with code $ret"

	if [ "$ret" -eq 0 ]; then
		echo "everything was applied"
		i=10
	else
		echo "Running again"
	fi
	i=$(( $i + 1 ))
done

if [ "$ret" -ne 0 ]; then
	echo "After 5 runs of the puppet client, it is still either applying changes or erroring out.  This is a problem.  please read the logs and correct the problem or continue if its ok"
	pause
fi

echo "testing local puppet agent against the newly configured master: $PUPPET_DIR/logs/testagent.log"

puppet agent --test --detailed-exitcodes >> $PUPPET_DIR/logs/testagent.log

ret=$?

if [ "$ret" -eq 0 -o "$ret" -eq 2 ]; then
	echo "agent ran fine"
else
	echo "agent did not run fine.  sorry but i'm no help now"
fi

pause

echo -n "killing puppetmaster"
while [ -e "/proc/$MASTER_PID" ]; do
	echo -n "."
	kill $MASTER_PID
	sleep 1
done

echo ""

echo "removing puppet temp dir"
rm -rf $PUPPET_DIR

envs=$(getEnvironments | perl -ple 's#\b(production|shared|framework)\b##g' | perl -ple "s#^\s+|\s+$|\s{2,}##g")


if [ "$(echo "$envs" | wc -w )" -eq 1 ]; then
	echo "Now that this master is all bootstrapped you will want to switch it to the environment you setup during init ($envs)"
	echo "run: puppet agent --test --environment=$envs"
else
	echo "Now that this master is all bootstrapped you will want to switch it to the proper environment"
	echo "run: puppet agent --test --environment=<env>"
fi
