#!/bin/bash

if [ "$1" == "DEBUG" ]; then
	set -x 
	shift
fi

function walkPathFor {
	local parent
	parent=$(dirname "$2")
	if [ "${parent##*/}" == "$1" ]; then
		echo $parent
	elif [ "$parent" == "$2" ]; then
		return 1
	else
		walkPathFor $1 $parent; return $?
	fi
}

binPath=$0
[ "${binPath:0:1}" != "/" ] && binPath="$(pwd)/$binPath"

__BASE__=$(dirname $(walkPathFor puppet.wrenchies.net $binPath)) || { echo "could not determin base path for the puppet directory"; exit 1; }

function pause {
	read -p "press enter to continue..."
}

function isEnvironment {
	[ -e "$__BASE__/environments/$1" ] && return 0
	return 1
}

function isShared {
	[ "$1" == "shared" ] && [ -e "$__BASE__/modules/shared" ] && return 0
	return 1
}

if isEnvironment "$1" || isShared "$1"; then
	passedEnv=$1
	shift
fi

function getDefaultEnv {
	[ -e "$HOME/.puppetDefaultEnv" ] && { cat "$HOME/.puppetDefaultEnv"; return 0; }
	return 1
}

function setDefaultEnv {
	{ isEnvironment "$1" || isShared "$1"; } && echo "$1" > "$HOME/.puppetDefaultEnv" && return 0
	return 1
}

function getEnv {
	[ ! -z "$passedEnv" ] && { echo "$passedEnv"; return 0; }
	getDefaultEnv && return 0
	return 1
}

function getEnvPath {
	local env
	env=$(getEnv) || return $?
	isEnvironment $env && { echo "$__BASE__/environments/$env/modules/main"; return 0; }
	isShared $env && { echo "$__BASE__/modules/shared"; return 0; }
	return 1
}

function getEnvManifestPath {
	if isEnvironment $1 || isShared $1; then
		echo "$(getEnvPath $1)/manifests"
		return 0
	fi
	return 1
}

function getEnvironments {
	echo -n $(ls $__BASE__/environments/)
	[ -e "$__BASE__/modules/shared" ] && echo -n " shared"
	if [ "$(ls $__BASE__/environments | wc -l)" -lt 1 -a ! -e "$__BASE__/modules/shared" ]; then
		return 1
	fi
	return 0
}

function usageEnvironments {
	echo "Valid Environments (* is default)"
	echo "------------------"
	for f in $(getEnvironments); do
		[ "$f" == "$(getDefaultEnv)" ] && echo -n "*"
		echo "$f"
	done
}

function getSvnStatus {
	svn status $__BASE__
}

function getSvnEdits {
	getSvnStatus | egrep -v "^(C|!|~|\?)[[:space:]]+" | perl -ple 's/^\s*\S+\s*//'
}

function svnBadEdits {
	getSvnStatus | egrep "^(C|!|~|\?)[[:space:]]+" > /dev/null 2>&1
}

function svnGoodEdits {
	getSvnStatus | egrep -v "^(C|!|~|\?)[[:space:]]+" > /dev/null 2>&1
}

