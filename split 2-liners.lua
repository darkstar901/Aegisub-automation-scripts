-- SETTINGS

st_name=" - Copy"		-- Upper line: add name to style name

-- END OF SETTINGS

script_name="Split 2-liners"
script_description="Split 2-liners for custom line spacing via styles"
script_author="dark_star90 - most code copypasted from unanimated scripts" --ua.JoinSplitSnap.lua; ua.QC.lua
script_version="1.1"
submenu="_darkis crappy scripts"

include("karaskel.lua")

function splitter(subs,sel)
meta, styles = karaskel.collect_head(subs)
	for i=1,#subs do
		if subs[i].class=="info" then
		local k=subs[i].key
		local v=subs[i].value
		if k=="Title" then stitle=v end
		if k=="Video File" then video=v end
		if k=="YCbCr Matrix" then colorspace=v end
		if k=="PlayResX" then resx=v end
		if k=="PlayResY" then resy=v end
		end
	 end 
	 
	for i=#sel,1,-1 do
	line=subs[sel[i]]
	text=line.text
	line.effect=line.effect:gsub(" %[3%-liner%] fix dat shit","") :gsub(" %[2%-liner%] set \\N for linebreak","")
	
	-- check for 3-liners
	karaskel.preproc_line(subtitles, meta, styles, line)
	stripped=line.text_stripped
	xres,yres=aegisub.video_size()
	realx=xres/yres*resy
	wf=realx/resx
	vidth=realx-(line.styleref.margin_l*wf)-(line.styleref.margin_r*wf)
	if stripped:match("\\N") then btxt=stripped 
		if text:match("^{[^}]*\\i1") and not text:match("\\i0") then line.styleref.italic=true end
	    bspace=btxt:match("^(.-)\\N")  aspace=btxt:match("\\N(.-)$")
	    wb=aegisub.text_extents(line.styleref,bspace)
	    wa=aegisub.text_extents(line.styleref,aspace)
	    if wb>=vidth or wa>=vidth then 
			line.effect=line.effect.." [3-liner] fix dat shit"
			text=text:gsub("\\N","")
		end
	end
	if line.width>vidth and not stripped:match("\\N") then 
	  if text:match("^{[^}]*\\i1") and not text:match("\\i0") then styleref.italic=true end
	  tekst="\\N"..stripped
	  diff=3000	stop=0
	    while stop==0 do
	      last=btxt
	      lastwb=wb or 0
	      lastwa=wa or 0
	      tekst=tekst:gsub("\\N([^%s{}]+%s)","%1\\N")
	      btxt=tekst:gsub(" \\N","\\N")
	      bspace=btxt:match("^(.-)\\N")
	      aspace=btxt:match("\\N(.-)$")
	      wb=aegisub.text_extents(line.styleref,bspace)
	      wa=aegisub.text_extents(line.styleref,aspace)
	      tdiff=math.abs(wb-wa)
	      if tdiff<diff then diff=tdiff else 
	        stop=1 btxt=last 
	      end
	    end
	    if lastwb>=vidth or lastwa>=vidth then line.effect=line.effect.." [3-liner] fix dat shit" end
	end
	if not line.effect:match(" [3-liner]") then 
		if line.width>vidth and not stripped:match("\\N") then line.effect=line.effect.." [2-liner] set \\N for linebreak" end
	end
	
	-- line splitting
	c=0
	if line.width>vidth then
	    if not text:match("\\N") and sel[i]<#subs then
			nextline=subs[sel[i]+1]
			if text:match(" that$") then text=text:gsub(" that$","") nextline.text="that "..nextline.text c=1 end
			if text:match(" and$") then text=text:gsub(" and$","") nextline.text="and "..nextline.text c=1 end
			if text:match(" but$") then text=text:gsub(" but$","") nextline.text="but "..nextline.text c=1 end
			if text:match(" so$") then text=text:gsub(" so$","") nextline.text="so "..nextline.text c=1 end
			if text:match(" to$") then text=text:gsub(" to$","") nextline.text="to "..nextline.text c=1 end
			if text:match(" when$") then text=text:gsub(" when$","") nextline.text="when "..nextline.text c=1 end
			if text:match(" with$") then text=text:gsub(" with$","") nextline.text="with "..nextline.text c=1 end
			if text:match(" the$") then text=text:gsub(" the$","") nextline.text="the "..nextline.text c=1 end
			subs[sel[i]+1]=nextline
	    end

	    if c==0 then
		text=text:gsub("{SPLIT}","{split}")
			if not text:match("\\N") and text:match("{split}") then text=text:gsub("{split}","\\N") end
			if not text:match("\\N") and text:match("%- ") then text=text:gsub("(.)%- (.-)$","%1\\N- %2") end
			if not text:match("\\N") and text:match("%. [{\\\"]?%w") then
				text=text
				:gsub("([MD][rs]s?)%. ","%1## ")
				:gsub("^(.-)%. ","%1. \\N")
				:gsub("## ",". ") end
			--if not text:match("\\N") and text:match("[%?!] {?%w") then text=text:gsub("^(.-)([%?!]) ","%1%2 \\N") end
			--if not text:match("\\N") and text:match(", {?%w") then text=text:gsub("^(.-), ","%1, \\N") end
			if text:match("\\N") and text:match("{split}") then text=text:gsub("\\N","/N"):gsub("{split}","\\N") end
	    end

	    if not text:match("\\N") and not text:match(" ") then text=text.."\\N"..text end

	    if text:match("\\N") then
			text=text:gsub("^%- (.-\\N)%- ","%1"):gsub("^({\\i1})%- (.-\\N)%- ","%1%2"):gsub("({\\i1})%- ","%1"):gsub("{add}","")
			line2=line
			
			txt=text:gsub("%b{}","")
					:gsub("^- ","")
					:gsub("}- ","")
			
			-- line 2
			aftern=text:match("\\N%s*(.*)")
			tags=text:match("^{\\[^}]-}") if tags and not aftern:match("^{\\[^}]-}") then aftern=tags..aftern end
			line2.text=aftern:gsub("/N","\\N")
			line2.text=line2.text:gsub("^%- ",""):gsub("}%- ","")
			
			subs.insert(sel[i]+1,line2)
	
			-- line 1
			text=text:gsub("^(.-)%s?\\N(.*)","%1"):gsub("/N","\\N"):gsub("^%- ",""):gsub("}%- ","")
			line.layer = line.layer+1
			line.style = line.style..st_name
		end
	end
	
	line.text=text
	subs[sel[i]]=line
	end
