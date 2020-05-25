script_name="ZERO WIDTH NO-BREAK SPACE KILLER"
script_description="Reformat"
script_author="dark_star90"
script_version="1.0"
submenu="_darkis crappy scripts"


re=require'aegisub.re'
unicode=require'aegisub.unicode'
clipboard=require("aegisub.clipboard")

function replaceall(subs, sel)
	table.remove(sel,1)
    for i=1, #subs do
	if subs[i].class=="dialogue" then table.insert(sel,i) end
	end
	for x, i in ipairs(sel) do
            line=subs[i]
	    text=line.text
	    text=text
		:gsub("-","NOTEMDASH")
	    :gsub("\\n","SMALL_BREAK")
	    :gsub("\\N","LARGE_BREAK")
	    :gsub("\\h","HARD_SPACE")
	    :gsub("%(","FIRSTCLIP")
		:gsub("%)","LASTCLIP")
	    text=text:gsub("﻿","")
		text=text
		:gsub("NOTEMDASH","-")
	    :gsub("SMALL_BREAK","\\n")
	    :gsub("LARGE_BREAK","\\N")
	    :gsub("HARD_SPACE","\\h")
		:gsub("FIRSTCLIP","%(")
		:gsub("LASTCLIP","%)")
	    line.text=text
	    subs[i]=line
    end
end

aegisub.register_macro(submenu.."/"..script_name,script_description,replaceall)