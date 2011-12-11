define rFile ($ensure="present",$backup=client,$owner=root,$group=root,$mode=644,$links="manage",$replace="true") {
	if $ensure=="present" {
		file{
			"$name":
				source=>[
					"puppet://puppet/modules/main/host/$domain/$hostname/$name",
					"puppet://puppet/modules/main/role/$role/$name",
					"puppet://puppet/modules/main/all/$name",
					"puppet://puppet/modules/shared/role/$role/$name",
					"puppet://puppet/modules/shared/all/$name",
					"puppet://puppet/modules/framework/role/$role/$name",
					"puppet://puppet/modules/framework/all/$name",
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
