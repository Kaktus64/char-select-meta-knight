-- name: [CS] \\#0f386f\\Meta \\#51316c\\Knight [WIP]
-- description: KNOW MY POWER

local TEXT_MOD_NAME = "[CS] Meta Knight"

-- Stops mod from loading if Character Select isn't on
if not _G.charSelectExists then
    djui_popup_create("\\#ffffdc\\\n"..TEXT_MOD_NAME.."\nRequires the Character Select Mod\nto use as a Library!\n\nPlease turn on the Character Select Mod\nand Restart the Room!", 6)
    return 0
end

local META_KNIGHT_ICON = get_texture_info("metak-icon")

local E_MODEL_META_KNIGHT = smlua_model_util_get_id("metak_geo")

--local META_KNIGHT_TUNE = audio_stream_load("metak-menu-theme.ogg")

--local META_KNIGHT_ART = get_texture_info("graffiti_metak")

local VOICETABLE_META_KNIGHT = {
nil
}

local VOICETABLE_META_KNIGHT_VOICE = {
    [CHAR_SOUND_OKEY_DOKEY] = nil, -- Starting game
	[CHAR_SOUND_LETS_A_GO] = 'mk_exhale.ogg', -- Starting level
	[CHAR_SOUND_PUNCH_YAH] = 'mk_dah.ogg', -- Punch 1
	[CHAR_SOUND_PUNCH_WAH] = 'mk_shoo.ogg', -- Punch 2
	[CHAR_SOUND_PUNCH_HOO] = 'mk_hah2.ogg', -- Punch 3
	[CHAR_SOUND_YAH_WAH_HOO] = nil, -- First/Second jump sounds
	[CHAR_SOUND_HOOHOO] = nil, -- Third jump sound
	[CHAR_SOUND_YAHOO_WAHA_YIPPEE] = nil, -- Triple jump sounds
	[CHAR_SOUND_UH] = 'mk_ow2.ogg', -- Wall bonk
	[CHAR_SOUND_UH2] = nil, -- Landing after long jump
	[CHAR_SOUND_UH2_2] = nil, -- Same sound as UH2; jumping onto ledge
	[CHAR_SOUND_HAHA] = nil, -- Landing triple jump
	[CHAR_SOUND_YAHOO] = 'mk_hiyah.ogg', -- Long jump
	[CHAR_SOUND_DOH] = 'mk_ow2.ogg', -- Long jump wall bonk
	[CHAR_SOUND_WHOA] = 'mk_humph.ogg', -- Grabbing ledge
	[CHAR_SOUND_EEUH] = 'mk_hmm.ogg', -- Climbing over ledge
	[CHAR_SOUND_WAAAOOOW] = nil, -- Falling a long distance
	[CHAR_SOUND_TWIRL_BOUNCE] = 'mk_hiyah.ogg', -- Bouncing off of a flower spring
	[CHAR_SOUND_GROUND_POUND_WAH] = nil,
	[CHAR_SOUND_HRMM] = 'mk_humph.ogg', -- Lifting something
	[CHAR_SOUND_HERE_WE_GO] = nil, -- Star get
	[CHAR_SOUND_SO_LONGA_BOWSER] = 'mk_knowmypower.ogg', -- Throwing Bowser
--DAMAGE
	[CHAR_SOUND_ATTACKED] = {'mk_hurt3.ogg', 'mk_hurt4.ogg', 'mk_hmm.ogg'}, -- Damaged
	[CHAR_SOUND_PANTING] = nil, -- Low health
	[CHAR_SOUND_ON_FIRE] = 'mk_hmm.ogg', -- Burned
--SLEEP SOUNDS
	[CHAR_SOUND_IMA_TIRED] = nil, -- Mario feeling tired
	[CHAR_SOUND_YAWNING] = nil, -- Mario yawning before he sits down to sleep
	[CHAR_SOUND_SNORING1] = nil, -- Snore Inhale
	[CHAR_SOUND_SNORING2] = nil, -- Exhale
	[CHAR_SOUND_SNORING3] = nil, -- Sleep talking / mumbling
--COUGHING (USED IN THE GAS MAZE)
	[CHAR_SOUND_COUGHING1] = nil, -- Cough take 1
	[CHAR_SOUND_COUGHING2] = nil, -- Cough take 2
	[CHAR_SOUND_COUGHING3] = nil, -- Cough take 3
--DEATH
	[CHAR_SOUND_DYING] = 'mk_hurt2.ogg', -- Dying from damage
	[CHAR_SOUND_DROWNING] = 'mk_surface.ogg', -- Running out of air underwater
    [CHAR_SOUND_MAMA_MIA] = 'mk_hurt_1.ogg', -- Booted out of level
--EXTRAS
    --[CHAR_SOUND_PRESS_START_TO_PLAY] = 'sm64_moneybags_jump.ogg'
}



