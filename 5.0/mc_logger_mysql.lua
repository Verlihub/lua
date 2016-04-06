--------------------------------------------------------------------------------
--  %%%%%%%%%%%%%%%%  mclog.lua  --- MC LoGGeR mySQL v1.0 by ZuZu %%%%%%%%%%%%%%%%%%%%
-- This plugin will log all Main Chat conversation into a database and will display
--               the newest N replies from Main Chat at login
-- ALSO some usefull commands:
--     !mc XX        - The bot will send you on private the last XX MC replies (for OPs class>4)
--           you can also use !mc without parameter and will display by the default 100
--     !delmc  ---- this command will delete the logs from database older than the "difference"
--                      parameter setted bellow
--                                 IMPORTANT:
--  You need to put into the folder /etc/verlihub/scripts/ the library utils.lua.lib
--       .. you can get it from: http://verlilinker.svn.sourceforge.net/viewvc/verlilinker/
--------------------------------------------------------------------------------

mc = "^!mc"  ---
del = "^!delmc"
lines = 10 ---number of latest lines from MC log written to each user at login
minclass = 5 --- minimum class to use command !mc
difference = 2*30  --- number of days to delete logs; example for 3 months set it to 90
version = "1.1"


--------------------------------------------------------------------------------
dofile('/etc/verlihub/scripts/utils.lua.lib') -- including some basic functions
--------------------------------------------------------------------------------

-- other configuration vars
local res, BotNick = VH:GetConfig("config", "hub_security")
if not res then BotNick = 'UNKNOWN' end

--------------------------------------------------------------------------------
function Main()
--------------------------------------------------------------------------------
   local sql = "CREATE TABLE IF NOT EXISTS `pi_mclog` (\
      `id` INTEGER(11) UNSIGNED NOT NULL AUTO_INCREMENT,\
      `from` VARCHAR(32) NOT NULL DEFAULT '',\
      `text` TEXT NOT NULL,\
      `time_sent` INTEGER(13) NOT NULL DEFAULT '0',\
      PRIMARY KEY (`id`),\
      INDEX `from` (`from`)\
   );"
   local res = VH:SQLQuery(sql)
   if res then
      VH:SendDataToAll(" MC log mySQL v"..version.." by ZuZu loaded ***|",10,10)
   else
      VH:SendDataToAll(" MC log mySQL loaded (but sql query failed) ***|", 10, 10)
   end
end
--------------------------------------------------------------------------------
function VH_OnParsedMsgChat (nick, data)
--------------------------------------------------------------------------------
   local sql = string.format("INSERT INTO `pi_mclog` SET `from`='%s',`text`='%s',`time_sent`=UNIX_TIMESTAMP();", escape_db(nick), escape_db(data))
   local res = VH:SQLQuery(sql)
   if not res then
      -- handle error
   end
   return 1
end

--------------------------------------------------------------------------------
function VH_OnUserLogin(nick)
--------------------------------------------------------------------------------
   VH:SendDataToUser(" Latest 10 messages ***|",nick)
    query = "SELECT `from`,`text`,`time_sent` FROM `pi_mclog` ORDER BY `time_sent` DESC LIMIT 0,"..lines..";"
   local i = 1
    local r,cnt = VH:SQLQuery(query);
   local out = "\n"
    for i = 1, cnt do
      local _,from,text,time_sent = VH:SQLFetch(cnt-i)
      out = out.."\n               "..os.date("%Y-%m-%d %H:%M:%S",tonumber(time_sent)).."  <"..from.."> "..text
   end
   VH:SendDataToUser(out.."|",nick)
end

--------------------------------------------------------------------------------
function VH_OnOperatorCommand(nick,data)
--------------------------------------------------------------------------------
   local r,cl = VH:GetUserClass(nick)
  if (r and (cl >= minclass) and string.find(data,mc)) then
    query = "SELECT `from`,`text`,`time_sent` FROM `pi_mclog` ORDER BY `time_sent` DESC LIMIT 0,"..lines..";"
      if string.find(data,mc.."%sall") then
         query="SELECT `id`,`from`,`text`,`time_sent` FROM `pi_mclog` ORDER BY `time_sent` DESC;"
      end
      if string.find(data,mc.."%s(%d+)$") then
         local _,_,x = string.find(data,mc.."%s(%d+)$")
         query="SELECT `id`,`from`,`text`,`time_sent` FROM `pi_mclog` ORDER BY `time_sent` DESC LIMIT 0,"..x..";"
      end
      local i = 1
      local r,cnt = VH:SQLQuery(query);
      local t = "$To: "..nick.." From: "..BotNick.." $<"..BotNick.."> \n       Id           Time                         From                         Text"
      for i = 1, cnt do
         local _,id,from,text,time_sent = VH:SQLFetch(cnt-i)
         t = t.."\n       "..id.."   "..os.date("%Y-%m-%d %H:%M:%S",tonumber(time_sent)).."    <"..from..">     "..text
      end
      VH:SendDataToUser(t.."|",nick)
      return 0
   end
   if (r and (cl >= minclass) and string.find(data,del)) then 
   present_date = os.time()
   rez_date = present_date - difference*86400
   query = "DELETE FROM `pi_mclog` WHERE `pi_mclog`.`time_sent` < "..rez_date..";"
   VH:SQLQuery(query)
     VH:SendDataToUser(" Logs older than "..difference.." days ( "..os.date("%Y-%m-%d %H:%M:%S",tonumber(rez_date)).." ) deleted|",nick)
    return 0
    end
   return 1
end
