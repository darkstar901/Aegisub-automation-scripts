script_name = "Perspective.py shortcut"
script_description = "Pulls data through perspective.py from Zeght https://github.com/TypesettingTools/Perspective"
script_author = "dark_star90"
script_version = "1.1"
submenu="_darkis crappy scripts"

function Perspective_GUI(subs,sel,act)
	GUI={
	{x=0,y=0,class="label",label=script_name.." v"..script_version},
	}
	P,res=aegisub.dialog.display(GUI,{"Apply first","Apply second","Kill Perspective","Cancel"},{ok='Apply first',cancel='Cancel'})
	if P == "Apply first" then
		kill_perspective()
		read_output()
		tags=lines[3]
	end
	if P == "Apply second" then
		kill_perspective()
		read_output()
		tags=lines[6]
	end
	if P == "Kill Perspective" then	
	kill_perspective()
	tags=""
	end
	line.text=line.text:gsub("\\i?clip%b()","\\clip%(m "..clip.."%)"..tags)
	return sel
end

function killtag(tag,t) t=t:gsub("\\"..tag.."[%d%.%-]*([\\}])","%1") return t end

function kill_perspective()
	line.text=killtag("frz",line.text)	
	line.text=killtag("frx",line.text)
	line.text=killtag("fry",line.text)
	line.text=line.text:gsub("\\org%b()","")
end

function read_output()
	konf=io.open(f_out)
	lines = {}
	for line in konf:lines() do
		table.insert(lines, line)
	end
	io.close(konf)
end
		
function perspective_clip(subs,sel)
f=aegisub.decode_path("?user").."\\automation\\autoload\\perspective.py"
f_out=aegisub.decode_path("?user").."\\Aegisub_perspective.conf"
--f_out=aegisub.decode_path("?script").."\\Aegisub_perspective.conf"
	for z,i in ipairs(sel) do
		line=subs[i]
		clip=line.text:match("clip%(m ([%d%.%a%s%-]+)")
		os.execute("py ".."\""..f.."\" \""..clip.."\">\""..f_out.."\"")
		Perspective_GUI()
		subs[i]=line
	end
end


aegisub.register_macro(submenu.."/"..script_name,script_description,perspective_clip)