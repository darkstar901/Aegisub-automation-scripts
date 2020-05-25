script_name="Wrap\\Unwrap { }"
script_description="ヽ( ﾟヮ・)ノ"
script_author="dark_star90"
script_version="2.1"

--Settings
kill_inline = true	--kill inline tags


function Kevin(subs, sel)
		for x, i in ipairs(sel) do
		line=subs[i]
		line.text = line.text
				:gsub("-","NOTEMDASH")
				:gsub("%(","FIRSTCLIP")
				:gsub("%)","LASTCLIP")
		line.text=line.text
				:gsub("{","")
				:gsub("}","")
		line.text = line.text
				:gsub("NOTEMDASH","-")
				:gsub("FIRSTCLIP","%(")
				:gsub("LASTCLIP","%)")
		subs[i]=line
		end
end

function switch (subs, sel)
	for x, i in ipairs(sel) do
		line=subs[i]
		tags=line.text:match("^{\\[^}]-}")
		--keep previous commments
		if line.text:match("{<([^\\}]-)>}") then line.text=line.text:gsub("{<([^\\}]-)>}","{|%1|}") :gsub("{([^\\}]-)}","{>%1<}") end
		--the actual stuff
		line.text=line.text
		:gsub("-","NOTEMDASH")
		:gsub("%(","FIRSTCLIP")
		:gsub("%)","LASTCLIP")
		:gsub("\\N","_br_")							--save linebreak
		:gsub("{<([^\\}]-)>}","{%1}")				--restore comment
		:gsub("{([^\\}]-)}","}{<%1>}{") 			--keep comment
		:gsub("{<>|([^\\}]-)|<>}","{<%1>}") 		--keep previous comment
		:gsub("{<>([^\\}]-)<>}","%1") 				--keep previous comment
		:gsub("^([^{]+)","{%1")						--First { when no tags
		:gsub("([^}]+)$","%1}")						--Last } on last collumn
		:gsub("([^}])({\\[^}]-})([^{])","%1}%2{%3")	--keep {} around tags
		:gsub("^({\\[^}]-})([^{])","%1{%2")			--First { after first set of tags
		:gsub("([^}])({\\[^}]-})$","%1}%2")
		:gsub("{}","")								--get rid off garbage
		:gsub("_br_","\\N")							--return linebreak
		:gsub("NOTEMDASH","-")
		:gsub("FIRSTCLIP","%(")
		:gsub("LASTCLIP","%)")
		if kill_inline == true then 
			line.text = line.text:gsub("}{\\[^}]-}{","") :gsub("{\\[^}]-}","")
			line.text = tags..line.text 
		end
		subs[i]=line
	end
end

--aegisub.register_macro("unwrap", script_description, Kevin)
aegisub.register_macro(script_name, script_description, switch)