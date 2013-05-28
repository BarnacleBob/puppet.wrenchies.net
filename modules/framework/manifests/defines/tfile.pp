define tFile ($ensure="present",$backup=client,$owner=root,$group=root,$mode=644,$links="manage",$replace="true",$destination="") {
	$role = $config::attributes[role]
	
	err("manifest path is ${settings::manifest}")
	$envPrefix=inline_template('<%= scope.lookupvar("settings::manifest").sub(/\/site.pp$/, "") %>')
	err("tfile envPrefix is ${envPrefix}")
	$prefix=inline_template('<%= envPrefix.sub(/\/(puppet.wrenchies.net\/)?environments\/.*$/, "") %>')
	err("tfile prefix is ${prefix}")
	
	if $destination == "" {
		$useDestination = $name
	}else{
		$useDestination = $destination
	}

	if $ensure=="present" {
		file{
			$useDestination:
				mode=>$mode,
				owner=>$owner,
				group=>$group,
				links=>$links,
				replace=>$replace,
				backup=>$backup,
				content=>
					inline_template(
						file(
							"$envPrefix/modules/main/files/host/${::domain}/${::hostname}/$name",
							"$envPrefix/modules/main/files/role/$role/$name",
							"$envPrefix/modules/main/files/all/$name",
							"$prefix/modules/shared/files/role/$role/$name",
							"$prefix/modules/shared/files/all/$name",
							"$prefix/puppet.wrenchies.net/modules/framework/files/role/$role/$name",
							"$prefix/puppet.wrenchies.net/modules/framework/files/all/$name"
						)
					)
		}
	}else{
		file{$name: ensure=>$ensure}
	}
}
