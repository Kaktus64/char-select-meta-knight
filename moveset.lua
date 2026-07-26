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

local META_WING_FLAP = audio_sample_load("metaflap.ogg")

local META_POINT_COLLECT = audio_sample_load("metapoint.ogg")

local META_POINT_COLLECT_MULTI = audio_sample_load("metapointmulti.ogg")

local META_SELECT_ABILITY = audio_sample_load("metaselect.ogg")

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
    e.metaHealTimer = 0
    e.metaQuadWingsTimer = 0
    e.metaInQuadWings = false
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
ACT_METAK_SPIN = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_MOVING | ACT_FLAG_ATTACKING)
ACT_FLYING_META = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_CUSTOM_ACTION)
ACT_META_SHUTTLE_LOOP = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_CUSTOM_ACTION)

function act_metak_fly(m)
 local e = gStateExtras[m.playerIndex]
    local stepResult = common_air_action_step(m, ACT_FREEFALL_LAND, CHAR_ANIM_DOUBLE_JUMP_RISE, AIR_STEP_NONE)
    m.faceAngle.y = m.intendedYaw - approach_s32(limit_angle(m.intendedYaw - m.faceAngle.y), 0, 0x300, 0x300)
    if m.playerIndex == 0 then 
    m.peakHeight = m.pos.y -- no fall sound
    --m.vel.y = m.vel.y + 3
    --SOUND_ACTION_SPIN
        smlua_anim_util_set_animation(m.marioObj, "metak-flap")
        if m.controller.buttonPressed & A_BUTTON ~= 0 and e.metaFlyCount ~= 3 then
            set_anim_to_frame(m, 0)
            e.metaFlyCount = e.metaFlyCount + 1
            audio_sample_play(META_WING_FLAP, m.pos, 2)
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
        --m.forwardVel = 40
        return set_mario_action(m, ACT_DIVE, 0)
    end
end
end

hook_mario_action(ACT_METAK_FLY, act_metak_fly)

function act_metak_spin(m)
 local e = gStateExtras[m.playerIndex]
    local stepResult = common_air_action_step(m, ACT_JUMP_LAND, CHAR_ANIM_RUNNING_UNUSED, AIR_STEP_NONE)
    m.faceAngle.y = m.intendedYaw - approach_s32(limit_angle(m.intendedYaw - m.faceAngle.y), 0, 0x300, 0x300)
    m.actionTimer = m.actionTimer + 1
    if m.playerIndex == 0 then 
    -- m.peakHeight = m.pos.y -- no fall sound
    --m.vel.y = m.vel.y + 3
    --SOUND_ACTION_SPIN
        smlua_anim_util_set_animation(m.marioObj, "metak-flip")
    if stepResult == AIR_STEP_LANDED then
        return set_mario_action(m, ACT_JUMP_LAND, 0)
    end
    if stepResult == AIR_STEP_HIT_WALL then
        mario_bonk_reflection(m, 0)
        return set_mario_action(m, ACT_METAK_SPIN, 0)
    end
    if m.actionTimer < 3 then
        m.vel.y = 25
    end
    if m.actionTimer % 5 == 0 then
        play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject);
    end
    if m.actionTimer > 18 then
        set_mario_action(m, ACT_FREEFALL, 0)
    end
end
end

hook_mario_action(ACT_METAK_SPIN, act_metak_spin)

