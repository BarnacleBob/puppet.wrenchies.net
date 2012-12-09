class framework::apt {
	$distro=inline_template('<%= scope.lookupvar("::lsbdistid").downcase %>')
	
	file{"/etc/apt/sources.list":	content => template("framework/apt/sources.list-${distro}-${::lsbdistrelease}")}
	cron_d{
		"apt_update":
			command => "/usr/bin/apt-get update > /dev/null",
			hour => 0,
			minute => 0,
	}
}
