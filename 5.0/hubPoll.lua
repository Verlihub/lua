--+++++++++++++++++++++++++++++++++++++++
--                                      |
--                                      |
--          HubPoll Script 2.0          |
--                                      |
--         Coded for QueensHub          |
--                                      |
--         Wolfbane/pR0Ps 2009          |
--                                      |
--                                      |
--+++++++++++++++++++++++++++++++++++++++

--Manage Syntax: !poll <add/remove/help> [<question>]_[<choice1>]_[<choiceN>]_[<lowClass>]
--Useage Syntax: +poll <view/vote/help> [<Data>]

_,opcmd = VH:GetConfig(\"config\",\"cmd_start_op\")
_,uscmd = VH:GetConfig(\"config\",\"cmd_start_user\")

_,MainHubBotName = VH:GetConfig(\"config\", \"hub_security\")

--Op Management commands
addTrig = \"add\"
removeTrig = \"remove\"

--User commands
viewTrig = \"view\"
voteTrig = \"vote\"

--Shared commands
mainTrig = \"poll\"
helpTrig = \"help\"

active = false
pollList = {}
userList = {}
numChoices = 0
question = \"\"
admin = \"\"
lowClass = 0


--Used ONLY for managing the poll
function VH_OnOperatorCommand(Nick, Cmd)
	Cmd, Params = First(Cmd)
	if Cmd == opcmd..mainTrig then
		local SubCmd, pollData = First(Params)
		-- Adding a poll
		if SubCmd == addTrig then
			if active then
				VH:SendDataToUser(\"<\"..MainHubBotName..\"> There is already a poll running, it was started by \"..admin..\"|\",Nick)
				return 0
			end
			loadPoll (pollData)
			VH:SendDataToUser(\"<\"..MainHubBotName..\"> Poll successfully created|\",Nick)
			--set globals
			admin = Nick
			active = true
			VH:SendDataToAll (\"<\"..MainHubBotName..\"> New poll created: \"..question..\" Type '\"..uscmd..mainTrig..\" \"..viewTrig..\"' to see it or '\"..uscmd..mainTrig..\" 
\"..helpTrig..\"' for help!|\",lowClass, 10)
			return 0
		-- Removing a poll
		elseif SubCmd == removeTrig then
			if not active then
				VH:SendDataToUser(\"<\"..MainHubBotName..\"> No poll to remove|\",Nick)
				return 0
			end
			--a poll can only be removed by its creator
			if Nick ~= admin then
				VH:SendDataToUser(\"<\"..MainHubBotName..\"> A poll can only be removed by its creator, \"..admin..\"|\",Nick)
			else
				removePoll()
				VH:SendDataToUser(\"<\"..MainHubBotName..\"> Poll removed|\",Nick)
			end
			return 0
		-- Help/unknown commands
		else
			if SubCmd ~= helpTrig  and SubCmd ~= \"\" then
				VH:SendDataToUser(\"<\"..MainHubBotName..\"> Command '\"..SubCmd..\"' not recognized, displaying help|\", Nick)
			end
			OPHelp(Nick)
			return 0
		end
	end
	return 1
end

--Used by everyone for voting and viewing the poll
function VH_OnUserCommand (Nick, Data)
	Cmd, Data = First(Data)
	if Cmd == uscmd..mainTrig then
		SubCmd, Param = First (Data)
		local class = GetClass(Nick)
		--check if there is a poll active and if the user is authorized to vote/view it
		if active and class and class >= lowClass then
			--User is voting
			if SubCmd == voteTrig then
				num = tonumber(Param)
				if (num ~=nil) then
					if userList[Nick] == 1 then
						VH:SendDataToUser(\"<\"..MainHubBotName..\"> Please only vote once to keep things fair|\",Nick)
					elseif num > 0 and num <= numChoices then
						pollList[num][2] = pollList[num][2] + 1
						userList[Nick] = 1
						VH:SendDataToUser(\"<\"..MainHubBotName..\"> Your vote has been counted|\",Nick)
					else
						VH:SendDataToUser(\"<\"..MainHubBotName..\"> Please enter a number within the polls' range|\",Nick)
					end
					return 0
				else		
					USRHelp (Nick)
					return 0
				end
			--User is viewing the poll
			elseif SubCmd == viewTrig then
				VH:SendDataToUser(\"<\"..MainHubBotName..\"> Current poll:\n\".. dispPoll (Nick == admin or userList[Nick] == 1), Nick)
				return 0
			--Everything else, show help
			else
				if SubCmd ~= helpTrig then
					VH:SendDataToUser(\"<\"..MainHubBotName..\"> Command '\"..SubCmd..\"' not recognized, displaying help|\", Nick)
				end
				USRHelp (Nick)
				return 0
			end
		--Trying to use the poll commands, not active
		elseif SubCmd == viewTrig or SubCmd == voteTrig then
			VH:SendDataToUser(\"<\"..MainHubBotName..\"> No poll currently active|\", Nick)
			return 0
		--Everything else, show help
		else
			if SubCmd ~= helpTrig and SubCmd ~= \"\" then
				VH:SendDataToUser(\"<\"..MainHubBotName..\"> Command '\"..SubCmd..\"' not recognized, displaying help|\", Nick)
			end
			USRHelp (Nick)
			return 0
		end
	end
	return 1
end

function VH_OnUserLogin(Nick)
	local class = GetClass (Nick)
	if(active and userList[Nick] ~= 1 and class and class >= lowClass) then
		VH:SendDataToUser(\"<\"..MainHubBotName..\"> There is currently a poll running!\n\"..dispPoll(false)..\"\nType '\"..uscmd..mainTrig..\" \"..voteTrig..\"' <number> to vote or 
'\"..uscmd..mainTrig..\" \"..helpTrig..\"' for help|\", Nick)
	end
end

function dispPoll (showNum)
	local temp = \"\"
	for i=1, numChoices do
		temp = temp .. \"[\"..i..\"] \"..pollList[i][1]
		if showNum then
			temp = temp .. \":\t\t\" ..pollList[i][2]
		end
		temp = temp .. \"\n\"
	end
	return question..\"\n\"..temp
end

function OPHelp (Nick)
	VH:SendDataToUser(\"<\"..MainHubBotName..\"> Help on using \"..opcmd..mainTrig..\":\n\"..
    opcmd..mainTrig..\" \"..addTrig..\" <question>_<choice1>_<choiceN>_<lowClass> === Starts a poll. NOTE: parameters after question must be separated by the '_' char.\n\"..
	\"       Example: \"..opcmd..addTrig..\" This is the question_Yes, I agree_Nope, wrong_0\n\"..
	opcmd..mainTrig..\" \"..removeTrig..\" === Removes the current poll. Can only be done by the creator.\n\"..
	opcmd..mainTrig..\" \"..helpTrig..\" === Display this message\n|\", Nick)
end

function USRHelp (Nick)
	VH:SendDataToUser(\"<\"..MainHubBotName..\"> Help on using \"..uscmd..mainTrig..\":\n\"..
    uscmd..mainTrig..\" \"..viewTrig..\" === Displays the current poll. Vote to see the current results\n\"..
	uscmd..mainTrig..\" \"..voteTrig..\" <number> === Casts your one and only vote towards option <number>.\n\"..
	uscmd..mainTrig..\" \"..helpTrig..\" === Display this message\n|\", Nick)
end

function loadPoll (data)
	question, choices = First(data, \"_\")
	-- determines the number of choices based on amount of _ symbols
	_,numChoices = string.gsub(data, \"_\", \" \")
	numChoices = numChoices - 1
	--loads the list of choices into the array
	tempList = choices
	for i=1, numChoices do
		pollList[i] = {}
		pollList[i][1], tempList = First(tempList, \"_\")
		pollList[i][2] = 0
	end
	lowClass = tonumber(tempList)
end

function removePoll ()
	--removes the poll
	pollList = {}
	userList = {}
	active = false
	admin = \"\"
	lowClass = 0
end

function First(Str, Sep)
	-- Takes the First \"word\", and returns it, also returns the rest of line
	if Sep == nil then
		-- It is the RegExp, that select the first Word
		Sep = \"%s\"
	end
	local i = string.find(Str, Sep)
	if i == nil then
		-- If the whole Str is not containing 2 word,
		--the whole Str is returned as the First word
		return Str, \"\"
	else
		return string.sub(Str, 1, i-1), string.sub(Str, i+1)
	end
end

function GetClass(nick)
	res, class = VH:GetUserClass(nick)
	if res and class then
		return class
	else
		return false
	end
end

