//************************************************************//
//
//	Gspeak by Thendon.exe
//	
//	Thanks Sanuye for teaching me c++
//	Thanks El-Marto for his artwork
//	Thanks Zigi for helping me creating the Easy-Installer
//	Thanks Kuro for his 3D-Models
//	Thanks Nockich for your advise
//	Thanks Rataj for improoving the plugin
//	and Thanks to all Betatesters, Servers
//
//************************************************************//

AddCSLuaFile()
gspeak = { version = 3000 };

//************************************************************//
// Change these Variables ingame by entering !gspeak if possible
//************************************************************//

--Setting Default variables
gspeak.settings = {
	distances = {
		modes = {
			{	name = "Whisper", range = 150, icon = "gspeak/gspeak_whisper.png", icon_ui = "gspeak/gspeak_whisper_ui.png" },
			{	name = "Talk", range = 450, icon = "gspeak/gspeak_talk.png", icon_ui = "gspeak/gspeak_talk_ui.png" },
			{	name = "Yell", range = 900, icon = "gspeak/gspeak_yell.png", icon_ui = "gspeak/gspeak_yell_ui.png" },
		},
		heightclamp = 0.75,
		iconview = 1000,
		radio = 150
	},
	HUD = {
		console = {	x = 0.02,	y = 0.06,	align = "tr" },
		status = { x = 0.02, y = 0.02, align = "br" }
	},
	def_mode = 2,
	cmd =  "!gspeak",
	def_key = KEY_LALT,
	head_icon = true,
	head_name = false,
	reminder = true,
	ts_ip = "0.0.0.0",
	radio = {
		down = 4,
		dist = 1500,
		volume = 1.5,
		noise = 0.01,
		start = "start_com",
		stop = "end_com",
		hearable = true,
		use_key = true,
		def_key = KEY_CAPSLOCK
	},
	password = "",
	overrideV = false,
	overrideC = false,
	dead_chat = false,
	dead_alive = false,
	auto_fastdl = true,
	trigger_at_talk = false,
	nickname = true,
	def_initialForceMove = true,
	updateName = false
}

gspeak.sounds = {
	names = {},
	path = { cl = "gspeak/client/", sv = "gspeak/server/" },
	default = { "end_com", "radio_beep1", "radio_beep2", "radio_click1",
							"radio_click2", "start_com", "radio_booting", "radio_booting_s",
							"radio_click", "radio_release", "radio_turnoff", "radio_turnoff_s" }
}

local meta = FindMetaTable("Entity")
function meta:IsRadio()
	return self.Radio and true or false
end

include("gspeak/sh_logging.lua")

function gspeak:add_sound(path, channel, volume, level, pitch)
	local _, _, name = string.find(path, "/.+/(.+)[.]")
	channel = channel or CHAN_ITEM
	volume = volume or 1.0
	level = level or 60
	pitch = pitch or 100

	sound.Add( {
	  name = name,
	  channel = channel,
	  volume = volume,
	  level = level,
	  pitch = pitch,
	  sound = path
	} )

	table.insert(gspeak.sounds.names, name )
end

function gspeak:player_valid(ply)
	return ply and IsValid( ply ) and ply:IsPlayer()
end

function gspeak:radio_valid(radio)
	return radio and IsValid( radio ) and radio:IsRadio()
end

function gspeak:get_talkmode_range(talkmode)
	if talkmode > #gspeak.settings.distances.modes then return 0 end
	local mode = gspeak.settings.distances.modes[talkmode]
	if !mode then return 0 end
	return mode.range
end

include("gspeak/sh_settings.lua")

if SERVER then
	include( "gspeak/sv_gspeak_run.lua" )
else
	include( "gspeak/cl_gspeak_run.lua" )
end
