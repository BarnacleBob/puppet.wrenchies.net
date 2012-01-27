#class framework::config {
stage{"first": before => Stage["main"] }
class config($attributes) {
	if ! $attributes[role] {
		fail("config must contain a role")
	}
}

Class["config"]{ stage => "first" }
