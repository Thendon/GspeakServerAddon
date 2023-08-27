

hook.Add("InitPostEntity", "gspeak_rebind_keys", function()
	if GAMEMODE_NAME == "darkrp" then return end

  	original_bind = GAMEMODE.PlayerBindPress
	function GAMEMODE.PlayerBindPress( _, ply, bind, pressed )
		if gspeak:PlayerBindPress( ply, bind, pressed ) then return true end
		return original_bind( _, ply, bind, pressed )
	end
end)


function gspeak:DeadChat()
	if gspeak.settings.deadHearsDead then
		if gspeak.cl.deadMuted then
			gspeak.cl.deadMuted = false
			gspeak:ChatPrint( " unmuted dead players ")
		else
			gspeak.cl.deadMuted = true
			gspeak:ChatPrint( " muted dead players ")
		end
	end
end

function gspeak:PlayerBindPress( ply, bind, pressed )
	if !gspeak.terrortown then return end
	if gspeak.settings.overrideV and bind == "+voicerecord" then
		return true
	elseif gspeak.settings.overrideV and bind == "+speed" and gspeak:IsPlayerAlive(LocalPlayer()) then
		return true
	elseif gspeak.settings.deadHearsDead and bind == "gm_showteam" and pressed and !gspeak:IsPlayerAlive(LocalPlayer()) then
		gspeak:DeadChat()
		return true
	elseif !gspeak.settings.deadHearsDead and bind == "gm_showteam" then
		return true
	end
end