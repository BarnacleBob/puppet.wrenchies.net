class production::role::base {
	class {
		"config":
			attributes => {
				role => "base",
				debug => "true"
			}
	}

	include framework::base
}
