local addonName, SUP = ...

-- Initialize the skill tracker
SUP.SkillTracker = {}
SUP.lastKnownSkills = {}

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
