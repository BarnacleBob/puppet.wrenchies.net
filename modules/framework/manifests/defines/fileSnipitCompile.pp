define fileSnipitCompile ($ensure="present",$backup=client,$owner=root,$group=root,$mode=644,$searchTags) {
	file{
		$name:
			ensure=>$ensure,
			backup=>$backup,
			mode=>$mode,
			owner=>$owner,
			group=>$group,
			replace=>true,
			content=>fileSnipitCompile($searchTags)
	}
}

define fileSnipit ($content){
	
}
