local addonName, SUP = ...
local CreateFrame = CreateFrame
local UIParent = UIParent
local math = math
local string = string
local table = table

function SUP.CreateConfigFrame()
    -- Create main config frame
    local frame = CreateFrame("Frame", "SUPConfigFrame", UIParent, "SUPConfigFrameTemplate")
    SUP.configFrame = frame

    -- Make frame movable
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- Declare anchorFrame at the top level of the function
    local anchorFrame = nil

    -- Initialize font slider
    frame.controlsContainer.FontSlider:SetValue(SUPConfig.fontSize)
    frame.controlsContainer.FontSlider:SetScript("OnValueChanged", function(self, value)
        SUPConfig.fontSize = value
        SUP.DebugPrint("Font size set to:", value)
        -- Update any active notifications
        for _, notification in ipairs(SUP.activeNotifications) do
            local fontPath = notification.text:GetFont()
            notification.text:SetFont(fontPath, value)
            notification.icon:SetSize(value * 1.7, value * 1.7)
        end

        -- Update anchor frame if it exists and is shown
        if anchorFrame and anchorFrame:IsShown() then
            for _, region in ipairs({ anchorFrame:GetRegions() }) do
                if region.GetObjectType and region:GetObjectType() == "FontString" then
                    local fontPath = region:GetFont()
                    region:SetFont(fontPath, value)

                    local width = SUP.CalculateNotificationWidth(value, region, false) * 1.2
                    local height = value * 2.5
                    anchorFrame:SetSize(width, height)
                    break
                end
            end
        end
    end)

    -- Initialize checkboxes
    frame.checkboxContainer.iconCheckbox:SetChecked(SUPConfig.showIcon)
    frame.checkboxContainer.soundCheckbox:SetChecked(SUPConfig.playSound)
    frame.checkboxContainer.debugCheckbox:SetChecked(SUPConfig.debugMode)

    -- Setup checkbox scripts
    frame.checkboxContainer.iconCheckbox:SetScript("OnClick", function(self)
        SUPConfig.showIcon = self:GetChecked()
    end)

    frame.checkboxContainer.soundCheckbox:SetScript("OnClick", function(self)
        SUPConfig.playSound = self:GetChecked()
    end)

    frame.checkboxContainer.debugCheckbox:SetScript("OnClick", function(self)
        SUPConfig.debugMode = self:GetChecked()
    end)

    -- Setup test button
    local testButton = _G[frame:GetName() .. "TestButton"]
    testButton:SetScript("OnClick", function()
        local randomSkill = SUP.trackableSkills[math.random(#SUP.trackableSkills)]
        local randomLevel = math.random(1, 300)
        SUP.ShowNotification(randomSkill, randomLevel)
    end)

    -- Setup position button and anchor frame
    local positionButton = frame.controlsContainer.positionButton

    positionButton:SetScript("OnClick", function()
        local fontSize = SUPConfig.fontSize
        local height = fontSize * 2.5

        SUP.DebugPrint("Font Size:", fontSize, "Calculated Height:", height)

        if not anchorFrame then
            anchorFrame = SUP.CreateAnchorFrame(positionButton)
        end

        -- Update size and font dynamically
        local width = SUP.CalculateNotificationWidth(fontSize, anchorFrame.text, false) * 1.2
        anchorFrame:SetSize(width, height)
        anchorFrame.text:SetFont(anchorFrame.text:GetFont(), fontSize)

        SUP.DebugPrint("Frame size updated:", "Width:", width, "Height:", height, "Visible:", anchorFrame:IsShown())

        anchorFrame:ToggleVisibility()
    end)
end
