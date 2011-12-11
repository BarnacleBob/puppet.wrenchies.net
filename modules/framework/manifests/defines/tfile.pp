define tFile ($ensure="present",$backup=client,$owner=root,$group=root,$mode=644,$links="manage",$replace="true") {
	if $ensure=="present" {
		err("called tFile($name)")
		file{
			$name:
				mode=>$mode,
				owner=>$owner,
				group=>$group,
				links=>$links,
				replace=>$replace,
				backup=>$backup,
				content=>
					inline_template(
						file(
							"$prefix/environments/$realEnvironment/modules/main/files/host/$domain/$hostname/$name",
							"$prefix/environments/$realEnvironment/modules/main/files/role/$role/$name",
							"$prefix/environments/$realEnvironment/modules/main/files/all/$name",
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