function act_flying_meta(m)
    local startPitch = m.faceAngle.x;

    --if (not (m.flags & MARIO_WING_CAP)) ~= 0 then
    --    if (m.area.camera.mode == CAMERA_MODE_BEHIND_MARIO) then
    --        set_camera_mode(m.area.camera, m.area.camera.defMode, 1);
    --    end
    --    return set_mario_action(m, ACT_FREEFALL, 0);
    --end

    smlua_anim_util_set_animation(m.marioObj, "metak-shuttleloop")
    --[[
    if (m.actionState == 0) then
        if (m.actionArg == 0) then
            
        else
            set_mario_animation(m, MARIO_ANIM_FORWARD_SPINNING_FLIP);
            if (m.marioObj.header.gfx.animInfo.animFrame == 1) then
                play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject);
            end
        end
    end
    --]]
    --m.marioObj.header.gfx.animInfo.animAccel = m.forwardVel * 30000

    update_flying(m);

    local stepResult = perform_air_step(m, 0)
    if stepResult == AIR_STEP_NONE then
        m.marioObj.header.gfx.angle.x = -m.faceAngle.x;
        m.marioObj.header.gfx.angle.z = m.faceAngle.z;
        m.actionTimer = 0;

    elseif stepResult == AIR_STEP_LANDED then
        set_mario_action(m, ACT_DIVE_SLIDE, 0);

        set_mario_animation(m, MARIO_ANIM_DIVE);
        set_anim_to_frame(m, 7);

        m.faceAngle.x = 0;
        queue_rumble_data(5, 60);

    elseif stepResult == AIR_STEP_HIT_WALL then
            if (m.wall ~= nil) ~= 0 then
                mario_set_forward_vel(m, -16.0);
                m.faceAngle.x = 0;

                if (m.vel.y > 0.0) ~= 0 then
                    m.vel.y = 0.0;
                end

                play_sound(SOUND_ACTION_BONK, m.marioObj.header.gfx.cameraToObject);

                m.particleFlags = m.particleFlags | PARTICLE_VERTICAL_STAR;
                set_mario_action(m, ACT_BACKWARD_AIR_KB, 0);
            else
                m.actionTimer = m.actionTimer + 1
                if (m.actionTimer == 0) ~= 0 then
                    play_sound(SOUND_ACTION_HIT, m.marioObj.header.gfx.cameraToObject);
                end

                if (m.actionTimer == 30) then
                    m.actionTimer = 0;
                end

                m.faceAngle.x = m.faceAngle.x - 0x200;
                if (m.faceAngle.x < -0x2AAA) ~= 0 then
                    m.faceAngle.x = -0x2AAA;
                end

                m.marioObj.header.gfx.angle.x = -m.faceAngle.x;
                m.marioObj.header.gfx.angle.z = m.faceAngle.z;
            end

    elseif stepResult == AIR_STEP_HIT_LAVA_WALL then
        lava_boost_on_wall(m);
    
    end


    if (m.faceAngle.x > 0x800 and m.forwardVel >= 48.0) then
        m.particleFlags = m.particleFlags | PARTICLE_DUST;
    end

    if (startPitch <= 0 and m.faceAngle.x > 0 and m.forwardVel >= 48.0) then
        play_sound(SOUND_ACTION_FLYING_FAST, m.marioObj.header.gfx.cameraToObject);
        queue_rumble_data(50, 40);
    end

    play_sound(SOUND_MOVING_FLYING, m.marioObj.header.gfx.cameraToObject);
    adjust_sound_for_speed(m);
    return false;
end

hook_mario_action(ACT_FLYING_META, { every_frame = act_flying_meta, gravity = nil } )

