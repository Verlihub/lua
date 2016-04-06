Here you can find a collection of LUA scripts for Verlihub. To find more scripts search on http://ro.4242.hu/cgi-bin/yabb2/YaBB.pl (Hungarian forums) or ask Google

Download Blocker (download_block.lua)
---
*LUA 5.0.x only*

This script will block downloads to no-registered users. Guest user (class 0), who will try to download a file, will recieve a alert message


Hub poll (HubPoll.lua)
----
*LUA 5.0.x only*

This script allows OPs to post polls that users can vote on. Useful for gathering the general opinion of the hub.
When a user connects to the hub (if he hasen't already voted and he has a relvant class), he will be prompted that there is a poll available and he will see some general information about commands. 
Script has been set up so only the admin (creator) can delete the poll. None - except the admin - will be able to see the results until he have voted. 
The syntax of the command is fairly easy. For example:

	!poll add Which OS do you prefer?_Windows_Mac_Linux_Other_3

would create a poll for users with class greater than 3 about which OS they prefer. Users would then use the +poll view and +poll vote triggers to vote and view the poll. If the users have a lower class, they will be told that no poll exists.

Last message (lastmsg.lua)
---
*LUA 5.0.x only*

This is a simple LUA script which display the last N chat messages to the user after he logged in. It's very useful when a user just logged in and he wants to know what other users was talking about.

Main Chat logger (mc_logger_mysql.lua)
----
This is a Main Chat logger which saves all the conversation in the hub database. It also display the latest 10 lines of MC at login to every user (or you can set up a specific class) 
or could display the lastest XX lines with the command

	!mc XX

> Note that you need a copy of  utils.lua.lib library in /etc/verlihub/scripts/ folder. You can get it from http://verlilinker.svn.sourceforge.net/viewvc/verlilinker/

MySQL Admin (mysqladmin.lua)
---
This script is used to allow hub owners to type SQL commands into PM chat with hub-security bot. First, admin must type a command to enter the "SQL mode", which allows him to type SQL commands directly into PM chat with the bot, and when he is finished, he needs to type a command to exit the "SQL mode".
For example:

	<[G]burek> !sql on
	<[GUSAR]> You have now entered the "SQL mode". That means all text messages You send to me will be interpreted as SQL commands. To quit SQL mode, type: !sql off
	<[G]burek> SHOW TABLES FROM hubburek;
	<[GUSAR]> 
	SetupList                
	banlist                  
	conn_types               
	custom_redirects         
	file_trigger             
	kicklist                 
	pi_forbid                
	pi_isp                   
	pi_plug                  
	reglist                  
	script_ip_nick           
	script_links_hlcs        
	script_log_joins_parts   
	script_search_categories 
	script_search_files      
	temp_rights              
	unbanlist                

	<[G]burek> DESCRIBE SetupList;
	<[GUSAR]> 
	file  varchar(15)  NO   PRI       
	var   varchar(32)  NO   PRI       
	val   text         YES         

	<[G]burek> DESCRIBE reglist;
	<[GUSAR]> 
	nick            varchar(40)  NO   PRI       
	class           int(2)       YES       1    
	class_protect   int(2)       YES       0    
	class_hidekick  int(2)       YES       0    
	hide_kick       tinyint(1)   YES       0    
	hide_keys       tinyint(1)   YES       0    
	hide_share      tinyint(1)   YES       0    
	reg_date        int(11)      YES         
	reg_op          varchar(30)  YES         
	pwd_change      tinyint(1)   YES       1    
	pwd_crypt       tinyint(1)   YES       1    
	login_pwd       varchar(60)  YES         
	login_last      int(11)      YES  MUL  0    
	logout_last     int(11)      YES  MUL  0    
	login_cnt       int(11)      YES       0    
	login_ip        varchar(16)  YES         
	error_last      int(11)      YES         
	error_cnt       int(11)      YES       0    
	error_ip        varchar(16)  YES         
	enabled         tinyint(1)   YES       1    
	email           varchar(60)  YES         
	note_op         text         YES         
	note_usr        text         YES         
	alternate_ip    varchar(16)  YES         

	<[G]burek> SELECT * FROM reglist WHERE class = -1 ORDER BY reg_date LIMIT 10;
	<[GUSAR]> 
	pinger     -1  0  0  0  0  0  1265749864  installation  0  1  nil  0           0           0    nil            nil  0  nil  1  nil  generic pinger nick  nil  nil    
	dchublist  -1  0  0  0  0  0  1265749864  installation  0  1  nil  1267778069  1267778072  103  64.18.156.199  nil  0  nil  1  nil  dchublist pinger     nil  nil    

	<[G]burek> !sql off
	<[GUSAR]> You have now exited the "SQL mode".

Slot listen (slotlist.lua)
---
This script shows a list of active users with free slots typing +slots command.

VH Memo (vh_memo.lua)
----
This script sends memories in hub mainchat. Use:

	!addmemo [memo] add a new memory (use ~~~ for new line)
	!delmemo ID   delelete the memory with given ID
	!memolist  list of all memories

VH PM Box (vh_pmbox.lua)
---
A solution to send messages to offline users. Use:

	!sendmsg <nick> <text> to send a new message
	!inbox
	!outbox
	!pmbot (only OP) when you leave the hub a BOT will log all received messages
