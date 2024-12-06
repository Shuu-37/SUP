local CreateFrame = CreateFrame
local UIParent = UIParent
local table = table
local string = string
local print = print

--- @type table<string, function>
local SlashCmdList = SlashCmdList
--- @type table
local _G = _G

local addonName, SUP = ...

-- Create the main addon frame for event handling
SUP.frame = CreateFrame("Frame")

-- Initialize saved variables with defaults if they don't exist
SUPConfig = SUPConfig or {
    fontSize = 14,
    showIcon = true,
    debugMode = false,
    position = { x = 0, y = 0 },
    playSound = true,
    soundKitID = 888 -- Default to Level Up sound
}

-- Register slash commands after ADDON_LOADED
local function RegisterSlashCommands()
    SLASH_SUP1 = "/sup"
    SlashCmdList["SUP"] = function(msg)
        if SUP.configFrame then
            SUP.configFrame:Show()
        else
            SUP.CreateConfigFrame()
            SUP.configFrame:Show()
        end
    end
end

-- Event handling
SUP.frame:RegisterEvent("ADDON_LOADED")
SUP.frame:RegisterEvent("CHAT_MSG_SKILL")
SUP.frame:RegisterEvent("SKILL_LINES_CHANGED")
SUP.frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
        print("SUP: Loaded successfully!")
        RegisterSlashCommands()
        -- SUP.CreateConfigFrame() -- debug
        -- SUP.configFrame:Show() -- debug
        SUP.SkillTracker.Initialize()
    elseif event == "SKILL_LINES_CHANGED" then
        SUP.SkillTracker.CheckForUpdates()
    end
end)
function SUP.DebugPrint(...)
    if SUPConfig.debugMode then
        print("|cFF00FF00[SUP Debug]|r", ...)
    end
end

-- Add trackable skills table
SUP.trackableSkills = {
    -- Primary Professions
    "Alchemy", "Blacksmithing", "Enchanting", "Engineering",
    "Herbalism", "Leatherworking", "Mining",
    "Skinning", "Tailoring",

    -- Secondary Professions
    "Cooking", "First Aid", "Fishing",

    -- Weapon Skills
    "Defense", "Daggers", "Fist Weapons", "One-Handed Axes", "One-Handed Maces",
    "One-Handed Swords", "Polearms", "Staves", "Two-Handed Axes",
    "Two-Handed Maces", "Two-Handed Swords", "Bows", "Crossbows",
    "Guns", "Thrown", "Wands", "Unarmed"
}

-- Add skill icons
SUP.skillIcons = {
    -- Primary Professions
    Alchemy = "Interface\\Icons\\Trade_Alchemy",
    Blacksmithing = "Interface\\Icons\\Trade_Blacksmithing",
    Enchanting = "Interface\\Icons\\Trade_Engraving",
    Engineering = "Interface\\Icons\\Trade_Engineering",
    Herbalism = "Interface\\Icons\\Trade_Herbalism",
    Leatherworking = "Interface\\Icons\\Trade_Leatherworking",
    Mining = "Interface\\Icons\\Trade_Mining",
    Skinning = "Interface\\Icons\\INV_Misc_Pelt_Wolf_01",
    Tailoring = "Interface\\Icons\\Trade_Tailoring",

    -- Secondary Professions
    Cooking = "Interface\\Icons\\INV_Misc_Food_15",
    ["First Aid"] = "Interface\\Icons\\Spell_Holy_SealOfSacrifice",
    Fishing = "Interface\\Icons\\Trade_Fishing",

    -- Weapon Skills
    Defense = "Interface\\Icons\\Ability_Defense",
    Daggers = "Interface\\Icons\\INV_Weapon_ShortBlade_01",
    ["Fist Weapons"] = "Interface\\Icons\\INV_Gauntlets_04",
    ["One-Handed Axes"] = "Interface\\Icons\\INV_Axe_01",
    ["One-Handed Maces"] = "Interface\\Icons\\INV_Mace_01",
    ["One-Handed Swords"] = "Interface\\Icons\\INV_Sword_04",
    Polearms = "Interface\\Icons\\INV_Spear_06",
    Staves = "Interface\\Icons\\INV_Staff_02",
    ["Two-Handed Axes"] = "Interface\\Icons\\INV_Axe_09",
    ["Two-Handed Maces"] = "Interface\\Icons\\INV_Hammer_05",
    ["Two-Handed Swords"] = "Interface\\Icons\\INV_Sword_05",
    Bows = "Interface\\Icons\\INV_Weapon_Bow_07",
    Crossbows = "Interface\\Icons\\INV_Weapon_Crossbow_02",
    Guns = "Interface\\Icons\\INV_Weapon_Rifle_01",
    Thrown = "Interface\\Icons\\INV_ThrowingKnife_02",
    Wands = "Interface\\Icons\\INV_Wand_01"
}

-- Create and anchor a frame
local frame = CreateFrame("Frame", "SUPFrame", UIParent)
frame:ClearAllPoints() -- Always clear points before setting new ones
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

-- Multiple anchor points example
local complexFrame = CreateFrame("Frame", "SUPComplexFrame", UIParent)
complexFrame:ClearAllPoints()
complexFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 10, -10)
complexFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -10, 10)
