#!/usr/bin/env ruby

require 'facter'

Facter.add("private_ips") do
	setcode do
		begin
			Facter.interfaces
		rescue 
			Facter.loadfacts()
		end
		
		private_ips=['127.0.0.1']
		
		interfaces = Facter.value('interfaces').to_s.split(',')
		interfaces.each do |interface|
			if Facter.value('ipaddress_' + interface)
				if Facter.value('ipaddress_' + interface) =~ /(10\.\d+\.\d+\.\d+|172\.(1[6789]|2\d|3[01])\.\d+\.\d+|192\.168\.\d+\.\d+)/
					private_ips.push($1)
				end
			end
		end
		
		private_ips.join(",")
	end
end

