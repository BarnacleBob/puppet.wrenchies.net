class framework::sudo {
	package{"sudo": ensure=>latest}
	rFile{"/etc/sudoers": mode=>440}
}
