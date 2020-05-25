script_name = "Directional blur"
script_description = "blur in specific direction using \\xshad and \\yshad"
script_author = "dark_star90"
script_version = "1.2"
submenu="_darkis crappy scripts"
--todo: add \a1 \a3 support for borders

--[[
You can set the direction with \xshad and/or \yshad and the number of iterations to one side into the effect field.
If any direction or the number of iterations are missing, a GUI will ask for the missing values.
]]--

include("karaskel.lua")

function krskl(subs,sel) meta, styles = karaskel.collect_head(subs) end

function shifter_loop()
	--\pos shiften
	xdigit = tostring(xnumber+x)
	ydigit = tostring(ynumber+y)
	l.text = line.text
	l.text = l.text
			:gsub("\\pos%(([%d%.%-]+),([%d%.%-]+)%)","POSITION")
			:gsub("-","NOTEMDASH")
			:gsub("%(","FIRSTCLIP")
			:gsub("%)","LASTCLIP")
	l.text = l.text:gsub("}{","")
	if l.text:match("POSITION") ~= nil then line.text = line.text:gsub("POSITION", "\\pos%("..xdigit..","..ydigit.."%)") end
	l.text = l.text
			:gsub("}{","")
			:gsub("NOTEMDASH","-")
			:gsub("FIRSTCLIP","%(")
			:gsub("LASTCLIP","%)")
	l.layer = l.layer+1
end

function number_collector(subs,sel)
	karaskel.preproc_line(subtitles, meta, styles, line)
		if tonumber(line.effect) ~= nil then linenumber = tonumber(string.format("%d",line.effect))
		else linenumber = 1 --aegisub.log("Add number of lines to be generated into effect field\n")
		end
		--Position
		if line.text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)") ~= nil then
			px = line.text:find("\\pos%(([%d%.%-]+),([%d%.%-]+)%)")
			py = line.text:find(",([%d%.%-]+)%)", px)
			pz = line.text:find("%)", px)
			posx = string.sub(line.text, px+5, py-1)
			xnumber = tonumber(posx)
			posy = string.sub(line.text, py+1, pz-1)
			ynumber = tonumber(posy)
		end
		--Override Tags
		if line.raw:match("\\xshad[%d%.%-]+") ~= nil then 
			shadx = line.text:match("\\xshad[%d%.%-]+"):gsub("\\xshad","")
			xshift = tonumber(shadx)
			line.text = line.text:gsub("\\xshad[%d%.%-]+","")
		else xshift = 0	end
		if line.raw:match("\\yshad[%d%.%-]+") ~= nil then 
			shady = line.text:match("\\yshad[%d%.%-]+"):gsub("\\yshad","")
			yshift = tonumber(shady)
			line.text = line.text:gsub("\\yshad[%d%.%-]+","")
		else yshift = 0	end
		if xshift==0 and yshift==0 or tonumber(line.effect) == nil then gui() end
		--aegisub.log("\\xhad or \\yshad bigger than 0 needed\n") end
		if line.raw:match("\\alpha&H%x+&") ~= nil then 
			alfa = line.text:match("\\alpha&H%x+&"):gsub("\\alpha&H",""):gsub("&","")
			alfa = tonumber("0x"..alfa)
			line.text = line.text:gsub("\\alpha&H%x+&","")
		else alfa = 0 end
end

function directional_blur(subs,sel)
	krskl(subs,sel)
	for z=#sel,1,-1 do
	i=sel[z]
	line=subs[i]
		l=line
		if line.text:match("\\pos") == nil then aegisub.log("Works only with \\pos\n")
		else number_collector(subs,sel)
			opacity=256-alfa
			alpha=string.format("%x", 256-opacity/(linenumber+1))
			line.text = line.text:gsub("\\pos","\\alpha&H"..alpha.."&\\pos")
			subs[i]=line
			for q = 1, linenumber do
				subs.insert(i+1,line)
				j=i
				j=j+1
				x = tonumber(string.format("%.3f", xshift*q/linenumber))
				y = tonumber(string.format("%.3f", yshift*q/linenumber))
				shifter_loop()
				subs[j]=l
			end
			for q = 1, linenumber do
				subs.insert(i+1,line)
				j=i
				j=j+1
				x = tonumber(string.format("%.3f", xshift*-q/linenumber))
				y = tonumber(string.format("%.3f", yshift*-q/linenumber))
				shifter_loop()
				subs[j]=l
			end
		end
		for s=z,#sel do sel[s]=sel[s]+linenumber end
    end
    return sel
end

function gui()
	GUI={
	{x=1,y=0,class="label",label=script_name.." v"..script_version},
	{x=0,y=1,class="label",label="Set blur direction: X"},
	{x=1,y=1,class="floatedit",name="X",value=xshift},
	{x=2,y=1,class="label",label="Y"},
	{x=3,y=1,class="floatedit",name="Y",value=yshift},
	{x=0,y=2,class="label",label="Set Iterations per side"},
	{x=1,y=2,class="label",label=" (half of generated lines):"},
	{x=3,y=2,class="floatedit",name="Iterations",value=linenumber}
	}
	P,res=aegisub.dialog.display(GUI,{"Apply","Cancel"},{ok='Apply',cancel='Cancel'})
	if P == "Apply" then
		xshift,yshift,linenumber = res.X,res.Y,res.Iterations
	end
end

aegisub.register_macro(submenu.."/"..script_name,script_description,directional_blur)