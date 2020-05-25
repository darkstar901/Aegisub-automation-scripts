script_name="Endtimecut"
script_description="Reduziert die Endzeit"
script_author="dark_star90"
script_version="2.0"

-- SETTINGS

cut=170		-- Wert in ms zum hinzufügen/reduzieren vom leadout.

-- END OF SETTINGS

function cutout(subs, sel)
	for z, i in ipairs(sel) do
	    line=subs[i]
		start=line.start_time
		endt=line.end_time
		
		if (endt-cut)>start then endt=(endt-cut) else endt=start
		end
	    line.end_time=endt
	    subs[i]=line
	    end
		j=sel[#sel]
		j=j+1
		l2=subs[j]
	    l2.start_time = line.end_time
		subs[j] = l2
	    sel={j}
		return sel
		end
		

aegisub.register_macro("Timing/Endtimecut", script_description, cutout)