class shared::mysql {
	package{"mysql-server": ensure=>installed}
	rFile{"/etc/my.cnf": require=>Package["mysql-server"],notify=>Exec["start mysql"]}
	
	dir{"/data/mysql": owner=>mysql, require=>Package["mysql-server"]}
	dir{"/data/mysql/log": owner=>mysql, require=>Package["mysql-server"]}
	dir{"/data/mysql/data": owner=>mysql, mode=>750, require=>Package["mysql-server"]}
	
	exec{
		"initalizeDatabases":
			command=>"/usr/bin/mysql_install_db --datadir=/data/mysql/data --user=mysql",
			creates=>"/data/mysql/data/mysql",
			require=>[
				RFile["/etc/my.cnf"],
				Dir["/data/mysql/data"],
				Dir["/data/mysql/log"],
			]
	}
	
	exec{
		"start mysql":
			command=>"/etc/init.d/mysqld start",
			refreshonly=>true,
	}
	
	exec{
		"check mysql root password":
			command=>"/bin/echo Please set the mysql root password now on $hostname; /bin/false",
			onlyif=>"/usr/bin/mysqladmin -u root version",
			require=>Exec["start mysql"]
	}

}

define mysql::user ($grants,$password,$hosts=""){
	if $hosts!="" {
		$extrahosts=[$hosts,"localhost"]
	}else{
		$extrahosts="localhost"
	}
	
	exec{
		"create $name mysql user":
			command=>inline_template('
				<% if grants.is_a?(Array); agrants=grants.flatten; else; agrants=[grants]; end -%>
				<% if extrahosts.is_a?(Array); ahosts=extrahosts.flatten; else; ahosts=[extrahosts]; end -%>
				<% agrants.each do |grant| -%>
				<% 	ahosts.each do |host| -%>
					/usr/bin/mysql -u root -e "grant <%= grant %> to \'<%= name %>\'@\'<%= host %>\' identified by \'<%= password %>\'"; 
				<% end -%>
				<% end -%>'),
			unless=>"/usr/bin/mysql -u '$name' -p'$password' -e 'show databases;'",
			before=>Exec["check mysql root password"],
			require=>Exec["start mysql"],
	}
}
			

define mysql::database {
	exec{
		"create $name mysql database":
			command=>"/usr/bin/mysqladmin create $name",
			creates=>"/data/mysql/data/$name",
			require=>Exec["start mysql"],
			before=>Exec["check mysql root password"]
	}
}

