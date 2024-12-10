local addonName, SUP = ...
local CreateFrame = CreateFrame
local UIParent = UIParent
local math = math
local string = string
local table = table
local UIDropDownMenu_SetWidth = UIDropDownMenu_SetWidth
local UIDropDownMenu_SetText = UIDropDownMenu_SetText
local UIDropDownMenu_Initialize = UIDropDownMenu_Initialize
local UIDropDownMenu_CreateInfo = UIDropDownMenu_CreateInfo
local UIDropDownMenu_AddButton = UIDropDownMenu_AddButton
local UIDropDownMenu_SetSelectedValue = UIDropDownMenu_SetSelectedValue

function SUP.CreateConfigFrame()
    SUP.DebugPrint("Starting config frame creation...")

    -- Create main config frame
    local frame = CreateFrame("Frame", "SUPConfigFrame", UIParent, "SUPConfigFrameTemplate")
    if not frame then
        SUP.DebugPrint("Failed to create config frame!")
        return
    end
    SUP.DebugPrint("Config frame created successfully")

    SUP.configFrame = frame

    -- Set frame properties
    frame:SetFrameStrata("DIALOG")
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:Show()

    -- Make frame movable
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- Initialize font slider
    frame.settingsContainer.FontSlider:SetValue(SUPConfig.fontSize)
    frame.settingsContainer.FontSlider:SetScript("OnValueChanged", function(self, value)
        SUPConfig.fontSize = value
        _G[self:GetName() .. "Text"]:SetText(string.format("Font Size (%d)", value))
        SUP.DebugPrint("Font size set to:", value)
        -- Update any active notifications
        for _, notification in ipairs(SUP.activeNotifications) do
            local fontPath = notification.text:GetFont()
            notification.text:SetFont(fontPath, value)
            notification.icon:SetSize(value * 1.7, value * 1.7)
        end

        -- Update anchor frame if it exists and is shown
        if SUP.anchorFrame and SUP.anchorFrame:IsShown() then
            for _, region in ipairs({ SUP.anchorFrame:GetRegions() }) do
                if region.GetObjectType and region:GetObjectType() == "FontString" then
                    local fontPath = region:GetFont()
                    region:SetFont(fontPath, value)

                    local width = SUP.CalculateNotificationWidth(value, region, false) * 1.2
                    local height = value * 2.5
                    SUP.anchorFrame:SetSize(width, height)
                    break
                end
            end
        end
    end)

    -- Set initial text values
    _G[frame.settingsContainer.FontSlider:GetName() .. "Text"]:SetText(string.format("Font Size (%d)", SUPConfig
        .fontSize))
    if frame.settingsContainer.DurationSlider then
        _G[frame.settingsContainer.DurationSlider:GetName() .. "Text"]:SetText(string.format("Duration (%.1fs)",
            SUPConfig.duration))
    end

    -- Initialize duration slider
    if frame.settingsContainer.DurationSlider then
        local initialDuration = SUPConfig.duration or 1.5
        frame.settingsContainer.DurationSlider:SetValue(initialDuration)
        frame.settingsContainer.DurationSlider:SetScript("OnValueChanged", function(self, value)
            SUPConfig.duration = value
            _G[self:GetName() .. "Text"]:SetText(string.format("Duration (%.1fs)", value))
            SUP.DebugPrint("Duration set to:", value)
        end)
    end

    -- Initialize volume slider
    if frame.settingsContainer.VolumeSlider then
        local initialVolume = SUPConfig.soundVolume or 100
        frame.settingsContainer.VolumeSlider:SetValue(initialVolume)
        frame.settingsContainer.VolumeSlider:SetScript("OnValueChanged", function(self, value)
            SUPConfig.soundVolume = value
            _G[self:GetName() .. "Text"]:SetText(string.format("Sound Volume (%d%%)", value))
            SUP.DebugPrint("Sound volume set to:", value)
        end)
    end

    -- Initialize checkboxes
    frame.settingsContainer.checkboxContainer.iconCheckbox:SetChecked(SUPConfig.showIcon)
    frame.settingsContainer.checkboxContainer.soundCheckbox:SetChecked(SUPConfig.playSound)

    -- Setup checkbox scripts
    frame.settingsContainer.checkboxContainer.iconCheckbox:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()
        SUPConfig.showIcon = isChecked
        SUP.DebugPrint("Icon checkbox clicked. New state:", isChecked)
        SUP.DebugPrint("SUPConfig.showIcon value:", SUPConfig.showIcon)
    end)

    frame.settingsContainer.checkboxContainer.soundCheckbox:SetScript("OnClick", function(self)
        SUPConfig.playSound = self:GetChecked()
        SUP.DebugPrint("Sound checkbox clicked. New state:", SUPConfig.playSound)
    end)

    -- Setup test button
    local testButton = frame.settingsContainer.TestButton
    testButton:SetScript("OnClick", function()
        local randomSkill = SUP.trackableSkills[math.random(#SUP.trackableSkills)]
        local randomLevel = math.random(1, 300)
        SUP.ShowNotification(randomSkill, randomLevel)
    end)

    -- Setup position button and anchor frame
    local positionButton = frame.settingsContainer.positionButton

    positionButton:SetScript("OnClick", function()
        local fontSize = SUPConfig.fontSize
        local height = fontSize * 2.5

        if not SUP.anchorFrame then
            SUP.positionButton = positionButton
            SUP.anchorFrame = SUP.CreateAnchorFrame()
        end

        -- Update size and font dynamically
        local width = SUP.CalculateNotificationWidth(fontSize, SUP.anchorFrame.text, false) * 1.2
        SUP.anchorFrame:SetSize(width, height)
        SUP.anchorFrame.text:SetFont(SUP.anchorFrame.text:GetFont(), fontSize)

        -- Show the anchor frame and update button text immediately
        if not SUP.anchorFrame:IsShown() then
            SUP.anchorFrame:Show()
            positionButton:SetText("Save Position")
        else
            SUP.anchorFrame:Hide()
            positionButton:SetText("Edit Position")
        end
    end)

    -- Set version text
    local versionText = _G[frame:GetName() .. "Version"]
    if versionText then
        local version = GetAddOnMetadata(addonName, "Version")
        versionText:SetText("v" .. version)
        SUP.DebugPrint("Version text set to:", version)
    else
        SUP.DebugPrint("Could not find version text element")
    end

    -- Initialize sound dropdown
    local soundDropdown = frame.settingsContainer.checkboxContainer.soundDropdown
    if soundDropdown then
        UIDropDownMenu_SetWidth(soundDropdown, 120)
        UIDropDownMenu_Initialize(soundDropdown, function(self, level)
            local info = UIDropDownMenu_CreateInfo()
            for soundName in pairs(SUP.SOUND_OPTIONS) do
                info.text = soundName
                info.value = soundName
                info.func = function(self)
                    _G.SUPConfig.sound = self.value
                    UIDropDownMenu_SetSelectedValue(soundDropdown, self.value)
                    -- Play sound preview
                    if SUP.SOUND_OPTIONS[self.value] then
                        PlaySound(SUP.SOUND_OPTIONS[self.value], "Master")
                    end
                end
                info.checked = (_G.SUPConfig.sound == soundName)
                UIDropDownMenu_AddButton(info)
            end
        end)
        UIDropDownMenu_SetSelectedValue(soundDropdown, _G.SUPConfig.sound or "Skill Up")
    else
        SUP.DebugPrint("Sound dropdown not found")
    end
end
