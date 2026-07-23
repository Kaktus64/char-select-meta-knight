function is_metak()
    return CT_META_KNIGHT == charSelect.character_get_current_number()
end

local function djui_hud_print_text_outlined(message, x, y, scaleX, scaleY)
    local scaleY = scaleY or scaleX
    local djuiColor = djui_hud_get_color()
    djui_hud_set_color(0, 0, 0, djuiColor.a)
    djui_hud_print_text(message, x, y + scaleY*2, scaleX, scaleY)
    djui_hud_print_text(message, x + scaleX*2, y, scaleX, scaleY)
    djui_hud_print_text(message, x, y - scaleY*2, scaleX, scaleY)
    djui_hud_print_text(message, x - scaleX*2, y, scaleX, scaleY)
    djui_hud_set_color(djuiColor.r, djuiColor.g, djuiColor.b, djuiColor.a)
    djui_hud_print_text(message, x, y, scaleX, scaleY)
end

local TEX_META_HUD_ABILITIES = get_texture_info("metak-ability-hud")

---@diagnostic disable: undefined-global
if not _G.charSelectExists then return end

local gStateExtras = {}
for i = 0, MAX_PLAYERS - 1 do
    gStateExtras[i] = {}
    local m = gMarioStates[i]
    local e = gStateExtras[i]
    e.rotAngle = 0
    e.charArg = 0
    e.metaPoints = 0
    e.metaQuickTimer = 0
    e.metaFlyCount = 0
end

local function limit_angle(a)
    return (a + 0x8000) % 0x10000 - 0x8000
end

local metaKFlyActions = {
    [ACT_JUMP] = true,
    [ACT_DOUBLE_JUMP] = true,
    [ACT_TRIPLE_JUMP] = true,
    [ACT_FREEFALL] = true,
    [ACT_LONG_JUMP] = true,
    [ACT_SIDE_FLIP] = true,
    [ACT_BACKFLIP] = true,
    [ACT_WALL_KICK_AIR] = true,
    [ACT_TOP_OF_POLE_JUMP] = true,
    [ACT_JUMP_KICK] = true,
}

ACT_METAK_FLY = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_MOVING)

function act_metak_fly(m)
 local e = gStateExtras[m.playerIndex]
    local stepResult = common_air_action_step(m, ACT_FREEFALL_LAND, CHAR_ANIM_DOUBLE_JUMP_RISE, AIR_STEP_NONE)
    m.faceAngle.y = m.intendedYaw - approach_s32(limit_angle(m.intendedYaw - m.faceAngle.y), 0, 0x300, 0x300)
    if m.playerIndex == 0 then 
    m.peakHeight = m.pos.y -- no fall sound
    --m.vel.y = m.vel.y + 3
    --SOUND_ACTION_SPIN
        if m.controller.buttonPressed & A_BUTTON ~= 0 and e.metaFlyCount ~= 3 then
            set_anim_to_frame(m, 0)
            e.metaFlyCount = e.metaFlyCount + 1
            play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject)
            m.vel.y = 35
            set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, 0)
            set_mario_action(m, ACT_METAK_FLY, 0)
        end
    if stepResult == AIR_STEP_LANDED then
        return set_mario_action(m, ACT_FREEFALL_LAND, 0)
    end
    if stepResult == AIR_STEP_HIT_WALL then
        mario_bonk_reflection(m, 0)
        return set_mario_action(m, ACT_METAK_FLY, 0)
    end
    if m.input & INPUT_Z_PRESSED ~= 0 then
        return set_mario_action(m, ACT_GROUND_POUND, 0)
    end
    if m.input & INPUT_B_PRESSED ~= 0 then
        m.forwardVel = 40
        return set_mario_action(m, ACT_DIVE, 0)
    end
end
end
hook_mario_action(ACT_METAK_FLY, act_metak_fly)

