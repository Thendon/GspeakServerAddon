local head_offset = Vector(0, 0, 80)

hook.Add( "RenderScreenspaceEffects", "gspeak_icon", function()
	local eye = EyeAngles()
	local ang = Angle (eye.p, eye.y, eye.r)
	ang:RotateAroundAxis(ang:Forward(), -90)
	ang:RotateAroundAxis(ang:Right(), 90)
	ang:RotateAroundAxis(ang:Up(), 180)

	cam.Start3D(EyePos(), eye)
        for k, ply in pairs(gspeak.cl.players) do
            if !gspeak:player_valid( ply ) then continue end
            if ply == LocalPlayer() then continue end

            if gspeak.viewranges then gspeak:DrawPlayerRanges(ply) end

            gspeak:DrawOverHead(ply, ang)
        end

        if gspeak.rangeEditing then
            render.SetColorMaterial()
        end
	cam.End3D()
end)

function gspeak:DrawPlayerRanges(ply)
    if !gspeak:player_alive(ply) then return end

    local pos = ply:GetPos() + gspeak:get_offset(ply)
    for i = 1, #gspeak.settings.distances.modes, 1 do
        local power = i % 3
        local col = Color(power==0 and 255 or 0, power==1 and 255 or 0, power==2 and 255 or 0)
        gspeak:draw_range(pos, gspeak.settings.distances.modes[i].range, gspeak.settings.distances.heightclamp, col)
    end
    gspeak:draw_range(pos, gspeak.settings.distances.iconview, 0, gspeak.cl.color.white)
end

function gspeak:draw_range( pos, size, cut, color)
	local normal = Vector(0,0,1)
	render.DrawWireframeSphere(pos, size, 8, 8, color)
	if cut == 0 then return end
	render.DrawQuadEasy(pos + Vector(0, 0, size) * Vector(1,1,cut), normal, size, size, color, 0)
	render.DrawQuadEasy(pos + Vector(0, 0, size) * Vector(1,1,cut), -normal, size, size, color, 0)
	render.DrawQuadEasy(pos - Vector(0, 0, size) * Vector(1,1,cut), normal, size, size, color, 0)
	render.DrawQuadEasy(pos - Vector(0, 0, size) * Vector(1,1,cut), -normal, size, size, color, 0)
end

function DrawGspeakIcon(ply, x, y, size)
    surface.SetDrawColor( gspeak.cl.color.white )
    if ply.failed then
        surface.SetMaterial( gspeak.cl.materials.off )
        surface.DrawTexturedRect( x, y, size, size )
    elseif ply.ts_id == 0 then --loading
        gspeak:DrawLoading(x, y+7, 4, 4, gspeak.cl.color.white)
    else
        local talkmode = gspeak:get_talkmode( ply )
        local _, _, mat, _ = gspeak:get_talkmode_details(talkmode)
        surface.SetMaterial( mat or gspeak.cl.materials.default_icon )
        surface.DrawTexturedRect( x, y, size, size )
    end
end

function gspeak:DrawOverHead(ply, ang)
	local client_alive = gspeak:player_alive(LocalPlayer())

    local ply_pos
    local isDeadchat = false
    if (gspeak:player_alive(ply)) then
		ply_pos = ply:GetPos()
        --out of defined view range
        if (LocalPlayer():GetPos():Distance(ply_pos) >= tonumber(gspeak.settings.distances.iconview)) then return end
    else
        if (!gspeak.settings.dead_chat) then return end
        if (gspeak.cl.dead_muted) then return end
        if (client_alive) then return end

        local slot = ply.dead_slot or 1
        ply_pos = gspeak.clientPos + dead_circle[slot]
        isDeadchat = true
    end

    --no reason to draw then
    if !ply.talking and ply.ts_id != 0 and !ply.failed then return end

    local pos = ply_pos + head_offset
    local pos_y = -15
    local drawName = gspeak.settings.head_name or isDeadchat

    if gspeak.settings.head_icon then
        if !drawName then pos_y = -8 end
        local size = 16
        local pos_x = -size * 0.5
        cam.Start3D2D(pos, ang, 1)
            DrawGspeakIcon(ply, pos_x, pos_y, size)
        cam.End3D2D()
    end
    
    if drawName then
        local ply_name = gspeak:GetName( ply )
        if !gspeak.settings.head_icon and ply.ts_id == 0 then
            if ply.failed then
                ply_name = "(error)"
            elseif ply.ts_id == 0 then
                ply_name = "(connecting)"
            end
        end
        cam.Start3D2D(pos, ang, 0.1)
            draw.DrawText( ply_name, "TnfBig", 0, pos_y, team.GetColor( ply:Team() ), TEXT_ALIGN_CENTER )
        cam.End3D2D()
    end
end

function gspeak:RefreshIcons()
	for k, v in pairs(gspeak.settings.distances.modes) do
		if v.icon then v.material = Material( v.icon, "noclamp unlitgeneric" ) end
		if v.icon_ui then v.material_ui = Material( v.icon_ui, "noclamp unlitgeneric" ) end
	end
end