filebucket{"client": path=>"/var/lib/puppet/clientbucket" }

Exec { path=>"/bin:/usr/bin:/sbin:/usr/sbin" }

File{ backup=>"client" }

Package{ ensure=>installed }

if $lsbdistid=="CentOS" {
	Package{ require=>Package["epel-release"] }
}

if $environment=~/([^_]+)_([^_]+)/ {
	#env is a user home directory env
	$prefix="/home/$1/puppet"
	$environmentUser=$1
	$realEnvironment=$2
}else{
	$prefix="/etc/puppet"
	$realEnvironment=$environment
}