local PALETTE_META_KNIGHT = {

    [PANTS]  = "FFC400", -- GOLD BLADES
    [SHIRT]  = "342E58", -- SHOULDER BLADES
    [GLOVES] = "ffffff", -- GLOVES
    [SHOES]  = "5E1376", -- SHOES
    [HAIR]   = "675790", -- WINGS
    [SKIN]   = "0D1753", -- BODY
    [CAP]    = "C2C2C2", -- MASK
	[EMBLEM] = "FFC800"  -- EYES
}

local PALETTE_MK_DARK = {

    [PANTS]  = "c6ced2", -- GOLD BLADES
    [SHIRT]  = "3f4854", -- SHOULDER BLADES
    [GLOVES] = "ffffff", -- GLOVES
    [SHOES]  = "650804", -- SHOES
    [HAIR]   = "3a4346", -- WINGS
    [SKIN]   = "555d68", -- BODY
    [CAP]    = "C2C2C2", -- MASK
	[EMBLEM] = "FFC800"  -- EYES
}

local PALETTE_MK_GALACTA = {

    [PANTS]  = "565e64", -- GOLD BLADES
    [SHIRT]  = "c5c9cc", -- SHOULDER BLADES
    [GLOVES] = "ffffff", -- GLOVES
    [SHOES]  = "ffffff", -- SHOES
    [HAIR]   = "ffffff", -- WINGS
    [SKIN]   = "ee46b3", -- BODY
    [CAP]    = "fcfffe", -- MASK
	[EMBLEM] = "ff0300"  -- EYES
}

local PALETTE_MK_MORPHO = {

    [PANTS]  = "e80d09", -- GOLD BLADES
    [SHIRT]  = "ffc500", -- SHOULDER BLADES
    [GLOVES] = "ffc500", -- GLOVES
    [SHOES]  = "ffc500", -- SHOES
    [HAIR]   = "fb4e02", -- WINGS
    [SKIN]   = "000000", -- BODY
    [CAP]    = "e80d09", -- MASK
	[EMBLEM] = "ffffff"  -- EYES
}

local PALETTE_MK_KIRBY = {

    [PANTS]  = "b8124d", -- GOLD BLADES
    [SHIRT]  = "f06775", -- SHOULDER BLADES
    [GLOVES] = "f598b1", -- GLOVES
    [SHOES]  = "ce1956", -- SHOES
    [HAIR]   = "842f55", -- WINGS
    [SKIN]   = "f598b1", -- BODY
    [CAP]    = "f1727f", -- MASK
	[EMBLEM] = "0057bc"  -- EYES
}

local PALETTE_MK_RETRO = {

    [PANTS]  = "fcb30d", -- GOLD BLADES
    [SHIRT]  = "fcb30d", -- SHOULDER BLADES
    [GLOVES] = "ffffff", -- GLOVES
    [SHOES]  = "5e54a0", -- SHOES
    [HAIR]   = "f62413", -- WINGS
    [SKIN]   = "000000", -- BODY
    [CAP]    = "5e54a0", -- MASK
	[EMBLEM] = "fcb30d"  -- EYES
}


--[[

local HM_META_KNIGHT = {
    label = {
        left = get_texture_info("KakLeftHealth"),
        right = get_texture_info("KakRightHealth"),
    },
    pie = {
        [1] = get_texture_info("KakPie1"),
        [2] = get_texture_info("KakPie2"),
        [3] = get_texture_info("KakPie3"),
        [4] = get_texture_info("KakPie4"),
        [5] = get_texture_info("KakPie5"),
        [6] = get_texture_info("KakPie6"),
        [7] = get_texture_info("KakPie7"),
        [8] = get_texture_info("KakPie8"),
    }
}

local COURSE_META_KNIGHT = {
    top = get_texture_info("KakCourse1"),
    bottom = get_texture_info("KakCourse2"),
}

local CAPTABLE_META_KNIGHT = {
    normal = smlua_model_util_get_id("kakcap_geo"),
    wing = smlua_model_util_get_id("kakwingcap_geo"),
    metal = smlua_model_util_get_id("kakmetalcap_geo"),
    --metalWing = smlua_model_util_get_id("custom_model_cap_wing_geo")
}

--]]

