script_name = "Clipping/shape bonanza"
script_description = "Clipping and shape bonanza utilizing Yutils.lua"
script_author = "dark_star90"
script_version = "2.5"
submenu="_darkis crappy scripts"

Yutils = include("Yutils.lua")
include("karaskel.lua")

function krskl(subs,sel) meta, styles = karaskel.collect_head(subs) end

function clip_border(subs,sel)
	krskl(subs,sel)
	for z,i in ipairs(sel) do
        line=subs[i]
		number_collector(subs,sel)
		an_error(subs,sel)
		border_to_shape(subs,sel)
		line.text = line.text:gsub("\\i?clip%b()","") --\\kill (i)clip
		save_tags(subs,sel)
		line.text = line.text:gsub(line.text, "{\\an"..align.."\\iclip%("..text_shape3.."%)}"..line.text)
		return_tags(subs,sel)
		subs[i]=line
	end
end

function Text_bounding_clip(subs,sel)
	krskl(subs,sel)
	for z,i in ipairs(sel) do
        line=subs[i]
		number_collector(subs,sel)
		text_shaper(subs,sel)
		bordshape = 0
		clip_bounding(subs,sel)
		line.text = line.text:gsub("\\i?clip%b()","") --\\kill (i)clip
		save_tags(subs,sel)
		line.text = line.text:gsub(line.text, "{\\an"..align.."\\clip%("..bounding_box.."%)}"..line.text)
		return_tags(subs,sel)
		subs[i]=line
	end
end

function Border_bounding_clip(subs,sel)
	krskl(subs,sel)
	for z,i in ipairs(sel) do
        line=subs[i]
		number_collector(subs,sel)
		text_shaper(subs,sel)
		bordshape = 1
		clip_bounding(subs,sel)
		line.text = line.text:gsub("\\i?clip%b()","") --\\kill (i)clip
		save_tags(subs,sel)
		line.text = line.text:gsub(line.text, "{\\an"..align.."\\clip%("..bounding_box.."%)}"..line.text)
		return_tags(subs,sel)
		subs[i]=line
	end
end

function save_tags(subs,sel)
	line.text = line.text
				:gsub("-","NOTEMDASH")
				:gsub("%(","FIRSTCLIP")
				:gsub("%)","LASTCLIP")
				:gsub("\\pos%(([%d%.%-]+),([%d%.%-]+)%)","position")
				:gsub("\\fs[%d%.%-]+","fontsize")
				:gsub("\\fscx[%d%.%-]+","scale_x")
				:gsub("\\fscy[%d%.%-]+","scale_y")
				:gsub("\\fsp[%d%.%-]+","spacing")
				:gsub("\\an%d+","")
end

function return_tags(subs,sel)
	line.text = line.text:gsub("}{","")
	if line.text:match("FIRSTCLIP") ~= nil then line.text = line.text:gsub("FIRSTCLIP","%(") end
	if line.text:match("LASTCLIP") ~= nil then line.text = line.text:gsub("LASTCLIP","%)") end
	if line.text:match("position") ~= nil then line.text = line.text:gsub("position", "\\pos%("..posx..","..posy.."%)") end
	if line.text:match("fontsize") ~= nil then line.text = line.text:gsub("fontsize", "\\fs"..fs) end
	if line.text:match("scale_x") ~= nil then line.text = line.text:gsub("scale_x", "\\fscx"..fscx) end
	if line.text:match("scale_y") ~= nil then line.text = line.text:gsub("scale_y", "\\fscy"..fscy) end
	if line.text:match("spacing") ~= nil then line.text = line.text:gsub("spacing", "\\fsp"..fsp) end
	if line.text:match("fade") ~= nil then line.text = line.text:gsub("fade", "\\fad%("..fad3.."%)") end
	line.text = line.text:gsub("NOTEMDASH","-")
end

