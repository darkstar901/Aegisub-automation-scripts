script_name="Textripper"
script_description="Faulheit wins"
script_author="dark_star90"
script_version="1.5"
submenu="_darkis crappy scripts"

include("karaskel.lua")
clipboard = require 'aegisub.clipboard'

--settings--
include_timings = "frames"	--"frames" or "ms", leave empty for text only
fps = 23.976 				--if no video is loaded; needed by "ms"
ftadd = 5 					--how many frames to add by Typecut offset
--end of settings--


function get_frames(subs, sel)
meta, styles = karaskel.collect_head(subs)
	scriptname=aegisub.file_name()
	scriptname=scriptname:gsub("%.ass"," ")
	scriptname=aegisub.decode_path("?script").."\\"..scriptname.."Typetext.txt"
	file=io.open(scriptname,"w")
		for x, i in ipairs(sel) do
		line=subs[i]
		times=subs[sel[1]]
		karaskel.preproc_line(subtitles, meta, styles, line)
		
		if include_timings=="ms" then
			time_offset = times.start_time
			start=line.start_time
			if start < 0 then start=0
			else start=start+fps*ftadd-time_offset
			end
			endt=line.end_time
			endt=endt+fps*ftadd-time_offset
			text=line.text_stripped:gsub("\\N","\n"..start.."|"..endt.."|")
			lines=start.."|"..endt.."|"..text.."\n"
		
		elseif include_timings=="frames" then
			time_offset = aegisub.frame_from_ms(times.start_time)
			if time_offset == nil then time_offset = math.floor(times.start_time/1000*fps) end
		
			start=aegisub.frame_from_ms(line.start_time)
			if 	start == nil then start=math.floor(line.start_time/1000*fps+1) end
			if 	start < 0 then start=0 else
				start=start+ftadd-time_offset
			end
			endt=aegisub.frame_from_ms(line.end_time)
			if endt == nil then endt=math.floor(line.end_time/1000*fps+1) end
			endt=endt+ftadd-time_offset
			text=line.text_stripped:gsub("\\N","\n"..start.."|"..endt.."|")
			lines=start.."|"..endt.."|"..text.."\n"
					
		else
			text=line.text_stripped:gsub("\\N","\n")
			lines=text.."\n"
		end	
		file:write(lines)
		end
		file:close()
		clipboard.set(scriptname)
end
	
aegisub.register_macro(submenu.."/"..script_name, script_description, get_frames)