function act_meta_shuttle_loop(m)
    local startPitch = m.faceAngle.x;

    m.actionTimer = m.actionTimer + 1

    --if (not (m.flags & MARIO_WING_CAP)) ~= 0 then
    --    if (m.area.camera.mode == CAMERA_MODE_BEHIND_MARIO) then
    --        set_camera_mode(m.area.camera, m.area.camera.defMode, 1);
    --    end
    --    return set_mario_action(m, ACT_FREEFALL, 0);
    --end

    smlua_anim_util_set_animation(m.marioObj, "metak-shuttleloop")
    --[[
    if (m.actionState == 0) then
        if (m.actionArg == 0) then
            
        else
            set_mario_animation(m, MARIO_ANIM_FORWARD_SPINNING_FLIP);
            if (m.marioObj.header.gfx.animInfo.animFrame == 1) then
                play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject);
            end
        end
    end
    --]]
    --m.marioObj.header.gfx.animInfo.animAccel = m.forwardVel * 30000

    if m.forwardVel > 27 then
        m.forwardVel = 27
    end

    if m.actionTimer > 150 then
        set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
    end

    update_flying(m);

    local stepResult = perform_air_step(m, 0)
    if stepResult == AIR_STEP_NONE then
        m.marioObj.header.gfx.angle.x = -m.faceAngle.x;
        m.marioObj.header.gfx.angle.z = m.faceAngle.z;
        --m.actionTimer = 0;

    elseif stepResult == AIR_STEP_LANDED then
        set_mario_action(m, ACT_DIVE_SLIDE, 0);

        set_mario_animation(m, MARIO_ANIM_DIVE);
        set_anim_to_frame(m, 7);

        m.faceAngle.x = 0;
        queue_rumble_data(5, 60);

    elseif stepResult == AIR_STEP_HIT_WALL then
            if (m.wall ~= nil) ~= 0 then
                mario_set_forward_vel(m, -16.0);
                m.faceAngle.x = 0;

                if (m.vel.y > 0.0) ~= 0 then
                    m.vel.y = 0.0;
                end

                play_sound(SOUND_ACTION_BONK, m.marioObj.header.gfx.cameraToObject);

                m.particleFlags = m.particleFlags | PARTICLE_VERTICAL_STAR;
                set_mario_action(m, ACT_BACKWARD_AIR_KB, 0);
            else
                m.actionTimer = m.actionTimer + 1
                if (m.actionTimer == 0) ~= 0 then
                    play_sound(SOUND_ACTION_HIT, m.marioObj.header.gfx.cameraToObject);
                end

                if (m.actionTimer == 30) then
                    m.actionTimer = 0;
                end

                m.faceAngle.x = m.faceAngle.x - 0x200;
                if (m.faceAngle.x < -0x2AAA) ~= 0 then
                    m.faceAngle.x = -0x2AAA;
                end

                m.marioObj.header.gfx.angle.x = -m.faceAngle.x;
                m.marioObj.header.gfx.angle.z = m.faceAngle.z;
            end

    elseif stepResult == AIR_STEP_HIT_LAVA_WALL then
        lava_boost_on_wall(m);
    
    end


    if (m.faceAngle.x > 0x800 and m.forwardVel >= 48.0) then
        m.particleFlags = m.particleFlags | PARTICLE_DUST;
    end

    if (startPitch <= 0 and m.faceAngle.x > 0 and m.forwardVel >= 48.0) then
        play_sound(SOUND_ACTION_FLYING_FAST, m.marioObj.header.gfx.cameraToObject);
        queue_rumble_data(50, 40);
    end

    play_sound(SOUND_MOVING_FLYING, m.marioObj.header.gfx.cameraToObject);
    adjust_sound_for_speed(m);

    if m.input & INPUT_Z_PRESSED ~= 0 then
        return set_mario_action(m, ACT_GROUND_POUND, 0)
    end
    if m.input & INPUT_B_PRESSED ~= 0 then
        m.vel.y = 35
        return set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
    end

    return false;

    
end

hook_mario_action(ACT_META_SHUTTLE_LOOP, { every_frame = act_meta_shuttle_loop, gravity = nil } )




