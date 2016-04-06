--This is a Powerful AntiAdvertising Script
 --Powered by Demone.Astaroth and OpiumVolage
 --igoru's version
 --History: Base= 'multiline antiadvertise' by OpiumVolage (your tables simplify the work I did until that moment). Here its features:
 --1)Script can block this types of advertisement:
 --A)   <user> example.no-ip.com
 --B)        <user> e x a m p l e . n o - i p . c o m
 --C)        <user>example.
 --        <user>no-
 --        <user>ip.
 --        <user>com
 --D)        <user>e
 --        x
 --        a
 --        m
 --        p
 --        l
 --        e
 --        .
 --        n
 --        o
 --        -
 --        i
 --        p
 --        .
 --        c
 --        o
 --        m
 BotName =  "UniBot"
 advtrigs  {"dns2go","servebeer","mine.nu","ip.com","dynip","depecheconnect.com","zapto.org",
         ".staticip","serveftp","ipactive","ip.org","no-ip","servegame","gotdns.org","ip.net",
         "ath.cx","dyndns","clanpimp","idlegames","sytes","unusualperson.com",
         "uni.cc","homeunix","ciscofreak.com","deftonzs.com","flamenap","xs4all","point2this.com","ip.info",
         ".myftp.",".d2g",".orgdns","myip.org","stufftoread.com","ip.biz","dynu.com","mine.org","kick-ass.net",
         "darkdata.net","ipme.net","udgnet.com","homeip.net","e-net.lv","newgnr.com","bst.net","bsd.net","ods.org",
         "bounceme.net","myvnc.com","kicks-ass.com","3utilities.com","myftp.biz","redirectme.net","servebeer.com","servecounterstrike.com",
         "servehalflife.com","servehttp.com","serveirc.com","servemp3.com","servepics.com","servequake.com",
         "damnserver.com","ditchyourip.com","dnsiskinky.com","geekgalaxy.com","net-freaks.com","ip.ca",
         "securityexploits.com","securitytactics.com","servehumour.com","servep2p.com","servesarcasm.com",
         "workisboring.com","hopto","dnsalias",".druglords","pxlbabes","pornstarguru","smslandet","gurka.se",
         "freefamily","skorpion","freeazzurra","cubalibre","virtualbar","valsts.lv","ip*com","hub.",
         "antechstore.it","fastolimpus","milleniumzone.net","isa-geek","exclusivehub.net","glesius.it","darkbios.it",
         "zodiako.net","overshadow","sytes.net","euroshok.com","fastdevils.net","freedomempire.net","cafuni",
         "(punto)","ns0","cucciolandia.net","jaunshubs","radiodance.ro","freewebs.com","go.dk","gravisnet","dieb.matthias-scheller.net",
         "netwars.ru", "miracle","modeles.lv"}
 validtrigs =  {"uninet","http://www.hub.lv/"} --insert here your addresses (like yours or multihub ones or great friend's hub ;) )
 controltrigs= {["boolean.mine.nu"]= 1,["boolean2.mine.nu"]= 2,~["boolean3.mine.nu"]= 3,["dreamland.gotdns.org"]= 4,["booleanradio.mine.nu"]= 5}
 --insert here addresses you want to be informed (no kick)
 tabAdvert =  {}
 function Main()
         VH:AddRobot(BotName, 10, "UniNet!", "Bot ", "info@uninet.lv", "0")
         OpChatN =  GetOpChatName()
 end
 TimerTicks =  60
 function VH_OnTimer()
         if TimerTicks > 0 then
                 TimerTicks =  TimerTicks - 1
         else
                 for key, value in tabAdvert do
                         if (tabAdvert[key].iClock > os.clock()+60) then
                                 tabAdvert[key]= nil
                         end
                 end
                 TimerTicks =  60
         end
         return 1;
 end
 function VH_OnParsedMsgChat(nick, message)
         retValue =  1;
         if not IsUserOperator(nick) then
                 res =  Verify(nick, message)
                 if not ( res = =  nil) then
                         tabAdvert[nick]= nil
                         BanUserM(nick, res)
                         retValue =  0;
                 end
                 for key, value in controltrigs do
                         if( string.find( string.lower(message), key) ) then
                                 VH:SendPMToAll("Control: User <"..nick.."> with IP ["..GetIP(nick).."] told in main: "..message.."", OpChatN, 3, 10)
                         end
                 end
                 spam                 if( string.find( string.lower(message), "no",1,1) ) and (string.find( string.lower(message), "ip.",1,1) ) then
                         if ( string.find( string.lower(message), "com",1,1)) or ( string.find( string.lower(message), "org",1,1) ) or ( string.find(string.lower(message), "info",1,1) ) then
                 spam= spam+1; end; end;
                 if( string.find( string.lower(message), "dns",1,1) ) and (string.find( string.lower(message), "2",1,1) ) and ( string.find(string.lower(message), "go",1,1) ) then
                 spam= spam+1; end
                 if( string.find( string.lower(message), "dy",1,1) ) and (string.find( string.lower(message), "nu",1,1) ) then                if( string.find( string.lower(message), ".net",1,1)) or ( 
string.find( string.lower(message), ".com",1,1) ) then
                 spam= spam+1;end; end
                 if( string.find( string.lower(message), "d n s a",1,1) ) or( string.find( string.lower(message), "d n s .",1,1) ) or ( string.find(string.lower(message), "d n s 2",1,1) ) or ( 
string.find(string.lower(message), "o d s .",1,1) ) or ( string.find(string.lower(message), "d y n",1,1) ) then
                 spam= spam+1;end
                 if spam>0 then
                         BanUserM(nick, message)
                         retValue =  0;
                 end
         end
         return retValue;
 end
 function VH_OnParsedMsgPM (from, message, to)
         retValue =  1;
         if not (IsUserOperator(from) or IsUserOperator(to)) then
                 local userdata =  to.." "..from
                 res =  Verify(userdata, message)
                 if not ( res = =  nil) then
                         tabAdvert[userdata]= nil
                         BanUserP(from, res, to)
                         retValue =  0;
                 end
                 for key, value in controltrigs do
                         if( string.find( string.lower(message), key) ) then
                                 VH:SendPMToAll("Control: User <"..from.."> with IP ["..GetIP(from).."] said to "..to.." this: "..message.."", OpChatN,3, 10)
                         end
                 end
                 spam                 if( string.find( string.lower(message), "no",1,1) ) and (string.find( string.lower(message), "ip.",1,1) ) then
                         if ( string.find( string.lower(message), "com",1,1)) or ( string.find( string.lower(message), "org",1,1) ) or ( string.find(string.lower(message), "info",1,1) ) then
                                 spam= spam+1;
                         end;
                 end;
                 if( string.find( string.lower(message), "dns",1,1) ) and (string.find( string.lower(message), "2",1,1) ) and ( string.find(string.lower(message), "go",1,1) ) then
                         spam= spam+1;
                  end
                 if( string.find( string.lower(message), "dy",1,1) ) and (string.find( string.lower(message), "nu",1,1) ) then
                         if( string.find( string.lower(message), ".net",1,1)) or ( string.find( string.lower(message), ".com",1,1) ) then
                 spam= spam+1;end; end
                 if( string.find( string.lower(message), "d n s a",1,1) ) or( string.find( string.lower(message), "d n s .",1,1) ) or ( string.find(string.lower(message), "d n s 2",1,1) ) or ( 
string.find(string.lower(message), "o d s .",1,1) ) or ( string.find(string.lower(message), "d y n",1,1) ) then
                 spam= spam+1;end
                 if spam>0 then
                         BanUserP(from, message, to)
                         retValue =  0;
                 end
         end
         return retValue;
 end
 function Verify(userdata, msg)
         if (not msg) or  not (userdata) then return nil end
         tmp = ""
         string.gsub(string.lower(msg), "([a-z0-9.:%-*])", function(x) tmp =  tmp..x end)
         if not tabAdvert[userdata] then
                 tabAdvert[userdata] =  { iClock =  os.clock(), l1 =  "", l2 =   "", l3 =  "", l4=  "", l5=  "", l6=  "", l7=  "", l8=  "", l9 =  tmp }
         else
                 tabAdvert[userdata].iClock =  os.clock()
                 tabAdvert[userdata].l1 =  tabAdvert[userdata].l2
                 tabAdvert[userdata].l2 =  tabAdvert[userdata].l3
                 tabAdvert[userdata].l3 =  tabAdvert[userdata].l4
                 tabAdvert[userdata].l4 =  tabAdvert[userdata].l5
                 tabAdvert[userdata].l5 =  tabAdvert[userdata].l6
                 tabAdvert[userdata].l6 =  tabAdvert[userdata].l7
                 tabAdvert[userdata].l7 =  tabAdvert[userdata].l8
                 tabAdvert[userdata].l8 =  tabAdvert[userdata].l9
                 tabAdvert[userdata].l9 =  tmp
         end
         local Lines =  
tabAdvert[userdata].l1..tabAdvert[userdata].l2..tabAdvert[userdata].l3..tabAdvert[userdata].l4..tabAdvert[userdata].l5..tabAdvert[userdata].l6..tabAdvert[userdata].l7..tabAdvert[userdata].l8..tabAdvert[userdata].l9
         if (string.find(Lines, "%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?")) then
                 return "( ipaddress in " ..Lines..")";
         end
         for key, value in advtrigs do
                 if (string.find(Lines, string.lower(value), 1, 1)) then
                         for key2, value2 in validtrigs do
                                 if (string.find(Lines, string.lower(value2), 1, 1)) then
                                         return nil
                                 end
                         end
                         return "("..value.." in " ..Lines..")"
                 end
         end
 end
 --- [ my functions ] ----
 function BanUserM(nick, message)
         message =  "main chat saying: "..message..""
         BanUser(nick, message)
 end
 function BanUserP(from, message, to)
         message =  "PM to <"..to.."> saying this: "..message..""
         BanUser(from, message)
 end
 function BanUser(nick, message)
 --        VH:SendDataToAll(nick.." got slaughtered by Lucifer for advertising!|", 1, 10)
         VH:SendDataToUser("$To: "..nick.." From: "..BotName.." $<"..BotName.."> I slaughtered you! Don't try again to advertise!", nick)
         VH:SendPMToAll("User <"..nick.."> with IP ["..GetIP(nick).."] advertised in "..message.."", BotName, 3, 10)
         VH:KickUser(BotName, nick, "Advirtesement...probably he wants to be crashed !")
 end
 function GetOpChatName()
         res, val =  VH:GetConfig("config", "opchat_name")
         if res then
                 return val
         end
         return "Unknown"
 end
 function GetIP(nick)
         res, ip =  VH:GetUserIP(nick)
         if not res then
                 ip =  "unknown"
         end
         return ip
 end
 function IsUserOperator(nick)
         res, class =  VH:GetUserClass(nick)
         if res and class >=  2 then
                 return true
         else
                 return false
         end
 end
