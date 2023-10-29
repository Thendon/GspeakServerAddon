--WIP not working at all
--prefere this type of registering type beforehand but what do i know

if CLIENT then
    local entMeta = FindMetaTable("Entity")

    function entMeta:InitializeNetworking()
        for key, snwVar in pairs(self.snwVars) do
            local value = snwVar:Read()
            self:SetSNWVar(key, value)
        end
    end

    function entMeta:SNWChanged()
        local key = net.ReadString()
        if (!self.snwVars[key]) then
            error("[SNW] unexpected key " .. tostring(key))
        end

        --local type = net.ReadUInt()
        --local type = self.snwVars[key].type
        
        local value = self.snwVars[key]:Read()
        self:SetSNWVar(key, value)
    end

    hook.Add("OnEntityCreated", "SNW.SignalEntityReady", function(ent)
        net.Start("SNW.EntityReadyForNetworking")
        net.WriteEntity(ent)
        net.SendToServer()
    end)

    net.Receive("SNW.InitializeEntityNetworking", function(len)
        local ent = net.ReadEntity()
        if (!IsValid(ent)) then return end

        ent:InitializeNetworking()
    end)

    net.Receive("SNW.EntitySNWChanged", function (len))
        local ent = net.ReadEntity()
        if (!IsValid(ent)) then return end

        ent:SNWChanged()
    end)
end

if SERVER then
    util.AddNetworkString( "SNW.EntityReadyForNetworking" )
    util.AddNetworkString( "SNW.InitializeEntityNetworking" )
    util.AddNetworkString( "SNW.InitializedEntityNetworking" )
    util.AddNetworkString( "SNW.EntitySNWChanged" )

    local entMeta = FindMetaTable("Entity")
    entMeta.initializedForPlayers = {}

    function entMeta:InitializeNetworkingForPlayer(ply)
        if (self.initializedForPlayers[ply]) then
            print("[SNW] ERR: Entity " .. tostring(ent) .. " already initialized for ply " .. tostring(ply))
            return
        end

        net.Start("SNW.InitializeEntityNetworking")
        net.WriteEntity(self)
        for key, snwVar in pairs(self.snwVars) do
            --net.WriteString(key)
            snwVar:Write()
        end
        --add all snw vars
        net.Send(ply)

        self.initializedForPlayers[ply] = true
    end

    net.Receive("SNW.EntityReadyForNetworking", function(len, ply)
        local ent = net.ReadEntity()
        if (!IsValid(ent)) then return end

        ent:InitializeForPlayer(ply)
    end)

    -- hook.Add("PlayerDisconnected", "SNW.PlayerDisconnected", function(ply)
    --     for i, ent in ipairs(ents.GetAll()) do
    --         ent:
    --     end
    -- end)
end

if true then
    SNW_BOOL = 0
    SNW_INTEGER = 1

    local entMeta = FindMetaTable("Entity")
    entMeta.snwVars = {} --wont work in meta table

    --meh should work as before, so no reg
    function entMeta:RegisterSNWVar(key, type, defaultValue)
        if (self.snwVars[key]) then
            print("[SNW] double registration of snw " .. tostring(key) .. " " .. tostring(type))
            return
        end
        
        local snwVar = {}
        --snwVar.ent = self
        --snwVar.key = key
        snwVar.value = defaultValue
        snwVar.type = type
        if (type == SNW_BOOL) then
            snwVar.Write = function()
                net.WriteBool(self.value)
            end
            snwVar.Read = function()
                return net.ReadBool()
            end
        elseif (type == SNW_INTEGER) then
            snwVar.Write = function()
                net.WriteInt(self.value)
            end
            snwVar.Read = function()
                return net.ReadInt()
            end
        end

        self.snwVars[key] = snwVar
    end

    function entMeta:SetSNWVar(key, value)
        if (!ValidateSNWRegistered(key)) then return end
        
        local prev = self.snwVars[key].value
        self.snwVars[key].value = value

        if (SERVER) then
            net.Start("SNW.EntitySNWChanged")
            net.WriteEntity(self)
            net.WriteString(key)
            self.snwVars[key]:Write()
            net.Broadcast()
        end
    end

    function entMeta:GetSNWVar(key)
        if (!ValidateSNWRegistered(key)) then return end

        return self.snwVars[key].value
    end

    function entMeta:ValidateSNWRegistered(key)
        if (!self.snwVars[key]) then
            error("[SNW] unexpected snw key " .. tostring(key))
            return false
        end

        return true
    end

    function entMeta:ValidateSNWVar(key, value, type, validator)
        if (!self:ValidateSNWRegistered(key))
            return false
        end

        if (!self.snwVars[key].type != type) then 
            error("[SNW] unexpected value type " .. tostring(key) .. " " .. tostring(self.snwVars[key].type))
            return false
        end

        if (typevalidator != nil && !validator(value)) then 
            error("[SNW] unexpected value type " .. tostring(key) .. " " .. tostring(value))
            return false
        end

        return true
    end

    function entMeta:SetSNWBool(key, value)
        if (!self:ValidateSNWVar(key, value, SNW_BOOL, function() return isbool(value) end)) then return end
        
        self:SetSNWVar(key, value)
    end

    function entMeta:GetSNWBool(key)
        if (!self:ValidateSNWVar(key, value, SNW_BOOL)) then return end

        return self:GetSNWVar(key)
    end

    function entMeta:SetSNWInt(key, value)
        if (!self:ValidateSNWVar(key, value, SNW_INTEGER, function() return isnumber(value) end)) then return end
        
        self:SetSNWVar(key, math.floor(value))
    end

    function entMeta:GetSNWInt(key)
        if (!self:ValidateSNWVar(key, value, SNW_INTEGER)) then return end

        return self:GetSNWVar(key)
    end
end