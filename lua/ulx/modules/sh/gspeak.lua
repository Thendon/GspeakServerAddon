AddCSLuaFile()

local CATEGORY_NAME = "Gspeak"

--MUTE

function ulx.gmute( calling_ply, target_plys )
	for i, target_ply in ipairs(target_plys) do
		ulx.fancyLogAdmin( calling_ply, "#A mutes #T in teamspeak", target_ply )
		target_ply:Mute()
	end
end

local muteCmd = ulx.command( CATEGORY_NAME, "ulx gmute", ulx.gmute, "!gmute" )
muteCmd:addParam{ type=ULib.cmds.PlayersArg }
--muteCmd:addParam{ type=ULib.cmds.NumArg, min=0, default=0, hint="xp", ULib.cmds.round }
muteCmd:defaultAccess( ULib.ACCESS_ADMIN )
muteCmd:help( "Mutes player in teamspeak server." )

--UNMUTE

function ulx.gunmute( calling_ply, target_plys )
	for i, target_ply in ipairs(target_plys) do
		target_ply:Unmute()
		ulx.fancyLogAdmin( calling_ply, "#A unmutes #T in teamspeak", target_ply )
	end
end

local unmuteCmd = ulx.command( CATEGORY_NAME, "ulx gunmute", ulx.gunmute, "!gunmute" )
unmuteCmd:addParam{ type=ULib.cmds.PlayersArg }
unmuteCmd:defaultAccess( ULib.ACCESS_ADMIN )
unmuteCmd:help( "Unmutes player in teamspeak server." )

--KICK

function ulx.gkick( calling_ply, target_plys )
	for i, target_ply in ipairs(target_plys) do
		target_ply:Kick()
		ulx.fancyLogAdmin( calling_ply, "#A kicks #T from teamspeak", target_ply )
	end
end

local kickCmd = ulx.command( CATEGORY_NAME, "ulx gkick", ulx.gkick, "!gkick" )
kickCmd:addParam{ type=ULib.cmds.PlayersArg }
kickCmd:defaultAccess( ULib.ACCESS_ADMIN )
kickCmd:help( "Kicks player from teamspeak server." )

--STARTSPEECH

function ulx.gstartspeech( calling_ply, target_plys )
	for i, target_ply in ipairs(target_plys) do
		target_ply:StartSpeech()
		target_ply:Unmute()
		ulx.fancyLogAdmin( calling_ply, "#T starts a speech", target_ply )
	end
end

local startSpeechCmd = ulx.command( CATEGORY_NAME, "ulx gstartspeech", ulx.gstartspeech, "!gstartspeech" )
startSpeechCmd:addParam{ type=ULib.cmds.PlayersArg }
startSpeechCmd:defaultAccess( ULib.ACCESS_ADMIN )
startSpeechCmd:help( "Player can be heart by everyone." )

--STOPSPEECH

function ulx.gstopspeech( calling_ply, target_plys )
	for i, target_ply in ipairs(target_plys) do
		target_ply:StopSpeech()
		ulx.fancyLogAdmin( calling_ply, "#T ends the speech", target_ply )
	end
end

local speechCmd = ulx.command( CATEGORY_NAME, "ulx gstopspeech", ulx.gstopspeech, "!gstopspeech" )
speechCmd:addParam{ type=ULib.cmds.PlayersArg }
speechCmd:defaultAccess( ULib.ACCESS_ADMIN )
speechCmd:help( "Player can be heart by everyone." )