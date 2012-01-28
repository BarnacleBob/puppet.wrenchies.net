define framework::debug () {
	if config::attributes[debug] == "true" {
		err("puppet.wrenchies.net framework debug: $name")
	}
}
