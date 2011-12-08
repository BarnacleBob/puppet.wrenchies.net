class framework::tcpwrapers {
	package{"tcp_wrappers": ensure=>latest}
	
	fileSnipitCompile{"/etc/hosts.allow": searchTags=>[$hostname,"hosts_allow"]}
	#fileSnipitCompile{"/etc/hosts.deny": searchTags=>[$hostname,"hosts_deny"]}
}
