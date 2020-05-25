script_name = "Autism Position Shifter"
script_description = "Shifts Position by 1, works with \\t in line."
script_author = "dark_star90 - inspired by unanimated"
script_version = "2.4"
submenu="_darkis crappy scripts"

Yutils = include("Yutils.lua")

function shift_left(subs,sel)
	x=-1
	y=0
	shifter(subs,sel)
end

function shift_right(subs,sel)
	x=1
	y=0
	shifter(subs,sel)
end

function shift_up(subs,sel)
	x=0
	y=-1
	shifter(subs,sel)
end

function shift_down(subs,sel)
	x=0
	y=1
	shifter(subs,sel)
end

function rotate_clockwise(subs,sel)
	rot_shift=-1
	rotater(subs,sel)
end

function rotate_counter_clockwise(subs,sel)
	rot_shift=1
	rotater(subs,sel)
end

function clipshift_left(subs,sel)
	x=-1
	y=0
	shift_clip(subs,sel)
end

function clipshift_right(subs,sel)
	x=1
	y=0
	shift_clip(subs,sel)
end

function clipshift_up(subs,sel)
	x=0
	y=-1
	shift_clip(subs,sel)
end

function clipshift_down(subs,sel)
	x=0
	y=1
	shift_clip(subs,sel)
end

function rotate_clip_counter_clockwise(subs,sel)
	rotation=1
	rotate_clip(subs,sel)
end

function rotate_clip_clockwise(subs,sel)
	rotation=-1
	rotate_clip(subs,sel)
end

function shift_clip_GUI(subs,sel,act)
	GUI={
	{x=1,y=0,class="label",label="Autism Position Shifter v"..script_version},
	{x=0,y=1,class="label",label="Move clip by: X"},
	{x=1,y=1,class="floatedit",name="X",value=0},
	{x=2,y=1,class="label",label="Y"},
	{x=3,y=1,class="floatedit",name="Y",value=0},
	}
	P,res=aegisub.dialog.display(GUI,{"Apply","Cancel"},{ok='Apply',cancel='Cancel'})
	if P == "Apply" then
		x,y = res.X,res.Y
		shift_clip(subs,sel)
	end
	return sel
end

function rotate_clip_GUI(subs,sel,act)
	GUI={
	{x=0,y=0,class="label",label="Autism Position Shifter v"..script_version},
	{x=0,y=1,class="checkbox",name="direction",label="Clockwise",value=true},
	{x=0,y=2,class="label",label="Rotate clip by"},
	{x=1,y=2,class="floatedit",name="rotation",value=0},
	{x=3,y=2,class="label",label="degree"},
	}
	P,res=aegisub.dialog.display(GUI,{"Apply","Cancel"},{ok='Apply',cancel='Cancel'})
	if P == "Apply" then
		rotation = res.rotation
		if res.direction == true then rotation = rotation*-1 end
		rotate_clip(subs,sel)
	end
	return sel
end

function shifter(subs,sel)
	for z,i in ipairs(sel) do
		shifter_loop(z,i,subs,sel)
		
	end
end

function shifter_loop(z,i,subs,sel)
	line=subs[i]
		--Position
		if line.text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)") ~= nil then
			px = line.text:find("\\pos%(([%d%.%-]+),([%d%.%-]+)%)")
			py = line.text:find(",([%d%.%-]+)%)", px)
			pz = line.text:find("%)", px)
			posx = string.sub(line.text, px+5, py-1)
			xdigit = tonumber(posx)
			xdigit = tostring(xdigit+x)
			posy = string.sub(line.text, py+1, pz-1)
			ydigit = tonumber(posy)
			ydigit = tostring(ydigit+y)
			end
		--\pos shiften
		line.text = line.text
				:gsub("\\pos%(([%d%.%-]+),([%d%.%-]+)%)","POSITION")
				:gsub("-","NOTEMDASH")
				:gsub("%(","FIRSTCLIP")
				:gsub("%)","LASTCLIP")
		line.text = line.text:gsub("}{","")
		if line.text:match("POSITION") ~= nil then line.text = line.text:gsub("POSITION", "\\pos%("..xdigit..","..ydigit.."%)") end
		line.text = line.text
				:gsub("}{","")
				:gsub("NOTEMDASH","-")
				:gsub("FIRSTCLIP","%(")
				:gsub("LASTCLIP","%)")
		subs[i]=line
end
		
