
local refs = {
    DT = { ui.reference("RAGE", "Other", "Double tap") },
    FD = ui.reference("RAGE", "Other", "Duck peek assist"),
    osaa = { ui.reference("AA", "Other", "On shot anti-aim") },
    slow_motion = { ui.reference("AA", "Other", "Slow motion") }
}
local states = {
    "Standing",
    "Running",
    "Inair",
    "Fakeduck",
    "Crouching",
    "Slowmo",
    "Aircrouch",
    "Doubletap",
    "Onshotaa"
}
local antiaim = {
    pitch = ui.reference("AA", "Anti-aimbot angles", "Pitch"),
    yaw_base = ui.reference("AA", "Anti-aimbot angles", "Yaw base"),
    yaw = { ui.reference("AA", "Anti-aimbot angles", "Yaw") },
    yaw_jitter = { ui.reference("AA", "Anti-aimbot angles", "Yaw jitter") } ,
    body_yaw = { ui.reference("AA", "Anti-aimbot angles", "Body yaw") },
    freeStanding_body_yaw = ui.reference("AA", "Anti-aimbot angles", "FreeStanding body yaw"),
    fake_yaw_limit = ui.reference("AA", "Anti-aimbot angles", "Fake yaw limit"),
    edge_yaw = ui.reference("AA", "Anti-aimbot angles", "Edge yaw"),
    freeStanding = { ui.reference("AA", "Anti-aimbot angles", "FreeStanding") },
    roll = ui.reference("AA", "Anti-aimbot angles", "Roll")
}

local set_var = {
    pitch = antiaim.pitch,
    yaw_base = antiaim.yaw_base,
    yaw_1 = antiaim.yaw[1],
    yaw_2 = antiaim.yaw[2],
    yaw_jitter1 = antiaim.yaw_jitter[1],
    yaw_jitter2 = antiaim.yaw_jitter[2],
    body_yaw1 = antiaim.body_yaw[1],
    body_yaw2 = antiaim.body_yaw[2],
    freeStanding_body_yaw = antiaim.freeStanding_body_yaw,
    fake_yaw_limit = antiaim.fake_yaw_limit,
    roll = antiaim.roll
}
local fakelag = {
    enabled = { ui.reference("AA", "Fake lag", "Enabled") },
    amount = ui.reference("AA", "Fake lag", "Amount"),
    variance = ui.reference("AA", "Fake lag", "Variance"),
    limit = ui.reference("AA", "Fake lag", "Limit")
}

local function get_state()
    if entity.get_local_player() == nil then return end
    local vx, vy = entity.get_prop(entity.get_local_player(), 'm_vecVelocity')
    local player_Standing = math.sqrt(vx ^ 2 + vy ^ 2) < 2
	local player_jumping = bit.band(entity.get_prop(entity.get_local_player(), 'm_fFlags'), 1) == 0
    local player_Fakeduck = ui.get(refs.FD)
    local player_Crouching = entity.get_prop(entity.get_local_player(), "m_flDuckAmount") > 0.5 and not (bit.band(entity.get_prop(entity.get_local_player(), 'm_fFlags'), 1) == 0)
    local player_slow_motion = ui.get(refs.slow_motion[2])
    local player_air_crouch = entity.get_prop(entity.get_local_player(), "m_flDuckAmount") > 0.5 and (bit.band(entity.get_prop(entity.get_local_player(), 'm_fFlags'), 1) == 0)
    local player_Doubletap = ui.get(refs.DT[2])
    local player_osaa = ui.get(refs.osaa[2])

    if player_Standing then
        return 'Standing'
    elseif player_jumping then
        return 'in-air'
    elseif player_Fakeduck then
        return 'Fakeduck'
    elseif player_Crouching then
        return 'Crouching'
    elseif player_slow_motion then
        return 'Slowmo'
    elseif player_air_crouch then
        return 'in-air crouch'
    elseif player_Doubletap then
        return 'Doubletap'
    elseif player_osaa then
        return 'onshot-aa'
    end
end
    
local ui_e = {
    ui.new_label("LUA", "B", "---------------------------------------------"),
    enable = ui.new_checkbox("LUA", "B", "Enable AA States"),
    state_sel = ui.new_combobox("LUA", "B", "States", states)
}

local function setup_ui()
    for i,v in pairs(states) do
        _G["tbl_"..v] = {
            pitch = ui.new_combobox("LUA", "B", "\aff96edff " .. v .. " Pitch", "Off","Default", "Up", "Down", "Minimal", "Random"),
            YawBase = ui.new_combobox("LUA", "B", "\aff96edff " .. v.." Yaw Base", "Local View", "At Targets"),
            Yaw = ui.new_combobox("LUA", "B", "\aff96edff " .. v.." Yaw Base", "Off", "180", "Spin", "Static", "180 Z", "Crosshair"),
            YawSlider = ui.new_slider("LUA", "B", "\aff96edff " .. v.." Yaw Angle", -180, 180, 0, true, °, 1),
            YawJitter = ui.new_combobox("LUA", "B", "\aff96edff " .. v.." Yaw Jitter", "Off", "Offset", "Center", "Random"),
            YawJitterSlider = ui.new_slider("LUA", "B", "\aff96edff " .. v.." Yaw Jitter Slider", -180, 180, 0, true, °, 1),
            BodyYaw = ui.new_combobox("LUA", "B", "\aff96edff " .. v.." Body Yaw", "Off", "Opposite", "Jitter", "Static"),
            BodyYawSlider = ui.new_slider("LUA", "B", "\aff96edff " .. v.." Body Yaw", -180, 180, 0, true, °, 1),
            freestandBodyYaw = ui.new_checkbox("LUA", "B", "\aff96edff " .. v.." FreeStanding Body Yaw"),
            fakelimit = ui.new_slider("LUA", "B", "\aff96edff " .. v.." Fake Yaw Limit", 0, 60, 0, true, °, 1),
            roll = ui.new_slider("LUA", "B", "\aff96edff " .. v.." Roll", -50, 50, 0, true, °, 1)
        }
    end
