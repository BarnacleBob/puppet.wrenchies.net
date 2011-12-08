class framework::base {
	dir{"/data": }
	dir{"/data/logs": }
	dir{"/data/config": }
	rDir{
		"/data/bin":
			sourceselect=>all,
			purge=>true,
			force=>true,
	}

	package{[
		"nano",
		"elinks",
		]:
			ensure=>latest
	}

	include framework::log
	include framework::epel
	include framework::puppet
	include framework::global_users
	include framework::sudo
	include framework::sshd


	#raw includes of mysql based resources not ready yet	but we do this any way and in the tcpwrapers class we only fetch for hosts.allow entries
	include framework::tcpwrapers
	
	tcpwrapers::allow{"sshd: 10.0.0.0/8 127.0.0.1 192.168.0.0/16 172.16.0.0/12": }

}