end

function split_linebreak(subs,sel)
	for i=#sel,1,-1 do
		line=subs[sel[i]]
		text=line.text
		
		--line splitting
		c=0
		if not text:match("\\N") and sel[i]<#subs then
			nextline=subs[sel[i]+1]
			if text:match(" that$") then text=text:gsub(" that$","") nextline.text="that "..nextline.text c=1 end
			if text:match(" and$") then text=text:gsub(" and$","") nextline.text="and "..nextline.text c=1 end
			if text:match(" but$") then text=text:gsub(" but$","") nextline.text="but "..nextline.text c=1 end
			if text:match(" so$") then text=text:gsub(" so$","") nextline.text="so "..nextline.text c=1 end
			if text:match(" to$") then text=text:gsub(" to$","") nextline.text="to "..nextline.text c=1 end
			if text:match(" when$") then text=text:gsub(" when$","") nextline.text="when "..nextline.text c=1 end
			if text:match(" with$") then text=text:gsub(" with$","") nextline.text="with "..nextline.text c=1 end
			if text:match(" the$") then text=text:gsub(" the$","") nextline.text="the "..nextline.text c=1 end
			subs[sel[i]+1]=nextline
		end
	
		if c==0 then
		text=text:gsub("{SPLIT}","{split}")
			if not text:match("\\N") and text:match("{split}") then text=text:gsub("{split}","\\N") end
			if not text:match("\\N") and text:match("%- ") then text=text:gsub("(.)%- (.-)$","%1\\N- %2") end
			if not text:match("\\N") and text:match("%. [{\\\"]?%w") then
				text=text
				:gsub("([MD][rs]s?)%. ","%1## ")
				:gsub("^(.-)%. ","%1. \\N")
				:gsub("## ",". ") end
			--if not text:match("\\N") and text:match("[%?!] {?%w") then text=text:gsub("^(.-)([%?!]) ","%1%2 \\N") end
			--if not text:match("\\N") and text:match(", {?%w") then text=text:gsub("^(.-), ","%1, \\N") end
			if text:match("\\N") and text:match("{split}") then text=text:gsub("\\N","/N"):gsub("{split}","\\N") end
		end
	
		if not text:match("\\N") and not text:match(" ") then text=text.."\\N"..text end
	
		if text:match("\\N") then
			text=text:gsub("^%- (.-\\N)%- ","%1"):gsub("^({\\i1})%- (.-\\N)%- ","%1%2"):gsub("({\\i1})%- ","%1"):gsub("{add}","")
			line2=line
			
			txt=text:gsub("%b{}","")
					:gsub("^- ","")
					:gsub("}- ","")
			
			-- line 2
			aftern=text:match("\\N%s*(.*)")
			tags=text:match("^{\\[^}]-}") if tags and not aftern:match("^{\\[^}]-}") then aftern=tags..aftern end
			line2.text=aftern:gsub("/N","\\N")
			line2.text=line2.text:gsub("^%- ",""):gsub("}%- ","")
			
			subs.insert(sel[i]+1,line2)
	
			-- line 1
			text=text:gsub("^(.-)%s?\\N(.*)","%1"):gsub("/N","\\N"):gsub("^%- ",""):gsub("}%- ","")
		end
		
		line.text=text
		subs[sel[i]]=line
	end
end

	
aegisub.register_macro(submenu.."/"..script_name,script_description,splitter)
aegisub.register_macro(submenu.."/".."Split at linebreak",script_description,split_linebreak)