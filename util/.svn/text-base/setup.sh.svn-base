#!/bin/bash

which svn > /dev/null 2>&1 || { echo "subversion not installed.  you will need that"; exit 1; }

svn info > /dev/null 2>&1 || { echo "this is not a svn checkout.  please change to a svn checkout you want to use"; exit 1; }

#svnRoot=$(svn info | perl -nle 'print $1 if m#URL:\s*(.*)$')

#svnUrl=$(svn info | perl -nle 'print $1 if m#Repository Root:\s*(.*)$')

[ "$(basename $(pwd))" != "puppet" ] && echo "i'm sorry, the wrenchies.net framework currently doesn't support running out of a directory root not called puppet"; exit 1; }

if [ ! -d "puppet.wrenchies.net" ]; then
	echo "puppet.wrenchies.net folder not found.  would you like to set it up here?"
	read -p "(y/n): " answer
	[ "$answer" != "y" ] && { echo "please setup the wrenchies framework manually then"; exit 1; }

	if [ ! -z "$(svn propget svn:externals .)" ]; then
		echo "sorry you already have a svn:externals property set on this directory."
		echo "i will now run propedit and you can manually add this line:
		echo "puppet.wrenchies.net file:///data/svn/puppet.wrenchies.net"
		read -p "press return to contiue..."

		svn propedit svn:externals .
		svn up
	else
		svn propset svn:externals "puppet.wrenchies.net file:///data/svn/puppet.wrenchies.net" .
		svn up
	fi
fi


