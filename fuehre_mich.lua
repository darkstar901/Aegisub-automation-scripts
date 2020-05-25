--Ersetzt das erste Anführungszeichen mit einem | welches anschließend mit Suchen & Ersetzen ausgetauscht werden muss.
--Als (dreiste) Vorlage diente change_capitalization.lua und ua.MultiLineEditor.lua von Unanimated.
script_name="Fuehre Mich"
script_description="Fuehre Mich"
script_author="dark_star90"
script_version="2.5"
submenu="_darkis crappy scripts"


re=require'aegisub.re'
unicode=require'aegisub.unicode'
clipboard=require("aegisub.clipboard")

-- Unicode support: this is used for capitalisation of non-standard characters. Add more if your language requires it.
unilow={"\"NOTEMDASH","\"ä","\"ö","\"ü","\"ë","\"å","\"ø","\"æ","\"á","\"é","\"í","\"ó","\"ú","\"ý","\"à","\"è","\"ì","\"ò","\"ù","\"ç","\"ï","\"â","\"ê","\"î","\"ô","\"û","\"c","\"d","\"e","\"n","\"r","\"š","\"t","\"ž","\"u","\"ñ","\"a","\"b","\"c","\"d","\"e","\"f","\"g","\"h","\"i","\"j","\"k","\"l","\"m","\"n","\"o","\"p","\"q","\"r","\"s","\"t","\"u","\"v","\"w","\"x","\"y","\"z","\"Ä","\"Ö","\"Ü","\"Ë","\"Å","\"Ø","\"Æ","\"Á","\"É","\"Í","\"Ó","\"Ú","\"Ý","\"À","\"È","\"Ì","\"Ò","\"Ù","\"Ç","\"Ï","\"Â","\"Ê","\"Î","\"Ô","\"Û","\"C","\"D","\"E","\"N","\"R","\"Š","\"T","\"Ž","\"U","\"Ñ","\"A","\"B","\"C","\"D","\"E","\"F","\"G","\"H","\"I","\"J","\"K","\"L","\"M","\"N","\"O","\"P","\"Q","\"R","\"S","\"T","\"U","\"V","\"W","\"X","\"Y","\"Z","\"0","\"1","\"2","\"3","\"4","\"5","\"6","\"7","\"8","\"9"}
unihigh={"|NOTEMDASH","|ä","|ö","|ü","|ë","|å","|ø","|æ","|á","|é","|í","|ó","|ú","|ý","|à","|è","|ì","|ò","|ù","|ç","|ï","|â","|ê","|î","|ô","|û","|c","|d","|e","|n","|r","|š","|t","|ž","|u","|ñ","|a","|b","|c","|d","|e","|f","|g","|h","|i","|j","|k","|l","|m","|n","|o","|p","|q","|r","|s","|t","|u","|v","|w","|x","|y","|z","|Ä","|Ö","|Ü","|Ë","|Å","|Ø","|Æ","|Á","|É","|Í","|Ó","|Ú","|Ý","|À","|È","|Ì","|Ò","|Ù","|Ç","|Ï","|Â","|Ê","|Î","|Ô","|Û","|C","|D","|E","|N","|R","|Š","|T","|Ž","|U","|Ñ","|A","|B","|C","|D","|E","|F","|G","|H","|I","|J","|K","|L","|M","|N","|O","|P","|Q","|R","|S","|T","|U","|V","|W","|X","|Y","|Z","|0","|1","|2","|3","|4","|5","|6","|7","|8","|9"}

function replaceall(subs, sel)
	table.remove(sel,1)
    for i=1, #subs do
	if subs[i].class=="dialogue" then table.insert(sel,i) end
	end
	for x, i in ipairs(sel) do
            line=subs[i]
	    text=line.text
	    text=text
	    :gsub("-","NOTEMDASH")
	    :gsub("\\n"," SMALL_BREAK")
	    :gsub("\\N"," LARGE_BREAK")
	    :gsub("\\h"," HARD_SPACE")
	    :gsub("%(","FIRSTCLIP")
		:gsub("%)","LASTCLIP")
	    for u=1,#unilow do
		text=text:gsub(unilow[u],unihigh[u])
		end
	    text=text
	    :gsub("NOTEMDASH","-")
	    :gsub(" SMALL_BREAK","\\n")
	    :gsub(" LARGE_BREAK","\\N")
	    :gsub(" HARD_SPACE","\\h")
		:gsub("FIRSTCLIP","%(")
		:gsub("LASTCLIP","%)")
	    line.text=text
	    subs[i]=line
    end
	editlines(subs,sel)
