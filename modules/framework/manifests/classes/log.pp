class framework::log {
	framework::debug{"node($fqdn) has attributes ${config::attributes}": }
	$role = $config::attributes[role]
	err("node($fqdn) is applying role($role) from env($environment)")
}
