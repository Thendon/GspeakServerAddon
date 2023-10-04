AddCSLuaFile()

local CATEGORY_NAME = "Gspeak"

--MUTE

function ulx.gmute( calling_ply, target_ply )
	ulx.fancyLogAdmin( calling_ply, "#A mutes #T", target_ply )
end

local muteCmd = ulx.command( CATEGORY_NAME, "ulx gmute", ulx.gmute, "!gmute" )
muteCmd:addParam{ type=ULib.cmds.PlayersArg }
--muteCmd:addParam{ type=ULib.cmds.NumArg, min=0, default=0, hint="xp", ULib.cmds.round }
muteCmd:defaultAccess( ULib.ACCESS_ADMIN )
muteCmd:help( "Mutes player in teamspeak server." )

--KICK

function ulx.gkick( calling_ply, target_ply )
	ulx.fancyLogAdmin( calling_ply, "#A kicks #T from teamspeak", target_ply )
end

local kickCmd = ulx.command( CATEGORY_NAME, "ulx gkick", ulx.gkick, "!gkick" )
kickCmd:addParam{ type=ULib.cmds.PlayersArg }
kickCmd:defaultAccess( ULib.ACCESS_ADMIN )
kickCmd:help( "Kicks player from teamspeak server." )

--SPEECH

function ulx.gspeech( calling_ply, target_ply )
	ulx.fancyLogAdmin( calling_ply, "#T holds a speech", target_ply )
end

local speechCmd = ulx.command( CATEGORY_NAME, "ulx gspeech", ulx.gspeech, "!gspeech" )
speechCmd:addParam{ type=ULib.cmds.PlayersArg }
speechCmd:defaultAccess( ULib.ACCESS_ADMIN )
speechCmd:help( "Player can be heart by everyone, every other player is muted" )