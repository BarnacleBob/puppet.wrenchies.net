define cron_d ($ensure="present",$command,$minute="*",$hour="*",$monthday="*",$month="*",$weekday="*",$environment="",$user="root") {
	file{
		"/etc/cron.d/$name":
			ensure=>$ensure,
			content=>inline_template("# WARNING: This cron.d job is controlled by puppet!
<% if !environment.is_a?(Array); aenv=[environment]; else; aenv=environment.flatten; end -%>
<% aenv.each do |env| -%><%= env %><% end %>
$minute $hour $monthday $month $weekday $user $command
")
	}
}
