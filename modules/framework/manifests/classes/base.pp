class framework::base {
	err("framework class base is being evaled")
	filebucket{"client": path=>"${settings::vardir}/clientbucket" }
	dir{"/data": }
	dir{"/data/home": }
	dir{"/data/logs": }
	dir{"/data/config": }
	rDir{
		"/data/bin":
			purge=>true,
			force=>true,
	}

	include framework::log
	include framework::puppet
	include framework::sudo
	include framework::sshd
	include framework::apt
}
