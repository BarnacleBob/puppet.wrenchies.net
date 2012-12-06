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
	dir{"${framework::packageRepos::documentRoot}/${distro}/$name/pool": }
	dir{"${framework::packageRepos::documentRoot}/${distro}/$name/dists": }
	dir{"${framework::packageRepos::documentRoot}/${distro}/$name/dists/$name": }
	
	rDir{
		"${framework::packageRepos::documentRoot}/${distro}/$name/pool/main":
			source => regsubst($framework::packageRepos::sourceRoot,'$',"/${distro}/$name"),
			notify => Exec["$distro $name generate apt-ftparchive.conf"]
	}

	gpg::export_key{
		"puppetPackageRepos":
			destination => "${framework::packageRepos::documentRoot}/${distro}/$name/signingkey.pub"
	}
	
	exec{
		"$distro $name generate apt-ftparchive.conf": 
			cwd => "${framework::packageRepos::documentRoot}/${distro}/$name",
			command => "/usr/bin/apt-ftparchive generate apt-ftparchive.conf",
			refreshonly => true,
			notify => Exec["$distro $name generate Release file"],
	}
	exec{
		"$distro $name generate Release file": 
			cwd => "${framework::packageRepos::documentRoot}/${distro}/$name",
			command => "/usr/bin/apt-ftparchive -c apt-release.conf release dists/${name} > dists/${name}/Release",
			refreshonly => true,
			notify => Gpg::Detached_sign_file["${framework::packageRepos::documentRoot}/${distro}/$name/dists/${name}/Release"],
	}
	
	gpg::detached_sign_file{
		"${framework::packageRepos::documentRoot}/${distro}/$name/dists/${name}/Release":
			key => "puppetPackageRepos",
			destination => "${framework::packageRepos::documentRoot}/${distro}/$name/dists/${name}/Release.gpg",
	}
	
}
