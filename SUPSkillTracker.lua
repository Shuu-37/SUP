local addonName, SUP = ...

-- Initialize the skill tracker
SUP.SkillTracker = {}
SUP.lastKnownSkills = {}

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
    "Swords",
    "Polearms", "Staves", "Two-Handed Axes",
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
    Defense = "Interface\\Icons\\Ability_Defend",
    Daggers = "Interface\\Icons\\INV_Weapon_ShortBlade_01",
    ["Fist Weapons"] = "Interface\\Icons\\INV_Gauntlets_04",
    ["One-Handed Axes"] = "Interface\\Icons\\INV_Axe_01",
    ["One-Handed Maces"] = "Interface\\Icons\\INV_Mace_01",
    Swords = "Interface\\Icons\\INV_Sword_04",
    Polearms = "Interface\\Icons\\INV_Spear_06",
    Staves = "Interface\\Icons\\INV_Staff_02",
    ["Two-Handed Axes"] = "Interface\\Icons\\INV_Axe_09",
    ["Two-Handed Maces"] = "Interface\\Icons\\INV_Hammer_05",
    ["Two-Handed Swords"] = "Interface\\Icons\\INV_Sword_04",
    Bows = "Interface\\Icons\\INV_Weapon_Bow_07",
    Crossbows = "Interface\\Icons\\INV_Weapon_Crossbow_02",
    Guns = "Interface\\Icons\\INV_Weapon_Rifle_01",
    Thrown = "Interface\\Icons\\INV_ThrowingKnife_02",
    Wands = "Interface\\Icons\\INV_Wand_01",
    Unarmed = "Interface\\Icons\\INV_Gauntlets_04"
}

function SUP.SkillTracker.GetProfessionLevel(index)
    if not index then return nil end
    local name, isHeader, _, rank = GetSkillLineInfo(index)
    if isHeader then return nil end
    return name, rank, name -- Using name as skillLine since Classic doesn't have separate skillLine IDs
end

function SUP.SkillTracker.ScanSkills()
    local skillData = {}

    -- Scan all skill lines
    for i = 1, GetNumSkillLines() do
        local name, isHeader, _, rank = GetSkillLineInfo(i)
        if not isHeader then
            for _, trackableSkill in ipairs(SUP.trackableSkills) do
                if name == trackableSkill then
                    skillData[name] = { name = name, rank = rank }
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
        if lastKnown and currentData.rank > lastKnown.rank then
            SUP.DebugPrint(string.format("Skill up detected: %s (%d -> %d)",
                currentData.name, lastKnown.rank, currentData.rank))
            SUP.ShowNotification(currentData.name, currentData.rank)
        end
    end

    -- Update last known skills
    SUP.lastKnownSkills = currentSkills
end
