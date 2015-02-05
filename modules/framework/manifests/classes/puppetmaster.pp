class framework::puppetmaster {
	case $lsbdistid {
		"Ubuntu": {
			package{"puppetmaster-common": alias=>"puppetmaster", before => Package["puppetmaster-passenger"]}
			package{"puppetmaster-passenger": notify=>Service["apache"]}
			package{"libmysql-ruby": ensure=>latest}

			package{"libapache2-mod-passenger": ensure=>latest}
			package{"librack-ruby": ensure=>latest}
		}
		"Centos": {
			package{"puppet-server": before=>TFile["/etc/puppet/puppet.conf"] }
			package{"rubygem-activerecord": ensure=>latest, notify=>Service["puppetmaster"]}
			package{"ruby-mysql": ensure=>latest, notify=>Service["puppetmaster"]}
		}
	}
	
	dir{"/var/lib/puppet/run": owner=>"puppet", group=>"puppet", require=>Package["puppetmaster"]}
	dir{"/var/lib/puppet": owner=>"puppet", group=>"puppet", require=>Package["puppetmaster"]}
	dir{
		"/etc/puppet/rack":
			owner=>puppet,
			group=>puppet,
			require=>Package["puppetmaster-passenger"],
			notify=>Service["apache"]
	}
	dir{"/var/lib/puppet/server_data": owner=>puppet,group=>puppet,mode=>750,require=>Package["puppetmaster-passenger"],notify=>Service["apache"]}
	
	tFile{"/etc/puppet/fileserver.conf": require=>Package["puppetmaster"]}
	rFile{"/etc/puppet/rack/config.ru": notify=>Service["apache"],owner=>puppet,group=>puppet}
	
	mysql::user{"puppet": grants=>"ALL on puppet.*", password=>"PupMySQEAL%", require=>Mysql::Database["puppet"]}
	mysql::database{"puppet": }
	
	apache::vhost{
		"puppet":
			documentRoot => "/usr/share/puppet/rack/puppetmasterd/public/",
			listen => "*:8140",
			owner => "puppet",
			group => "puppet",
			puppetPushed => "false",
			topDirectives => [
				"PassengerHighPerformance on",
				"PassengerMaxPoolSize 12",
				"PassengerPoolIdleTime 1500",
				"#PassengerMaxRequests 1000",
				"PassengerStatThrottleRate 60",
				"RackAutoDetect Off",
				"RailsAutoDetect Off"
			],
			vhostDirectives => [
				"SSLEngine on",
				"SSLProtocol             ALL -SSLv2 -SSLv3",
				"SSLCipherSuite          EDH+CAMELLIA:EDH+aRSA:EECDH+aRSA+AESGCM:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH:+CAMELLIA256:+AES256:+CAMELLIA128:+AES128:+SSLv3:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!IDEA:!ECDSA:kEDH:CAMELLIA256-SHA:AES256-SHA:CAMELLIA128-SHA:AES128-SHA",
				"SSLHonorCipherOrder     on",

				"SSLCertificateFile /var/lib/puppet/ssl/certs/$::fqdn.pem",
				"SSLCertificateKeyFile /var/lib/puppet/ssl/private_keys/$::fqdn.pem",
				"#SSLCertificateChainFile /var/lib/puppet/ssl/ca/ca_crt.pem",
				"#SSLCACertificateFile /var/lib/puppet/ssl/ca/ca_crt.pem",
				"SSLCertificateChainFile /var/lib/puppet/ssl/certs/ca.pem",
				"SSLCACertificateFile /var/lib/puppet/ssl/certs/ca.pem",

				"#see known issue http://reductivelabs.com/trac/puppet/wiki/UsingMongrel",
				"#SSLCARevocationFile /var/lib/puppet/ssl/ca/ca_crl.pem",

				"SSLVerifyClient optional",
				"SSLVerifyDepth  1",
				"SSLOptions +StdEnvVars",

				"RequestHeader unset X-Forwarded-For",
				"RequestHeader set X-SSL-Subject %{SSL_CLIENT_S_DN}e",
				"RequestHeader set X-Client-DN %{SSL_CLIENT_S_DN}e",
				"RequestHeader set X-Client-Verify %{SSL_CLIENT_VERIFY}e",

				"RackBaseURI /",
				"PassengerHighPerformance on",
			],
			directoryDirectives => [
				"Options None",
				"AllowOverride None",
				"Order allow,deny",
				"allow from all",
			]
	}
	apache::module{
		"passenger": 
			config=>[
				"<IfModule mod_passenger.c>",
				"  PassengerRoot /usr",
				"  PassengerRuby /usr/bin/ruby",
				"</IfModule>",
			]
	}
	apache::module{"ssl": }
	
	#note we need to graceful apache when the puppet.conf file changes to pick it up right away
	#FIXME: this has been observed to not work
	TFile["/etc/puppet/puppet.conf"] ~> Service[$framework::apache::service]
}
