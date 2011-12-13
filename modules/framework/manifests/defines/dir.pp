define dir ($ensure="directory", $owner=root,$group=root,$mode=755,$purge=false,$recurse=false,$force=false) {
	file{
		"$name":
			ensure=>$ensure,
			owner=>$owner,
			group=>$group,
			mode=>$mode,
			purge=>$purge,
			recurse=>$recurse,
			force=>$force
	}
}