function rotater(subs,sel)
	for z,i in ipairs(sel) do
			line=subs[i]
		--Rotation
		rotate = 0
		line.text=recalc(line.text,"\\frz")
		--if line.text:match("\\frz[%d%.%-]+") ~= nil then 
		--	rot1 = line.text:find("\\frz[%d%.%-]+")
		--	rot2 = line.text:find("[\\}]", rot1+1)
		--	rot3 = string.sub(line.text, rot1+4, rot2-1)
		--	rotate = tonumber(rot3)
		--end
		----\frz shiften
		--line.text = line.text
		--		:gsub("\\frz[%d%.%-]+","")
		--		:gsub("-","NOTEMDASH")
		--		:gsub("%(","FIRSTCLIP")
		--		:gsub("%)","LASTCLIP")
		--line.text = line.text:gsub(line.text, "{\\frz"..rotate+rot_shift.."}"..line.text)
		--line.text = line.text
		--		:gsub("}{","")
		--		:gsub("NOTEMDASH","-")
		--		:gsub("FIRSTCLIP","%(")
		--		:gsub("LASTCLIP","%)")
		--aegisub.log(line.text)
		subs[i]=line
		end
	end

function calc(num) --ripped from recalculator
	num=round(num+rot_shift,3)
    return num
end

function recalc(text,tg) --ripped from recalculator
	val="([%d%.%-]+)"
	-- split into non-tf/tf segments if there are transforms
	seg={}
	if text:match("\\t%b()") then
		for seg1,seg2 in text:gmatch("(.-)(\\t%b())") do table.insert(seg,seg1) table.insert(seg,seg2) end
		table.insert(seg,text:match("^.*\\t%b()(.-)$"))
	else table.insert(seg,text)
	end
	-- change non-tf/tf/all segments
	for q=1,#seg do
		seg[q]=seg[q]:gsub(tg.."("..val..")",function(a) return tg..calc(tonumber(a)) end)
	end
	nt=""
	for q=1,#seg do nt=nt..seg[q] end
	return nt
end
	
function round(n,dec) dec=dec or 0 n=math.floor(n*10^dec+0.5)/10^dec return n end --ripped from recalculator

function posio(xx,yy) 
	xx,yy=0,0
	xx,yy=text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)")
	xx=round(xx) yy=round(yy)
	return xx,yy
end

function rotate_clip(subs,sel)
	for z,i in ipairs(sel) do
		line=subs[i]
		text=line.text:gsub("\\i?clip%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)","\\i?clip(m %1 %2 l %3 %2 %3 %4 %1 %4)")
		if text:match("\\move") then text=text:gsub("\\move","\\pos") mp="\\move" else mp="\\pos" end
		ctext=text:match("clip%(m ([%d%.%a%s%-]+)")
		if text:match("\\pos") then xx,yy = posio(xx,yy)
			ctext2=ctext:gsub("([%d%.%-]+)%s([%d%.%-]+)",function(a,b) return a-xx.." "..b-yy end)
		else pos="(0,0)" ctext2=ctext
		end
		ctext2="m "..ctext2:gsub("([%d%.]+)",function(a) return round(a) end)
		MATRIX = Yutils.math.create_matrix()
		ctext2 = Yutils.shape.transform(ctext2 , MATRIX.rotate("z", rotation))
		ctext3=ctext2:gsub("([%d%.%-]+)%s([%d%.%-]+)",function(a,b) return a+xx.." "..b+yy end)
		if line.text:match("\\iclip")=="\\iclip" then clippy = "\\iclip%(" else clippy = "\\clip%(" end
		line.text = line.text:gsub("\\i?clip%b()",clippy..ctext3..")")
		subs[i]=line
	end
end

function shift_clip(subs,sel)
	for z,i in ipairs(sel) do
		line=subs[i]
		text=line.text:gsub("\\i?clip%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)","\\i?clip(m %1 %2 l %3 %2 %3 %4 %1 %4)")
		if text:match("\\move") then text=text:gsub("\\move","\\pos") mp="\\move" else mp="\\pos" end
		ctext=text:match("clip%(m ([%d%.%a%s%-]+)")
		if text:match("\\pos") then xx,yy = posio(xx,yy)
			ctext2=ctext:gsub("([%d%.%-]+)%s([%d%.%-]+)",function(a,b) return a-xx.." "..b-yy end)
		else pos="(0,0)" ctext2=ctext
		end
		ctext2="m "..ctext2:gsub("([%d%.]+)",function(a) return round(a) end)
		ctext2 = Yutils.shape.move(ctext2, x, y)
		ctext3=ctext2:gsub("([%d%.%-]+)%s([%d%.%-]+)",function(a,b) return a+xx.." "..b+yy end)
		if line.text:match("\\iclip")=="\\iclip" then clippy = "\\iclip%(" else clippy = "\\clip%(" end
		line.text = line.text:gsub("\\i?clip%b()",clippy..ctext3..")")
		subs[i]=line
	end
