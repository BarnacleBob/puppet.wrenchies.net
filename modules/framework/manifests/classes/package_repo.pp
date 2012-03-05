class framework::packageRepo {
	$repoDomain="packages.puppet.${::domain}"
	$documentRoot="${Framework::Apache::defaultDocumentRoot}/${repoDomain}"

	apache::vhost {
		$repoDomain:
			puppetPushed => "false",
	}
	
	dir{"$documentRoot/ubuntu": }
	rDir{"$documentRoot/scripts": }
	
	
}

class framework::package_repo::debian {
	
}
