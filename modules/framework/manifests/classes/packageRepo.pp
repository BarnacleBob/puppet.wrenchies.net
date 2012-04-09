class framework::packageRepos($ubuntu=True) {
	$repoDomain="packages.puppet.${::domain}"
	$documentRoot="${Framework::Apache::defaultDocumentRoot}/${repoDomain}"
	$sourceRoot=[
		"puppet:///modules/main/packages"
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
}

define framework::packageRepo::ubuntu($sourceRoot){
	if $releaseVersion !~ /\d{2}\.\d{2}/ {
		fail("framework::packageRepo::ubuntu requires a name of the format 10.04, 11.04 etc")
	}

	framework::packageRepo::debianStyle{$name: $distro="ubuntu"}
}

define framework::packageRepo::debianStyle($distro){
	$releaseVersion=$name
	
	dir{"${framework::packageRepos::documentRoot}/${distro}/$name": }
	dir{"${framework::packageRepos::documentRoot}/${distro}/$name/pool": }
	dir{"${framework::packageRepos::documentRoot}/${distro}/$name/pool/main": }
	
	rDir{
		"${framework::packageRepos::documentRoot}/${distro}/$name/pool/main":
			source => regsubst($framework::packageRepos::sourceRoot,'$','/${distro}/$name'),
			notify => Exec["regenerate debian repo $name"]
	}
	
	exec{
		"regenerate debian repo $name": 
			command => "${framework::packageRepos::documentRoot}/scripts/generate_debian_repo ${framework::packageRepos::documentRoot}/${distro}/$name",
			refreshonly => true
	}
}
