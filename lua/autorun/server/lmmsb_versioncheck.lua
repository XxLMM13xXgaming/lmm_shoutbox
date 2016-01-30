--[[You really should not edit this!]]--
local version = "1.1" -- DO NOT EDIT THIS!
local version_url = "https://gist.githubusercontent.com/XxLMM13xXgaming/123374fd244750553e66/raw/lmm_shoutbox" -- DO NOT EDIT THIS!
local update_url = "https://github.com/XxLMM13xXgaming/lmm_shoutbox" -- DO NOT EDIT THIS!
local msg_outdated = "You are using a outdated/un-supported version. You are on version "..version.."! go here to update: " .. update_url -- DO NOT EDIT THIS!
local ranksthatgetnotify = { "superadmin", "owner", "admin", "trial moderator", "moderator" } -- DO NOT EDIT THIS!

http.Fetch(version_url, function(body, len, headers, code, ply)
	if (string.Trim(body) ~= version) then
		MsgC( Color(255,0,0), "[Shoutbox] You are NOT using the latest version! ("..string.Trim(body)..")\n" )
	else
		MsgC( Color(255,0,0), "[Shoutbox] You are using the latest version! ("..version..")\n" )
	end
end )	
timer.Create("LMMSBVersionCheckServerTimer", 600, 0, function()
	http.Fetch(version_url, function(body, len, headers, code, ply)
		if (string.Trim(body) ~= version) then
			MsgC( Color(255,0,0), "[Shoutbox] You are NOT using the latest version! ("..string.Trim(body)..")\n" )
		end
	end )
end )
	 
hook.Add("PlayerInitialSpawn", "LMMSBVersionCheckServerTimer", function(ply)
	if (table.HasValue( ranksthatgetnotify, ply:GetUserGroup() ) ~= true) then return end
	
	http.Fetch(version_url, function(body, len, headers, code)

		if (string.Trim(body) ~= version) then
			ply:ChatPrint("[Shoutbox] "..msg_outdated)
			timer.Create( "LMMSBVersionCheckTimer", 600, 6, function()
				ply:ChatPrint("[Shoutbox] "..msg_outdated)
			end )
		else
			MsgC( Color(255,0,0), "[Shoutbox] You are using the latest version! ("..version..")\n" )
		end
		
	end, function(error)

		-- Silently fail

	end)
end)