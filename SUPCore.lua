local addonName, SUP = ...
local L = SUP.Locals

-- Create the main addon frame for event handling
SUP.frame = L.CreateFrame("Frame")

-- Initialize saved variables with defaults if they don't exist
SUPConfig = SUPConfig or {
    fontSize = 14,
    showIcon = true,
    debugMode = false,
    position = { x = 0, y = 0 },
    skillTrackerPosition = { x = 0, y = 0 },
    playSound = true,
    soundKitID = 6295, -- Profession skill up sound
    duration = 1.0
}

-- Register slash commands after ADDON_LOADED
local function RegisterSlashCommands()
    SLASH_SUP1 = "/sup"
    SlashCmdList["SUP"] = function(msg)
        SUP.DebugPrint("Slash command received")
        if SUP.configFrame then
            SUP.DebugPrint("Showing existing config frame")
            SUP.configFrame:Show()
        else
            SUP.DebugPrint("Creating new config frame")
            SUP.CreateConfigFrame()

            -- Debug frame properties after creation
            local frame = SUP.configFrame
            if frame then
                SUP.DebugPrint("Frame Properties:",
                    "IsVisible:", frame:IsVisible(),
                    "Alpha:", frame:GetAlpha(),
                    "Width:", frame:GetWidth(),
                    "Height:", frame:GetHeight(),
                    "Parent:", frame:GetParent():GetName()
                )
            else
                SUP.DebugPrint("Frame is not defined.")
            end

            if SUP.configFrame then
                SUP.DebugPrint("Config frame created successfully")
                SUP.configFrame:Show()
            else
                SUP.DebugPrint("Failed to create config frame!")
            end
        end
    end
end

-- Event handling
SUP.frame:RegisterEvent("ADDON_LOADED")
SUP.frame:RegisterEvent("SKILL_LINES_CHANGED")
SUP.frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
        print("SUP: Loaded successfully! Use /sup to open the configuration window.")
        RegisterSlashCommands()
        -- Creates the configFrame and shows it immediately on load
        SUP.CreateConfigFrame() -- DEBUG REMOVE
        SUP.configFrame:Show()  -- DEBUG REMOVE
        -- Create the anchor frame immediately on load
        if not SUP.anchorFrame then
            SUP.anchorFrame = SUP.CreateAnchorFrame()
        end
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
