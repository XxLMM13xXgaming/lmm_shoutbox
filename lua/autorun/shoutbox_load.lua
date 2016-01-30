if (SERVER) then
	AddCSLuaFile("shoutbox_config.lua")
	include("shoutbox_config.lua")
	
	if !(file.Exists("lmm_shoutbox_data", "DATA")) then
		file.CreateDir("lmm_shoutbox_data", "DATA")
	end
	
	local message = [[
	
	-------------------------------
	| Shoutbox                    |
	| Made By: XxLMM13xXgaming    |
	| Project started: 1/28/2016  |
	| Version: 1.0                |
	-------------------------------
	
	]]
	MsgC(Color(140,0,255), message) 
end

if (CLIENT) then
	include("shoutbox_config.lua")

	local message = [[
	
	-------------------------------
	| Shoutbox                    |
	| Made By: XxLMM13xXgaming    |
	| Project started: 1/28/2016  |
	| Version: 1.0                |
	-------------------------------
	
	]]
	MsgC(Color(140,0,255), message) 
end