function text_shaper(subs,sel)
	text_shape = Yutils.decode.create_font(fontname, bold, italic, underline, strikeout, fontsize, scale_x / 100, scale_y / 100, spacing).text_to_shape(line.text_stripped)
	if rotation ~= 0 then 
		MATRIX = Yutils.math.create_matrix()
		text_shape = Yutils.shape.transform(text_shape , MATRIX.rotate("z", rotation))
		if shadow ~= 0 then aegisub.log("Warning: \\shad and \\frz at the same time may shift the position slightly, manual correction could be needed.\n\n") end
	end
	--testing
	if align ~= "7" and rotation == 0 then
		move_x, move_y = 0,0
		xx = fontsize/style.fontsize*scale_x/style.scale_x
		yy = fontsize/style.fontsize*scale_y/style.scale_y
		if align == "1" then move_y = (line.bottom-line.top)*yy end
		if align == "2" then move_x, move_y = (line.right-line.left)/2*xx, (line.bottom-line.top)*yy end
		if align == "3" then move_x, move_y = (line.right-line.left)*xx, (line.bottom-line.top)*yy end
		if align == "4" then move_y = (line.middle-line.top)*yy end
		if align == "5" then move_x, move_y = (line.right-line.left)/2*xx, (line.middle-line.top)*yy end
		if align == "6" then move_x, move_y = (line.right-line.left)*xx, (line.middle-line.top)*yy end
		if align == "8" then move_x = (line.right-line.left)/2*xx end
		if align == "9" then move_x = (line.right-line.left)*xx end
		xdigit = xdigit-move_x
		ydigit = ydigit-move_y
	end
	--testing
	text_shape = Yutils.shape.move(text_shape, xdigit, ydigit)
end

function border_to_shape(subs,sel)
	border = border+0.5+blur/1.5
	text_shape = Yutils.decode.create_font(fontname, bold, italic, underline, strikeout, fontsize, scale_x / 100, scale_y / 100, spacing).text_to_shape(line.text_stripped)
	text_shape = Yutils.shape.flatten(text_shape)
	--Join Type
	join_type = "round"
	if line.effect == "round" then join_type = "round"
	elseif line.effect == "bevel" then join_type = "bevel"
	elseif line.effect == "miter" then join_type = "miter"
	end
	text_shape = outliner(text_shape, border, border, join_type)
	--shape move+rotation
	if rotation ~= 0 then 
		MATRIX = Yutils.math.create_matrix()
		text_shape = Yutils.shape.transform(text_shape , MATRIX.rotate("z", rotation))
	end
	text_shape3 = Yutils.shape.move(text_shape, xdigit, ydigit)
end

function clip_bounding(subs,sel)
	x0, y0, x1, y1 = Yutils.shape.bounding(text_shape)
	x2, y2, x3, y3 = Yutils.math.round(x0)-2, Yutils.math.round(y0)-2, Yutils.math.round(x1)+2, Yutils.math.round(y1)+2
	if bordshape == 1 then 
		x2, y2 = x2-border, y2-border
		x3, y3 = x3+border, y3+border
	end
	if align ~= "7" and rotation ~= 0 then
		move_x, move_y = 0,0
		xx = fontsize/style.fontsize*scale_x/style.scale_x
		yy = fontsize/style.fontsize*scale_y/style.scale_y
		if align == "1" then move_y = (line.bottom-line.top)*yy end
		if align == "2" then move_x, move_y = (line.right-line.left)/2*xx, (line.bottom-line.top)*yy end
		if align == "3" then move_x, move_y = (line.right-line.left)*xx, (line.bottom-line.top)*yy end
		if align == "4" then move_y = (line.middle-line.top)*yy end
		if align == "5" then move_x, move_y = (line.right-line.left)/2*xx, (line.middle-line.top)*yy end
		if align == "6" then move_x, move_y = (line.right-line.left)*xx, (line.middle-line.top)*yy end
		if align == "8" then move_x = (line.right-line.left)/2*xx end
		if align == "9" then move_x = (line.right-line.left)*xx end
		x2, x3 = x2-move_x, x3-move_x
		y2, y3 = y2-move_y, y3-move_y
	end
	bounding_box = x2..","..y2..","..x3..","..y3
