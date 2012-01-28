filebucket{"client": path=>"/var/lib/puppet/clientbucket" }

Exec { path=>"/bin:/usr/bin:/sbin:/usr/sbin" }

File{ backup=>"client" }

Package{ ensure=>installed }

if $realEnvironment!="" {
	if $environment=~/([^_]+)_([^_]+)/ {
		#env is a user home directory env
		$environmentUser=$1
		$realEnvironment=$2
	}else{
		$realEnvironment=$environment
	}
}
