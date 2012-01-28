#class framework::config {
class config($attributes) {
	err("config class is being evaled")
	if ! $attributes[role] {
		fail("config must contain a role")
	}
}
