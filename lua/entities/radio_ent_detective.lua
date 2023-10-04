AddCSLuaFile()

ENT.Base = "base_entity"
ENT.Type = "anim"
ENT.Spawnable = false
ENT.PrintName = "Stational Radio"
ENT.Category = "Gspeak"
ENT.Author = "Thendon.exe & Kuro"
ENT.Instructions = "Hold E to talk"
ENT.Purpose = "Talk!"

function ENT:Initialize()
	//Own Changeable Variables
	self.online = true --Online when picked up (default = true)
	self.freq = 1201 --Default frequency (devide 10 or default = 900)
	self.locked_freq = true --Should the frequency be locked? if true you don't have to put values into freq min and max
	self.freq_min = 800 --Min frequency (default = 800)
	self.freq_max = 1200 --Max frequency (default = 900)
	self.range = 150 --Default Range
	self.locked_range = true --Should the volume/range be locked? If true you don't have to put values into range min and max
	self.range_min = 100 --Min range (default = 100)
	self.range_max = 300 --Max range (default = 300)

	self:StationInitialize()
end

include("gspeak/entities/sh_def_station.lua")