local ANIMTABLE_META_KNIGHT = {
    [_G.charSelect.CS_ANIM_MENU] = "metak-idle",
    [CHAR_ANIM_IDLE_HEAD_CENTER] = "metak-idle",
    [CHAR_ANIM_IDLE_HEAD_LEFT] = "metak-idle",
    [CHAR_ANIM_IDLE_HEAD_RIGHT] = "metak-idle",
    [CHAR_ANIM_FIRST_PERSON] = "metak-idle",
    [CHAR_ANIM_SINGLE_JUMP] = "metak-jump",
    [CHAR_ANIM_GENERAL_FALL] = "metak-fall",
    [CHAR_ANIM_RUNNING] = "metak-run",
    [CHAR_ANIM_WALKING] = "metak-run",
    [CHAR_ANIM_AIR_KICK] = "metak-downslash",
    [CHAR_ANIM_LAND_FROM_SINGLE_JUMP] = "metak-jumpland",
    [CHAR_ANIM_LAND_FROM_DOUBLE_JUMP] = "metak-jumpland",
    [CHAR_ANIM_GENERAL_LAND] = "metak-generalland",
    [CHAR_ANIM_FIRST_PUNCH] = "metak-slash1",
    [CHAR_ANIM_FIRST_PUNCH_FAST] = "metak-slash1end",
    [CHAR_ANIM_SECOND_PUNCH] = "metak-slash1",
    [CHAR_ANIM_SECOND_PUNCH_FAST] = "metak-slash1end",
    [CHAR_ANIM_RUNNING_UNUSED] = "metak-thrust",
    [CHAR_ANIM_GROUND_KICK] = "metak-downslash",
}

local CSloaded = false

if _G.charSelectExists then
    CT_META_KNIGHT = _G.charSelect.character_add("Meta Knight", {"know his power"}, "Kaktus64", {r = 81, g = 49, b = 108}, E_MODEL_META_KNIGHT, CT_MARIO, META_KNIGHT_ICON, 1.1)
    easymodemk_option = _G.charSelect.add_option("Easy Mode (Meta Knight)", 0, 1, {"Off", "On"}, {""}, true)
end

local function on_character_select_load()

    CSloaded = true

    _G.charSelect.character_add_voice(E_MODEL_META_KNIGHT, VOICETABLE_META_KNIGHT)

    _G.charSelect.character_add_palette_preset(E_MODEL_META_KNIGHT, PALETTE_META_KNIGHT, "Meta Knight")
    _G.charSelect.character_add_palette_preset(E_MODEL_META_KNIGHT, PALETTE_MK_DARK, "Mirror World")
    _G.charSelect.character_add_palette_preset(E_MODEL_META_KNIGHT, PALETTE_MK_GALACTA, "Sealed Away")
    _G.charSelect.character_add_palette_preset(E_MODEL_META_KNIGHT, PALETTE_MK_MORPHO, "Butterfly")
    _G.charSelect.character_add_palette_preset(E_MODEL_META_KNIGHT, PALETTE_MK_KIRBY, "Superstar Warrior")
    _G.charSelect.character_add_palette_preset(E_MODEL_META_KNIGHT, PALETTE_MK_RETRO, "NES")

    _G.charSelect.character_add_animations(E_MODEL_META_KNIGHT, ANIMTABLE_META_KNIGHT)

    _G.charSelect.credit_add("[CS] Meta Knight", "Kaktus64", "Mod Creator")
    _G.charSelect.credit_add("[CS] Meta Knight", "Squishy6094", "HUD Outlining")
    _G.charSelect.credit_add("[CS] Meta Knight", "Saul", "Action Recreation")

    _G.charSelect.character_set_category(CT_META_KNIGHT, "Kirby")

end

hook_event(HOOK_ON_MODS_LOADED, on_character_select_load)

function is_metak()
    return CT_META_KNIGHT == charSelect.character_get_current_number()
end