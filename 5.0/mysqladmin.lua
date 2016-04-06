--------------------------------------------------------------------------------
--
-- Script name: mysqladmin.lua
-- Author: burek
-- E-mail: burek021@gmail.com
-- Date: 03/Mar/2010
-- Version: 1.1
-- Updated: 03/Mar/2010
--
--------------------------------------------------------------------------------
-- Description:
--   This script is used to allow hub owners to type SQL commands into PM chat
--   with hub-security bot. First, admin must type a command to enter the
--   "SQL mode", which allows him to type SQL commands directly into PM chat with
--   the bot, and when he is finished, he needs to type a command to exit the
--   "SQL mode".
-- Commands introduced:
--   !sql on
--   !sql off
-- Dependecies:
--   a) It uses a library named "utils.lua.lib" which can be found at:
--      http://forums.verlihub-project.org/viewtopic.php?f=14&t=4648
--      Download that library and put it in the same folder with this file.
-- Notice:
--   To see the result sets correctly in Your PM chats, You must configure Your
--   DC client to use 'monospace' font, like 'System' or 'Courier New' or such.
--------------------------------------------------------------------------------

-- the parent folder of the 'scripts' folder
base_dir = '/home/verlihub_burek/.verlihub' -- WITHOUT TRAILING SLASH!

-- list of operators that are currently in "sql" mode
active_nicks = {}

-- triggers
cmd_on  = '!sql on'
cmd_off = '!sql off'

-- who can use the trigger
min_class = 10

-- messages
msg_welcome = 'You have now entered the "SQL mode". That means all text messages You send to me will be interpreted as SQL commands. To quit SQL mode, type: ' .. cmd_off
err_already_in_sql_mode = 'You are already in "SQL mode". Please type some SQL commands You whish to execute.'
err_not_in_sql_mode = 'You are not in "SQL mode". To enter SQL mode, please type: ' .. cmd_on
msg_goodbye = 'You have now exited the "SQL mode".'
err_invalid_sql = 'Your SQL command is invalid or empty.'
err_slq_error = 'MySQL server returned an error reply with null result.'
msg_slq_executed = 'SQL query has been executed successfully.'

--------------------------------------------------------------------------------

_,BotNick = VH:GetConfig('config', 'hub_security')
dofile(base_dir .. '/scripts/utils.lua.lib')
MAX_COLUMN_WIDTH = 30

--------------------------------------------------------------------------------
function SendPm(nick, msg)
--------------------------------------------------------------------------------
	VH:SendDataToUser(string.format('$To: %s From: %s $<%s> %s|', nick, BotNick, BotNick, escape_dc(msg)), nick)
end

--------------------------------------------------------------------------------
function GetResultSet(cnt)
--------------------------------------------------------------------------------
	local rs = {}
	for i = 0, cnt-1 do
		local tmp = {VH:SQLFetch(i)}
		if tmp and tmp[1] then
			local row = {}
			for j = 2, #tmp do -- skip first
				table.insert(row, tostring(tmp[j]))
			end
			table.insert(rs, row)
		end
	end
	return rs
end

--------------------------------------------------------------------------------
function GetColumnWidths(rs)
--------------------------------------------------------------------------------
	local column_widths = nil
	if rs and rs[1] then
		column_widths = {}
		for i = 1, #rs do
			local row = rs[i]
			for j = 1, #row do
				if not column_widths[j] then column_widths[j] = 1 end -- init
				if column_widths[j] < string.len(row[j]) then
					column_widths[j] = string.len(row[j])
				end
				if column_widths[j] > MAX_COLUMN_WIDTH then
					column_widths[j] = MAX_COLUMN_WIDTH
				end
			end
		end
	end
	return column_widths
end

--------------------------------------------------------------------------------
function PrintResultSet(rs)
--------------------------------------------------------------------------------
	local rez = ''
	if rs and rs[1] then
		local column_widths = GetColumnWidths(rs)
		for i = 1, #rs do
			local row = rs[i]
			for j = 1, #row do
				rez = rez .. string.format(' %-'..column_widths[j]..'s ', row[j])
			end
			rez = rez .. '\n'
		end
	end
	return rez
end

--------------------------------------------------------------------------------
function VH_OnOperatorCommand(nick, data)
--------------------------------------------------------------------------------
	local _,UserClass = VH:GetUserClass(nick)
	if UserClass < min_class then
		return 1
	end

	if string.find(data, cmd_on, 1, 1) == 1 then
		if active_nicks[nick] then
			SendPm(nick, err_already_in_sql_mode)
		else
			active_nicks[nick] = 1
			SendPm(nick, msg_welcome)
		end
		return 0
	elseif string.find(data, cmd_off, 1, 1) == 1 then
		if not active_nicks[nick] then
			SendPm(nick, err_not_in_sql_mode)
		else
			active_nicks[nick] = nil
			SendPm(nick, msg_goodbye)
		end
		return 0
	else
		return 1
	end
end

--------------------------------------------------------------------------------
function VH_OnParsedMsgAny(nick, data)
--------------------------------------------------------------------------------
	local s = string.format('$To: %s From: %s $<%s> ', BotNick, nick, nick)
	if string.find(data, s, 1, 1) ~= 1 then -- not a PM to bot
		return 1
	end

	if not active_nicks[nick] then -- not in SQL mode
		return 1
	end

	data = string.sub(data, string.len(s)+1)
	if string.len(trim(data)) < 1 then
		SendPm(nick, err_invalid_sql)
		return 0
	end

	if (string.find(data, '!', 1, 1) == 1) or (string.find(data, '+', 1, 1) == 1) then -- ignore commands
		return 1
	end

	data = unescape_dc(data)
	if string.find(string.upper(trim(data)), 'SELECT ', 1, 1) == 1 then -- hack, because lua tables cannot handle nil values correctly
		data = string.gsub(data, '[sS][eE][lL][eE][cC][tT] (.-) [fF][rR][oO][mM] ', "SELECT %1,'' FROM ")
	end
	local res, cnt = VH:SQLQuery(data)

	if not res then -- mysql returned an error
		SendPm(nick, err_slq_error)
	else
		if cnt and (cnt > 0) then -- SQL query has a result set, display it
			local rs = GetResultSet(cnt)
			local tbl = PrintResultSet(rs)
			SendPm(nick, '\n' .. tbl)
		else -- query has got no result set
			SendPm(nick, msg_slq_executed)
		end
	end

	return 0
end
