class framework::stunnel {
	package{"stunnel": ensure=>latest}
	managedDir{"/etc/stunnel": owner=>nobody,group=>nobody}
	dir{"/var/run/stunnel": owner=>nobody}
}

define stunnel::instance ($listen,$connect,$cert=""){

	service{
		"stunnel_$name":
			ensure=>running,
			start=>"/usr/sbin/stunnel /etc/stunnel/$name.conf",
			stop=>"/usr/bin/killall '/usr/sbin/stunnel /etc/stunnel/$name.conf'",
			pattern=>"/usr/sbin/stunnel /etc/stunnel/$name.conf",
			require=>Package["stunnel"]
	}
	
	if $cert!="" {
		if !defined(RFile[$cert]){
			rFile{$cert: notify=>Service["stunnel_$name"], owner=>"nobody",group=>"nobody",mode=>"600"}
		}
	}else{
		if !defined(RFile["/etc/stunnel/$name.pem"]){
			rFile{"/etc/stunnel/$name.pem": notify=>Service["stunnel_$name"], owner=>"nobody",group=>"nobody",mode=>"600"}
		}
	}

	file{
		"/etc/stunnel/$name.conf":
			notify=>Service["stunnel_$name"],
			content=>inline_template('
cert=<%if cert!="" %><%= cert %><% else %>/etc/stunnel/$name.pem<% end %>
pid=/var/run/stunnel/<%= name %>.pid
setuid=nobody
setgid=nobody

[https]
accept=<%= listen %>
connect=<%= connect %>
'),
	}

}
