class framework::sshd {
	package{"openssh-server": ensure=>latest}
	service{
		"sshd":
			ensure=>running,
			enable=>true,
			hasstatus=>true,
			hasrestart=>true,
			require=>Package["openssh-server"]
	}
	
	rFile{"/etc/ssh/sshd_config": notify=>Service["sshd"],mode=>600}
}
