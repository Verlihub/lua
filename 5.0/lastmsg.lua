-- Copyright (c) by Sergey Leonovich 2008
-- E-Mail: sheep2k@gmail.com
-- Improved by burek

-- Wanted messages count minus one
MAX_MSG = 30
DATE_FORMAT = '%d/%b/%Y %H:%M:%S'
local msgs = {}

--------------------------------------------------------------------------------
function VH_OnParsedMsgChat (nick, data)
--------------------------------------------------------------------------------
   if #msgs >= MAX_MSG then
      table.remove(msgs, 1) -- remove the first item, shifting down other items
   end
   local msg = string.format('[%s] <%s> %s', os.date(DATE_FORMAT), nick, data)
   table.insert(msgs, msg) -- add new msg to the end of the list
   return 1
end

--------------------------------------------------------------------------------
function VH_OnUserLogin(nick)
--------------------------------------------------------------------------------
   if #msgs > 0 then
      local msg = string.format('Current time is: %s. The last %d chat message(s) follow(s):\r\n', os.date(DATE_FORMAT), #msgs)
      for k, v in pairs(msgs) do
         msg = msg .. v .. '\r\n'
      end
      msg = msg .. '|'
      VH:SendDataToUser(msg, nick)
   end
   return 1
end
