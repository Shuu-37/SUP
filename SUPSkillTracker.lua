local addonName, SUP = ...
local L = SUP.Locals

-- Initialize the skill tracker and saved variables
SUP.SkillTracker = {}
SUP.lastKnownSkills = {}
_G.SUPTrackedSkills = _G.SUPTrackedSkills or {}

-- Add trackable skills table with proper ordering
SUP.skillOrder = {
    -- Primary Professions
    "Alchemy",
    "Blacksmithing",
    "Enchanting",
    "Engineering",
    "Herbalism",
    "Leatherworking",
    "Mining",
    "Skinning",
    "Tailoring",

    -- Secondary Professions
    "Cooking",
    "First Aid",
    "Fishing",

    -- Weapon Skills
    "Axes",
    "Bows",
    "Crossbows",
    "Daggers",
    "Defense",
    "Fist Weapons",
    "Guns",
    "Maces",
    "Polearms",
    "Staves",
    "Swords",
    "Thrown",
    "Two-Handed Axes",
    "Two-Handed Maces",
    "Two-Handed Swords",
    "Unarmed",
    "Wands"
}

-- Update trackable skills to match the new order
SUP.trackableSkills = {}
for _, skillName in ipairs(SUP.skillOrder) do
    table.insert(SUP.trackableSkills, skillName)
end

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
    Defense = "Interface\\Icons\\Ability_Defend",
    Axes = "Interface\\Icons\\INV_Axe_01",
    ["Two-Handed Axes"] = "Interface\\Icons\\INV_Axe_09",
    Daggers = "Interface\\Icons\\INV_Weapon_ShortBlade_01",
    Maces = "Interface\\Icons\\INV_Mace_01",
    ["Two-Handed Maces"] = "Interface\\Icons\\INV_Hammer_05",
    Polearms = "Interface\\Icons\\INV_Spear_06",
    Staves = "Interface\\Icons\\INV_Staff_02",
    Swords = "Interface\\Icons\\INV_Sword_04",
    ["Two-Handed Swords"] = "Interface\\Icons\\INV_Sword_04",
    ["Fist Weapons"] = "Interface\\Icons\\INV_Gauntlets_04",
    Unarmed = "Interface\\Icons\\INV_Gauntlets_04",
    Bows = "Interface\\Icons\\INV_Weapon_Bow_07",
    Crossbows = "Interface\\Icons\\INV_Weapon_Crossbow_02",
    Guns = "Interface\\Icons\\INV_Weapon_Rifle_01",
    Thrown = "Interface\\Icons\\INV_ThrowingKnife_02",
    Wands = "Interface\\Icons\\INV_Wand_01"
}

function SUP.SkillTracker.GetProfessionLevel(index)
    if not index then return nil end
    local name, isHeader, _, rank = L.GetSkillLineInfo(index)
    if isHeader then return nil end
    return name, rank, name
end

function SUP.SkillTracker.ScanSkills()
    local skillData = {}

    -- Scan all skill lines
    for i = 1, L.GetNumSkillLines() do
        local name, isHeader, _, rank, _, _, maxRank = L.GetSkillLineInfo(i)
        if not isHeader then
            for _, trackableSkill in ipairs(SUP.trackableSkills) do
                if name and name == trackableSkill then
                    skillData[name] = { name = name, rank = rank, max = maxRank }
                    break
                end
            end
        end
    end

    return skillData
end

function SUP.SkillTracker.Initialize()
    SUP.DebugPrint("Initializing Skill Tracker")
    SUP.lastKnownSkills = SUP.SkillTracker.ScanSkills()
end

function SUP.SkillTracker.CheckForUpdates()
    SUP.DebugPrint("Checking for skill changes")
    local currentSkills = SUP.SkillTracker.ScanSkills()

    -- Compare with last known skills
    for skillId, currentData in pairs(currentSkills) do
        local lastKnown = SUP.lastKnownSkills[skillId]
        if lastKnown then
            -- Check for skill level up
            if currentData.rank > lastKnown.rank then
                SUP.DebugPrint(string.format("Skill up detected: %s (%d -> %d)",
                    currentData.name, lastKnown.rank, currentData.rank))
                SUP.ShowNotification(currentData.name, currentData.rank)
            end
            -- Check for max level change
            if currentData.max ~= lastKnown.max then
                SUP.DebugPrint(string.format("Max level changed for %s: %d -> %d",
                    currentData.name, lastKnown.max, currentData.max))
            end
        end
    end

    -- Update last known skills
    SUP.lastKnownSkills = currentSkills
end

function SUP.GetSkillIndex(skillName)
    for index, skill in ipairs(SUP.trackableSkills) do
        if skill == skillName then
            return index
        end
    end
    return 999 -- fallback for any skills not in the list
end
