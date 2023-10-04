

surface.CreateFont("CaptureItBug", {font = "Capture it", size = 100 } )
surface.CreateFont("CaptureItSmall", {font = "Capture it", size = 40 } )
surface.CreateFont("CaptureItTiny", {font = "Capture it", size = 20 } )
surface.CreateFont("TnfBig", {font = "thenextfont", size = 100 } )
surface.CreateFont("TnfSmall", {font = "thenextfont", size = 40 } )
surface.CreateFont("TnfTiny", {font = "thenextfont", size = 20 } )

if (gspeak.cl != nil) then 
	gspeak.io:Disconnect() 
end

gspeak.cl = {
	materials = {
		off = Material( "gspeak/gspeak_off.png", "noclamp unlitgeneric" ),
		error = Material( "gspeak/gspeak_error.png", "noclamp unlitgeneric" ),
		loading = Material( "gspeak/gspeak_loading.png", "noclamp unlitgeneric" ),
		logo = Material( "gspeak/gspeak_logo.png", "noclamp unlitgeneric" ),
		radio_back = Material( "gspeak/gspeak_radio_back.png", "noclamp unlitgeneric" ),
		default_icon = Material("gspeak/gspeak_yell.png", "noclamp unlitgeneric"),
		default_icon_ui = Material("gspeak/gspeak_yell_ui.png", "noclamp unlitgeneric"),
		circle = Material("gspeak/circlemenu.png", "noclamp unlitgeneric"),
	},
	tmm = {
		selected = 1,
		active = false
	},
	players = {},
	radios = {},
	settings = {},
	running = false,
	failed = false,
	--start_talking = false,
	tm_tab = 0,
	tslib = {
		version = 0,
		req = 2500,
		max = 3100,
		wrongVersion = false
	},
	TS = {
		version = 0,
		req = 2500,
		max = 3100,
		connected = false,
		inChannel = false,
		failed = false
	},
	loadanim = {
		state = {0, 0, 0, 0},
		dir = 1,
		active = 1
	},
	player = {
		standing = Vector(0,0,60),
		crouching = Vector(0,0,40),
		dead = Vector(0,0,0),
		vehicle = Vector(0,0,30)
	},
	deadMuted = false,
	color = {
		red = Color( 231, 76, 60, 255),
		green = Color( 46, 204, 113, 255 ),
		blue = Color( 52, 152, 219, 255 ),
		black = Color( 44, 62, 80, 255 ),
		white = Color( 255, 255, 255, 255 ),
		yellow = Color( 241, 196, 15, 255 )
	}
}

include("vgui/gspeak_ui.lua")

//************************************************************//
//								Utils
//************************************************************//

function gspeak:NoDoubleEntry(variable, Table)
	for k, v in pairs(Table) do
		if v == variable then return end
	end
	table.insert(Table, variable)
end

//************************************************************//
//								INITIALIZE
//************************************************************//

gspeak:VersionCheck()
--handled after net init was called
--gspeak:LoadSettings( gspeak.cl.settings )

local files = file.Find("sound/" .. gspeak.sounds.path.cl .. "*","DOWNLOAD")
local workshop = file.Find("sound/" .. gspeak.sounds.path.cl .. "*","WORKSHOP")
table.Add (files, workshop)

for k, v in pairs(files) do
	gspeak:AddSound(gspeak.sounds.path.cl .. v)
end

hook.Add("OnEntityCreated", "ent_array", function( ent )
	if ent:IsPlayer() then
		gspeak:NoDoubleEntry( ent, gspeak.cl.players )
	end
end)

hook.Add("InitPostEntity", "gspeak_initialization", function()
    gspeak:request_init()
    --[[
    local old_voice = GAMEMODE.PlayerStartVoice
    function GAMEMODE.PlayerStartVoice( _, ply )
        if gspeak.settings.overrideV then return false end
        return old_voice( ply )
    end
    ]]
end)

function gspeak:SetDefaultVars()
	if !gspeak.cl.settings.talkmode then
		gspeak.cl.settings.talkmode = gspeak.settings.def_mode
		gspeak:ChangeSetting( { "talkmode" }, gspeak.cl.settings, "talkmode", gspeak.settings.def_mode )
	end
	if !gspeak.cl.settings.key then
		gspeak.cl.settings.key = gspeak.settings.def_key
		gspeak:ChangeSetting( { "key" }, gspeak.cl.settings, "key", gspeak.settings.def_key )
	end
	if !gspeak.cl.settings.radio_key then
		gspeak.cl.settings.radio_key = gspeak.settings.radio.def_key
		gspeak:ChangeSetting( { "radio_key" }, gspeak.cl.settings, "radio_key", gspeak.settings.radio.def_key )
	end
	if !gspeak.cl.settings.deadVolume then
		gspeak.cl.settings.deadVolume = gspeak.settings.def_deadVolume
		gspeak:ChangeSetting( { "deadVolume" }, gspeak.cl.settings, "deadVolume", gspeak.settings.def_deadVolume )
	end
end

net.Receive("gspeak_server_settings", function()
	local setting = net.ReadTable()
	gspeak.settings[setting.name] = setting.value
	gspeak:RefreshIcons()
	if gspeak.cl.TS.connected then gspeak.io:SendSettings() end
end)

net.Receive("gspeak_init", function( len )
	gspeak.settings = net.ReadTable()

	--cast icon picture to material and save it
	gspeak:RefreshIcons()
	gspeak:LoadSettings( gspeak.cl.settings )
	gspeak:SetDefaultVars()
	if gspeak.cl.TS.connected then gspeak.io:SendSettings() end

	gspeak.io:Load()
end)

include("gspeak/io/cl_iohandler.lua")
include("gspeak/cl_player.lua")
include("gspeak/cl_input.lua")
include("gspeak/cl_input.lua")
include("gspeak/cl_radio.lua")
include("gspeak/cl_animations.lua")
include("gspeak/cl_connection.lua")
include("gspeak/cl_volume_control.lua")
include("gspeak/ui/cl_wgui.lua")