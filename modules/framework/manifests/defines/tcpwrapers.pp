define tcpwrapers::allow ($ensure="present") {
	$useName=sha1("allow$name")
	@@fileSnipit{$useName: content=>"$name", tag=>[$hostname,"hosts_allow"]}
}
define tcpwrapers::deny ($ensure="present") {
	$useName=sha1("deny$name")
	@@fileSnipit{$useName: content=>"$name", tag=>[$hostname,"hosts_deny"]}
}
