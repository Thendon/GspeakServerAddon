--theoretically working
--proxy missing though
--and every type besides bool and int

AddCSLuaFile()

local SNWVar = {}
SNWVar.__index = SNWVar

function SNWVar:new(key, type, value)
    local snwVar = {}
    setmetatable(snwVar, SNWVar)
    snwVar.key = key
    snwVar.type = type
    snwVar.value = value

    return snwVar
end

setmetatable( SNWVar, {__call = SNWVar.new } )

local function validateType(type, value)
    if (type == SNW_BOOL) then return isbool(value) end
    if (type == SNW_INTEGER) then return isnumber(value) end
end

local function registerSNWVar(ent, key, type, value)
    ent.snwVars[key] = SNWVar(key, type, value)
end

local function validateSNWVar(ent, key, type, allowRegistration, value)
    if !ent.useSnwVars then error("[SNW] system disabled for this entity (use ENT.useSnwVars = true to enable system)") end

    if (ent.snwVars == nil) then
        ent.snwVars = {}
    end

    if (value != nil && !validateType(type, value)) then
        error("[SNW] unexpected value type " .. tostring(key))
        return false
    end

    if (ent.snwVars[key] == nil) then
        if (!allowRegistration) then return false end

        registerSNWVar(ent, key, type, value)
    end

    if (ent.snwVars[key].type != type) then 
        error("[SNW] unexpected value type " .. tostring(key) .. " " .. tostring(ent.snwVars[key].type) .. " passed " .. tostring(type))
        return false
    end

    return true
end

local function readSNWVar(ent)
    local key = net.ReadString()
    local type = net.ReadInt(4)
    local value = nil

    if (!validateSNWVar(ent, key, type, true)) then return nil end

    if (type == SNW_BOOL) then 
        value = net.ReadBool()
    elseif (type == SNW_INTEGER) then 
        value = net.ReadInt(32) 
    end
    
    return SNWVar(key, type, value)
end

local function writeSNWVar(snwVar)
    net.WriteString(snwVar.key)
    net.WriteInt(snwVar.type, 4)
    if (snwVar.type == SNW_BOOL) then 
        net.WriteBool(snwVar.value)
    elseif (snwVar.type == SNW_INTEGER) then 
        net.WriteInt(snwVar.value, 32) 
    end
end

if CLIENT then
    --local entMeta = FindMetaTable("Entity")

    local function snwChanged(ent)
        local snwVar = readSNWVar(ent)
        
        if (snwVar == nil) then return end

        ent:SetSNWVar(snwVar.key, snwVar.value)
    end

    local function initializeNetworking(ent)
        local count = net.ReadInt(16)
        for i = 1, count do
            snwChanged(ent)
        end
        ent.snwInitialized = true
    end

    hook.Add("OnEntityCreated", "SNW.SignalEntityReady", function(ent)
        if (!ent.useSnwVars) then return end
        if (ent.snwInitialized) then return end

        net.Start("SNW.EntityReadyForNetworking")
        net.WriteEntity(ent)
        net.SendToServer()
    end)

    net.Receive("SNW.InitializeEntityNetworking", function(len)
        local ent = net.ReadEntity()
        --print("InitializeEntityNetworking " .. tostring(ent))
        if (!IsValid(ent)) then return end

        initializeNetworking(ent)
    end)

    net.Receive("SNW.EntitySNWChanged", function (len)
        local ent = net.ReadEntity()
        --print("EntitySNWChanged " .. tostring(ent))
        if (!IsValid(ent)) then return end

        snwChanged(ent)
    end)
end

if SERVER then
    util.AddNetworkString( "SNW.EntityReadyForNetworking" )
    util.AddNetworkString( "SNW.InitializeEntityNetworking" )
    util.AddNetworkString( "SNW.InitializedEntityNetworking" )
    util.AddNetworkString( "SNW.EntitySNWChanged" )

    function initializeNetworkingForPlayer(ent, ply)
        if !ent.useSnwVars then return end

        if (ent.initializedForPlayers == nil) then
            ent.initializedForPlayers = {}
        end
        
        if (ent.initializedForPlayers[ply]) then
            print("[SNW] ERR: Entity " .. tostring(ent) .. " already initialized for ply " .. tostring(ply))
            return
        end

        net.Start("SNW.InitializeEntityNetworking")
        net.WriteEntity(ent)
        net.WriteInt(table.Count(ent.snwVars), 16)
        for key, snwVar in pairs(ent.snwVars) do
            writeSNWVar(snwVar)
        end
        --add all snw vars
        net.Send(ply)

        ent.initializedForPlayers[ply] = true
    end

    function removeNetworkingForPlayer(ent, ply)
        if !ent.useSnwVars then return end

        ent.initializedForPlayers[ply] = nil
    end

    net.Receive("SNW.EntityReadyForNetworking", function(len, ply)
        local ent = net.ReadEntity()

        if (!IsValid(ent)) then return end

        initializeNetworkingForPlayer(ent, ply)
    end)

    hook.Add("PlayerDisconnected", "SNW.PlayerDisconnected", function(ply)
        for i, ent in ipairs(ents.GetAll()) do
            removeNetworkingForPlayer(ent, ply)
        end
    end)
end

if true then
    SNW_BOOL = 0
    SNW_INTEGER = 1

    local entMeta = FindMetaTable("Entity")

    local function transmitSNVVarChange(ent, key)
        local transmitState = ent:UpdateTransmitState()

        if (transmitState == TRANSMIT_NEVER) then return end
        
        net.Start("SNW.EntitySNWChanged")
        net.WriteEntity(ent)
        writeSNWVar(ent.snwVars[key])

        if (transmitState == TRANSMIT_ALWAYS) then
            net.Broadcast()
        elseif (transmitState == TRANSMIT_PVS) then
            net.SendPVS(ent:GetPos())
        end
    end

    function entMeta:SetSNWVar(key, value)
        local prev = self.snwVars[key].value
        self.snwVars[key].value = value

        if (SERVER) then
            transmitSNVVarChange(self, key)
        end
    end

    function entMeta:GetSNWVar(key)
        return self.snwVars[key].value
    end

    function entMeta:SetSNWBool(key, value)
        if (!validateSNWVar(self, key, SNW_BOOL, true, value)) then return end
        
        self:SetSNWVar(key, value)
    end

    function entMeta:GetSNWBool(key)
        if (!validateSNWVar(self, key, SNW_BOOL, false)) then return end

        return self:GetSNWVar(key)
    end

    function entMeta:SetSNWInt(key, value)
        if (!validateSNWVar(self, key, SNW_INTEGER, true, value)) then return end
        
        self:SetSNWVar(key, math.floor(value))
    end

    function entMeta:GetSNWInt(key)
        if (!validateSNWVar(self, key, SNW_INTEGER, false)) then return end

        return self:GetSNWVar(key)
    end
end