function metak_update(m)

    local e = gStateExtras[m.playerIndex]

    if m.controller.buttonDown & L_TRIG ~= 0 then
        e.metaPoints = e.metaPoints + 1
    end

    if m.controller.buttonPressed & X_BUTTON ~= 0 and e.metaQuickTimer == 0 and e.metaPoints > 7 then
        e.metaQuickTimer = 500
        e.metaPoints = e.metaPoints - 8
        play_sound(SOUND_MENU_POWER_METER, m.marioObj.header.gfx.cameraToObject)
    end

    if m.controller.buttonPressed & Y_BUTTON ~= 0 and e.metaPoints > 9 and m.health ~= 2176 then
        m.health = 2176
        e.metaPoints = e.metaPoints - 10
        play_sound(SOUND_MENU_POWER_METER, m.marioObj.header.gfx.cameraToObject)
    end
    
    if e.metaPoints > 50 then
        e.metaPoints = 50
    end

    if e.metaQuickTimer > 0 then

        e.metaQuickTimer = e.metaQuickTimer - 1

        if m.action == ACT_WALKING and m.forwardVel > 45 and m.forwardVel < 55 then
            m.forwardVel = m.forwardVel + 0.965
        end
        if m.action == ACT_WALKING and m.forwardVel > 35 and m.forwardVel < 40 then
            m.forwardVel = m.forwardVel + 1.02
        end
        if m.action == ACT_WALKING and m.forwardVel > 32 and m.forwardVel < 32.1 then
            m.forwardVel = 40
        end
        if m.action == ACT_WALKING and m.forwardVel > 35 and m.forwardVel < 60 then
            m.forwardVel = m.forwardVel + 1.02
        end
        if m.action == ACT_WALKING and m.forwardVel > 32 and m.forwardVel < 33 then
            m.forwardVel = 40
            set_mario_particle_flags(m, PARTICLE_VERTICAL_STAR, 0)
            play_mario_jump_sound(m)
            play_sound(SOUND_GENERAL_COIN_SPURT_EU, m.marioObj.header.gfx.cameraToObject)
        end
        if m.action == ACT_WALKING and m.forwardVel > 35 then
            m.marioBodyState.torsoAngle.x = 0
            --smlua_anim_util_set_animation(m.marioObj, "mario_fast_run")
            set_mario_particle_flags(m, PARTICLE_DUST, 0)
            obj_get_temp_spawn_particles_info(E_MODEL_SMOKE)
        end

    end

    if metaKFlyActions[m.action] and m.vel.y < 0 and m.input & INPUT_A_PRESSED ~= 0 and e.metaFlyCount ~= 3 then
        play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject)
        set_mario_action(m, ACT_METAK_FLY, 0)
        set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, 0)
        m.vel.y = 35
        e.metaFlyCount = e.metaFlyCount + 1
    end

    if m.pos.y == m.floorHeight then
        e.metaFlyCount = 0
    end

    if m.action == ACT_WALKING then
        m.marioBodyState.torsoAngle.x = 0
        m.marioBodyState.torsoAngle.z = 0
    end

end

function metak_set_action(m)

end

function metak_before_set_action(m, inc)

end

function metak_hud(m) 

    djui_hud_set_resolution(RESOLUTION_N64)

    local screenheightMK = djui_hud_get_screen_height()

    local screenwidthMK = djui_hud_get_screen_width()

    local m = gMarioStates[0]

    local e = gStateExtras[m.playerIndex]

    djui_hud_set_font(FONT_SPECIAL)

    djui_hud_set_color(255, 0, 0, 255)

    local metaPoints = string.format("%.0f", e.metaPoints)
    local metaQuickTimer = string.format("MQ: %.0f", e.metaQuickTimer)
    local metaFlyCount = string.format("MF: %.0f", e.metaFlyCount)

    djui_hud_print_text(metaPoints, 125, 220, 0.5)
    djui_hud_print_text(metaQuickTimer, 125, 200, 0.5)
    djui_hud_print_text(metaFlyCount, 125, 180, 0.5)

    djui_hud_set_color(255, 255, 255, 255)

    djui_hud_render_texture(TEX_META_HUD_ABILITIES, -20, screenheightMK - 110, 1, 1)

    djui_hud_print_text_outlined(metaPoints, 87.5, screenheightMK - 55, 0.5)

    if e.metaPoints ~= 50 then 
        djui_hud_set_color(248, 248, 0, 255) 
    end
    
    if e.metaPoints == 50 then
        djui_hud_set_color(255, 255, 176, 255)
    end

    djui_hud_render_rect(77, screenheightMK - 13 - e.metaPoints / 50 * 65, 8, e.metaPoints / 50 * 65)

    djui_hud_set_color(255, 255, 255, 150)

    if e.metaQuickTimer ~= 0 then

    djui_hud_render_rect(6, screenheightMK - 47 - e.metaQuickTimer / 500 * 32, 32, e.metaQuickTimer / 500 * 32)

    end

end

_G.charSelect.character_hook_moveset(CT_META_KNIGHT, HOOK_MARIO_UPDATE, metak_update)
_G.charSelect.character_hook_moveset(CT_META_KNIGHT, HOOK_ON_SET_MARIO_ACTION, metak_set_action)
_G.charSelect.character_hook_moveset(CT_META_KNIGHT, HOOK_BEFORE_SET_MARIO_ACTION, metak_before_set_action)
_G.charSelect.character_hook_moveset(CT_META_KNIGHT, HOOK_ON_HUD_RENDER_BEHIND, metak_hud)
