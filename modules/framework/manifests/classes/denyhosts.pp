class framework::denyhosts {
	package{"denyhosts": ensure=>latest}
	service{
		"denyhosts":
			ensure=>running,
			enable=>true,
			hasstatus=>true,
			hasrestart=>true,
			require=>Package["denyhosts"]
	}
	
	rFile{"/etc/denyhosts.conf": require=>Package["denyhosts"], notify=>Service["denyhosts"],mode=>600}
	
	
}