end

function shapegen(subs,sel)
	krskl(subs,sel)
	for z,i in ipairs(sel) do
            line=subs[i]
			number_collector(subs,sel)
			an_error(subs,sel)
			line_override = line.text:gsub("}"..line.text_stripped,"}")
		--Join Type
		join_type = "round"
		if line.effect == "round" then join_type = "round"
		elseif line.effect == "bevel" then join_type = "bevel"
		elseif line.effect == "miter" then join_type = "miter"
		end
		--Shape generieren
		text_shape = Yutils.decode.create_font(fontname, bold, italic, underline, strikeout, fontsize, 1, 1, spacing).text_to_shape(line.text_stripped)
		text_shape = Yutils.shape.flatten(text_shape)
		text_shape = Yutils.shape.to_outline(text_shape, borderx, bordery, join_type)
		line.text = line_override
				:gsub("-","NOTEMDASH")
				:gsub("%(","FIRSTCLIP")
				:gsub("%)","LASTCLIP")
				:gsub("\\pos%(([%d%.%-]+),([%d%.%-]+)%)","position")
				:gsub("\\fs[%d%.%-]+","")
				:gsub("\\fscx[%d%.%-]+","scale_x")
				:gsub("\\fscy[%d%.%-]+","scale_y")
				:gsub("\\frz[%d%.%-]+","rotation")
				:gsub("\\fax[%d%.%-]+","xzerr")
				:gsub("\\fsp[%d%.%-]+","")
				:gsub("\\bord[%d%.%-]+","")
				:gsub("\\an%d+","")
		line.text = line.text:gsub(line.text, "{\\an7\\bord0\\p1}"..line.text..text_shape)
		line.text = line.text:gsub("}{","")
		if line.text:match("FIRSTCLIP") ~= nil then line.text = line.text:gsub("FIRSTCLIP","%(") end
		if line.text:match("LASTCLIP") ~= nil then line.text = line.text:gsub("LASTCLIP","%)") end
		if line.text:match("position") ~= nil then line.text = line.text:gsub("position", "\\pos("..posx..","..posy..")") end
		if line.text:match("scale_x") ~= nil then line.text = line.text:gsub("scale_x", "\\fscx"..fscx) end
		if line.text:match("scale_y") ~= nil then line.text = line.text:gsub("scale_y", "\\fscy"..fscy) end
		if line.text:match("rotation") ~= nil then line.text = line.text:gsub("rotation", "\\frz"..frz) end
		if line.text:match("xzerr") ~= nil then line.text = line.text:gsub("xzerr", "\\fax"..fax) end
		if line.text:match("fade") ~= nil then line.text = line.text:gsub("fade", "\\fad%("..fad3.."%)") end
		line.text = line.text:gsub("NOTEMDASH","-")
		
		--aegisub.log(line.text)
		if align ~= "7" then aegisub.log("Use \\an7 goddammit D:\n")
		else subs[i]=line end
		end		
	end

function clipgen(subs,sel)
	krskl(subs,sel)
		for z,i in ipairs(sel) do
            line=subs[i]
			number_collector(subs,sel)
			an_error(subs,sel)
		text_shaper(subs,sel)
		line.text = line.text:gsub("\\i?clip%b()","") --\\kill (i)clip
		save_tags(subs,sel)
		line.text = line.text:gsub(line.text, "{\\an"..align.."\\iclip%("..text_shape.."%)}"..line.text)
		return_tags(subs,sel)
		subs[i]=line
		end		
	end

