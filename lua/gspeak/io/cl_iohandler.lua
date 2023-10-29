

local tslibHandler = include("gspeak/io/cl_tslib.lua")
-- local sqliteHandler = include("gspeak/io/cl_sqlite.lua")
-- local filestreamHandler = include("gspeak/io/cl_filestream.lua")

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

function gspeak.io:Kick()
    tslibHandler:Kick()
end

function gspeak.io:Join()
    tslibHandler:Join()
end

function gspeak.io:Disconnect()
    tslibHandler:Disconnect()
end

function gspeak.io:SetHearable(tsId, volume, pos, effect)
    return tslibHandler:SetHearable(tsId, volume, pos, effect)
end

function gspeak.io:RemoveHearable(tsId)
    return tslibHandler:RemoveHearable(tsId)
end

function gspeak.io:GetHearableData(tsId)
    return tslibHandler:GetHearableData(tsId)
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

function gspeak.io:IsInChannel()
    return tslibHandler:IsInChannel()
end

function gspeak.io:GetTsId()
    return tslibHandler:GetTsId()
end

function gspeak.io:GetHearables()
    return tslibHandler:GetHearables()
end

-- function gspeak.io:Tick()
--     tslibHandler:Tick()
-- end