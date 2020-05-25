script_name = "QC adder"
script_description = "Adds \\N Nickname and shifts position."
script_author = "dark_star90"
script_version = "1.0"
submenu="_darkis crappy scripts"

namae = "kageru"
shift_x = 0
shift_y = -69

function GUI(subs,sel,act)
	GUI={
	{x=0,y=0,class="label",label="QC adder v"..script_version},
	{x=0,y=1,class="checkbox",name="prev",label="shift \\pos in previous line",value=true},
	{x=0,y=2,class="label",label="Shift X position by"},
	{x=0,y=3,class="label",label="Shift Y position by"},
	{x=0,y=4,class="label",label="Add Name"},
	{x=1,y=2,class="floatedit",name="x",value=shift_x},
	{x=1,y=3,class="floatedit",name="y",value=shift_y},
	{x=1,y=4,class="edit",name="namer",value=namae},
	}
	P,res=aegisub.dialog.display(GUI,{"Just do it","Cancel"},{ok='Just do it',cancel='Cancel'})
	if P == "Just do it" then
		if res.prev == true then shift_prev(subs,sel) end
		qc_adder(subs,sel)
	end
	return sel
end

function qc_adder(subs,sel)
	for z,i in ipairs(sel) do
	    line=subs[i]
		if line.text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)") == nil then aegisub.log("\\pos tag is needed in selected line") end
		--Position
		if line.text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)") ~= nil then
			px = line.text:find("\\pos%(([%d%.%-]+),([%d%.%-]+)%)")
			py = line.text:find(",([%d%.%-]+)%)", px)
			pz = line.text:find("%)", px)
			posx = string.sub(line.text, px+5, py-1)
			xdigit = tonumber(posx)
			xdigit = tostring(xdigit+res.x)
			posy = string.sub(line.text, py+1, pz-1)
			ydigit = tonumber(posy)
			ydigit = tostring(ydigit+res.y)
			end
		--Namen einfügen und \pos shiften
		line.text = line.text
				:gsub("\\pos%(([%d%.%-]+),([%d%.%-]+)%)","POSITION")
				:gsub("-","NOTEMDASH")
				:gsub("%(","FIRSTCLIP")
				:gsub("%)","LASTCLIP")
		line.text = line.text:gsub(line.text, line.text.."\\N"..res.namer)
		if line.text:match("POSITION") ~= nil then line.text = line.text:gsub("POSITION", "\\pos%("..xdigit..","..ydigit.."%)") end
		line.text = line.text
				:gsub("}{","")
				:gsub("NOTEMDASH","-")
				:gsub("FIRSTCLIP","%(")
				:gsub("LASTCLIP","%)")
		subs[i]=line
		end
	end
	
function shift_prev(subs,sel)
	for z,i in ipairs(sel) do
			j=i
			j=j-1
            lprev=subs[j]
		if lprev.text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)") == nil then aegisub.log("\\pos tag is needed in previous line\n") end
		--\\fad speichern
		if lprev.text:match("\\fad%(%d+,%d+%)") ~= nil then
			fad1 = lprev.text:find("\\fad%(%d+,%d+%)")
			fad2 = lprev.text:find("%)", fad1)
			fad3 = string.sub(lprev.text, fad1+5, fad2-1)
			lprev.text = lprev.text:gsub("\\fad%(%d+,%d+%)","fade")
			end
		--Position
		if lprev.text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)") ~= nil then
			px = lprev.text:find("\\pos%(([%d%.%-]+),([%d%.%-]+)%)")
			py = lprev.text:find(",([%d%.%-]+)%)", px)
			pz = lprev.text:find("%)", px)
			posx = string.sub(lprev.text, px+5, py-1)
			xdigit = tonumber(posx)
			xdigit = tostring(xdigit+res.x)
			posy = string.sub(lprev.text, py+1, pz-1)
			ydigit = tonumber(posy)
			ydigit = tostring(ydigit+res.y)
			end
		--Namen einfügen und \pos shiften
		lprev.text = lprev.text
				:gsub("-","NOTEMDASH")
				:gsub("\\pos%(([%d%.%-]+),([%d%.%-]+)%)","position")
				:gsub("%(","FIRSTCLIP")
				:gsub("%)","LASTCLIP")
				:gsub("NOTEMDASH","-")
		lprev.text = lprev.text:gsub("}{","")
		if lprev.text:match("FIRSTCLIP") ~= nil then lprev.text = lprev.text:gsub("FIRSTCLIP","%(") end
		if lprev.text:match("LASTCLIP") ~= nil then lprev.text = lprev.text:gsub("LASTCLIP","%)") end
		if lprev.text:match("position") ~= nil then lprev.text = lprev.text:gsub("position", "\\pos%("..xdigit..","..ydigit.."%)") end
		if lprev.text:match("fade") ~= nil then lprev.text = lprev.text:gsub("fade", "\\fad%("..fad3.."%)") end
		--aegisub.log(lprev.text)
		subs[j]=lprev
		end		
	end
	
aegisub.register_macro(submenu.."/"..script_name,script_description,GUI)