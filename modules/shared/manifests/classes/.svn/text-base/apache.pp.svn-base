class shared::apache {
	package{"httpd": ensure=>installed}
	
	rFile{"/etc/httpd/conf/httpd.conf": require=>Package["httpd"], notify=>Service["httpd"]}
	
	service{
		"httpd":
			ensure=>running,
			enable=>true,
			restart=>"/etc/init.d/httpd graceful",
			require=>Package["httpd"],
			before=>Exec["apache full restart"]
	}
	
	managedDir{"/data/config/httpd": }
	dir{"/data/sites": }
	dir{"/data/logs/vhosts": }
	dir{"/data/logs/httpd": owner=>apache, group=>apache}
	
	exec{
		"apache full restart":
			command=>"/etc/init.d/httpd stop; /etc/init.d/httpd start",
			refreshonly=>true,
	}
}

class apache::health::site {
	apache::vhost{"healthcheck": documentRoot=>"/data/sites/httpHealthCheck",listen=>"*:8888",puppetPushed=>"true"}
}

define apache::listen ($vhosts="false"){
	
	if $vhosts!="false" and $vhosts!="true" {
		fail("Apache::Listen[$name] parameter vhosts needs to be true or false")
	}
	
	$shaName=sha1($name)
	
	file{
		"/data/config/httpd/listen_$shaName.conf":
			notify=>Exec["apache full restart"],
			content=>inline_template('
listen <%= name %>
<% if vhosts=="true" %>
namevirtualhost <%= listen %>
<% end %>
'),
	}

}

define apache::vhost ($documentRoot,$aliases="",$owner="root",$group="root",$mode="644",$extraDirectives="",$template="shared/apacheVhost",$listen="*:80",$defaultVhost="false",$puppetPushed="false",$sourceselect="all",$directoryDirectives=""){
	if $defaultVhost=="true" {
		$vhostprefix="000-default-"
	}else{
		$vhostprefix=""
	}
	
	if $puppetPushed=="true" {
		rDir{"$documentRoot": owner=>$owner,group=>$group,mode=>$mode,sourceselect=>$sourceselect}
	}else{
		dir{"$documentRoot": owner=>$owner,group=>$group,mode=>$mode}
	}
	
	if ! defined(Apache::Listen[$listen]) {
		apache::listen{$listen: vhosts=>"true"}
	}
	
	dir{"/data/logs/vhosts/$name": owner=>"apache",group=>"apache"}
	
	file{
		"/data/config/httpd/$vhostprefix$name.vhost":
			content=>template($template),
			notify=>Service["httpd"],
			require=>[
				Package["httpd"],
				Dir["/data/logs/vhosts/$name"],
				ManagedDir["/data/config/httpd"]
			]
	}
}