function inner_shadow(subs,sel)
	krskl(subs,sel)
	inner_shadow=true
	for z,i in ipairs(sel) do
	line3=subs[i]
	clipgen(subs,sel)
	shapegen(subs,sel)
	line1=subs[i]
	if line1.text:match("\\an7") == nil then aegisub.log("Use \\an7 goddammit D:\n")
	else subs.insert(i+1,line1,line1)
		j=i
		j=j+1
		k=i
		k=k+2
		line2=subs[j]
		line1.layer=line.layer+1
		line2.layer=line2.layer+2
		line1.text = line.text:gsub("\\iclip","\\clip")
		line2.text = line2.text:gsub("\\i?clip%b()","")
		line3.text = line3.text:gsub("\\i?clip%b()","")
		line1.text = line1.text
			:gsub("-","NOTEMDASH")
			:gsub("%(","FIRSTCLIP")
			:gsub("%)","LASTCLIP")
		line2.text = line2.text
		:gsub("\\[xy]?shad[%d%.%-]+","")
			:gsub("-","NOTEMDASH")
			:gsub("%(","FIRSTCLIP")
			:gsub("%)","LASTCLIP")
		line3.text = line3.text
		:gsub("\\[xy]?shad[%d%.%-]+","")
		:gsub("\\bord[%d%.%-]+","")
			:gsub("-","NOTEMDASH")
			:gsub("%(","FIRSTCLIP")
			:gsub("%)","LASTCLIP")
		line1.text = line1.text:gsub(line1.text,"{\\1a&HFE&}"..line1.text)
		line2.text = line2.text:gsub(line2.text,"{\\shad0}"..line2.text)
		line3.text = line3.text:gsub(line3.text,"{\\bord0\\shad0}"..line3.text)
		if line1.text:match("[xy]?shad") == nil then line1.text = line1.text:gsub(line1.text,"{\\shad3}"..line1.text)end
		color_3 = "&H"..string.sub(style.color3,5)
		if line1.text:match("\\3c") == nil then line1.text = line1.text:gsub(line1.text,"{\\3c"..color_3.."}"..line1.text)
												line2.text = line2.text:gsub(line2.text,"{\\3c"..color_3.."}"..line2.text) end
		
		line1.text = line1.text
				:gsub("\\1?c&H%x+&","")
				:gsub("\\3c","\\c")
				:gsub("}{","")
				:gsub("FIRSTCLIP","%(")
				:gsub("LASTCLIP","%)")
				:gsub("NOTEMDASH","-")
		line1.effect = "shadow_"..line1.effect
		line2.text = line2.text
				:gsub("\\1?c&H%x+&","")
				:gsub("\\3c","\\c")
				:gsub("}{","")
				:gsub("FIRSTCLIP","%(")
				:gsub("LASTCLIP","%)")
				:gsub("NOTEMDASH","-")
		line2.effect = "border_"..line2.effect
		line3.text = line3.text
				:gsub("}{","")
				:gsub("FIRSTCLIP","%(")
				:gsub("LASTCLIP","%)")
				:gsub("NOTEMDASH","-")
		line3.effect = "fill_"..line3.effect
		subs[i]=line1
		subs[j]=line2
		subs[k]=line3
		end	
	end
	inner_shadow = false
end

