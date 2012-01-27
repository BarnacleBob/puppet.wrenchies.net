class framework::base {
	err("framework class base is being evaled")
	dir{"/data": }
	dir{"/data/logs": }
	dir{"/data/config": }
	rDir{
		"/data/bin":
			sourceselect=>all,
			purge=>true,
			force=>true,
	}

	include framework::log
	include framework::puppet
	include framework::sudo
	include framework::sshd
}
