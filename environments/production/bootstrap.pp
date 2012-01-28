import "framework"
import "main"

node default {
	err("node($fqdn) is env($environment) with modules ($settings::modulepath)")
	include framework::role::puppetmaster
}
