local addonName, SUP = ...
local L = SUP.Locals

function SUP.CreateConfigFrame()
    SUP.DebugPrint("Starting config frame creation...")

    -- Create main config frame
    local frame = L.CreateFrame("Frame", "SUPConfigFrame", UIParent, "SUPConfigFrameTemplate")
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
    local fontSlider = SUP.Utils.GetSettingsElement(frame, "FontSlider")
    if fontSlider then
        fontSlider:SetValue(SUPConfig.fontSize)
        fontSlider:SetScript("OnValueChanged", function(self, value)
            SUPConfig.fontSize = value
            self.Text:SetText(string.format("Font Size (%d)", value))
            SUP.DebugPrint("Font size set to:", value)
            -- Update any active notifications
            for _, notification in ipairs(SUP.activeNotifications) do
                local fontPath = notification.text:GetFont()
                notification.text:SetFont(fontPath, value)
                notification.icon:SetSize(value * 1.7, value * 1.7)
            end
            if SUP.anchorFrame then
                SUP.anchorFrame:UpdateFontSize(value)
            end
        end)
    end

    -- Set initial text values
    local fontSliderText = SUP.Utils.GetSettingsElement(frame, "FontSlider.Text")
    if fontSliderText then
        fontSliderText:SetText(string.format("Font Size (%d)", SUPConfig.fontSize))
    end

    -- Initialize duration slider
    local durationSlider = SUP.Utils.GetSettingsElement(frame, "DurationSlider")
    if durationSlider then
        durationSlider:SetValue(SUPConfig.duration or 1.5)
        -- Set initial text value
        durationSlider.Text:SetText(string.format("Duration (%.1fs)", SUPConfig.duration or 1.5))
        durationSlider:SetScript("OnValueChanged", function(self, value)
            SUPConfig.duration = value
            self.Text:SetText(string.format("Duration (%.1fs)", SUPConfig.duration))
            SUP.DebugPrint("Duration set to:", value)
        end)
    end

    -- Initialize checkboxes
    local iconCheckbox = SUP.Utils.GetSettingsElement(frame, "checkboxContainer.iconCheckbox")
    local soundCheckbox = SUP.Utils.GetSettingsElement(frame, "checkboxContainer.soundCheckbox")

    if iconCheckbox then
        iconCheckbox:SetChecked(SUPConfig.showIcon)
        iconCheckbox:SetScript("OnClick", function(self)
            SUPConfig.showIcon = self:GetChecked()
            SUP.DebugPrint("Icon checkbox clicked. New state:", SUPConfig.showIcon)
        end)
    end

    if soundCheckbox then
        soundCheckbox:SetChecked(SUPConfig.playSound)
        soundCheckbox:SetScript("OnClick", function(self)
            SUPConfig.playSound = self:GetChecked()
            SUP.DebugPrint("Sound checkbox clicked. New state:", SUPConfig.playSound)
        end)
    end

    -- Setup test button
    local testButton = SUP.Utils.GetSettingsElement(frame, "TestButton")
    if testButton then
        testButton:SetScript("OnClick", function()
            local randomSkill = SUP.trackableSkills[math.random(#SUP.trackableSkills)]
            local randomLevel = math.random(1, 300)
            SUP.ShowNotification(randomSkill, randomLevel)
        end)
    end

    -- Setup position button
    local positionButton = SUP.Utils.GetSettingsElement(frame, "positionButton")
    if positionButton then
        positionButton:SetScript("OnClick", function()
            if not SUP.anchorFrame then
                SUP.positionButton = positionButton
                SUP.anchorFrame = SUP.CreateAnchorFrame()
            end
            SUP.anchorFrame:UpdateSize()
            if not SUP.anchorFrame:IsShown() then
                SUP.anchorFrame:Show()
                positionButton:SetText("Save Position")
            else
                SUP.anchorFrame:Hide()
                positionButton:SetText("Edit Position")
            end
        end)
    end

    -- Set version text
    local versionText = SUP.Utils.GetFrameElement(frame, "$parentVersion")
    if versionText then
        local version = L.GetAddOnMetadata(addonName, "Version") or "Unknown"
        versionText:SetText("v" .. version)
        -- Add debug prints to help diagnose the issue
        SUP.DebugPrint("Version text element found:", versionText)
        SUP.DebugPrint("Setting version text to:", "v" .. version)
    else
        SUP.DebugPrint("Could not find version text element")
        -- Add additional debug info
        SUP.DebugPrint("Frame elements available:", frame:GetChildren())
    end

    -- Initialize sound dropdown
    local soundDropdown = SUP.Utils.GetSettingsElement(frame, "checkboxContainer.soundDropdown")
    if soundDropdown then
        L.UIDropDownMenu_SetWidth(soundDropdown, 120)
        L.UIDropDownMenu_Initialize(soundDropdown, function(self, level)
            local info = L.UIDropDownMenu_CreateInfo()
            for soundName in pairs(SUP.SOUND_OPTIONS) do
                info.text = soundName
                info.value = soundName
                info.func = function(self)
                    _G.SUPConfig.sound = self.value
                    L.UIDropDownMenu_SetSelectedValue(soundDropdown, self.value)
                    -- Play sound preview
                    if SUP.SOUND_OPTIONS[self.value] then
                        L.PlaySound(SUP.SOUND_OPTIONS[self.value], "Master")
                    end
                end
                info.checked = (_G.SUPConfig.sound == soundName)
                L.UIDropDownMenu_AddButton(info)
            end
        end)
        L.UIDropDownMenu_SetSelectedValue(soundDropdown, _G.SUPConfig.sound or "Skill Up")
    else
        SUP.DebugPrint("Sound dropdown not found")
    end
end
