--[[
	VH-PM-Box 2.0 by An†oZ™ 
	
	!sendmsg <nick> <testo>
	!inbox
	!outbox
	!pmbot (only OP)
]]--

sBot = ""
fPmBox = "/dir/to/verlihub/scripts/pmbox"
LogFolder = "/dir/to/verlihub/scripts/pmlogs/" -- make folder...
Allowed = { [10]=true, [5]=true, [4]=true, [3]=true, [2]=true, [1]=true, [0]=nil, } -- true/nil
AllowBot = { [10]=true, [5]=true, [4]=true, [3]=true, } -- true/nil -- bot (only for op!!)


function Main()
	if loadfile(fPmBox) then
		dofile(fPmBox)
	else
		tPM={};tPmBot={}
		Save()
	end
	tID={}
	for i in pairs(tPM) do
		for ii,v in pairs(tPM[i]) do
			tID[v]=true
		end
	end
	local _,botname = VH:GetConfig("config","hub_security")
	if sBot ~= "" then VH:AddRobot(sBot, 10, "PM-BoX by An†oZ™", "", "http://volksfusion.net/minos", "0") else sBot=botname end
	for i in pairs(tPmBot) do
		local _,class = VH:GetUserClass(i)
		if not class then
			VH:AddRobot(i.."•AFK", 5, "PM Bot Logger", "PM-BOT", "http://volksfusion.net/minos", "0")
		end
	end
end

function VH_OnUserLogin(user)
	local _,class = VH:GetUserClass(user)
	if AllowBot[class] then
		VH:SendDataToUser("$UserCommand 1 3 PM-BoX 2\\Disable/Enable Bot $<%[mynick]> !pmbot&#124;|", user)
		if tPmBot[user] then VH:DelRobot(user.."•AFK") end
	end
	VH:SendDataToUser("$UserCommand 1 3 PM-BoX 2\\Inbox $<%[mynick]> !inbox&#124;|", user)
	if Allowed[class] then
		VH:SendDataToUser("$UserCommand 1 3 PM-BoX 2\\Send Message $<%[mynick]> !sendmsg %[line:nick] %[line:message]&#124;|", user)
		VH:SendDataToUser("$UserCommand 1 3 PM-BoX 2\\Outbox $<%[mynick]> !outbox&#124;|", user)
	end
	if tPM[user:lower()] then
		VH:SendDataToUser("<"..sBot.."> New messages inbox.  !inbox   to read.|", user)
		VH:SendDataToUser("$To: "..user.." From: "..sBot.." $<"..sBot.."> New messages inbox.  !inbox   to read.|", user)
	end
end
function VH_OnUserLogout(user) if tPmBot[user] then VH:AddRobot(user.."•AFK", 5, "PM Bot Logger", "PM-BOT", "http://volksfusion.net/minos", "0") end end

