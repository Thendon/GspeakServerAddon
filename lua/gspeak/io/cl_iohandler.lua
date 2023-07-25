//************************************************************//
//							GSPEAK IOHandler
//************************************************************//

local tslibHandler = include("gspeak/io/cl_tslib.lua")
local sqliteHandler = include("gspeak/io/cl_sqlite.lua")
local filestreamHandler = include("gspeak/io/cl_filestream.lua")

gspeak.io = {}

function gspeak.io:Load()
    tslibHandler:LoadTslib()
end

function gspeak.io:SendSettings()
    tslibHandler:SendSettings()
end

function gspeak.io:CheckConnection()
    tslibHandler:CheckConnection()
end

function gspeak.io:SetPlayer(tsId, volume, playerIndex, pos, isEntity, entityIndex)
    tslibHandler:SetPlayer(tsId, volume, playerIndex, pos, isEntity, entityIndex)
end

function gspeak.io:RemovePlayer(playerIndex, isEntity, entityIndex)
    tslibHandler:RemovePlayer(playerIndex, isEntity, entityIndex)
end

function gspeak.io:SetLocalPlayer(forward, up)
    tslibHandler:SetLocalPlayer(forward, up)
end

function gspeak.io:SendName(name)
    tslibHandler:SendName(name)
end

function gspeak.io:IsTalking()
    return tslibHandler:IsTalking()
end