function number_collector(subs,sel)
karaskel.preproc_line(subtitles, meta, styles, line)
			style = styles[line.style]
			align = nil
		--\\fad speichern
		if line.text:match("\\fad%(%d+,%d+%)") ~= nil then
			fad1 = line.text:find("\\fad%(%d+,%d+%)")
			fad2 = line.text:find("%)", fad1)
			fad3 = string.sub(line.text, fad1+5, fad2-1)
			line.text = line.text:gsub("\\fad%(%d+,%d+%)","fade")
			end
		--Position
		if line.text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)") ~= nil then
			px = line.text:find("\\pos%(([%d%.%-]+),([%d%.%-]+)%)")
			py = line.text:find(",([%d%.%-]+)%)", px)
			pz = line.text:find("%)", px)
			posx = string.sub(line.text, px+5, py-1)
			xdigit = tonumber(posx)
			posy = string.sub(line.text, py+1, pz-1)
			ydigit = tonumber(posy)
			end
		--Style Values
		fontname = style.fontname
		bold = style.bold
		italic = style.italic
		underline = style.underline
		strikeout = style.strikeout
		fontsize = style.fontsize
		scale_x = style.scale_x
		scale_y = style.scale_y
		spacing = style.spacing
		if style.spacing ~= 0 then aegisub.log("Use \\fsp you stupid shit :V\n") end
		border = style.outline
		shadow = style.shadow
		--Override Tags
		if line.text:match("\\fn") ~= nil then fontname = line.text:match("\\fn[^\\}]+"):gsub("\\fn","") end
		if line.text:match("\\b%d") == "\\b1" then bold = true end
		if line.text:match("\\b%d") == "\\b0" then bold = false end
		if line.text:match("\\i%d") == "\\i1" then italic = true end
		if line.text:match("\\i%d") == "\\i0" then italic = false end
		if line.text:match("\\u%d") == "\\u1" then underline = true end
		if line.text:match("\\u%d") == "\\u0" then underline = false end
		if line.text:match("\\s%d") == "\\s1" then strikeout = true end
		if line.text:match("\\s%d") == "\\s0" then strikeout = false end
		if line.text:match("\\fs[%d%.%-]+") ~= nil then
			fs = line.text:match("\\fs[%d%.%-]+"):gsub("\\fs","")
			fontsize = tonumber(fs)
			end
		if line.text:match("\\fscx[%d%.%-]+") ~= nil then
			fscx = line.text:match("\\fscx[%d%.%-]+"):gsub("\\fscx","")
			scale_x = tonumber(fscx)
			end
		if line.text:match("\\fscy[%d%.%-]+") ~= nil then
			fscy = line.text:match("\\fscy[%d%.%-]+"):gsub("\\fscy","")
			scale_y = tonumber(fscy)
			end
		if line.text:match("\\fsp[%d%.%-]+") ~= nil then
			fsp = line.text:match("\\fsp[%d%.%-]+"):gsub("\\fsp","")
			spacing = tonumber(fsp)
			aegisub.log(fsp)
			end
		if line.text:match("\\bord[%d%.%-]+") ~= nil then 
			bord = line.text:match("\\bord[%d%.%-]+"):gsub("\\bord","")
			border = tonumber(bord)
		end
			borderx = border/scale_x*100
			bordery = border/scale_y*100
		if inner_shadow == true then 
		borderx = borderx/2
		bordery = bordery/2
		end
		if line.raw:match("\\shad[%d%.%-]+") ~= nil then 
			shad1 = line.text:match("\\shad[%d%.%-]+"):gsub("\\shad","")
			shadow = tonumber(shad1)
			end
		if line.text:match("\\frz[%d%.%-]+") ~= nil then 
			frz = line.text:match("\\frz[%d%.%-]+"):gsub("\\frz","")
			rotation = tonumber(frz)
		else rotation = 0 end
		if line.text:match("\\fax[%d%.%-]+") ~= nil then 
			fax = line.text:match("\\fax[%d%.%-]+"):gsub("\\fax","")
			--aegisub.log(fax)
			xzerr = tonumber(fax)
		end
		if line.text:match("\\blur[%d%.%-]+") ~= nil then 
			blurred = line.text:match("\\blur[%d%.%-]+"):gsub("\\blur","")
			blur = tonumber(blurred)
		else blur = 0
		end
		if line.text:match("\\an%d") ~= nil then
			align = line.text:match("\\an%d+")
			align = align:gsub("\\an","") end
		if line.text:match("\\an%d") == nil then align = tostring(style.align) end
		if line.text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)") == nil then aegisub.log("only works with \\pos\n") end
