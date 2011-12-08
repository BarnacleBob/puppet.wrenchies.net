#!/usr/bin/env ruby

require 'facter'

Facter.add("users_with_homes") do
	setcode do
		homes=[]
		
		home = Dir.new("/home") 
		home.each do |d| 
			if d.to_s!="." and d.to_s!=".." and File.directory?(home.path + "/" + d.to_s) then 
				homes.push(d.to_s)
			end
		end
		
		homes.join(",")
	end
end