function metak_update(m)

    local e = gStateExtras[m.playerIndex]

    if m.controller.buttonDown & R_TRIG ~= 0 then
        e.metaPoints = e.metaPoints + 1
    end

    if m.controller.buttonDown & L_TRIG == 0 then

    if m.controller.buttonPressed & X_BUTTON ~= 0 and e.metaQuickTimer == 0 and e.metaPoints > 7 then
        e.metaQuickTimer = 1000
        e.metaPoints = e.metaPoints - 8
        audio_sample_play(META_SELECT_ABILITY, m.marioObj.header.gfx.cameraToObject, 4)
    end

    end

    if m.controller.buttonDown & L_TRIG ~= 0 then

    if m.controller.buttonPressed & X_BUTTON ~= 0 and e.metaQuadWingsTimer == 0 and e.metaPoints > 17 then
        e.metaQuadWingsTimer = 2500
        e.metaPoints = e.metaPoints - 18
        audio_sample_play(META_SELECT_ABILITY, m.marioObj.header.gfx.cameraToObject, 4)
        set_mario_action(m, ACT_TRIPLE_JUMP, 0)
        m.pos.y = m.pos.y + 5
        m.vel.y = 120
        e.metaInQuadWings = true
    end

    end

    if m.action == ACT_TRIPLE_JUMP and e.metaInQuadWings == true then

        smlua_anim_util_set_animation(m.marioObj, "metak-shuttlestart")

    end

    if m.action == ACT_TRIPLE_JUMP and m.vel.y < -10 and e.metaQuadWingsTimer ~= 0 and e.metaInQuadWings == true then
        set_mario_action(m, ACT_FLYING_META, 0)
        m.forwardVel = 35
    end


    if m.controller.buttonPressed & Y_BUTTON ~= 0 and e.metaPoints > 9 and m.health ~= 2176 and e.metaHealTimer == 0 then
        e.metaPoints = e.metaPoints - 10
        audio_sample_play(META_SELECT_ABILITY, m.marioObj.header.gfx.cameraToObject, 4)
        e.metaHealTimer = 50
    end

    if e.metaHealTimer ~= 0 then
        m.health = m.health + 50
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
            m.forwardVel = m.forwardVel + 1.03
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
        audio_sample_play(META_WING_FLAP, m.pos, 2)
        set_mario_action(m, ACT_METAK_FLY, 0)
        set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, 0)
        m.vel.y = 35
        e.metaFlyCount = e.metaFlyCount + 1
    end

    if m.action == ACT_BACKFLIP and m.vel.y < -10 then
        set_mario_action(m, ACT_META_SHUTTLE_LOOP, 0)
        play_sound(SOUND_ACTION_FLYING_FAST, m.marioObj.header.gfx.cameraToObject);
        m.forwardVel = 35
    end

    if m.action == ACT_BACKFLIP then
        --set_mario_anim_with_accel(m, MARIO_ANIM_FORWARD_SPINNING_FLIP, 3)
    end

    if m.pos.y == m.floorHeight then
        e.metaFlyCount = 0
        e.metaInQuadWings = false
    end

    if m.action == ACT_WALKING then
        m.marioBodyState.torsoAngle.x = 0
        m.marioBodyState.torsoAngle.z = 0
    end

    if e.metaHealTimer > 0 then
        e.metaHealTimer = e.metaHealTimer - 1
    end

    if e.metaQuadWingsTimer > 0 then
        e.metaQuadWingsTimer = e.metaQuadWingsTimer - 1
    end

    if e.metaInQuadWings == true then
        m.marioBodyState.capState = MARIO_HAS_WING_CAP_ON
    end

    if m.action == ACT_CROUCHING then

        m.marioObj.header.gfx.scale.y = 0.6
        m.marioObj.header.gfx.scale.x = 1.3
        m.marioObj.header.gfx.scale.z = 1.3
    
    end

    if m.action == ACT_WALKING then
        m.marioBodyState.eyeState = MARIO_EYES_LOOK_UP
    end
    if m.action == ACT_JUMP then
        m.marioBodyState.eyeState = MARIO_EYES_LOOK_UP
    end
    if m.action == ACT_METAK_FLY then
        m.marioBodyState.eyeState = MARIO_EYES_LOOK_UP
    end


end

function metak_set_action(m)

end

