script_name = "Ruby_Kara"
script_description = "Get the formatted lyrics by Yahoo's API and ruby them, then apply the karaoke style."
script_author = "Wanakachi"
ruby_part_from = "domo&Kage Maboroshi&KiNen"
Kara_part_from = "Michiyama Karen"
script_version = "1.0"

require "karaskel"
local request = require("luajit-request")
local ffi = require"ffi"
local utf8 = require"utf8"
local json = require"json"
-- local Y = require"Yutils"
-- local tts = Y.table.tostring
meta = nil;
styles = nil;

--Typesetting Parameters--
rubypadding = 0 --extra spacing of ruby chars
rubyscale = 0.5 --scale of ruby chars 

--Separators--
char_s = "##"  -- s(tart) of ruby part
char_m = "|<"  -- m(iddle) which divides the whole part into kanji and furigana
char_e = "##"  -- e(nd) of ruby part

--Ruby Part--
local function deleteEmpty(tbl)
	for i=#tbl,1,-1 do
		if tbl[i] == "" then
		table.remove(tbl, i)
		end
	end
	return tbl
end

local function Split(szFullString, szSeparator)
	local nFindStartIndex = 1
	local nSplitIndex = 1
	local nSplitArray = {}   
	while true do
		local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)      
		if not nFindLastIndex then
			nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
			break      
		end
		nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
		nFindStartIndex = nFindLastIndex + string.len(szSeparator)
		nSplitIndex = nSplitIndex + 1
	end
return nSplitArray
end

local function send2YahooV2(sentence,appid,grade)
	local url = "https://jlp.yahooapis.jp/FuriganaService/V2/furigana"
	params = {["q"] = sentence,
			  ["grade"] = grade}
	data = {["id"] = "1234-1",
			["jsonrpc"] = "2.0",
			["method"] = "jlp.furiganaservice.furigana",
			["params"] = params}
	local result, err, message = request.send(url,{
		method = "POST",
		headers = {['content-type'] = "application/x-www-form-urlencoded",
				   ["User-Agent"] = "Yahoo AppID: " .. appid},
		data = json.encode(data)}
		)
	if (not result) then aegisub.debug.out(err, message) end
	return result.body
end

