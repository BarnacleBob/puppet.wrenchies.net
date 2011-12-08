class shared::puppetmaster {
	package{"puppet-server": before=>TFile["/etc/puppet/puppet.conf"] }
	package{"rubygem-activerecord": ensure=>latest, notify=>Service["puppetmaster"]}
	package{"ruby-mysql": ensure=>latest, notify=>Service["puppetmaster"]}
	
	dir{"/var/lib/puppet/run": owner=>"puppet", group=>"puppet", require=>Package["puppet-server"], before=>Service["puppetmaster"]}

	tFile{"/etc/puppet/fileserver.conf": require=>Package["puppet-server"], before=>Service["puppetmaster"]}
	
	mysql::user{"puppet": grants=>"ALL on puppet.*", password=>"PupMySQEAL%", require=>Mysql::Database["puppet"]}
	mysql::database{"puppet": }

	service{
		"puppetmaster":
			ensure=>running,
			enable=>true,
			hasstatus=>true,
			restart=>"/sbin/service puppetmaster reload",
			require=>[
				Package["puppet-server"],
				TFile["/etc/puppet/puppet.conf"],
				Mysql::User["puppet"],
				Mysql::Database["puppet"],
				TFile["/etc/puppet/puppet.conf"],
			],
	}
}
