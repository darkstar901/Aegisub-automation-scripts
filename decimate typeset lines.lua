script_name="decimate typeset lines"
script_description="keep first line from Frame-by-frame stuff"
script_author="dark_star90"
script_version="1.1"
submenu="_darkis crappy scripts"


function minimize(subs, sel)
	sort_by_time(subs,sel)
	table.sort(subtable,function(a,b)
				return a.text:lower():gsub("{[^}]-}","")<b.text:lower():gsub("{[^}]-}","")
				or (a.text:lower():gsub("{[^}]-}","")==b.text:lower():gsub("{[^}]-}","") and a.i<b.i) end)
				
	
	-- lines back
    for x, i in ipairs(sel) do
		local l=subtable[x]
		subs[i]=l
    end
	
	repeat join(subs,sel) until #sel==1
	sort_by_time(subs,sel)


	-- lines back
    for x, i in ipairs(sel) do
	local l=subtable[x]
	subs[i]=l
    end
	return sel
end
	
function sort_by_time(subs,sel)	
	if #sel==1 then 
		table.remove(sel,1)
		for i=1, #subs do
			if subs[i].class=="dialogue" then table.insert(sel,i) end
		end
	end
	
	subtable={}
    -- lines into table
    for x, i in ipairs(sel) do
		local l=subs[i]
		l.i=x
		table.insert(subtable,l)
		
    end
    
    -- sort lines
  	table.sort(subtable,function(a,b) return a.start_time<b.start_time or (a.start_time==b.start_time and a.end_time<b.end_time) end)
end

function join (subs,sel)
    l1=subs[sel[1]]	
	l2=subs[sel[2]]
	if l2.start_time <= l1.end_time and l2.start_time >= l1.start_time and l1.text:lower():gsub("{[^}]-}","") == l2.text:lower():gsub("{[^}]-}","") then
		l1.end_time = l2.end_time
		subs[sel[1]] = l1
		subs.delete(sel[2])
		for s=2,#sel do sel[s]=sel[s]-1 end
		table.remove(sel,2)
		return subs[sel[1]]
	else table.remove(sel,1)
		return sel
	end
end  
	  
	  
	  
aegisub.register_macro(submenu.."/"..script_name, script_description, minimize)