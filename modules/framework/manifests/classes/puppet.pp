class framework::puppet {
	package{"puppet": ensure=>latest }

	rFile{"/data/bin/puppetctl": mode=>755}
	tFile{"/etc/puppet/puppet.conf": require=>Package["puppet"]}

	service{"puppet": enable=>false, require=>Package["puppet"]}

	cron_d{
		"puppetRun":
			environment=>"MAILTO=barnaclebob+trackly@gmail.com",
			command=>"/data/bin/puppetctl run cron",
			hour=>"*",
			minute=>inline_template("<% require 'ipaddr' %><%= IPAddr.new('$ipaddress').to_i % 60 %>"),
			require=>RDir["/data/bin"]
	}
}
