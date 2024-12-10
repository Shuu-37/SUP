local CreateFrame = CreateFrame
local UIParent = UIParent
local table = table
local string = string
local print = print
local GetAddOnMetadata = (rawget(_G, "C_AddOns") and _G.C_AddOns.GetAddOnMetadata) or rawget(_G, "GetAddOnMetadata")

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
    soundKitID = 6295, -- Profession skill up sound
    duration = 1.0
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
        print("SUP: Loaded successfully! Use /sup to open the configuration window.")
        RegisterSlashCommands()
        SUP.CreateConfigFrame() -- debug
        SUP.configFrame:Show()  -- debug
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
