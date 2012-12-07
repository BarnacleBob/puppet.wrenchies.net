class framework::puppet {
	package{"facter": ensure=>latest}
	package{"puppet": ensure=>latest}

	tFile{"/etc/puppet/puppet.conf": require=>Package["puppet"]}

	service{"puppet": enable=>false, require=>Package["puppet"]}

	cron_d{
		"puppetRun":
			environment=>"MAILTO=puppet@$domain",
			command=>"/data/bin/puppetctl run cron",
			hour=>"*",
			minute=>inline_template("<% require 'ipaddr' %><%= IPAddr.new('$ipaddress').to_i % 60 %>"),
			require=>RDir["/data/bin"]
	}
}