end

function editlines(subs,sel)
    ADD=aegisub.dialog.display
    ak=aegisub.cancel
    editext=""    dura=""	edeff=""	edact=""	edst=""
    for z,i in ipairs(sel) do
	   	progress("Reading line: "..z.."/"..#sel.." ("..math.floor(z/#sel*100).."%)")
	line=subs[i]
	text=line.text
	editext=editext..text.."\n"
	edst=edst..line.style.."\n"
	edact=edact..line.actor.."\n"
	edeff=edeff..line.effect.."\n"
    end
    editext=nRem(editext)
    edst=nRem(edst)
    edact=nRem(edact)
    edeff=nRem(edeff)
	editbox(subs,sel)
    if failt==1 then editext=res.dat editbox(subs,sel) end
    return sel
end

function editbox(subs,sel)
progress("Loading Editor...")
	nocom=editext:gsub("%b{}","") :gsub("%—"," ")
	words=0
	for wrd in nocom:gmatch("%S+") do words=words+1 end
		
	GUI1={
	{x=0,y=0,width=10,class="label",label=" Fuehre Mich v"..script_version},
	{x=10,y=0,width=22,name="info",class="edit",value="Lines loaded: "..#sel..", Words: "..words..", Characters: "..editext:len()},
	{x=0,y=1,width=52,height=7,class="textbox",name="dat",value=editext},
	{x=0,y=8,width=1,class="checkbox",name="re1",label="Replace:",value=true},
	{x=1,y=8,width=15,class="edit",name="rep1",value="|"},
	{x=16,y=8,width=1,class="label",label="with"},
	{x=17,y=8,width=15,class="edit",name="rep2",value="„"},
	{x=32,y=8,width=12,class="edit",name="repl1",value=""},
	{x=0,y=9,width=1,class="checkbox",name="re2",label="Replace:",value=true},
	{x=1,y=9,width=15,class="edit",name="rep3",value="\""},
	{x=16,y=9,width=1,class="label",label="with"},
	{x=17,y=9,width=15,class="edit",name="rep4",value="“"},
	{x=32,y=9,width=12,class="edit",name="repl2",value=""},
	{x=0,y=10,width=1,class="checkbox",name="re3",label="Replace:",value=true},
	{x=1,y=10,width=15,class="edit",name="rep5",value="\'"},
	{x=16,y=10,width=1,class="label",label="with"},
	{x=17,y=10,width=15,class="edit",name="rep6",value="’"},
	{x=32,y=10,width=12,class="edit",name="repl3",value=""},
	{x=0,y=11,width=1,class="checkbox",name="re4",label="Replace:",value=true},
	{x=1,y=11,width=15,class="edit",name="rep7",value="!?"},
	{x=16,y=11,width=1,class="label",label="with"},
	{x=17,y=11,width=15,class="edit",name="rep8",value="?!"},
	{x=32,y=11,width=12,class="edit",name="repl4",value=""},
	{x=0,y=12,width=1,class="checkbox",name="re5",label="Replace:",value=false},
	{x=1,y=12,width=15,class="edit",name="rep9",value="..."},
	{x=16,y=12,width=1,class="label",label="with"},
	{x=17,y=12,width=15,class="edit",name="rep10",value="…"},
	{x=32,y=12,width=12,class="edit",name="repl5",value=""},
	}
	buttons={"Save","Replace","Cancel"}
	GUI=GUI1
	repeat
	if P~="Save" and P ~="Cancel" and P~=nil then
	    if P=="Replace" then
	      c1=0
	      c2=0
	      c3=0
	      c4=0
	      c5=0
	     -- if res.rt or GUI==GUI1 then 
		  if res.re1 then res.dat,c1=replacer(res.dat,res.rep1,res.rep2,c1) else res.dat=replacer(res.dat,"|","\"",c1) end
		  if res.re2 then res.dat,c2=replacer(res.dat,res.rep3,res.rep4,c2) end
		  if res.re3 then res.dat,c3=replacer(res.dat,res.rep5,res.rep6,c3) end
		  if res.re4 then res.dat,c4=replacer(res.dat,res.rep7,res.rep8,c4) end
		  if res.re5 then res.dat,c5=replacer(res.dat,res.rep9,res.rep10,c5) end
		  
	      res.repl1=c1.." replacements"
		  res.repl2=c2.." replacements"
		  res.repl3=c3.." replacements"
		  res.repl4=c4.." replacements"
		  res.repl5=c5.." replacements"
		end
	    for key,val in ipairs(GUI) do val.value=res[val.name] end
	    if P=="Switch" then
		if GUI==GUI1 then GUI=GUI2 info=res.info else GUI=GUI1 end
		for key,val in ipairs(GUI) do if val.name=="dat" then val.value=res[val.name] end end
	    end
	    for key,val in ipairs(GUI) do
		if val.name=="info" then val.value=info or res[val.name] end
		if val.name=="sent" then val.value=false end
	    end
	end
	P,res=ADD(GUI,buttons,{save='Save',close='Cancel'})
	until P=="Save" or P=="Cancel"

	if P=="Cancel" then ak() end
	if P=="Save" then savelines(subs,sel) end
	lastrep1=res.rep1	lastrep2=res.rep2
	regr=res.reg	luar=res.lua
	return sel
end

--function replacer_all(d,a,b,ce)
--	rep1=esc(a)
--	d,r=d:gsub(rep1,b)
--	ce=ce+r
--	return d,ce
--end

function string:split( inSplitPattern, outResults )
  if not outResults then
    outResults = { }
  end
  local theStart = 1
  local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
  while theSplitStart do
    table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
    theStart = theSplitEnd + 1
    theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
  end
  table.insert( outResults, string.sub( self, theStart ) )
  return outResults
end

function replacer(d,a,b,ce)
	rep1=esc(a)
	d=d:gsub("{","||{") :gsub("}","}||")
	t_able= d:split("||")
	tekst=""
	for i = 1, #t_able do
		if not t_able[i]:match("{") then
		t_able[i],r=t_able[i]:gsub(rep1,b)
		ce=ce+r
		else t_able[i],r=t_able[i]:gsub("|","\"")
		end
	tekst=tekst..t_able[i]
	end
	d=tekst
	return d,ce
end

function savelines(subs,sel)
progress("Saving...")
    tdat={}	sdat={}	adat={}	edat={}
    tt=res.dat.."\n"	if #sel==1 then tt=tt:gsub("\n(.)","\\N%1") tt=tt:gsub("\\N "," \\N") end
    ss=res.dast or "" if ss~="" then ss=ss.."\n" end
    aa=res.dact or "" if aa~="" then aa=aa.."\n" end
    ee=res.deaf or "" if ee~="" then ee=ee.."\n" end
    for dataline in tt:gmatch("(.-)\n") do table.insert(tdat,dataline) end
    for dataline in ss:gmatch("(.-)\n") do table.insert(sdat,dataline) end
    for dataline in aa:gmatch("(.-)\n") do table.insert(adat,dataline) end
    for dataline in ee:gmatch("(.-)\n") do table.insert(edat,dataline) end
    
    if #sdat>0 and #sel~=#sdat then t_error("Line count for Style ["..#sdat.."] does not \nmatch the number of selected lines ["..#sel.."].") end
    if #adat>0 and #sel~=#adat then t_error("Line count for Actor ["..#adat.."] does not \nmatch the number of selected lines ["..#sel.."].") end
    if #edat>0 and #sel~=#edat then t_error("Line count for Effect ["..#edat.."] does not \nmatch the number of selected lines ["..#sel.."].") end
    
    failt=0
    if #sel~=#tdat and #sel>1 then failt=1 else
	for z,i in ipairs(sel) do
        line=subs[i]
	line.text=tdat[z]
	line.style=sdat[z] or line.style
	line.actor=adat[z] or line.actor
	line.effect=edat[z] or line.effect
	subs[i]=line
	end
    end
    if failt==1 then
	t_error("Line count of edited text does not \nmatch the number of selected lines.")
	clipboard.set(res.dat)
    end
    aegisub.set_undo_point(script_name)
    return sel
end

function t_error(message,cancel)
  ADD({{class="label",label=message}},{"OK"},{close='OK'})
  if cancel then ak() end
end

function progress(msg)
  if aegisub.progress.is_cancelled() then ak() end
  aegisub.progress.title(msg)
end

function esc(str) str=str:gsub("[%%%(%)%[%]%.%-%+%*%?%^%$]","%%%1") return str end
function resc(str) str=str:gsub("[%%%(%)%[%]%.%*%-%+%?%^%$\\{}]","\\%1") return str end
function nRem(x) x=x:gsub("\n$","") return x end
STAG="^{\\[^}]-}"

aegisub.register_macro(submenu.."/"..script_name,script_description,replaceall)