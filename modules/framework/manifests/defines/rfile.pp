define rFile ($ensure="present",$backup=client,$owner=root,$group=root,$mode=644,$links="manage",$replace="true",$destination="") {
	$role = $config::attributes[role]

	if $destination == "" {
		$useDestination = $name
	}else{
		$useDestination = $destination
	}

	if $ensure=="present" {
		file{
			"$useDestination":
				source=>[
					"puppet:///modules/main/host/${::domain}/${::hostname}/$name",
					"puppet:///modules/main/role/$role/$name",
					"puppet:///modules/main/all/$name",
					"puppet:///modules/shared/role/$role/$name",
					"puppet:///modules/shared/all/$name",
					"puppet:///modules/framework/role/$role/$name",
					"puppet:///modules/framework/all/$name",
				],
				backup=>$backup,
				mode=>$mode,
				owner=>$owner,
				group=>$group,
				links=>$links,
				replace=>$replace
		}
	}else{
		file{"$name": ensure=>absent}
	}
}
