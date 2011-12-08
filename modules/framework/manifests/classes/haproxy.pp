class framework::haproxy {
	package{"haproxy": ensure=>installed}

	tFile{"/etc/haproxy/haproxy.cfg": require=>Package["haproxy"], notify=>Service["haproxy"]}

	service{
		"haproxy":
			ensure=>running,
			enable=>true,
			restart=>"/etc/init.d/haproxy reload",
			hasstatus=>true,
			require=>Package["haproxy"],
	}
	
	exec{
		"haproxy full restart":
			command=>"/etc/init.d/haproxy restart",
			require=>Service["haproxy"],
			refreshonly=>true,
	}	
}
