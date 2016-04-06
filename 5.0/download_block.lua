botname = "Blocker"
botdesc = "Download Blocker"
botemail = ""

-- Get the hub name
res, hubname = VH:GetConfig("config", "hub_name")


-- Create a table to populate later
RegRCTM = {}

-- On any event
function VH_OnParsedMsgAny(nick, data)

   -- On RevConnectToMe
   if (string.sub(data, 1, 15) == "$RevConnectToMe") then
      -- Get the sender and receiver nicks
      local _, _, fromnick, tonick = string.find(data, "$RevConnectToMe%s+(%S+)%s+(%S+)" )
      -- Get sender class
      local _, sclass = VH:GetUserClass(fromnick)
      -- Get receiver class
      local _, rclass = VH:GetUserClass(tonick)

      -- If sender and receiver both regged, no restrictions
      if (sclass >= 1) and (rclass >= 1) then
         return 1
      -- If member is unregged, disallow
      elseif (sclass == 0) then
                        MsgPM(fromnick, "Guests can only download from guests, to download from a registered user you need to register.  Type +reginfo in main chat to find out how to register.")
                        return 0
      -- If sender is regged, and receiver is unregged
      elseif (sclass >= 1) and (rclass == 0) then
                        RegRCTM[tonick] = 1
                        return 1
      -- Disallow everything else
      else
         return 1
                end
   -- On ConnectToMe
   elseif (string.sub(data, 1, 12) == "$ConnectToMe") then
      -- Get receiver nick
      local _, _, tonick = string.find(data, "$ConnectToMe%s+(%S+)%s+.*" )
      -- Get sender class      
      local _,sclass = VH:GetUserClass(nick)
      -- Get receiver class
      local _,rclass = VH:GetUserClass(tonick)

      -- If sender is regged, no restrictions   
      if sclass >= 1 then
         return 1
      -- If sender is unregged, and receiver is regged      
                elseif (sclass == 0) and (rclass ~=0) then

         -- Check if CTM has been initiated by passive reg
         if (RegRCTM[nick] ~= nil) then
            -- Clear the sender's nick
            RegRCTM[nick] = nil
            -- Allow the connection
            return 1
         -- Otherwise disallow
         else
            MsgPM(nick, "You must register to download in "..hubname..". Type +reginfo in main chat to find out how to register.")
            return 0
         end

      -- Disallow everything else
      else
         return 0
      end

   -- Allow all non-CTM/RCTM traffic
        else
      return 1
   end

end

-- Send PMs to users/OPs
function MsgPM(user, data)
      return VH:SendDataToUser("$To: %nick From: "..botname.." $<"..botname.."> "..data.."|", user)
end

-- On script unload
function UnLoad()
   -- Delete bot from user list
   VH:DelRobot(botname)
end