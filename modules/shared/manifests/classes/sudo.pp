class shared::sudo {
	package{"sudo": ensure=>latest}
	rFile{"/etc/sudoers": mode=>440}
}
