class framework::packageRepos($ubuntu=True) {
	$repoDomain = "packages.puppet.${::domain}"
	$documentRoot = "${Framework::Apache::defaultDocumentRoot}/${repoDomain}"
	$sourceRoot = [
		"puppet:///modules/main/packages",
		"puppet:///modules/shared/packages",
		"puppet:///modules/framework/packages",
	]

	apache::vhost {
		$repoDomain:
			puppetPushed => "false",
			directoryDirectives => [
				"AllowOverride Indexes",
				"Options Indexes FollowSymLinks",
			],
	}
	
	dir{"${documentRoot}/ubuntu": }
	rDir{
		"${documentRoot}/scripts":
			source=>regsubst($sourceRoot, '$', '/scripts')
	}
	
	if $ubuntu=="True" {
		framework::packageRepo::ubuntu{"10.04": }
	}
	
	gpg::key{"puppetPackageRepos": }
}

define framework::packageRepo::ubuntu(){
	if $name !~ /\d{2}\.\d{2}/ {
		fail("framework::packageRepo::ubuntu requires a name of the format 10.04, 11.04 etc")
	}

	framework::packageRepo::debianStyle{$name: distro => "ubuntu"}
}

define framework::packageRepo::debianStyle($distro){
	$releaseVersion=$name
	
	dir{"${framework::packageRepos::documentRoot}/${distro}/$name": }
	dir{"${framework::packageRepos::documentRoot}/${distro}/$name/.cache": }
	dir{"${framework::packageRepos::documentRoot}/${distro}/$name/pool": }
	dir{"${framework::packageRepos::documentRoot}/${distro}/$name/dists": }
	dir{"${framework::packageRepos::documentRoot}/${distro}/$name/dists/$name": }
	dir{"${framework::packageRepos::documentRoot}/${distro}/$name/dists/$name/main": }
	dir{"${framework::packageRepos::documentRoot}/${distro}/$name/dists/$name/main/binary-amd64": }
	
	rDir{
		"${framework::packageRepos::documentRoot}/${distro}/$name/pool/main":
			source => regsubst($framework::packageRepos::sourceRoot,'$',"/${distro}/$name"),
			notify => Exec["$distro $name generate ftp-archive"]
	}

	gpg::export_key{
		"puppetPackageRepos":
			destination => "${framework::packageRepos::documentRoot}/${distro}/$name/signingkey.pub"
	}
	
	file{
		"${framework::packageRepos::documentRoot}/${distro}/$name/apt-ftparchive.conf":
			content => template("framework/apt/apt-ftparchive.conf")
	}

	file{
		"${framework::packageRepos::documentRoot}/${distro}/$name/apt-release.conf":
			content => template("framework/apt/apt-release.conf")
	}

	file{
		"${framework::packageRepos::documentRoot}/${distro}/${name}/sources.list":
			content => template("framework/apt/sources.list-${distro}-${name}")
	}
	
	exec{
		"$distro $name generate ftp-archive": 
			cwd => "${framework::packageRepos::documentRoot}/${distro}/$name",
			command => "/usr/bin/apt-ftparchive generate apt-ftparchive.conf",
			creates => "${framework::packageRepos::documentRoot}/${distro}/$name/dists/$name/Contents-amd64",
			logoutput => "true",
			notify => Exec["$distro $name generate Release file"],
			subscribe => File["${framework::packageRepos::documentRoot}/${distro}/$name/apt-ftparchive.conf"],
	}
	exec{
		"$distro $name generate Release file": 
			cwd => "${framework::packageRepos::documentRoot}/${distro}/$name",
			command => "/usr/bin/apt-ftparchive -c apt-release.conf release dists/${name} > dists/${name}/Release",
			creates => "${framework::packageRepos::documentRoot}/${distro}/$name/dists/${name}/Release",
			notify => Gpg::Detached_sign_file["${framework::packageRepos::documentRoot}/${distro}/$name/dists/${name}/Release"],
			require => Exec["$distro $name generate ftp-archive"],
			logoutput => "true",
			subscribe => File["${framework::packageRepos::documentRoot}/${distro}/$name/apt-release.conf"],
	}
	
	gpg::detached_sign_file{
		"${framework::packageRepos::documentRoot}/${distro}/$name/dists/${name}/Release":
			key => "puppetPackageRepos",
			destination => "${framework::packageRepos::documentRoot}/${distro}/$name/dists/${name}/Release.gpg",
			require => Exec["$distro $name generate Release file"],
	}
	
}
