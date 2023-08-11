

hook.Add("InitPostEntity", "gspeak_rebind_keys", function()
	if GAMEMODE_NAME == "darkrp" then return end

  	original_bind = GAMEMODE.PlayerBindPress
	function GAMEMODE.PlayerBindPress( _, ply, bind, pressed )
		if gspeak:PlayerBindPress( ply, bind, pressed ) then return true end
		return original_bind( _, ply, bind, pressed )
	end
end)


function gspeak:DeadChat()
	if gspeak.settings.dead_chat then
		if gspeak.cl.dead_muted then
			gspeak.cl.dead_muted = false
			chat.AddText( gspeak.cl.color.red, "[Gspeak]",  gspeak.cl.color.black, " unmuted dead players ")
		else
			gspeak.cl.dead_muted = true
			chat.AddText( gspeak.cl.color.red, "[Gspeak]",  gspeak.cl.color.black, " muted dead players ")
		end
	end
end

function gspeak:PlayerBindPress( ply, bind, pressed )
	if !gspeak.terrortown then return end
	if gspeak.settings.overrideV and bind == "+voicerecord" then
		return true
	elseif gspeak.settings.overrideV and bind == "+speed" and gspeak:player_alive(LocalPlayer()) then
		return true
	elseif gspeak.settings.dead_chat and bind == "gm_showteam" and pressed and !gspeak:player_alive(LocalPlayer()) then
		gspeak:DeadChat()
		return true
	elseif !gspeak.settings.dead_chat and bind == "gm_showteam" then
		return true
	end
end