class framework::role::puppetmaster {
	class{
		"config":
			attributes => {
				role => "pipe",
			}
	}
	
	include framework::base
	include framework::apache
	include framework::mysql
	include framework::puppetmaster

}
