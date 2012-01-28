filebucket{"client": path=>"/var/lib/puppet/clientbucket" }

Exec { path=>"/bin:/usr/bin:/sbin:/usr/sbin" }

File{ backup=>"client" }

Package{ ensure=>installed }
