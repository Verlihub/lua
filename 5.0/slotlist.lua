--
--      SLOTLIST - 1.01 for Verli
--
--      Script by FlipFlop aka flupke-t-flopke - 2008/10/16
--      Requested by Puma
--      Roughly based on a script by Tezla for Ptokax
--
--      Script to show the active users with free slots, unfortunately it seems Verli doesn't listen on the UDP-port, so passive users-responses can't be caught.
--      Type +slots in mainchat to see the users with free slots
--
--      To do: make a proper SL_NickList in case a second or third person starts a +slot command while the first one is still processing
--
--      Version history:
--      1.01 - only active users and operators and higher can use the command now

SL_Slots = {}
SL_Nslots = 0
SL_Message = "%d of %d slots free: %s"

SL_Wait = 5 -- wait for searchresults in seconds
SL_TimerEnable = 0
SL_Timeout = 300 -- cache life in seconds
SL_LastUpdate = 0
SL_NickList = ""
SL_TimerCounter = 0

function VH_OnParsedMsgAny(nick, data)
       if string.find(data,"$SR") then
      local s, e, free, all = string.find(data, " (%d+)/(%d+)\005")
      if free ~= "0" then
         if not SL_Slots[nick] then
            SL_Nslots = SL_Nslots + 1
         end
         SL_Slots[nick] = { tonumber(free), tonumber(all) }
      end
   end
   return 1      
end

function VH_OnUserCommand(nick,data)
   if string.find(data,"^%+slots") then
      res,SL_Botname = VH:GetConfig("config","hub_security")
      result, sMyinfo = VH:GetMyINFO(nick)
      result, iClass = VH:GetUserClass(nick)
      if string.find(sMyinfo, "M:A") or iClass > 2 then
         local now = os.time()
         SL_NickList = nick
         if now > SL_LastUpdate + SL_Timeout then
            SL_Slots = {}
            SL_Nslots = 0
            VH:SendDataToUser("<"..SL_Botname.."> Checking users for slots, please wait "..SL_Wait.." seconds...|",nick)
            SL_LastUpdate = now
            SL_TimerCounter = SL_Wait
            VH:SendDataToAll("$Search Hub:"..SL_Botname.." T?F?0?1?.|",0,10)
            SL_TimerEnable = 1
            return 0
         else
            SL_SENDRESULT()
            return 0
         end
      else
         VH:SendDataToUser("<"..SL_Botname.."> Only active users can use this command. To get active you need to change your connection settings.|",nick)
         return 0
      end
   end
   return 1
end


function SL_SENDRESULT()
   local now = os.time()
   res,SL_Botname = VH:GetConfig("config","hub_security")
   VH:SendDataToUser("<"..SL_Botname.."> -------------------------------------------------- FREE SLOTS --------------------------------------------------|",SL_NickList)
   VH:SendDataToUser("<"..SL_Botname.."> Last check: "..math.floor((now-SL_LastUpdate)/60).. " minutes ago.|",SL_NickList)
   for k, v in pairs(SL_Slots) do
      VH:SendDataToUser("<"..SL_Botname.."> ".. string.format(SL_Message, v[1], v[2], k).."|",SL_NickList)
   end
   VH:SendDataToUser("<"..SL_Botname.."> --------------------------------------------------    "..SL_Nslots.." users    ------------------------------------------------------|",SL_NickList)
end

function VH_OnTimer()
   if SL_TimerEnable==1 then
      if SL_TimerCounter > 0 then
         SL_TimerCounter = SL_TimerCounter - 1
      else
         SL_TimerEnable = 0
         SL_SENDRESULT()
      end
   end
end

