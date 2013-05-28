define rDir (
		$ensure = present,
		$backup = client,
		$owner = root,
		$group = root,
		$ignore = ".svn",
		$links = "manage",
		$purge = false,
		$replace = true,
		$sourceselect = all,
		$force = false,
		$source = "",
		$destination = ""
	){
	$role = $config::attributes[role]
	
	if $destination == "" {
		$useDestination = $name
	}else{
		$useDestination = $destination
	}
	
	if $source == "" {
		$useSource = [
			"puppet:///modules/main/host/${::domain}/${::hostname}/$name",
			"puppet:///modules/main/role/$role/$name",
			"puppet:///modules/main/all/$name",
			"puppet:///modules/shared/role/$role/$name",
			"puppet:///modules/shared/all/$name",
			"puppet:///modules/framework/role/$role/$name",
			"puppet:///modules/framework/all/$name",
		]
	}else{
		$useSource = $source
	}
	
	if $ensure=="present" {
		file{
			$useDestination:
				source => $useSource,
				backup => $backup,
				owner => $owner,
				group => $group,
				ignore => $ignore,
				links => $links,
				purge => $purge,
				replace => $replace,
				sourceselect => $sourceselect,
				recurse => true,
				force => $force,
		}
	}else{
		file{
			"$name":
				ensure => absent,
				recurse => true,
				force => true,
		}
	}
}
