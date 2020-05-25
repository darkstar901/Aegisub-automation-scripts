script_name="Anti-Blinker Linking"
script_description="Autosnapper"
script_author="dark_star90"
script_version="1.7"
submenu="_darkis crappy scripts"

--Settings--
max_gap  	=  65	--time in ms
mpv_link 	= 220	--gap-time in ms mpv does auto-linking
lead_in_gap	= 320	--max pause between scene change and line.start_time incl lead-in
--Settings--

function cutout(subs, sel)
	for z, i in ipairs(sel) do
	    line=subs[i]
	    j=i+1
		if i~=sel[#sel] then
			l2=subs[j]
			gap = l2.start_time - line.end_time
			if gap ~= 0 and gap < max_gap and gap > -1*max_gap then
				l2.start_time = line.end_time
				l2.effect=l2.effect.." [start time snapped by "..gap.."ms]"
				subs[j] = l2
			end
		
			if gap >= max_gap and gap < mpv_link then
				l3=subs[j]
				l3.text="{\\alpha&HFF&}Line to prevent MPV Auto-Linking"
				l3.actor=""
				l3.effect=" [line inserted]"
				l3.start_time=line.end_time
				l3.end_time=l2.start_time
				subs.insert(i+1, l3)
				for s=z,#sel do sel[s]=sel[s]+1 end
			end
		
			if gap >= mpv_link and gap < lead_in_gap then
				l2.effect=l2.effect.." [gap only "..gap.."ms; check and fix if needed]"
				subs[j] = l2
			end
		end
	end
end		

aegisub.register_macro(submenu.."/"..script_name, script_description, cutout)