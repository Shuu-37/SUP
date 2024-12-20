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

    -- Add these near the start of the function after creating the frame
    local notificationsContent = SUP.Utils.GetElement(frame, "notificationsContent")
    local trackerContent = SUP.Utils.GetElement(frame, "trackerContent")
    local notificationsTab = SUP.Utils.GetElement(frame, "tabContainer.notificationsTab")
    local trackerTab = SUP.Utils.GetElement(frame, "tabContainer.trackerTab")

    -- Add debug prints to help diagnose any issues
    SUP.DebugPrint("Notifications Content:", notificationsContent)
    SUP.DebugPrint("Tracker Content:", trackerContent)
    SUP.DebugPrint("Notifications Tab:", notificationsTab)
    SUP.DebugPrint("Tracker Tab:", trackerTab)

    -- Function to switch tabs
    local function SwitchTab(selectedTab)
        if selectedTab == "notifications" then
            notificationsContent:Show()
            trackerContent:Hide()
            notificationsTab:SetEnabled(false)
            trackerTab:SetEnabled(true)
        else
            notificationsContent:Hide()
            trackerContent:Show()
            notificationsTab:SetEnabled(true)
            trackerTab:SetEnabled(false)
            -- Update skill list when switching to tracker tab
            SUP.UpdateSkillList(trackerContent.scrollFrame.content)
        end
    end

    -- Set up tab button scripts
    if notificationsTab then
        notificationsTab:SetScript("OnClick", function()
            SwitchTab("notifications")
        end)
    end

    if trackerTab then
        trackerTab:SetScript("OnClick", function()
            SwitchTab("tracker")
        end)
    end

    -- Show notifications tab by default
    SwitchTab("notifications")

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
        fontSlider:SetValue(_G.SUPConfig.fontSize or 12)
        fontSlider:SetScript("OnValueChanged", function(self, value)
            _G.SUPConfig.fontSize = value
            self.Text:SetText(string.format("Font Size (%d)", value))
            SUP.DebugPrint("Font size set to:", value)
            -- Update any active notifications
            for _, notification in ipairs(SUP.activeNotifications or {}) do
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
        fontSliderText:SetText(string.format("Font Size (%d)", _G.SUPConfig.fontSize or 12))
    end

    -- Initialize duration slider
    local durationSlider = SUP.Utils.GetSettingsElement(frame, "DurationSlider")
    if durationSlider then
        durationSlider:SetValue(_G.SUPConfig.duration or 1.5)
        -- Set initial text value
        durationSlider.Text:SetText(string.format("Duration (%.1fs)", _G.SUPConfig.duration or 1.5))
        durationSlider:SetScript("OnValueChanged", function(self, value)
            _G.SUPConfig.duration = value
            self.Text:SetText(string.format("Duration (%.1fs)", value))
            SUP.DebugPrint("Duration set to:", value)
        end)
    end

    -- Initialize checkboxes
    local iconCheckbox = SUP.Utils.GetSettingsElement(frame, "checkboxContainer.iconCheckbox")
    local soundCheckbox = SUP.Utils.GetSettingsElement(frame, "checkboxContainer.soundCheckbox")

    if iconCheckbox then
        iconCheckbox:SetChecked(_G.SUPConfig.showIcon)
        iconCheckbox:SetScript("OnClick", function(self)
            _G.SUPConfig.showIcon = self:GetChecked()
            SUP.DebugPrint("Icon checkbox clicked. New state:", _G.SUPConfig.showIcon)
        end)
    end

    if soundCheckbox then
        soundCheckbox:SetChecked(_G.SUPConfig.playSound)
        soundCheckbox:SetScript("OnClick", function(self)
            _G.SUPConfig.playSound = self:GetChecked()
            SUP.DebugPrint("Sound checkbox clicked. New state:", _G.SUPConfig.playSound)
        end)
    end

    -- Setup test button
    local testButton = SUP.Utils.GetSettingsElement(frame, "TestButton")
    if testButton then
        testButton:SetScript("OnClick", function()
            if #SUP.trackableSkills > 0 then
                local randomSkill = SUP.trackableSkills[math.random(#SUP.trackableSkills)]
                local randomLevel = math.random(1, 300)
                SUP.ShowNotification(randomSkill, randomLevel)
                SUP.DebugPrint("Test notification shown for:", randomSkill, "Level:", randomLevel)
            else
                SUP.DebugPrint("No trackable skills found for test notification")
            end
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

-- Add this function after SUP.CreateConfigFrame()
function SUP.UpdateSkillList(scrollChild)
    -- Clear existing content
    for _, child in pairs({ scrollChild:GetChildren() }) do
        child:Hide()
        child:SetParent(nil)
    end

    local currentSkills = SUP.SkillTracker.ScanSkills()
    local yOffset = -5
    local rowHeight = 24

    -- Skill categories
    local primaryProfessions = {
        ["Alchemy"] = true,
        ["Blacksmithing"] = true,
        ["Enchanting"] = true,
        ["Engineering"] = true,
        ["Herbalism"] = true,
        ["Leatherworking"] = true,
        ["Mining"] = true,
        ["Skinning"] = true,
        ["Tailoring"] = true
    }

    local secondaryProfessions = {
        ["Cooking"] = true, ["First Aid"] = true, ["Fishing"] = true
    }

    -- Helper function to create skill row
    local function CreateSkillRow(skillName, skillData)
        local row = CreateFrame("Frame", nil, scrollChild)
        row:SetSize(320, rowHeight)
        row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 5, yOffset)

        local checkbox = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        checkbox:SetPoint("LEFT", row, "LEFT", 0, 0)
        checkbox:SetSize(24, 24)

        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(20, 20)
        icon:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
        icon:SetTexture(SUP.skillIcons[skillName] or "Interface\\Icons\\INV_Misc_QuestionMark")

        local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        nameText:SetPoint("LEFT", icon, "RIGHT", 5, 0)
        nameText:SetText(skillName)

        local levelText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        levelText:SetPoint("LEFT", nameText, "RIGHT", 6, 0)
        levelText:SetText(string.format("(%d/%d)", skillData.rank, skillData.max))
        levelText:SetTextColor(0.7, 0.7, 0.7, 1)

        yOffset = yOffset - rowHeight - 2
    end

    -- Create category headers and add skills
    local function AddCategoryHeader(text)
        -- Create a frame to hold both the background and text
        local headerFrame = CreateFrame("Frame", nil, scrollChild)
        headerFrame:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, yOffset)
        headerFrame:SetSize(320, rowHeight) -- Match your content width

        -- Create the background texture
        local bg = headerFrame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.1, 0.1, 0.1, 0.8) -- Dark semi-transparent background
        -- Alternative: Use a gradient
        -- bg:SetGradientAlpha("HORIZONTAL", 0.1, 0.1, 0.1, 0.8, 0.1, 0.1, 0.1, 0)

        -- Create the text
        local header = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        header:SetPoint("LEFT", headerFrame, "LEFT", 5, 0)
        header:SetText(text)

        yOffset = yOffset - (rowHeight)
    end

    -- Add Primary Professions
    AddCategoryHeader("Primary Professions")
    for skillName, skillData in pairs(currentSkills) do
        if primaryProfessions[skillName] then
            CreateSkillRow(skillName, skillData)
        end
    end

    -- Add Secondary Professions
    yOffset = yOffset - 10
    AddCategoryHeader("Secondary Professions")
    for skillName, skillData in pairs(currentSkills) do
        if secondaryProfessions[skillName] then
            CreateSkillRow(skillName, skillData)
        end
    end

    -- Add Weapon Skills
    yOffset = yOffset - 10
    AddCategoryHeader("Weapon Skills")
    for skillName, skillData in pairs(currentSkills) do
        if not primaryProfessions[skillName] and not secondaryProfessions[skillName] then
            CreateSkillRow(skillName, skillData)
        end
    end

    -- Update scroll child height
    scrollChild:SetHeight(math.abs(yOffset) + 5)
end