tCmd={
	sendmsg=function(user,data,class)
		if not Allowed[class] then VH:SendDataToUser("<"..sBot.."> You are not allowed to use this command.|", user) return 0 end
		local _,_,usr,msg = string.find(data, "^%p%S+%s+(%S+)%s(.*)")
		if not msg then VH:SendDataToUser("<"..sBot.."> *** Syntax: !sendmsg <nick> <msg>|", user) return 0 end
		if not tPM[usr:lower()] then tPM[usr:lower()]={} end
		if not tPM[usr:lower()][user:lower()] then tPM[usr:lower()][user:lower()]=GenID() Save() end
		Logger(tPM[usr:lower()][user:lower()],msg)
		VH:SendDataToUser("<"..sBot.."> Message stored for "..usr..": "..msg.."|",user)
		VH:SendDataToUser("$To: "..usr.." From: "..sBot.." $<"..sBot.."> New messages inbox.  !inbox   to read.|", usr)
		return 0
	end,
	outbox=function(user,data,class)
		if not Allowed[class] then VH:SendDataToUser("<"..sBot.."> You are not allowed to use this command.|", user) return 0 end
		str = ""
		for i,v in pairs(tPM) do
			for ii,vv in pairs(tPM[i]) do
				if ii==user:lower() then
					str=str.."--================== <"..i.."> ==================--\n"
					local f,e = io.open(LogFolder..tPM[i][ii]..".log")
					if f then
						local s = f:read("*a")
						if s and s:len() > 0 then
							str=str..s.."\n"
						end
						f:close()
					end
				end
			end
		end
		if str=="" then  VH:SendDataToUser("<"..sBot.."> No messages.|",user) return 0 end
		VH:SendDataToUser("$To: "..user.." From: "..sBot.." $<"..sBot.."> Outbox: \n\n"..str.."|",user)
		return 0
	end,
	inbox=function(user,data,class)
		if not tPM[user:lower()] or tPM[user:lower()]=={} then VH:SendDataToUser("<"..sBot.."> No Messages.|",user) return 0 end
		str=""
		for i in pairs(tPM[user:lower()]) do
			str=str.."--================== <"..i.."> ==================--\n"
			local f,e = io.open(LogFolder..tPM[user:lower()][i]..".log")
			if f then
				local s = f:read("*a")
				if s and s:len() > 0 then
					str=str..s.."\n"
				end
				f:close()
			end
			Logger(tPM[user:lower()][i])
			tPM[user:lower()][i]=nil
		end
		tPM[user:lower()]=nil
		Save()
		VH:SendDataToUser("$To: "..user.." From: "..sBot.." $<"..sBot.."> Inbox: \n\n"..str.."|",user)
		return 0
	end,
	pmbot=function(user,data,class)
		if class >= 2 and AllowBot[class] then
			if not tPmBot[user] then
				tPmBot[user]=1
				VH:SendDataToUser("<"..sBot.."> PM Bot enabled for you. When you leave this hub, Bot "..user.."•AFK will be in userlist and log every message received.|",user)
			else
				tPmBot[user]=nil
				VH:SendDataToUser("<"..sBot.."> PM Bot disabled.|",user)		
			end
			Save()
		end
		return 0
	end,
}

function VH_OnOperatorCommand(op,data)
	local _,_,cmd = string.find(data, "^%p(%S+)")
	local cmd = string.lower(cmd)
	local _,class = VH:GetUserClass(op)
	if tCmd[cmd] then return tCmd[cmd](op,data,class) end
    return 1
end
VH_OnUserCommand=VH_OnOperatorCommand

function VH_OnParsedMsgPM(from,msg,To)
	local _,class = VH:GetUserClass(from);
	local _,_,to = string.find(To, "^(%S+)•AFK$")
	if to and tPmBot[to] then
		if not Allowed[class] then VH:SendDataToUser("$To: "..from.." From: "..to.."•AFK $<"..to.."•AFK> You are not allowed to write here. << http://volksfusion.net/minos >>|", from) return 0 end
		if not tPM[to:lower()] then	tPM[to:lower()]={} end
		if not tPM[to:lower()][from:lower()] then
			tPM[to:lower()][from:lower()]=GenID(); Save();
			VH:SendDataToUser("$To: "..from.." From: "..to.."•AFK $<"..to.."•AFK> You are talking with a bot. Your messages will logged and sended to "..to.." when login. << http://volksfusion.net/minos >>|", from)
		end
		Logger(tPM[to:lower()][from:lower()],msg)
	end
	return 1
end

Save = function()
	local file = io.open(fPmBox, "w")
	if file then
		file:write("tPM={\n")
		for i in pairs(tPM) do
			file:write("\t[\""..i.."\"]={\n")
			for ii in pairs(tPM[i]) do
				file:write("\t\t[\""..ii.."\"]="..tPM[i][ii]..",\n")
			end
			file:write("\t},\n")
		end
		file:write("}\ntPmBot={\n")
		for i in pairs(tPmBot) do
			file:write("\t[\""..i.."\"]=1,\n")
		end
		file:write("}")
		file:flush()
		file:close()
	end
end

Logger = function(id,str)
	local file = LogFolder..id..".log"
	if not str then
		--local f,e = io.open(file,"w") 
		--f:write("")  f:close()
		os.remove(file)
	else
		f,e = io.open(file,"a+")
		if f then
		 f:write("   ["..os.date("%d-%m, %H:%M.%S").."] "..str:gsub("|","&#124;").."\n")
		 f:flush() f:close()
		end
	end
   collectgarbage("collect")
end

GenID=function(user)
	local n_id = math.random(100000,999999)
	if not tID[n_id] then tID[n_id]=true; return n_id else return GenID() end
end