end

function round_loop(num) -- borrowed from the lua-users wiki (all of the intelligent code you see in here is)
  local mult = 10^(3 or 0)
  return math.floor(num * mult + 0.5) / mult
end


function loop_pos_gui(subs,sel)
	GUI={
	{x=0,y=0,class="label",label="Looper"},
	{x=1,y=0,class="label",label="Autism Position Shifter v"..script_version},
	{x=0,y=1,class="label",label="X offset"},
	{x=1,y=1,class="floatedit",name="X",value=0},
	{x=0,y=2,class="label",label="Y offset"},
	{x=1,y=2,class="floatedit",name="Y",value=0},
	{x=0,y=3,class="label",label="Max lines for 1 loop"},
	{x=1,y=3,class="intedit",name="L",value=20},
	{x=0,y=4,class="label",label="Acceleration"},
	{x=1,y=4,class="floatedit",name="accel",value=0.5},
	}
	P,res=aegisub.dialog.display(GUI,{"Apply","Cancel"},{ok='Apply',cancel='Cancel'})
	if P == "Apply" then
		xx,yy= res.X,res.Y
		loop = res.L
		accel= res.accel
	repeat looping(subs,sel) until #sel==0
	end
end


function looping(subs,sel)
	for z,i in ipairs(sel) do
		if z <= loop/4 then 					acc= (z/(loop/4))^accel end
		if z > loop/4 and z <= loop/2 then 	acc= (-1*(z-loop/2)/(loop/4))^accel end
		if z > loop/2 and z <= loop/4*3 then 	acc= -1*((z-loop/2)/(loop/4))^accel end
		if z > loop/4*3 and z <= loop then 		acc= -1*(-1*(z-loop)/(loop/4))^accel end
		x=round_loop(xx*acc)
		y=round_loop(yy*acc)
		--aegisub.log(z.." - "..yy.."  "..acc.."  "..x.."  "..y.."\n")
		shifter_loop(z,i,subs,sel)
	end
	sn=loop+1
	while sn > 0 do 
	table.remove(sel, sn)
	sn=sn-1
	end
	return sel
end

aegisub.register_macro(submenu.."/"..script_name.."/Shift \\pos Left",script_description,shift_left)
aegisub.register_macro(submenu.."/"..script_name.."/Shift \\pos Right",script_description,shift_right)
aegisub.register_macro(submenu.."/"..script_name.."/Shift \\pos Up",script_description,shift_up)
aegisub.register_macro(submenu.."/"..script_name.."/Shift \\pos Down",script_description,shift_down)
aegisub.register_macro(submenu.."/"..script_name.."/Rotate \\frz Counter-clockwise",script_description,rotate_clockwise)
aegisub.register_macro(submenu.."/"..script_name.."/Rotate \\frz Clockwise",script_description,rotate_counter_clockwise)
aegisub.register_macro(submenu.."/"..script_name.."/Shift \\clip Left",script_description,clipshift_left)
aegisub.register_macro(submenu.."/"..script_name.."/Shift \\clip Right",script_description,clipshift_right)
aegisub.register_macro(submenu.."/"..script_name.."/Shift \\clip Up",script_description,clipshift_up)
aegisub.register_macro(submenu.."/"..script_name.."/Shift \\clip Down",script_description,clipshift_down)
aegisub.register_macro(submenu.."/"..script_name.."/Shift \\clip GUI",script_description,shift_clip_GUI)
aegisub.register_macro(submenu.."/"..script_name.."/Rotate \\clip Counter-clockwise",script_description,rotate_clip_counter_clockwise)
aegisub.register_macro(submenu.."/"..script_name.."/Rotate \\clip Clockwise",script_description,rotate_clip_clockwise)
aegisub.register_macro(submenu.."/"..script_name.."/Rotate \\clip by degree",script_description,rotate_clip_GUI)
aegisub.register_macro(submenu.."/"..script_name.."/Loop Position",script_description,loop_pos_gui)