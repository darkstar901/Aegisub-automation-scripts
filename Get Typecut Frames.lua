script_name="Get Typecut Frames"
script_description="Faulheit wins"
script_author="dark_star90"
script_version="1.7"
submenu="_darkis crappy scripts"

clipboard = require 'aegisub.clipboard'
typecut_conf=aegisub.decode_path("?user").."\\typecut.conf"

function first_conf()
fps = 23.976 --if no video is loaded
before = ""
separator = ","
zeparator = "-"	
after = ""
ftadd = 5 --frames to add at beginning/end
f_txt = true --output in textfile (always copy to clipboard)
end

function read_conf()
konf=io.open(typecut_conf)
	lines = {}
	for line in konf:lines() do
		table.insert(lines, line)
	end
	konf:close()
	if lines[1]:match("Get Typecut Frames Settings") == "Get Typecut Frames Settings" then
	fps = 		lines[3]:gsub("fps:","")
	before =	lines[4]:gsub("Before:","")
	separator =	lines[5]:gsub("Separator 1:","")
	zeparator =	lines[6]:gsub("Separator 2:","")
	after =		lines[7]:gsub("After:","")
	ftadd =		lines[8]:gsub("Frames_to_add:","")
	if lines[9]:match("true")=="true" then f_txt = true else f_txt = false end
	else first_conf()
	end
end

function write_conf()
konf=io.open(typecut_conf,"w")
conf = 
"Get Typecut Frames Settings\n\nfps:"..fps..
"\nBefore:"..before..
"\nSeparator 1:"..separator..
"\nSeparator 2:"..zeparator..
"\nAfter:"..after..
"\nFrames_to_add:"..ftadd..
"\nTextfile output:"..tostring(f_txt)
konf:write(conf)
konf:close()
end
	
function options(subs,sel)
konf=io.open(typecut_conf)
    if konf==nil then 
		first_conf()
		write_conf()
	end
read_conf()
gui={
  {x=0,y=0,width=2,class="label",label="Get Typecut Frames Options"},
  {x=0,y=1,class="label",label="FPS:"},
  {x=1,y=1,class="floatedit",name="fps",value=fps,hint="only when no video is loaded"},
  {x=0,y=2,class="label",label="Prefix Text:"},
  {x=1,y=2,class="edit",name="Before",value=before},
  {x=0,y=3,class="label",label="Separator taod:"},
  {x=1,y=3,class="edit",name="Separator 1",value=separator},
  {x=0,y=4,class="label",label="Separator nino:"},
  {x=1,y=4,class="edit",name="Separator 2",value=zeparator},
  {x=0,y=5,class="label",label="Text Suffix:"},
  {x=1,y=5,class="edit",name="After",value=after},
  {x=0,y=6,class="label",label="Frames to add:"},
  {x=1,y=6,class="intedit",name="Frames_to_add",value=ftadd},
  {x=0,y=7,width=3,class="checkbox",name="Textfile output",label="Textfile output:",value=f_txt}
}
P,res=aegisub.dialog.display(gui,{"Save","Cancel"},{ok='Save',cancel='Cancel'})
	if P == "Save" then
		conf ="Get Typecut Frames Settings\n\n"
		for key,val in ipairs(gui) do
			if val.class=="checkbox" then conf=conf..val.name..":"..tf(res[val.name]).."\n" end
			if val.class=="floatedit" then conf=conf..val.name..":"..res[val.name].."\n" end
			if val.class=="intedit" then conf=conf..val.name..":"..res[val.name].."\n" end
			if val.class=="edit" then conf=conf..val.name..":"..res[val.name].."\n" end
		end
  	konf=io.open(typecut_conf,"w")
	konf:write(conf)
	konf:close()
	end
end

function tf(val)
	if val==true then ret="true"
	elseif val==false then ret="false"
	else ret=val end
	return ret
end

function get_frames(subs, sel)
	read_conf()
	scriptname=aegisub.file_name()
	scriptname=scriptname:gsub("%.ass"," ")
	clippy = ""
	if f_txt == true then file=io.open(aegisub.decode_path("?script").."\\"..scriptname.."Typecuts.txt","w") end
	for x, i in ipairs(sel) do
		line=subs[i]
		start=aegisub.frame_from_ms(line.start_time)
		if start == nil then start=math.floor(line.start_time/1000*fps+1) end
		start=start-ftadd
		if start < 0 then start=0 end
		endt=aegisub.frame_from_ms(line.end_time)
		if endt == nil then endt=math.floor(line.end_time/1000*fps+1) end
		endt=endt+ftadd-1
		lines=before..start..separator..endt..after.."\n"
		clippy=clippy..lines
		end
	if f_txt == true then
	file:write(clippy)
	file:close()
	end
	clipboard.set(clippy)
end

function get_frames2(subs, sel)
	read_conf()
	scriptname=aegisub.file_name()
	scriptname=scriptname:gsub("%.ass"," ")
	clippy = ""
	if f_txt == true then file=io.open(aegisub.decode_path("?script").."\\"..scriptname.."Typecuts.txt","w") end
	for x, i in ipairs(sel) do
		line=subs[i]
		start=aegisub.frame_from_ms(line.start_time)
		if start == nil then start=math.floor(line.start_time/1000*fps+1) end
		start=start-ftadd
		if start < 0 then start=0 end
		endt=aegisub.frame_from_ms(line.end_time)
		if endt == nil then endt=math.floor(line.end_time/1000*fps+1) end
		endt=endt+ftadd-1
		lines=before..start..zeparator..endt..after.."\n"
		clippy=clippy..lines
		end
	if f_txt == true then
	file:write(clippy)
	file:close()
	end
	clipboard.set(clippy)
end

function actorfill(subs,sel)
	for z, i in ipairs(sel) do
		line=subs[i]
		j=i-1
		l2=subs[j]
		if l2.actor ~= nil and line.actor == "" then line.actor=l2.actor end
		subs[i]=line
	end
end
function effectfill(subs,sel)
	for z, i in ipairs(sel) do
		line=subs[i]
		j=i-1
		l2=subs[j]
		if l2.effect ~= nil and line.effect == "" then line.effect=l2.effect end
		subs[i]=line
	end
end

aegisub.register_macro(submenu.."/"..script_name.."/taod", script_description, get_frames)
aegisub.register_macro(submenu.."/"..script_name.."/nino", script_description, get_frames2)
aegisub.register_macro(submenu.."/"..script_name.."/_Options", script_description, options)
aegisub.register_macro(submenu.."/"..script_name.."/Fill actor numbers", script_description, actorfill)
aegisub.register_macro(submenu.."/"..script_name.."/Fill effect numbers", script_description, effectfill)