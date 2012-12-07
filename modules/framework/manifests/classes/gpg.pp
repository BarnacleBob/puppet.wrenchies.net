class framework::gpg {
	package{"gnupg": ensure => latest }
	package{"rng-tools": ensure => latest }

	$puppet_keyring = "${settings::vardir}/.gpg_keyring"
	$puppet_trustdb = "${settings::vardir}/.gpg_trustdb"
	$default_options = "--trustdb-name ${puppet_trustdb} --no-default-keyring --no-random-seed-file --homedir /dev/null --keyring ${puppet_keyring}.pubring --secret-keyring ${puppet_keyring}.secring"
}

