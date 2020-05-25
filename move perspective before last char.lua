script_name = "Move perspective to last char"
script_description = "Copy \\frz\\fax\\c\\3c\\4c before last char for gradient character"
script_author = "dark_star90"
script_version = "1.2"
submenu="_darkis crappy scripts"

function shift_tags(subs,sel)
	for z,i in ipairs(sel) do
		line=subs[i]
		frz = line.text:match("\\frz[%d%.%-]+")
		fax = line.text:match("\\fax[%d%.%-]+")
		color1 = line.text:match("(\\1?c&[^\\}]-)[\\}]")
		color3 = line.text:match("(\\3c&[^\\}]-)[\\}]")
		color4 = line.text:match("(\\4c&[^\\}]-)[\\}]")
		if color1==nil then color1="" end
		if color3==nil then color3="" end
		if color4==nil then color4="" end
		if fax==nil then fax="" end
		if frz==nil then frz="" end
		tags = frz..fax..color1..color3..color4
		--kill last \frz\fax
		if line.text:match("{\\[^}]-}.$") ~= nil then 
			last1 = line.text:match("{\\[^}]-}.$")
			last2 = last1:gsub("\\frz[%d%.%-]+","") :gsub("\\fax[%d%.%-]+","") :gsub("(\\[134]?c&H%x+&)","")
			line.text = line.text:gsub(last1,last2) :gsub("{}(.)$","%1")
		end
		orig = line.text
		--shift tags
		line.text=line.text:gsub("({\\[^}]-)}(.)$","%1"..tags.."}%2")
		if orig==line.text then line.text=line.text:gsub("([^}])$","{"..tags.."}%1") end
		if orig==line.text then line.text=line.text:gsub("([^}])({[^\\}]-})$","{"..tags.."}%1%2") end
		subs[i]=line
	end
end

aegisub.register_macro(submenu.."/"..script_name,script_description,shift_tags)