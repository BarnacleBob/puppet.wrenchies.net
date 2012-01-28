class framework::log {
	err("node($fqdn) has attributes ${config::attributes}")
	$role = $config::attributes[role]
	err("node($fqdn) is applying role($role) from env($environment)")
}
