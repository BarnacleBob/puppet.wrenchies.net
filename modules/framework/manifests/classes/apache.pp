#class framework::apache {
class framework::apache($std_modules="true") {
	#note this is a helper for use outside of framework.  if it changes framework needs to be changed in several places
	$defaultDocumentRoot = "/data/sites"
	$defaultConfigPath = "/data/config/apache"

	case $lsbdistid {
		"Ubuntu": {
			$package="apache2"
			$service="apache2"
			$user="www-data"
			$group="www-data"
			$config="/etc/apache2/apache2.conf"
			$documentroot="/var/www"
			$serverroot="/etc/apache2"
			$pidfile="/var/run/apache2.pid"
			$iconPath="/usr/share/apache2/icons/"	# Trailing / is important
		}
		"CentOs": {
			$package="httpd"
			$service="httpd"
			$user="apache"
			$group="apache"
			$config="/etc/httpd/conf/httpd.conf"
			$documentroot="/var/www/html"
			$serverroot="/etc/httpd"
			$pidfile="run/httpd.pid"
			$iconPath="/var/www/icons/"		# Trailing / is important
		}
	}
	
	if $std_modules=="true" {
		include apache::modules::standard
	}
	
	package{$package: ensure=>latest}
	service{
		$service:
			alias=>apache,
			enable=>true,
			ensure=>running,
			require=>Package[$package],
			restart=>$lsbdistid ? {
				"Ubuntu" => "/etc/init.d/apache2 reload",
				"CentOs" => "/etc/init.d/httpd graceful"
			},
			before=>Exec["apache full restart"]
	}

	file{$config: ensure => "/data/config/apache/httpd.conf", require=>Package[$package], notify=>Service[$service]}
	
	exec{
		"apache full restart":
			command=>"/etc/init.d/$service stop; sleep 1; /etc/init.d/$service start",
			refreshonly=>true,
	}
		
	managedDir{"/data/config/apache": }
	dir{"/data/sites": }
	dir{"/data/logs/vhosts": }
	dir{"/data/logs/httpd": owner=>$user, group=>$group}
	
	tFile{"/data/config/apache/httpd.conf": notify=>Service["apache"]}
}

class apache::health::site {
	apache::vhost{"healthcheck": documentRoot=>"/data/sites/httpHealthCheck",listen=>"*:8888",puppetPushed=>"true"}
}

class apache::modules::standard {
	apache::module{"alias": }
	apache::module{"auth_basic": }
	apache::module{"authn_file": }
	apache::module{"authz_default": }
	apache::module{"authz_groupfile": }
	apache::module{"authz_host": }
	apache::module{"autoindex": }
	apache::module{"cgi": }
	apache::module{
		"deflate":
			config=>[
				"<IfModule mod_deflate.c>",
				"	# these are known to be safe with MSIE 6",
				"          AddOutputFilterByType DEFLATE text/html text/plain text/xml",
				"          # everything else may cause problems with MSIE 6",
				"          AddOutputFilterByType DEFLATE text/css",
				"          AddOutputFilterByType DEFLATE application/x-javascript application/javascript application/ecmascript",
				"          AddOutputFilterByType DEFLATE application/rss+xml",
				"</IfModule>",
			]
	}
	apache::module{"dir": }
	apache::module{"env": }
	apache::module{"headers": }
	apache::module{"mime": }
	apache::module{"negotiation": }
	apache::module{"proxy": }
	apache::module{"proxy_balancer": }
	apache::module{"proxy_http": }
	apache::module{"rewrite": }
	apache::module{"setenvif": }
	apache::module{"status": }
}

define apache::module ($so="false",$config="false"){
	case $lsbdistid {
		"Ubuntu": {$path="/usr/lib/apache2/modules"}
		"CentOs": {$path="modules/"}
	}
	if $so=="false"{
		$module_object="mod_$name.so"
	}else{
		$module_object="$so"
	}
	file{
		"/data/config/apache/module_$name.conf":
			notify=>Exec["apache full restart"],
			require=>ManagedDir["/data/config/apache"],
			content=>inline_template('
				<% aconfig=[config].flatten %>
				LoadModule <%= name %>_module <%= path %>/<%= module_object %>
				<% if config!="false" then %>
					<% aconfig.each do |c| %>
						<%= c %>
					<% end %>
				<% end %><%= "\n" %>'
			),
	}
}

define apache::listen ($vhosts="false"){
	
	if $vhosts!="false" and $vhosts!="true" {
		fail("Apache::Listen[$name] parameter vhosts needs to be true or false")
	}
	
	$shaName = sha1($name)
	
	file{
		"/data/config/apache/listen_$shaName.conf":
			notify=>Exec["apache full restart"],
			require=>ManagedDir["/data/config/apache"],
			content=>inline_template('
				listen <%= name %>
				<% if vhosts=="true" %>
				namevirtualhost <%= listen %>
				<% end %><%= "\n" %>'
			),
	}

}

define apache::vhost (
		$documentRoot = "/data/sites/$name",
		$aliases = "",
		$owner = "root",
		$group = "root",
		$mode = "644",
		$template = "framework/apacheVhost",
		$listen = "*:80",
		$defaultVhost = "false",
		$puppetPushed = "true",
		$sourceselect = "all",
		$topDirectives = "",
		$vhostDirectives = "",
		$directoryDirectives = ""
	){

	if $defaultVhost=="true" {
		$vhostprefix = "000-default-"
	}else{
		$vhostprefix = "001-"
	}
	
	if $puppetPushed == "true" {
		rDir{"$documentRoot": owner=>$owner,group=>$group,sourceselect=>$sourceselect}
	}else{
		dir{"$documentRoot": owner=>$owner,group=>$group,mode=>$mode}
	}
	
	if ! defined(Apache::Listen[$listen]) {
		apache::listen{$listen: vhosts=>"true"}
	}
	
	dir{"/data/logs/vhosts/$name": owner=>$framework::apache::user,group=>$framework::apache::group}
	
	file{
		"/data/config/apache/$vhostprefix$name.vhost":
			content=>template($template),
			notify=>Service[$framework::apache::service],
			require=>[
				Dir["/data/logs/vhosts/$name"],
				ManagedDir["/data/config/apache"]
			]
	}
}
