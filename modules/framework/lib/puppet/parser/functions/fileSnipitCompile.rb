
module Puppet::Parser::Functions
	newfunction(:fileSnipitCompile, :type=>:rvalue) do |args|
		contents=""
		
		dbh = Mysql.real_connect(Puppet.settings.value(:dbserver), Puppet.settings.value(:dbuser), Puppet.settings.value(:dbpassword), Puppet.settings.value(:dbname),Puppet.settings.value(:dbport),Puppet.settings.value(:dbsocket))
		
		snipitTagIds=[]
		
		res = dbh.query("SELECT id FROM puppet_tags WHERE name='filesnipit'") 
		res.each do |row| 
			snipitTagIds.push(row[0]) 
		end 

		if snipitTagIds.length==0 
			raise Puppet::ParseError, "unable to find snipit tags #{extraSearchTags}"
		else
			tagIds=[]
		
			res = dbh.query("SELECT id FROM puppet_tags WHERE name IN (\'" + args.join("\',\'") + "\')") 
			res.each do |row| 
				tagIds.push(row[0]) 
			end 
			
			resourceIds=Hash.new()

			sql="SELECT resource_id FROM resource_tags WHERE puppet_tag_id in (" + snipitTagIds.join(",") + ")"
			
			res = dbh.query(sql) 
			res.each do |row| 
				resourceIds[row[0]]=1
			end

			tagIds.each do |tagId|
				if resourceIds.length > 0
					filteringIds=Hash.new()
					sql="SELECT resource_id FROM resource_tags WHERE puppet_tag_id=#{tagId} AND resource_id IN (" + resourceIds.keys.join(",") + ")"
				
					res = dbh.query(sql) 
					res.each do |row| 
						filteringIds[row[0]]=1
					end
					
					resourceIds.each_key do |resourceId|
						if not filteringIds.has_key?(resourceId)
							resourceIds.delete(resourceId)
						end
					end
				end
			end
			
			if resourceIds.length > 0
				sql="SELECT id FROM resources WHERE exported=1 AND id in (" + resourceIds.keys.join(",") + ")"
				
				filteringIds=Hash.new()

				res = dbh.query(sql) 
				res.each do |row| 
					filteringIds[row[0]]=1
				end
					
				resourceIds.each_key do |resourceId|
					if not filteringIds.has_key?(resourceId)
						resourceIds.delete(resourceId)
					end
				end

				if resourceIds.length>0 
					paramIds=[] 
					res = dbh.query("select id from param_names where name = \'content\'") 
					res.each do |row| 
						paramIds.push(row[0]) 
					end
					
					if paramIds.length>0 
						res = dbh.query("SELECT value FROM param_values WHERE param_name_id IN (" + paramIds.join(",") + ") AND resource_id IN (" + resourceIds.keys.join(",") + ")") 
						res.each do |row| 
							contents = contents + row[0] +  "\n"
						end 
					end 
				end 
			end 
		end 
		contents
	end
end
