
local function AddCSLuaDir(dir)
    dir = dir .. "/"
    local files, dirs = file.Find(dir.."*", "LUA")

    for k, file in ipairs(files) do
        if !string.EndsWith(file, ".lua") then continue end
		
		local fileSide = string.lower(string.Left(file , 3))
		if fileSide != "sh_" and fileSide != "cl_" then continue end

		AddCSLuaFile(dir..file)
		gspeak.ConsoleLog("add file "..dir..file)
    end
    
    for k, subdir in ipairs(dirs) do
        --print("[AUTOLOAD] Directory: " .. dir)
        AddCSLuaDir(dir..subdir)
    end
end

AddCSLuaDir("gspeak")

util.AddNetworkString( "ts_talking" )
util.AddNetworkString( "ts_talkmode" )
util.AddNetworkString( "ts_id" )
util.AddNetworkString( "ts_kick" )
util.AddNetworkString( "gspeak_server_settings" )
util.AddNetworkString( "gspeak_failed" )
util.AddNetworkString( "gspeak_failed_broadcast" )
util.AddNetworkString( "gspeak_init" )
util.AddNetworkString( "gspeak_request_init" )
util.AddNetworkString( "gspeak_setting_change" )
util.AddNetworkString( "gspeak_name_change" )
util.AddNetworkString( "radio_freq_change" )
util.AddNetworkString( "radio_sending_change" )
util.AddNetworkString( "radio_online_change" )
util.AddNetworkString( "radio_page_req" )
util.AddNetworkString( "radio_page_set" )
util.AddNetworkString( "radio_send_settings" )
util.AddNetworkString( "radio_init" )
util.AddNetworkString( "player_hears_player" )

include("gspeak/sv_player.lua")

//************************************************************//
//						FASTDL SETTINGS
//
//Uncomment the following code if you want to host the
//files all on your own FastDL.
//************************************************************//

--[[resource.AddFile("materials/gspeak/gspeak_off.png")
resource.AddFile("materials/gspeak/gspeak_error.png")
resource.AddFile("materials/gspeak/gspeak_loading.png")
resource.AddFile("materials/gspeak/gspeak_whisper.png")
resource.AddFile("materials/gspeak/gspeak_talk.png")
resource.AddFile("materials/gspeak/gspeak_yell.png")
resource.AddFile("materials/gspeak/gspeak_whisper_ui.png")
resource.AddFile("materials/gspeak/gspeak_talk_ui.png")
resource.AddFile("materials/gspeak/gspeak_yell_ui.png")
resource.AddFile("materials/gspeak/arrow_up.png")
resource.AddFile("materials/gspeak/arrow_down.png")
resource.AddFile("materials/gspeak/gspeak_logo_new.png")
resource.AddFile("materials/gspeak/gspeak2_logo.png")
resource.AddFile("materials/gspeak/gspeak_radio_back.png")
resource.AddFile("materials/gspeak/gspeak_logo.png")
resource.AddFile("materials/gspeak/radio/funktronics.vmt")
resource.AddFile("materials/gspeak/radio/MilitaryRadio.vmt")
resource.AddFile("materials/VGUI/entities/swep_radio.vmt")
resource.AddFile("materials/VGUI/entities/radio_cop.vmt")
resource.AddFile("materials/VGUI/entities/radio_fire.vmt")
resource.AddFile("materials/VGUI/entities/radio_taxi.vmt")
resource.AddFile("materials/VGUI/entities/radio_ems.vmt")
resource.AddFile("materials/VGUI/entities/radio_ent_station.vmt")
resource.AddFile("materials/VGUI/HUD/swep_radio.vmt")
resource.AddFile("materials/VGUI/HUD/radio_cop.vmt")
resource.AddFile("materials/VGUI/HUD/radio_fire.vmt")
resource.AddFile("materials/VGUI/HUD/radio_taxi.vmt")
resource.AddFile("materials/VGUI/HUD/radio_ems.vmt")
resource.AddFile("materials/VGUI/TTT/radio_d.vmt")
resource.AddFile("materials/VGUI/TTT/radio_t.vmt")
resource.AddFile("materials/VGUI/TTT/radio_d_s.vmt")
resource.AddFile("models/gspeak/militaryradio.mdl")
resource.AddFile("models/gspeak/funktronics.mdl")
resource.AddFile("models/gspeak/vfunktronics.mdl")
resource.AddFile("sound/gspeak/server/radio_click.mp3")
resource.AddFile("sound/gspeak/server/radio_release.mp3")
resource.AddFile("sound/gspeak/server/radio_booting.mp3")
resource.AddFile("sound/gspeak/server/radio_turnoff.mp3")
resource.AddFile("sound/gspeak/server/radio_booting_s.mp3")
resource.AddFile("sound/gspeak/server/radio_turnoff_s.mp3")
resource.AddFile("sound/gspeak/client/radio_click1.mp3")
resource.AddFile("sound/gspeak/client/radio_click2.mp3")
resource.AddFile("sound/gspeak/client/radio_beep1.mp3")
resource.AddFile("sound/gspeak/client/radio_beep2.mp3")
resource.AddFile("sound/gspeak/client/start_com.mp3")
resource.AddFile("sound/gspeak/client/end_com.mp3")
resource.AddFile("resource/fonts/capture it.ttf")]]

