
AddCSLuaFile()

gspeak = gspeak or {}
gspeak.version = 3100

//************************************************************//
// Change these Variables ingame by entering 
// !gspeak in chat or gspeak in console
//************************************************************//

--Setting Default variables
gspeak.default_settings = {
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
	joinCmd = "!gjoin",
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
	water = {
		scale = 100,
		smooth = 0.999,
		boost = 1.0
	},
	wall = {
		scale = 50,
		smooth = 0.5,
		boost = 1.0
	},
	password = "",
	channelName = "",
	overrideV = false,
	overrideC = false,
	deadHearsDead = false,
	deadHearsAlive = true,
	auto_fastdl = true,
	trigger_at_talk = false,
	nickname = true,
	def_initialForceMove = true,
	updateName = false,
	def_deadVolume = 0.9
}

gspeak.settings = table.Copy(gspeak.default_settings)

gspeak.sounds = {
	names = {},
	path = { cl = "gspeak/client/", sv = "gspeak/server/" },
	default = { "end_com", "radio_beep1", "radio_beep2", "radio_click1",
							"radio_click2", "start_com", "radio_booting", "radio_booting_s",
							"radio_click", "radio_release", "radio_turnoff", "radio_turnoff_s" }
}

gspeak.voiceEffects = {
	None = 0,
	Radio = 1,
	Water = 2,
	Wall = 3,
	//Dead = 4
}

local meta = FindMetaTable("Entity")

function meta:IsRadio()
	return self.Radio and true or false
end

function meta:IsGspeakEntity()
	return self.GspeakEntity and true or false
end

include("gspeak/sh_logging.lua")

function gspeak:AddSound(path, channel, volume, level, pitch)
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

function gspeak:GetTalkmodeRange(talkmode)
	if talkmode <= 0 || talkmode > #gspeak.settings.distances.modes then return -1 end
	local mode = gspeak.settings.distances.modes[talkmode]
	return mode.range
end

include("gspeak/sh_settings.lua")

if SERVER then
	include( "gspeak/sv_gspeak_run.lua" )
else
	include( "gspeak/cl_gspeak_run.lua" )
end
