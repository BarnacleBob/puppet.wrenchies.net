class framework::epel {
	if $lsbdistid=="CentOS" {
		rFile{"/tmp/epel-release-5-4.noarch.rpm": }

		package{
			"epel-release":
				provider=>rpm,
				ensure=>installed,
				require=>RFile["/tmp/epel-release-5-4.noarch.rpm"],
				source=>"/tmp/epel-release-5-4.noarch.rpm"
		}
	}
}
