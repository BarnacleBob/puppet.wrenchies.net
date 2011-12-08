class shared::php::httpd {
	if !defined(RFile["/etc/php.ini"]){
		rFile{"/etc/php.ini": }
	}
	package{"php": ensure=>latest, before=>RFile["/etc/php.ini"], notify=>Exec["apache full restart"]}
}

class shared::php::cli {
	if !defined(RFile["/etc/php.ini"]){
		rFile{"/etc/php.ini": }
	}
	package{"php-cli": ensure=>latest, before=>RFile["/etc/php.ini"]}
}