//************************************************************//
//Comment this out if you do not want to use the
//Workshop Collection.
//************************************************************//
resource.AddWorkshop( 533494097 )

//************************************************************//
//								FUNCTIONS
//************************************************************//

-- function gspeak:updateName( ply, name )
-- 	net.Start("gspeak_name_change")
-- 		net.WriteString( name )
-- 	net.Send(ply)
-- end

function gspeak:add_file(path, file)
	local new = true
	for i, j in pairs(gspeak.sounds.default) do
		if j .. ".mp3" == file then
			new = false
		end
	end

	if new then
		gspeak.ConsolePrint( "adding: " .. path .. file)
		resource.AddFile(path .. file)
	end
end

//************************************************************//
//								INITIALIZE
//************************************************************//

gspeak:VersionCheck()
gspeak:LoadSettings( gspeak.settings )

local files = file.Find("sound/" .. gspeak.sounds.path.sv .. "*", "GAME")
for k, v in pairs(files) do
	if v == "radio_booting_s" or v == "radio_turnoff_s" or v == "radio_click" or v == "radio_release" then
		gspeak:AddSound(gspeak.sounds.path.sv .. v, CHAN_ITEM, 1.0, 20)
	else
		gspeak:AddSound(gspeak.sounds.path.sv .. v)
	end
	gspeak:add_file(gspeak.sounds.path.sv, v)
end

local files = file.Find("sound/" .. gspeak.sounds.path.cl .. "*", "GAME")
for k, v in pairs(files) do
	gspeak:add_file(gspeak.sounds.path.cl, v)
end

//************************************************************//
//								NETCODE
//************************************************************//

net.Receive("radio_online_change",function( len, ply )
	local radio = net.ReadEntity()
	local online = !net.ReadBool()
	radio:SetOnline(online)
	if online then
		radio:EmitSound("radio_booting")
	else
		radio:EmitSound("radio_turnoff")
	end
end)

net.Receive("radio_freq_change", function( len, ply )
	local radio = net.ReadEntity()
	local isSwep = net.ReadBool()
	local freq = net.ReadInt( 32 )
	if isSwep then
		radio.ent:SetFreq(freq)
	else
		radio:SetFreq(freq)
	end
end)

net.Receive("radio_sending_change", function( len, ply )
	local radio = net.ReadEntity()
	local sending = net.ReadBool()

	if !radio or !IsValid(radio) or !radio:IsRadio() then return end

	radio:SetSending( sending )

	if radio:GetParent().silent then return end

	local now = CurTime()
	if sending and radio.last_sound < now - 0.1 then
		radio:EmitSound("radio_click")
		radio.last_sound = now
	elseif radio.last_sound < now - 0.1 then
		radio:EmitSound("radio_release")
		radio.last_sound = now
	end
end)

net.Receive("radio_init", function( len, ply )
	local radio = net.ReadEntity()
	if !gspeak:radio_valid(radio) then return end
	radio:SendSettings(ply)
end)

net.Receive("gspeak_failed", function( len, ply )
	net.Start( "gspeak_failed_broadcast" )
		net.WriteEntity(ply)
	net.Broadcast()
end)

net.Receive("gspeak_request_init", function( len, ply )
	net.Start( "gspeak_init" )
		net.WriteTable(gspeak.settings)
	net.Send( ply )
end)

net.Receive("gspeak_setting_change", function(len, ply)
	local setting = net.ReadTable()
	if (setting.name == "password") then
		setting.value = tostring(setting.value)
	end

	gspeak:ChangeSetting(string.Explode( ".", setting.name ), gspeak.settings, setting.name, setting.value)
end)

net.Receive("radio_page_req", function(len, ply)
	local radio = net.ReadEntity()
	local page = net.ReadInt(3)
	if !gspeak:radio_valid(radio) then return end
	radio.menu.page = page
	net.Start("radio_page_set")
		net.WriteEntity(radio)
		net.WriteInt(page, 3)
	net.Broadcast()
end)

//************************************************************//
//								HOOKS
//************************************************************//

concommand.Add("gspeak_assign_tsid", function(ply, cmd, args, argStr)
	if (ply != nil && ply:IsValid() && !ply:IsSuperAdmin()) then return end

	local playerName = args[1]
	local tsId = args[2]

	for i, ply in ipairs(player.GetBots()) do
		if (ply:GetName() != playerName) then continue end

		ply:SetTalkmode(3)
		ply:SetTsId(tsId)
		return
	end

	gspeak.ConsoleWarning("debug code, pls comment me out")
	for i, ply in ipairs(player.GetAll()) do
		if (ply:GetName() != playerName) then continue end

		ply:SetTalkmode(3)
		ply:SetTsId(tsId)
		return
	end
end)