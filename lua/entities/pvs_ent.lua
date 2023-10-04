AddCSLuaFile()

include("gspeak/tests/sh_simpleNWVar.lua")

ENT.Base = "base_entity"
ENT.Type = "anim"
ENT.Spawnable = true
ENT.PrintName = "PVS Ent"
ENT.Category = "Gspeak"
ENT.Author = "Thendon.exe"
ENT.Instructions = "Spawn and watch console"
ENT.Purpose = "Debug"
ENT.useSnwVars = true

local idcount = 0

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "NetworkVar" )
end

function ENT:Initialize()
    if SERVER then
        idcount = idcount + 1 --called before initialize
        self:SetValue(idcount)
    end

	self:SetModel( "models/gspeak/militaryradio.mdl" )
end

function ENT:Draw()
	self:DrawModel()
end

local serverSlowTick = 10
local clientSlowTick = 100
local tick = 0

function ENT:Think()
    if CLIENT then
        tick = tick + 1
        if (tick < clientSlowTick) then return end
        tick = 0

        local nw1 = self:GetNWInt("NW1")
        local nw2 = self:GetNW2Int("NW2")
        local snw = self:GetSNWInt("SNW")
        local nwv = self:GetNetworkVar()

        print(tostring(self) .. "\nnw1: " .. tostring(nw1) .. "\nnw2: " .. tostring(nw2) .. "\nsnw: " .. tostring(snw) .. "\nnwv: " .. tostring(nwv) .. "\n")
    end

    if SERVER then
        tick = tick + 1
        if (tick < serverSlowTick) then return end
        tick = 0

        self:SetValue(CurTime())
    end
end

if SERVER then
	function ENT:UpdateTransmitState()
        --return TRANSMIT_PVS --default
		return TRANSMIT_ALWAYS -- gspeak radios
	end
end

function ENT:SetValue(value)
    value = math.floor(value)

    self:SetNWInt("NW1", value)
    self:SetNW2Int("NW2", value)
    self:SetSNWInt("SNW", value)
    self:SetNetworkVar(value)
end