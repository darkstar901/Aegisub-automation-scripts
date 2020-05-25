script_name="Time Signs by Frame"
script_description="Faulheit wins"
script_author="dark_star90"
script_version="1.0"
submenu="_darkis crappy scripts"


function get_frames(subs, sel)
	for x, i in ipairs(sel) do
		line=subs[i]
		line.start_time=aegisub.ms_from_frame(line.text)
		--aegisub.log(line.start_time)
		--aegisub.log(line.text)
		line.end_time=aegisub.ms_from_frame(line.text)
		subs[i]=line
	end
end



aegisub.register_macro(submenu.."/"..script_name, script_description, get_frames)