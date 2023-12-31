SWEP.Category = "Gspeak"
SWEP.Author = "Thendon.exe & Kuro"
SWEP.Instructions = "Left Click - Turn ON/OFF\nRight Click - Open frequency UI\nCAPSLOCK - Default Talk Key\n!gspeak for config"
SWEP.Purpose = "Talk!"
SWEP.ViewModel = Model( "models/gspeak/vfunktronics.mdl" )
SWEP.ViewModelFOV = 56
SWEP.WorldModel = Model( "models/gspeak/funktronics.mdl" )
SWEP.BounceWeaponIcon = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Secondary.Ammo	= "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false

SWEP.UseHands = false
SWEP.HoldType = "slam"

function SWEP:DefaultInitialize()
	--self.last_think = 0
	self.deployed = false

	self:SetWeaponHoldType( self.HoldType )

	if SERVER then
		self.ent = ents.Create( "radio_ent" )
		self.ent:SetModel( self.WorldModel )
		self.ent:SetPos( self:GetPos() )
		self.ent:SetParent( self )
		self.ent:SetFreq( self.freq )
		self.ent:Spawn()
		self.ent:SetOnline(self.online)
		self.ent:SetHearable(self.show_hearable)
		self.ent:SetRange( self.range )
		self.ent.settings = { 
			trigger_at_talk = self.trigger_at_talk, 
			start_com = self.start_com, 
			end_com = self.end_com 
		}

		self:DeleteOnRemove( self.ent )
	end
end

function SWEP:OwnerChanged()
	if SERVER then
		self.ent:SetOwner( self:GetOwner() )
		self.ent:SetSpeaker( self:GetOwner() )
	end
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:Holster( wep )
	self.deployed = false
	if SERVER and !gspeak.settings.radio.use_key then
		self.ent:SetSending( false )
	end
	return true
end

function SWEP:Deploy( wep )
	self.deployed = true
	if SERVER and !gspeak.settings.radio.use_key  then
		self.ent:SetSending( true )
	end
	return true
end

function SWEP:DrawWorldModel()
	if !IsValid(self.Owner) then
		self:DrawModel()
		return
	end
	self.deployed = true
end

function SWEP:PostDrawViewModel(vm, weapon, ply)
	local vm_pos = vm:GetPos()
	local ang = vm:GetAngles()
	local x = 0
	local y = 0

	local offset = ang:Forward() * 6.44 + ang:Right() * 2.14 + ang:Up() * (-1.3)
	local white = Color(255,255,255,255)
	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Right(), 90)
	ang:RotateAroundAxis(ang:Up(), 0)
	cam.Start3D2D(vm_pos + offset, ang+Angle(-0.5,0,0), 0.01)
	local alpha = 255
	if !self.online then alpha = 100 end
	surface.SetDrawColor(alpha,alpha,alpha,255)
	surface.SetMaterial(gspeak.cl.materials.radio_back)
	surface.DrawTexturedRect(x-15,y-37,170,170)
	if self.online && self.ent then
		draw.DrawText( "Frequency", "BudgetLabel", x, y, white, TEXT_ALIGN_LEFT )
		draw.DrawText( tostring(self.freq/10), "BudgetLabel", x+140, y, white, TEXT_ALIGN_RIGHT )
		y = y + 7
		if self.show_hearable then
			draw.DrawText( "--------------------", "BudgetLabel", x, y, white, TEXT_ALIGN_LEFT)
			y = y + 7
			for k, v in pairs(self.ent.connected_radios) do
				if k == 7 then break end
				if gspeak:radio_valid(Entity(v)) then
					local speaker = Entity(v):GetSpeaker()
					if gspeak:player_valid(speaker) then
						draw.DrawText( string.sub(Entity(v):GetSpeaker():GetTeamspeakName(),1,14), "BudgetLabel", x, y, white, TEXT_ALIGN_LEFT )
						local status = "idl"
						if Entity(v):GetSpeaker():IsTalking() then status = "inc" end
						draw.DrawText( "| "..status, "BudgetLabel", x+140, y, white, TEXT_ALIGN_RIGHT )
						y = y + 10
					end
				end
			end
		end
	end
	cam.End3D2D()
end

function SWEP:PrimaryAttack()
	if (!IsFirstTimePredicted()) then return end

	self.online = !self.online
	if SERVER then
		if !self.silent then 
			if (self.online) then 
				self.ent:EmitSound("radio_booting_s")
			else 
				self.ent:EmitSound("radio_turnoff_s") 
			end
		end
		self.ent:SetOnline(self.online)
	end

	self:SetNextPrimaryFire( CurTime() + 0.2 )
end

function SWEP:SecondaryAttack()
	if (!IsFirstTimePredicted()) then return end
	if self.locked_freq == true then return end
	if CLIENT then self:open_settings() end

	self:SetNextSecondaryFire( CurTime() + 0.2 )
end

-- function SWEP:checkThink( now )
-- 	if self.last_think < now - 0.2 then
-- 		self.last_think = now
-- 		return false
-- 	end
-- 	return true
-- end

function SWEP:ShouldDropOnDie()
	return true
end

function SWEP:OnDrop()
	self:OwnerChanged()
end

function SWEP:Equip()
	self:OwnerChanged()
end

local function frequencySlider( panel )
	local panel_value = panel:GetValue()
	panel.next_try = panel.next_try or 0
	panel.last_value = panel.last_value or panel_value

	if panel.last_value == panel_value then return end
	local now = CurTime() 
	if panel.next_try < now then return end

	local new_value = math.floor( (panel_value * 10) + 0.5 )
	net.Start("radio_freq_change")
		net.WriteEntity( self )
		net.WriteBool( true ) --SWEP true ENT false
		net.WriteInt( new_value , 32 )
	net.SendToServer()
	self.freq = new_value
	panel.last_value = panel_value
	panel.next_try = now + 0.1
end

function SWEP:open_settings()
	if (settingsPanel != nil) then
		settingsPanel:Close()
		return
	end

	settingsPanel = vgui.Create( "DFrame" )
	settingsPanel:Center()
	settingsPanel:SetSize( 500, 100 )
	settingsPanel:SetTitle( "Radio Config" )
	settingsPanel:SetDraggable( true )
	settingsPanel:MakePopup()
	settingsPanel.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 75, 75, 75, 255 ) )
	end
	settingsPanel.OnClose = function()
		settingsPanel = nil
	end

	local DSlider = vgui.Create( "DNumSlider", settingsPanel )
	DSlider:SetPos( 10, 50 )
	DSlider:SetSize( 500, 25 )
	DSlider:SetText( "Frequency" )
	DSlider:SetMin( self.freq_min/10 )
	DSlider:SetMax( self.freq_max/10 )
	DSlider:SetDecimals( 1 )
	DSlider:SetValue( self.freq/10 )
	DSlider.Think = frequencySlider

	settingsPanel:SetPos( ScrW()/2 - 250, ScrH()/2 - 50/2)
end
