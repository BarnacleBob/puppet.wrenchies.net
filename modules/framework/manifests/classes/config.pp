#class framework::config {
class config($attributes) {
	if ! $attributes[role] {
		fail("config must contain a role")
	}
}
