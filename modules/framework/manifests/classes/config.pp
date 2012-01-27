#class framework::config {
stage{"first": before => Stage["main"] }
class config($attributes) {
	err("config class is being evaled")
	if ! $attributes[role] {
		fail("config must contain a role")
	}
}

Class["config"]{ stage => "first" }
