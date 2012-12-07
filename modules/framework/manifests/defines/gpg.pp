# define gpg (
define gpg::key ($ensure="present") {
	if ! defined(Class["framework::gpg"]){
		include framework::gpg
	}
		
	if $ensure=="present" {
		exec{
			"build gpg key $name":
				command => "/data/bin/create_gpg_key '$name' ${framework::gpg::default_options}",
				logoutput => "on_failure",
				unless => "/usr/bin/gpg ${framework::gpg::default_options} --list-secret-keys '$name'",
				require => [
					RDir["/data/bin"],
					Class["framework::gpg"],
				],
		}		 
	}else{
		exec{
			"delete gpg key $name":
				command => "gpg ${framework::gpg::default_options} --delete-secret-and-public-key '$name'",
				onlyif => "gpg ${framework::gpg::default_options} --list-secret-keys '$name'",
		}
	}
}

define gpg::export_key($ensure="present", $destination){
	if $ensure == "present" {
		exec{
			"export gpg key $keyring $name":
				command => "gpg ${framework::gpg::default_options}  --export --armor --yes --output ${destination} '$name'",
				subscribe => Exec["build gpg key $name"],
				refreshonly => true,
				require => Class["framework::gpg"],
				logoutput => "on_failure",
		}
	}else{
		file{$destination: ensure => absent}
	}
}

define gpg::detached_sign_file($ensure="present", $key, $destination){
	if $ensure == "present" {
		exec{
			"sign $name with gpg key $key":
				command => "gpg ${framework::gpg::default_options}  --local-user '$key' --detach-sign --armor --yes --output '${destination}' '$name'",
				subscribe => Exec["build gpg key $key"],
				refreshonly => true,
				require => Class["framework::gpg"],
				logoutput => "on_failure",
		}
	}else{
		file{$destination: ensure => absent}
	}
}
