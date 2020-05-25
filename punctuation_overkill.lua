--Setzt ... bei Satzunterbrechungen.
--Als Vorlage diente change_capitalization.lua von Unanimated.
script_name = "Punctation Overkill"
script_description = "..."
script_author = "dark_star90"
script_version = "2.5"
submenu="_darkis crappy scripts"

-- Unicode support: this is used for capitalisation of non-standard characters. Add more if your language requires it.
unilow={"ä","ö","ü","ë","å","ø","æ","á","é","í","ó","ú","ý","à","è","ì","ò","ù","ç","ï","â","ê","î","ô","û","c","d","e","n","r","š","t","ž","u","ñ","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9"}
unihigh={"... ä","... ö","... ü","... ë","... å","... ø","... æ","... á","... é","... í","... ó","... ú","... ý","... à","... è","... ì","... ò","... ù","... ç","... ï","... â","... ê","... î","... ô","... û","... c","... d","... e","... n","... r","... š","... t","... ž","... u","... ñ","... a","... b","... c","... d","... e","... f","... g","... h","... i","... j","... k","... l","... m","... n","... o","... p","... q","... r","... s","... t","... u","... v","... w","... x","... y","... z","... 0","... 1","... 2","... 3","... 4","... 5","... 6","... 7","... 8","... 9"}

--Settings
cases = "all"		-- "all": evertime a sentence does not end with .!? -- "comma": evertime a sentence does not end with ,.!?

function second_coming(subs, sel)
  	 --[[
	for i=1, #subs do
	if subs[i].class=="dialogue" then table.insert(sel,i) end
	]]--
	for x, i in ipairs(sel) do
        line=subs[i]
		j=i
		j=j-1
		l2=subs[j]
	    text=line.text
	    text=text
		:gsub("^([^{])","{}%1")
		:gsub("-","NOTEMDASH")
	    if x > 1 then
			if l2.text:match("%s...$") == nil and cases == "all" then
				for u=1,#unilow do text=text:gsub("^({[^}]-}['\"]?)"..unilow[u],"%1"..unihigh[u]) end
			end
			if l2.text:match(" ...$") ~= nil then
				text=text:gsub("^({[^}]-}['\"]?)".."([%a%s])","%1... ".."%2") :gsub("%s%s+"," ")
			end
		end
	    text=text
	    :gsub("^{}","")
		:gsub("NOTEMDASH","-")
		if cases == "all" then text=text:gsub("([,%a])$","%1 ...") end
		if cases == "comma" then text=text:gsub ("%a$","%1 ...") end
	    line.text=text
	    subs[i]=line
    end
end

aegisub.register_macro(submenu.."/"..script_name, script_description, second_coming)