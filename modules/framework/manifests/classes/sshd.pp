class framework::sshd {
	case $lsbdistid {
		"Ubuntu": {
			$package="openssh-server"
			$service="ssh"
		}
		"CentOs": {
			$package="openssh-server"
			$service="sshd"
		}
	}
	package{$package: ensure=>latest}
	service{
		$service:
			ensure=>running,
			enable=>true,
			hasstatus=>true,
			hasrestart=>true,
			require=>Package[$package]
	}

	rFile{"/etc/ssh/sshd_config": notify=>Service[$service],mode=>600}
}