function metak_before_set_action(m, inc)

    if inc == ACT_START_CROUCHING then
        return ACT_CROUCHING
    end

    if inc == ACT_STOP_CROUCHING then
        return ACT_IDLE
    end

    if inc == ACT_DOUBLE_JUMP then
        return ACT_JUMP
    end

    if inc == ACT_JUMP_KICK then
        return ACT_METAK_SPIN
    end

    if inc == ACT_LONG_JUMP then
        return ACT_JUMP
    end

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
    local metaHealTimer = string.format("MH: %.0f", e.metaHealTimer)
    local metaQuadWingsTimer = string.format("MW: %.0f", e.metaQuadWingsTimer)
    local metaActionTimer = string.format("AT: %.0f", m.actionTimer)

    djui_hud_print_text(metaPoints, 125, 220, 0.5)
    djui_hud_print_text(metaQuickTimer, 125, 200, 0.5)
    djui_hud_print_text(metaFlyCount, 125, 180, 0.5)
    djui_hud_print_text(metaHealTimer, 125, 160, 0.5)
    djui_hud_print_text(metaQuadWingsTimer, 170, 220, 0.5)
    djui_hud_print_text(metaActionTimer, 170, 200, 0.5)

    djui_hud_set_color(255, 255, 255, 255)

    djui_hud_render_texture(TEX_META_HUD_ABILITIES, -20, screenheightMK - 110, 1, 1)

    djui_hud_set_font(FONT_SPECIAL)

    if e.metaPoints ~= 50 then 
        djui_hud_set_color(255, 255, 255, 255) 
        djui_hud_print_text_outlined(metaPoints, 87.5, screenheightMK - 55, 0.5)
    end
    
    if e.metaPoints == 50 then
        djui_hud_set_color(248, 248, 0, 255) 
        djui_hud_print_text_outlined("MAX", 87.5, screenheightMK - 55, 0.5)
    end

    if e.metaPoints ~= 50 then 
        djui_hud_set_color(248, 248, 0, 255) 
    end
    
    if e.metaPoints == 50 then
        djui_hud_set_color(255, 255, 176, 255)
    end

    djui_hud_render_rect(77, screenheightMK - 13 - e.metaPoints / 50 * 65, 8, e.metaPoints / 50 * 65)

    djui_hud_set_color(255, 255, 255, 150)

    if e.metaQuickTimer ~= 0 then

    djui_hud_render_rect(6, screenheightMK - 47 - e.metaQuickTimer / 1000 * 32, 32, e.metaQuickTimer / 1000 * 32)

    end

    if e.metaHealTimer ~= 0 then

    djui_hud_render_rect(41, screenheightMK - 47 - e.metaHealTimer / 50 * 32, 32, e.metaHealTimer / 50 * 32)

    end

    if e.metaQuadWingsTimer ~= 0 then

    djui_hud_render_rect(6, screenheightMK - 12 - e.metaQuadWingsTimer / 2500 * 32, 32, e.metaQuadWingsTimer/ 2500 * 32)

    end

end

function metak_interact(m, o, int)

    local m = gMarioStates[0]

    local e = gStateExtras[m.playerIndex]

    if int == INTERACT_COIN then

            e.metaPoints = e.metaPoints + o.oDamageOrCoinValue

            audio_sample_play(META_POINT_COLLECT, m.marioObj.header.gfx.cameraToObject, 2.5)
        
    end

    if int == INTERACT_STAR_OR_KEY then

            e.metaPoints = e.metaPoints + 10

            audio_sample_play(META_POINT_COLLECT_MULTI, m.marioObj.header.gfx.cameraToObject, 10)
        
    end

end

_G.charSelect.character_hook_moveset(CT_META_KNIGHT, HOOK_MARIO_UPDATE, metak_update)
_G.charSelect.character_hook_moveset(CT_META_KNIGHT, HOOK_ON_SET_MARIO_ACTION, metak_set_action)
_G.charSelect.character_hook_moveset(CT_META_KNIGHT, HOOK_BEFORE_SET_MARIO_ACTION, metak_before_set_action)
_G.charSelect.character_hook_moveset(CT_META_KNIGHT, HOOK_ON_HUD_RENDER_BEHIND, metak_hud)
_G.charSelect.character_hook_moveset(CT_META_KNIGHT, HOOK_ON_INTERACT, metak_interact)