end
function an_error(subs,sel)
	if align ~= "7" and rotation ~= 0 then aegisub.log("Use \\an7 goddammit D:\n") end
end

-- Converts shape to stroke version
local FP_PRECISION = 3	-- Floating point precision by numbers behind point (for shape points)
local MAX_CIRCUMFERENCE = 1.5	-- Circumference step size to create round edges out of lines
local MITER_LIMIT = 200	-- Maximal length of a miter join

local function rotate2d(x, y, angle)
	local ra = math.rad(angle)
	return math.cos(ra)*x - math.sin(ra)*y,
		math.sin(ra)*x + math.cos(ra)*y
end

function outliner(shape, width_xy, width_y, mode)
			-- Check arguments
			if type(shape) ~= "string" or type(width_xy) ~= "number" or width_y ~= nil and type(width_y) ~= "number" or mode ~= nil and type(mode) ~= "string" then
				error("shape, line width (general or horizontal and vertical) and optional mode expected", 2)
			elseif width_y and (width_xy < 0 or width_y < 0 or not (width_xy > 0 or width_y > 0)) or width_xy <= 0 then
				error("one width must be >0", 2)
			elseif mode and mode ~= "round" and mode ~= "bevel" and mode ~= "miter" then
				error("valid mode expected", 2)
			end
			-- Line width values
			local width, xscale, yscale
			if width_y and width_xy ~= width_y then
				width = math.max(width_xy, width_y)
				xscale, yscale = width_xy / width, width_y / width
			else
				width, xscale, yscale = width_xy, 1, 1
			end
			-- Collect figures
			local figures, figures_n, figure, figure_n = {}, 0, {}, 0
			local last_move
			Yutils.shape.filter(shape, function(x, y, typ)
				-- Check point type
				if typ and not (typ == "m" or typ == "l") then
					error("shape have to contain only \"moves\" and \"lines\"", 2)
				end
				-- New figure?
				if not last_move or typ == "m" then
					-- Enough points in figure?
					if figure_n > 2 then
						-- Last point equal to first point? (yes: remove him)
						if last_move and figure[figure_n][1] == last_move[1] and figure[figure_n][2] == last_move[2] then
							figure[figure_n] = nil
						end
						-- Save figure
						figures_n = figures_n + 1
						figures[figures_n] = figure
					end
					-- Clear figure for new one
					figure, figure_n = {}, 0
					-- Save last move for figure closing check
					last_move = {x, y}
				end
				-- Add point to current figure (if not copy of last)
				if figure_n == 0 or not(figure[figure_n][1] == x and figure[figure_n][2] == y) then
					figure_n = figure_n + 1
					figure[figure_n] = {x, y}
				end
			end)
			-- Insert last figure (with enough points)
			if figure_n > 2 then
				-- Last point equal to first point? (yes: remove him)
				if last_move and figure[figure_n][1] == last_move[1] and figure[figure_n][2] == last_move[2] then
					figure[figure_n] = nil
				end
				-- Save figure
				figures_n = figures_n + 1
				figures[figures_n] = figure
			end
			-- Create stroke shape out of figures
			local stroke_shape, stroke_shape_n = {}, 0
			for fi, figure in ipairs(figures) do
				-- One pass for inner, one for outer outline
				for i = 2, 2 do
					-- Outline buffer
					local outline, outline_n = {}, 0
					-- Point iteration order = inner or outer outline
					local loop_begin, loop_end, loop_steps
					if i == 1 then
						loop_begin, loop_end, loop_step = #figure, 1, -1
					else
						loop_begin, loop_end, loop_step = 1, #figure, 1
					end
					-- Iterate through figure points
					for pi = loop_begin, loop_end, loop_step do
						-- Collect current, previous and next point
						local point = figure[pi]
						local pre_point, post_point
						if i == 1 then
							if pi == 1 then
								pre_point = figure[pi+1]
								post_point = figure[#figure]
							elseif pi == #figure then
								pre_point = figure[1]
								post_point = figure[pi-1]
							else
								pre_point = figure[pi+1]
								post_point = figure[pi-1]
							end
						else
							if pi == 1 then
								pre_point = figure[#figure]
								post_point = figure[pi+1]
							elseif pi == #figure then
								pre_point = figure[pi-1]
								post_point = figure[1]
							else
								pre_point = figure[pi-1]
								post_point = figure[pi+1]
							end
						end
						-- Calculate orthogonal vectors to both neighbour points
						local vec1_x, vec1_y, vec2_x, vec2_y = point[1]-pre_point[1], point[2]-pre_point[2], point[1]-post_point[1], point[2]-post_point[2]
						local o_vec1_x, o_vec1_y = Yutils.math.ortho(vec1_x, vec1_y, 0, 0, 0, 1)
						o_vec1_x, o_vec1_y = Yutils.math.stretch(o_vec1_x, o_vec1_y, 0, width)
						local o_vec2_x, o_vec2_y = Yutils.math.ortho(vec2_x, vec2_y, 0, 0, 0, -1)
						o_vec2_x, o_vec2_y = Yutils.math.stretch(o_vec2_x, o_vec2_y, 0, width)
						-- Check for gap or edge join
						local is_x, is_y = Yutils.math.line_intersect(point[1] + o_vec1_x - vec1_x, point[2] + o_vec1_y - vec1_y,
																					point[1] + o_vec1_x, point[2] + o_vec1_y,
																					point[1] + o_vec2_x - vec2_x, point[2] + o_vec2_y - vec2_y,
																					point[1] + o_vec2_x, point[2] + o_vec2_y,
																					true)
						if is_y then
							-- Add gap point
							outline_n = outline_n + 1
							outline[outline_n] = string.format("%s%s %s",
																		outline_n == 1 and "m " or outline_n == 2 and "l " or "",
																		Yutils.math.round(point[1] + (is_x - point[1]) * xscale, FP_PRECISION), Yutils.math.round(point[2] + (is_y - point[2]) * yscale, FP_PRECISION))
						else
							-- Add first edge point
							outline_n = outline_n + 1
							outline[outline_n] = string.format("%s%s %s",
																		outline_n == 1 and "m " or outline_n == 2 and "l " or "",
																		Yutils.math.round(point[1] + o_vec1_x * xscale, FP_PRECISION), Yutils.math.round(point[2] + o_vec1_y * yscale, FP_PRECISION))
							-- Create join by mode
							if mode == "bevel" then
								-- Nothing to add!
							elseif mode == "miter" then
								-- Add mid edge point(s)
								is_x, is_y = Yutils.math.line_intersect(point[1] + o_vec1_x - vec1_x, point[2] + o_vec1_y - vec1_y,
																					point[1] + o_vec1_x, point[2] + o_vec1_y,
																					point[1] + o_vec2_x - vec2_x, point[2] + o_vec2_y - vec2_y,
																					point[1] + o_vec2_x, point[2] + o_vec2_y)
								if is_y then	-- Vectors intersect
									local is_vec_x, is_vec_y = is_x - point[1], is_y - point[2]
									local is_vec_len = Yutils.math.distance(is_vec_x, is_vec_y)
									if is_vec_len > MITER_LIMIT then
										local fix_scale = MITER_LIMIT / is_vec_len
										outline_n = outline_n + 1
										outline[outline_n] = string.format("%s%s %s %s %s",
																					outline_n == 2 and "l " or "",
																					Yutils.math.round(point[1] + (o_vec1_x + (is_vec_x - o_vec1_x) * fix_scale) * xscale, FP_PRECISION), Yutils.math.round(point[2] + (o_vec1_y + (is_vec_y - o_vec1_y) * fix_scale) * yscale, FP_PRECISION),
																					Yutils.math.round(point[1] + (o_vec2_x + (is_vec_x - o_vec2_x) * fix_scale) * xscale, FP_PRECISION), Yutils.math.round(point[2] + (o_vec2_y + (is_vec_y - o_vec2_y) * fix_scale) * yscale, FP_PRECISION))
									else
										outline_n = outline_n + 1
										outline[outline_n] = string.format("%s%s %s",
																					outline_n == 2 and "l " or "",
																					Yutils.math.round(point[1] + is_vec_x * xscale, FP_PRECISION), Yutils.math.round(point[2] + is_vec_y * yscale, FP_PRECISION))
									end
								else	-- Parallel vectors
									vec1_x, vec1_y = Yutils.math.stretch(vec1_x, vec1_y, 0, MITER_LIMIT)
									vec2_x, vec2_y = Yutils.math.stretch(vec2_x, vec2_y, 0, MITER_LIMIT)
									outline_n = outline_n + 1
									outline[outline_n] = string.format("%s%s %s %s %s",
																				outline_n == 2 and "l " or "",
																				Yutils.math.round(point[1] + (o_vec1_x + vec1_x) * xscale, FP_PRECISION), Yutils.math.round(point[2] + (o_vec1_y + vec1_y) * yscale, FP_PRECISION),
																				Yutils.math.round(point[1] + (o_vec2_x + vec2_x) * xscale, FP_PRECISION), Yutils.math.round(point[2] + (o_vec2_y + vec2_y) * yscale, FP_PRECISION))
								end
							else	-- not mode or mode == "round"
								-- Calculate degree & circumference between orthogonal vectors
								local degree = Yutils.math.degree(o_vec1_x, o_vec1_y, 0, o_vec2_x, o_vec2_y, 0)
								local circ = math.abs(math.rad(degree)) * width
								-- Join needed?
								if circ > MAX_CIRCUMFERENCE then
									-- Add curve edge points
									local circ_rest = circ % MAX_CIRCUMFERENCE
									for cur_circ = circ_rest > 0 and circ_rest or MAX_CIRCUMFERENCE, circ - MAX_CIRCUMFERENCE, MAX_CIRCUMFERENCE do
										local curve_vec_x, curve_vec_y = rotate2d(o_vec1_x, o_vec1_y, cur_circ / circ * degree)
										outline_n = outline_n + 1
										outline[outline_n] = string.format("%s%s %s",
																					outline_n == 2 and "l " or "",
																					Yutils.math.round(point[1] + curve_vec_x * xscale, FP_PRECISION), Yutils.math.round(point[2] + curve_vec_y * yscale, FP_PRECISION))
									end
								end
							end
							-- Add end edge point
							outline_n = outline_n + 1
							outline[outline_n] = string.format("%s%s %s",
																		outline_n == 2 and "l " or "",
																		Yutils.math.round(point[1] + o_vec2_x * xscale, FP_PRECISION), Yutils.math.round(point[2] + o_vec2_y * yscale, FP_PRECISION))
						end
					end
					-- Insert inner or outer outline to stroke shape
					stroke_shape_n = stroke_shape_n + 1
					stroke_shape[stroke_shape_n] = table.concat(outline, " ")
				end
			end
			return table.concat(stroke_shape, " ")
		end
		
aegisub.register_macro(submenu.."/".."\\iclip Text",script_description,clipgen)
aegisub.register_macro(submenu.."/".."\\iclip Text with border",script_description,clip_border)
aegisub.register_macro(submenu.."/".."\\clip Text bounding",script_description,Text_bounding_clip)
aegisub.register_macro(submenu.."/".."\\clip Text with border bounding",script_description,Border_bounding_clip)
aegisub.register_macro(submenu.."/".."Create Text border shape",script_description,shapegen)
aegisub.register_macro(submenu.."/".."Create inner shadow",script_description,inner_shadow)