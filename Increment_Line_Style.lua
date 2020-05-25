script_name = "Increment Line Style"
script_description = "Sets the Style of a Line to the next defined Style."
script_author = "dark_star90"
script_version = "2.1"
submenu="_darkis crappy scripts"

--Yutils = include("Yutils.lua")
include("karaskel.lua")

function stylechanger(subs,sel)
	meta, styles = karaskel.collect_head(subs)
		for z,i in ipairs(sel) do
            line=subs[i]
			index = styles.n
			for k, v in ipairs(styles) do
				if line.style == v.name then index = k end
			end
			if index == styles.n then line.style = styles[1].name
			else line.style = styles[index+1].name end
		subs[i]=line
		end	
	end

aegisub.register_macro(submenu.."/"..script_name,script_description,stylechanger)