local function KaraText(newText,lineKara)
	rubyTbl = deleteEmpty(Split(newText,char_s))
	newRubyTbl = {}
	for i=1,#rubyTbl do
		if string.find(rubyTbl[i],char_m) then
			newRubyTbl[#newRubyTbl+1] = rubyTbl[i]
		else 
			for j=1,utf8.len(rubyTbl[i]) do
				newRubyTbl[#newRubyTbl+1] = utf8.sub(rubyTbl[i],j,j)
			end
		end
	end
	-- aegisub.debug.out(tts(newRubyTbl).."\n")
	sylNum = #lineKara
	for i=#newRubyTbl,2,-1 do
		realWord = string.match(newRubyTbl[i],"([^|<]+)[<|]?")
		if utf8.len(realWord)<utf8.len(lineKara[sylNum].sylText) then
			newRubyTbl[i-1] = newRubyTbl[i-1]..newRubyTbl[i]
			table.remove(newRubyTbl,i)
			-- aegisub.debug.out(realWord.."|"..lineKara[sylNum].sylText.."\n")
		else
			sylNum = sylNum - 1
		end
	end
	-- aegisub.debug.out(tts(newRubyTbl)..'\n')
	tmpSylText = ""
	tmpSylKDur = 0
	i = 1
	newKaraText = ""
	while i<=#lineKara do
		tmpSylText = tmpSylText..lineKara[i].sylText
		tmpSylKDur = tmpSylKDur + lineKara[i].kDur
		table.remove(lineKara,1)
		realWord = string.match(newRubyTbl[i],"([^|<]+)[<|]?")
		-- aegisub.debug.out('\n'..tostring(tmpSylKDur)..tmpSylText.."    "..realWord)
		if tmpSylText == realWord then
			newKaraText = newKaraText..string.format("{\\k%d}%s",tmpSylKDur,newRubyTbl[i])
			table.remove(newRubyTbl,i)
			tmpSylText = ""
			tmpSylKDur = 0
		end
		-- aegisub.debug.out('\n'..newKaraText)
	end
	return newKaraText
end


local function Ruby(subs, sel, ori)
    meta, styles = karaskel.collect_head(subs)
    for i = 1, #ori do
        local line = ori[i]
		local furiline = sel[i]
		local newline = table.copy(line)
		newline.text = ""
		newline.comment = false

		karaskel.preproc_line(subtitles, meta, styles, line)
        local kara = line.kara
		local lineKara = {}

		for i = 1, #kara do
			local syl = kara[i]
			if syl.duration > 0 then
				table.insert(lineKara, { kDur = syl.duration, sylText = syl.text })
			end
		end

		for _, entry in ipairs(lineKara) do
			local kDur = entry.kDur
			local sylText = entry.sylText
			local lastMatch = 1
			while true do
				local startMatch, nextMatch = furiline.text:find("##(.-)|<", lastMatch)

				if nextMatch then
					local matchText = furiline.text:sub(startMatch + 2, nextMatch - 2)
					_, farMatch = matchText:find("##")
					while (farMatch) do
						matchText = matchText:sub(farMatch + 1)
						_, farMatch = matchText:find("##")
					end

					if matchText == sylText then
						local startMatch, nextMatch = furiline.text:find("|<(.-)##", lastMatch)
						local matchText = furiline.text:sub(startMatch + 2, nextMatch - 2)
						sylText = sylText .. "|<" .. matchText
						break
					else
						lastMatch = nextMatch + 1
					end
				else
					break
				end
			end

			kDur = math.floor(kDur / 10)
			newline.text = newline.text .. "{\\k" .. kDur .. "}" .. sylText
		end

        subs.append(newline)
    end
end



local function json2LineText(jsonStr,lineNum)
	lineText = ""
	-- json error handle
	if json.decode(jsonStr).error then return "" end
	wordTbl = json.decode(jsonStr).result.word
	if wordTbl.furigana and wordTbl.furigana~=wordTbl.surface then
		if wordTbl.subword then
			subTbl = wordTbl.subword
			for i=1,#subTbl do
				if subTbl[i].surface~=subTbl[i].furigana then
					lineText = lineText..char_s..subTbl[i].surface..char_m..subTbl[i].furigana..char_e
				else
					lineText = lineText..subTbl[i].surface
				end
			end
		else
			lineText = lineText..char_s..wordTbl.surface..char_m..wordTbl.furigana..char_e
		end
	else
		for i=1,#wordTbl do
			if wordTbl[i].furigana and wordTbl[i].furigana~=wordTbl[i].surface then
				if wordTbl[i].subword then 
					subTbl = wordTbl[i].subword
					for i=1,#subTbl do
						if subTbl[i].surface~=subTbl[i].furigana then
							lineText = lineText..char_s..subTbl[i].surface..char_m..subTbl[i].furigana..char_e
						else
							lineText = lineText..subTbl[i].surface
						end
					end
				else
					lineText = lineText..char_s..wordTbl[i].surface..char_m..wordTbl[i].furigana..char_e
				end
			else
				lineText = lineText..wordTbl[i].surface
			end
		end
	end
	return lineText
end


local function oneClickRuby(subtitles, selected_lines)
	local grade = "1" --1~6 correspond to Japan primary school student grade, 7 for middle school and 8 for normal people.
 	local appid = "dj00aiZpPVZKRHFzZHY4Y3RtaSZzPWNvbnN1bWVyc2VjcmV0Jng9Zjg-" --suggest to change to your own appid.
	for i=1,#subtitles do
		if subtitles[i].class=="dialogue" then
			dialogue_start = i - 1
			break
		end
	end
	newLineTbl = {}
	originLineTbl = {}
	for i=1,#selected_lines do
		lineNum = tostring(selected_lines[i]-dialogue_start)
		l = subtitles[selected_lines[i]]
		orgText = l.text			
		l.comment = true
		subtitles[selected_lines[i]] = l
		text = orgText:gsub("{[^}]+}", "")
		if string.find(text,char_m) then
			newText = text
		else
			aegisub.progress.task("Requesting for line: "..lineNum)
			result = send2YahooV2(text,appid,grade)
			aegisub.progress.task("Parsing for line: "..lineNum)
			newText = json2LineText(result,lineNum)
		end
		-- newText = xml2KaraLineText(result,line_table or key_value,lineNum)
		aegisub.progress.task("Writing for line: "..lineNum)
		if newText ~= "" then
			l.text = newText
		else
			l.text = orgText
		end
		l.effect = "furi pattern"
		newLineTbl[#newLineTbl+1] = l
		originLineTbl[#originLineTbl+1] = subtitles[selected_lines[i]]
		aegisub.progress.set(i/#selected_lines*100)
	end
	-- uncomment this if you have the demand to use the raw format
	subtitles.append(table.unpack(newLineTbl))
	Ruby(subtitles, newLineTbl, originLineTbl)
	aegisub.debug.out("Done.")
end

--Kara Part--
local function check_subtitle_line(line, handle_style)
    -- same as aegisub Karaoke templater, see https://aegi.vmoe.info/docs/3.2/Automation/Karaoke_Templater/Template_execution_rules_and_order/#iterate-throughok
    return line.class == "dialogue" and line.style == handle_style and
        ((not line.comment and (line.effect=="" or line.effect=="karaoke")) or
         (line.comment and line.effect=="karaoke"))
end


local function set_style(subtitles, handle_style, advance_time, sep_threshold)
    -- 处理歌词时间重叠的情况，将重叠的歌词分为数层，每层中的歌词不互相重叠
    -- layers存储每层歌词的信息，属性为`last_end`(该层上一条歌词的结束时间)和`counter`(已处理的该层歌词数)
    local layers = {}

    for i = 1, subtitles.n do
        local line = subtitles[i]
        if check_subtitle_line(line, handle_style) then
            local layer_i = 0
            local last_start, style_i
            while (true) do
                local cur_layer, cur_layer_next
                local start_time = line.start_time  -- value of `last_start` in `cur_layer_next`
                cur_layer = layers[layer_i]
                if not cur_layer then
                    start_time = line.start_time - advance_time
                    cur_layer = { last_start = start_time, last_end = line.start_time, counter = 0 }
                end
                if line.start_time >= cur_layer.last_end then
                    style_i = cur_layer.counter % 2 + 1 + 2 * layer_i

                    last_start = cur_layer.last_start
                    cur_layer_next = { last_start = start_time, last_end = line.end_time, counter = cur_layer.counter + 1 }
                    if line.start_time - cur_layer.last_end > sep_threshold then
                        last_start = line.start_time - advance_time
                        cur_layer_next.last_start = last_start  -- align the start time of the next subtitle 
                    end
                    layers[layer_i] = cur_layer_next
                    break
                end
                layer_i = layer_i + 1
            end

            line.text = string.format("{\\k%d}%s", math.floor((line.start_time - last_start)/10), line.text)
            line.start_time = last_start

            line.style = string.format("K%d", style_i)
            subtitles[i] = line -- replace origin subtitles
        end
    end
end

local function macro_set_style(subtitles, selected_lines, active_line)
    config = {
        {class="label", label="Karaoke line style:", x=0, y=0},
        {class="edit", name="style", value="Default", x=1, y=0},
        {class="label", label="Advance time (ms):", x=0, y=1},
        {class="floatedit", name="advance_time", value="100", x=1, y=1},
        {class="label", label="Seperation threshold (ms):", x=0, y=2},
        {class="floatedit", name="sep_threshold", value="2000", x=1, y=2}
    }
    btn, result = aegisub.dialog.display(config)
    if btn then
        set_style(subtitles, result.style, math.floor(result.advance_time), math.floor(result.sep_threshold))
    end
end


function Ruby_Kara(subtitles, selected_lines, active_line)
	oneClickRuby(subtitles, selected_lines)
	macro_set_style(subtitles, selected_lines, active_line)
end

aegisub.register_macro(script_name, script_description, Ruby_Kara)
