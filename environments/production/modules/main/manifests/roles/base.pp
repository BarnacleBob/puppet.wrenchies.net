class production::role::base {
	class {
		"config":
			attributes => {
				role => "base"
			}
	}

	include framework::base
}
