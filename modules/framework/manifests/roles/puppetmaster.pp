class framework::role::puppetmaster {
 	$role="puppetmaster"
 	
 	include framework::base
	include framework::apache
	include framework::mysql
 	include framework::puppetmaster

}
