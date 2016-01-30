util.AddNetworkString("LMMSBOpenMenu")
util.AddNetworkString("LMMSBReOpenMenu")
util.AddNetworkString("LMMSBReOpenMenuNoX")
util.AddNetworkString("LMMSBWriteShoutout")
util.AddNetworkString("LMMSBRateRemove")

function GetPlayerBySteamID64(steamid64)
	for k, v in pairs(player.GetAll()) do
		if steamid64 == v:SteamID64() then
			return v
		end
	end
	return false
end
-- 80

net.Receive("LMMSBWriteShoutout", function(len, ply)
	local shout = net.ReadString()
	
	if string.len( shout ) > 70 then
		shout = string.sub( shout, 1, 77 ).."..."	
	end
	
	local Day = os.date( "%d")
	local Month = os.date( "%m")
	local Year = os.date( "%Y")
	
	local Hour = os.date("%I")
	local Min = os.date("%M")
	local AMPM = os.date("%p")
	
	
	local date = Month.."/"..Day.."/"..Year.." "..Hour..":"..Min.." "..AMPM
	
	file.Write("lmm_shoutbox_data/"..ply:SteamID64()..".txt", shout.."|"..date.."|".."0".."|"..ply:Nick())
end)

net.Receive("LMMSBRateRemove", function(len, ply)
	local userfile = net.ReadString()
	
	if ply:SteamID64() == string.StripExtension(userfile) or table.HasValue(LMMSBConfig.RanksThatCanRemove, ply:GetUserGroup()) then
		file.Delete("lmm_shoutbox_data/"..userfile, "DATA")
	else
		ply:ChatPrint("No Access!")
	end
end)

function LMMSBSendMenu(ply, xornah)

	local files = {}
	local posts = 0
	for k,v in pairs( file.Find( "lmm_shoutbox_data/*.txt", "DATA" ) ) do
		local tosend = file.Read( "lmm_shoutbox_data/" .. v )
		local tbl = string.Explode( "|", tosend)
		
		local thething
		
		if GetPlayerBySteamID64(string.StripExtension(v)) == false then
			thething = nil
		else
			thething = GetPlayerBySteamID64(string.StripExtension(v))
		end
		
		posts = posts + 1
		
		local file = v
		local name = thething
		local message = tbl[1]
		local date = tbl[2]
		local rates = tbl[3]
		local thename = tbl[4]
		table.insert( files, { file, name, message, date, rates, thename } )
	end	
	
	local Hour = os.date("%I")
	local Min = os.date("%M")
	local AMPM = os.date("%p")	
	
	local lastrefresh = Hour..":"..Min.." "..AMPM
	
	net.Start("LMMSBOpenMenu")
		net.WriteTable(files)
		net.WriteBool(xornah)
		net.WriteFloat(posts)
		net.WriteString(lastrefresh)
	net.Send(ply)
end

net.Receive("LMMSBReOpenMenu", function(len, ply)
	LMMSBSendMenu(ply, true)
end)

net.Receive("LMMSBReOpenMenuNoX", function(len, ply)
	LMMSBSendMenu(ply, false)
end)

function LMMSBOpenMenu(ply, text)
	local text = string.lower(text)
	if(string.sub(text, 0, 100)== "!shoutbox" or string.sub(text, 0, 100)== "/shoutbox" or string.sub(text, 0, 100)== "!sb" or string.sub(text, 0, 100)== "/sb") then
		LMMSBSendMenu(ply, true)
		for k, v in pairs(player.GetAll()) do
			ply:ChatPrint(v:Nick().." "..v:SteamID64())
		end
		return ''
	end
end 
hook.Add("PlayerSay", "LMMSBOpenMenu", LMMSBOpenMenu)

concommand.Add( "+shoutbox", function(ply)
	LMMSBSendMenu(ply, true)
end)