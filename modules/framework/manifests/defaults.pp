Exec { path=>"/bin:/usr/bin:/sbin:/usr/sbin" }

File{ backup=>"client" }

Package{ ensure=>installed }
