script_name="Delete Empty Lines with Tags"
script_description="Garbage Detector"
script_author="dark_star90"
script_version="1.1"
submenu="_darkis crappy scripts"

include("karaskel.lua")

function deleter(subs,sel)
	--progress("Deleting empty lines")
	noe_sel={}
	meta, styles = karaskel.collect_head(subs)
	for s=#sel,1,-1 do
	    line=subs[sel[s]]
		karaskel.preproc_line(subtitles, meta, styles, line)
	    if line.text_stripped=="" and line.text:match("}m ")==nil then
		for z,i in ipairs(noe_sel) do noe_sel[z]=i-1 end
		subs.delete(sel[s])
	    else
		table.insert(noe_sel,sel[s])
	    end
	end
	return noe_sel
end
aegisub.register_macro(submenu.."/"..script_name, script_description, deleter)