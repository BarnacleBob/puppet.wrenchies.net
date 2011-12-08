class framework::iptables {
	rFile{"/etc/sysconfig/iptables": notify=>Service["iptables"],mode=>600}
	rFile{"/etc/sysconfig/iptables-config": notify=>Service["iptables"],mode=>644}
	
	service{
		"iptables":
			ensure=>running,
			enable=>true,
			hasstatus=>true,
			hasrestart=>true,
	}
	
}


class framework::ipables::disabled {
	service{
		"iptables":
			enable=>false,
			ensure=>stopped,
	}
}
