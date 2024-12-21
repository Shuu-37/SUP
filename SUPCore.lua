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
    skillTrackerPosition = {
        point = "CENTER",
        relativePoint = "CENTER",
        x = 0,
        y = 0
    },
    trackerSize = {
        width = 200,
        height = 150
    },
    playSound = true,
    sound = "Skill Up",
    soundKitID = 6295,             -- Profession skill up sound
    duration = 1.0,
    trackerDisplayVisible = false, -- Add this new variable for initial visibility state
    trackerStyle = {               -- Add default tracker style settings
        spacing = 2,               -- MIN_SPACING
        iconSize = 20.5,
        fontSize = 12.0,
        barHeight = 2,
        entryHeight = 25 -- MIN_ENTRY_HEIGHT
    }
}

-- Register slash commands after ADDON_LOADED
local function RegisterSlashCommands()
    SLASH_SUP1 = "/sup"
    SLASH_SUP2 = "/sup reset"
    SlashCmdList["SUP"] = function(msg)
        if msg == "reset" then
            -- Reset all saved variables
            SUPConfig = {
                fontSize = 14,
                showIcon = true,
                debugMode = false,
                position = {
                    point = "CENTER",
                    relativePoint = "CENTER",
                    x = 0,
                    y = 0
                },
                skillTrackerPosition = {
                    point = "CENTER",
                    relativePoint = "CENTER",
                    x = 0,
                    y = 0
                },
                trackerSize = {
                    width = 200,
                    height = 150
                },
                playSound = true,
                sound = "Skill Up",
                soundKitID = 6295,
                duration = 1.0,
                trackerDisplayVisible = false,
                trackerStyle = {
                    spacing = 2,
                    iconSize = 20.5,
                    fontSize = 12.0,
                    barHeight = 2,
                    entryHeight = 25
                }
            }
            SUPTrackedSkills = {}

            -- Force position update if tracker exists
            if SUP.skillTrackerDisplay then
                SUP.skillTrackerDisplay:ClearAllPoints()
                SUP.skillTrackerDisplay:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
                SUP.skillTrackerDisplay:Hide()
            end

            -- Force position update if anchor frame exists
            if SUP.anchorFrame then
                SUP.anchorFrame:ClearAllPoints()
                SUP.anchorFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
                SUP.anchorFrame:Hide()
            end

            print("SUP: All saved variables have been reset to defaults. Please /reload to apply changes.")
            return
        end

        -- Original command handling
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
        -- SUP.CreateConfigFrame() -- DEBUG REMOVE
        -- SUP.configFrame:Show()  -- DEBUG REMOVE
        -- Create the anchor frame immediately on load
        if not SUP.anchorFrame then
            SUP.anchorFrame = SUP.CreateAnchorFrame()
        end
        SUP.SkillTracker.Initialize()
        -- Create the skill tracker display and set initial visibility
        SUP.skillTrackerDisplay = SUP.CreateSkillTrackerDisplay()
        -- Initial visibility is handled in CreateSkillTrackerDisplay now
    elseif event == "SKILL_LINES_CHANGED" then
        SUP.SkillTracker.CheckForUpdates()
    end
end)
function SUP.DebugPrint(...)
    if SUPConfig.debugMode then
        print("|cFF00FF00[SUP Debug]|r", ...)
    end
end