end
local tables = {
    tbl_Standing,
    tbl_Inair,
    tbl_Fakeduck,
    tbl_Crouching,
    tbl_Slowmo,
    tbl_Aircrouch,
    tbl_Doubletap,
    tbl_Onshotaa,
    tbl_Running
}

client.set_event_callback("run_command", function()
    if not ui.is_menu_open() then return
    elseif ui.is_menu_open() then
        if not ui.get(ui_e.enable) then
            for i,v in pairs(tbl_Standing) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Inair) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Fakeduck) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Crouching) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Slowmo) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Aircrouch) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Doubletap) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Onshotaa) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Running) do ui.set_visible(v,valse) end
        elseif ui.get(ui_e.enable) and ui.get(ui_e.state_sel) == "Standing" then
            for i,v in pairs(tbl_Standing) do ui.set_visible(v, true) end
            for i,v in pairs(tbl_Inair) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Fakeduck) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Crouching) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Slowmo) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Aircrouch) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Doubletap) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Onshotaa) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Running) do ui.set_visible(v,valse) end
        elseif ui.get(ui_e.enable) and ui.get(ui_e.state_sel) == "Running" then
            for i,v in pairs(tbl_Standing) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Running) do ui.set_visible(v, true) end
            for i,v in pairs(tbl_Inair) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Fakeduck) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Crouching) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Slowmo) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Aircrouch) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Doubletap) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Onshotaa) do ui.set_visible(v, false) end
        elseif ui.get(ui_e.enable) and ui.get(ui_e.state_sel) == "Inair" then
            for i,v in pairs(tbl_Standing) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Running) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Inair) do ui.set_visible(v, true) end
            for i,v in pairs(tbl_Fakeduck) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Crouching) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Slowmo) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Aircrouch) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Doubletap) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Onshotaa) do ui.set_visible(v, false) end
        elseif ui.get(ui_e.enable) and ui.get(ui_e.state_sel) == "Fakeduck" then
            for i,v in pairs(tbl_Standing) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Inair) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Running) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Fakeduck) do ui.set_visible(v, true) end
            for i,v in pairs(tbl_Crouching) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Slowmo) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Aircrouch) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Doubletap) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Onshotaa) do ui.set_visible(v, false) end
        elseif ui.get(ui_e.enable) and ui.get(ui_e.state_sel) == "Crouching" then
            for i,v in pairs(tbl_Standing) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Running) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Inair) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Fakeduck) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Crouching) do ui.set_visible(v, true) end
            for i,v in pairs(tbl_Slowmo) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Aircrouch) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Doubletap) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Onshotaa) do ui.set_visible(v, false) end
        elseif ui.get(ui_e.enable) and ui.get(ui_e.state_sel) == "Slowmo" then
            for i,v in pairs(tbl_Standing) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Running) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Inair) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Fakeduck) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Crouching) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Slowmo) do ui.set_visible(v, true) end
            for i,v in pairs(tbl_Aircrouch) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Doubletap) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Onshotaa) do ui.set_visible(v, false) end
        elseif ui.get(ui_e.enable) and ui.get(ui_e.state_sel) == "Aircrouch" then
            for i,v in pairs(tbl_Standing) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Running) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Inair) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Fakeduck) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Crouching) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Slowmo) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Aircrouch) do ui.set_visible(v, true) end
            for i,v in pairs(tbl_Doubletap) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Onshotaa) do ui.set_visible(v, false) end
        elseif ui.get(ui_e.enable) and ui.get(ui_e.state_sel) == "Doubletap" then
            for i,v in pairs(tbl_Standing) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Running) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Inair) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Fakeduck) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Crouching) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Slowmo) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Aircrouch) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Doubletap) do ui.set_visible(v, true) end
            for i,v in pairs(tbl_Onshotaa) do ui.set_visible(v, false) end
        elseif ui.get(ui_e.enable) and ui.get(ui_e.state_sel) == "Onshotaa" then
            for i,v in pairs(tbl_Standing) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Running) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Inair) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Fakeduck) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Crouching) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Slowmo) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Aircrouch) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Doubletap) do ui.set_visible(v, false) end
            for i,v in pairs(tbl_Onshotaa) do ui.set_visible(v, true) end
        end
    end
end)


client.set_event_callback("run_command", function()
    if ui.get(ui_e.enable) then
        if get_state() == "Standing" then
            for v,i in pairs(set_var) do
                ui.set(v, ui.get(tbl_Standing..v)) end
        end
    end
end)


setup_ui()