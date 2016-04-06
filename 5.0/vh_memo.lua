--[[  VH: Memo Bot v. 3.0 by An†oZ™
	Lua version 5.1

** comandi
!addmemo [memo]   • add Memo (use ~~~ for new line)
!delmemo [n. memo]   • delMemo ( !memolist to view memo number)
!memolist   • list of all memories

]]--

sBot = "MemO-Bot" -- enter botname
sTime = 30 -- enter time in minutes
Menu = "Memories"
fMemo = "/home/user_name/verlihub/scripts/memories" -- enter filename path
TimeRemove = true --Auto-Remove Time from messages [true/false]


Allowed = { [0]=0,[1]=0,[2]=0,[3]=0,[4]=0,[5]=0,[10]=1, } -- profili he possono usare i comandi

Class = function(nick)
	res, class = VH:GetUserClass(nick)
	if res and class then
		return class
	end
end

function VH_OnUserLogin(user)
if (Allowed[Class(user)] == 1) then
  VH:SendDataToUser("$UserCommand 1 3 "..Menu.."\\Memo List $<%[mynick]> !memolist&#124;|",user)
  VH:SendDataToUser("$UserCommand 1 3 "..Menu.."\\Add Memo $<%[mynick]> !addmemo %[line:Type Memo.  Ex.   line1~~~line2~~~line3]&#124;|",user)
  VH:SendDataToUser("$UserCommand 1 3 "..Menu.."\\Del Memo $<%[mynick]> !delmemo %[line:Memo number to delete]&#124;|",user)
end
end

function Main()
if sBot then VH:AddRobot(sBot, 10, "Memo by An†oZ™", "", "http://volksfusion.net/minos", "0") end
if loadfile(fMemo) then
  dofile(fMemo)
else
  tMemo = {}
  VH:SendDataToAll("<memo-bot> *** Memo Store File created: "..fMemo.." .|",10,10)
end
SaveToFile()
n,Memos,tm,sendm=1,Randomize(tMemo),0,sTime*60
end

function Randomize(T)
temp={}
for i,v in pairs(T) do
  table.insert(temp,T[i])
end
t={}
while temp[1] do
  iM = math.random(table.getn(temp))
  table.insert(t,temp[iM])
  table.remove(temp,iM)
end
return t
end

function RemTime(data)
   if TimeRemove then
      return string.gsub(string.gsub(data,"^%b[] <","<"),"~~~%b[] <","~~~<")
   else
      return data
   end
end

function VH_OnTimer()
tm=tm+1
if tm >= sendm then
if not Memos[n] then n=1 end
if Memos[n] then
  VH:SendDataToAll("<"..sBot.."> \n\n\t"..string.gsub(Memos[n],"~~~", "\n\t").."\n|",0,10)
  n=n+1
end
tm=0
end
end

VH_OnUserCommand = function(user,data)
	local _,_,cmd = string.find(data,"^%p(%S+)")
	if cmd == "addmemo" then
		local _,_,mem = string.find(data, "%paddmemo%s+(.+)")
    if not mem then VH:SendDataToUser("*** Sintax: !addmemo <memo>|",user) return 0 end
    local mem = RemTime(string.gsub(mem,"\r\n","~~~"))
		table.insert(tMemo, mem)
    Memos=Randomize(tMemo)
    VH:SendDataToUser("Adding memo:\n\n\t-==================-\n\t"..string.gsub(mem,"~~~", "\n\t").."\n\t-==================-\n|",user)
    SaveToFile()   
    return 0
  elseif (cmd == "delmemo") then   
    local _,_,mem = string.find(data, "%pdelmemo%s+(%d+)")
    if not mem then VH:SendDataToUser("*** Sintax: !delmemo <n.memo>|",user) return 0 end
    local nmem = tonumber(mem)
    if not tMemo[nmem] then VH:SendDataToUser("<"..sBot.."> Memo not found.|",user) return 0 end
    VH:SendDataToUser("Memo deleted.\n\n\t-=======[ "..mem.." ]=======-\n\t"..tMemo[nmem].."\n\t-==================-\n|",user)
    table.remove(tMemo, nmem)
    Memos=Randomize(tMemo)
    SaveToFile()
    return 0
  elseif cmd == "memolist" then   
    sTmp = "Memories List:\n"   
    for nmb,M in pairs(tMemo) do
       sTmp = sTmp.."\n\t-=======[ "..nmb.." ]=======-\n\t"..string.gsub(M,"~~~", "\n\t").."\n\t-==================-\n"
    end
    VH:SendDataToUser("$To: "..user.." From: "..sBot.." $<"..sBot.."> "..sTmp.."|",user)     
    return 0
  end
return 1
end
VH_OnOperatorCommand=VH_OnUserCommand

function SaveToFile()
local file = io.open(fMemo, "w")
if file then
  file:write("tMemo={\n")
  for i in pairs(tMemo) do
     file:write(string.format("%q",tMemo[i])..",\n")
  end
  file:write("}")
  file:flush()
  file:close()
end
end
