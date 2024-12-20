local addonName, SUP = ...
local L = SUP.Locals

function SUP.CreateSkillTrackerDisplay()
    -- Set up resizing with dynamic minimum size based on entries
    local MIN_ENTRY_HEIGHT = 25 -- Minimum height per entry
    local MIN_SPACING = 2       -- Minimum spacing between entries
    local BAR_OFFSET = 1        -- Fixed offset for progress bars below content
    local MIN_WIDTH = 150
    local MIN_HEIGHT = 100

    -- Initialize saved variables if they don't exist
    SUPConfig.trackerShown = SUPConfig.trackerShown or false
    SUPConfig.trackerSize = SUPConfig.trackerSize or { width = 200, height = 150 }
    SUPConfig.trackerStyle = SUPConfig.trackerStyle or {
        spacing = MIN_SPACING,
        iconSize = 20.5,
        fontSize = 12.0,
        barHeight = 2,
        entryHeight = MIN_ENTRY_HEIGHT
    }

    -- Create the main container frame
    local frame = L.CreateFrame("Frame", "SUPSkillTrackerDisplay", UIParent, "BackdropTemplate")
    Mixin(frame, BackdropTemplateMixin)

    -- Set size using individual width and height values
    frame:SetSize(200, 150) -- Set initial size
    frame:Hide()

    -- Make it movable like other frames
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- Set up resizing with dynamic minimum size based on entries
    local MIN_ENTRY_HEIGHT = 25 -- Minimum height per entry
    local MIN_SPACING = 2       -- Minimum spacing between entries
    local BAR_OFFSET = 1        -- Fixed offset for progress bars below content
    local MIN_WIDTH = 150
    local MIN_HEIGHT = 100
    local ASPECT_RATIO = MIN_WIDTH / MIN_HEIGHT
    frame:SetResizable(true)

    -- Function to calculate minimum height based on visible entries
    local function GetMinimumHeight()
        local visibleEntries = 0
        for _, entry in pairs(frame.entries) do
            if entry:IsShown() then
                visibleEntries = visibleEntries + 1
            end
        end
        local spacing = SUPConfig.trackerStyle.spacing or 2
        return (MIN_ENTRY_HEIGHT * visibleEntries) +
            (spacing * math.max(0, visibleEntries - 1)) +
            10 -- padding
    end

    -- Create resize button
    local resizeButton = CreateFrame("Button", nil, frame)
    resizeButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 20, 0)
    resizeButton:SetSize(16, 16)
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeButton:Hide()
    resizeButton:SetFrameLevel(frame:GetFrameLevel() + 2)

    -- Create invisible hover extension frame
    local hoverExtension = CreateFrame("Frame", nil, frame)
    hoverExtension:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 20, 0)
    hoverExtension:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 20, 0)
    hoverExtension:SetWidth(20)
    hoverExtension:SetFrameLevel(frame:GetFrameLevel() + 1)

    -- Show/hide resize button on hover
    frame:HookScript("OnEnter", function() resizeButton:Show() end)
    hoverExtension:HookScript("OnEnter", function() resizeButton:Show() end)
    frame:HookScript("OnLeave", function()
        if not frame.isSizing then
            resizeButton:Hide()
        end
    end)
    hoverExtension:HookScript("OnLeave", function()
        if not frame.isSizing then
            resizeButton:Hide()
        end
    end)

    -- Keep button visible while resizing
    resizeButton:HookScript("OnEnter", function() resizeButton:Show() end)
    resizeButton:HookScript("OnLeave", function()
        if not frame.isSizing then
            resizeButton:Hide()
        end
    end)

    -- Set up resize functionality
    resizeButton:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            frame:StartSizing("BOTTOMRIGHT")
            frame.isSizing = true
        end
    end)

    resizeButton:SetScript("OnMouseUp", function(self, button)
        frame:StopMovingOrSizing()
        frame.isSizing = false
        -- Save the new size
        SUPConfig.trackerSize.width = frame:GetWidth()
        SUPConfig.trackerSize.height = frame:GetHeight()
        SUP.DebugPrint(string.format("Tracker resized to: %.0f x %.0f", frame:GetWidth(), frame:GetHeight()))
    end)

    -- Container for skill entries
    local skillContainer = L.CreateFrame("Frame", nil, frame)
    skillContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    skillContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    frame.skillContainer = skillContainer

    -- Function to create a skill entry
    local function CreateSkillEntry(skillName)
        local entry = L.CreateFrame("Frame", nil, skillContainer)
        entry:SetHeight(SUPConfig.trackerStyle.entryHeight or MIN_ENTRY_HEIGHT)
        entry:SetPoint("LEFT", 0, 0)
        entry:SetPoint("RIGHT", 0, 0)

        -- Skill icon
        local icon = entry:CreateTexture(nil, "ARTWORK")
        icon:SetSize(SUPConfig.trackerStyle.iconSize or 20.5, SUPConfig.trackerStyle.iconSize or 20.5)
        icon:SetPoint("LEFT", entry, "LEFT", 5, 0)
        icon:SetTexture(SUP.skillIcons[skillName] or "Interface\\Icons\\INV_Misc_QuestionMark")

        -- Skill name
        local name = entry:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        name:SetPoint("LEFT", icon, "RIGHT", 5, 0)
        name:SetText(skillName)
        name:SetFont(name:GetFont(), SUPConfig.trackerStyle.fontSize or 12.0)

        -- Skill level text
        local levelText = entry:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        levelText:SetPoint("RIGHT", entry, "RIGHT", -5, 0)
        levelText:SetFont(levelText:GetFont(), SUPConfig.trackerStyle.fontSize or 12.0)

        -- Progress bar background
        local spacing = SUPConfig.trackerStyle.spacing or MIN_SPACING
        local barBg = entry:CreateTexture(nil, "BACKGROUND")
        barBg:SetPoint("TOPLEFT", entry, "BOTTOMLEFT", 5, spacing)
        barBg:SetPoint("BOTTOMRIGHT", entry, "BOTTOMRIGHT", -5, -spacing)
        barBg:SetColorTexture(0, 0, 0, 0.8)

        -- Progress bar foreground
        local barFg = entry:CreateTexture(nil, "ARTWORK")
        barFg:SetPoint("TOPLEFT", barBg, "TOPLEFT", 0, 0)
        barFg:SetPoint("BOTTOM", barBg, "BOTTOM", 0, 0)
        barFg:SetColorTexture(0.25, 0.5, 1.0, 1.0)

        entry.icon = icon
        entry.name = name
        entry.levelText = levelText
        entry.barBg = barBg
        entry.barFg = barFg

        -- Function to update the entry's progress
        function entry:UpdateProgress(current, max)
            if not current or not max then return end -- Guard against nil values
            self.levelText:SetText(string.format("%d/%d", current, max))
            local width = self.barBg:GetWidth()
            if width > 0 then -- Only update if we have a valid width
                local progress = math.min(1, math.max(0, current / max))
                self.barFg:SetWidth(math.max(1, width * progress))
            end
        end

        return entry
    end

    -- Function to update the display
    function frame:UpdateDisplay()
        SUP.DebugPrint("UpdateDisplay called")
        local yOffset = 0
        local currentSkills = SUP.SkillTracker.ScanSkills()

        -- Create sorted list of tracked skills
        local sortedSkills = {}
        local currentSkills = SUP.SkillTracker.ScanSkills()

        -- Get skills in the same order as they appear in the game's skill list
        local orderedSkills = {}
        for i = 1, L.GetNumSkillLines() do
            local name, isHeader = L.GetSkillLineInfo(i)
            if not isHeader and currentSkills[name] and _G.SUPTrackedSkills[name] then
                table.insert(orderedSkills, name)
            end
        end

        -- Add skills in the original game order
        for _, skillName in ipairs(orderedSkills) do
            table.insert(sortedSkills, {
                name = skillName,
                data = currentSkills[skillName]
            })
        end

        -- Hide all existing entries
        for _, child in pairs({ self.skillContainer:GetChildren() }) do
            child:Hide()
        end

        -- Create/update entries for tracked skills
        for _, skillInfo in ipairs(sortedSkills) do
            local skillName = skillInfo.name
            local skillData = skillInfo.data
            local spacing = math.max(2, SUPConfig.trackerStyle.spacing or 2)

            -- If skill data is missing or rank is 0, try to get current skill info
            if not skillData or not skillData.rank or skillData.rank == 0 then
                local currentRank, maxRank = SUP.SkillTracker.GetSkillRank(skillName)
                if currentRank and maxRank then
                    skillData = { rank = currentRank, max = maxRank }
                end
            end

            local entry = self.entries[skillName]
            if not entry then
                SUP.DebugPrint("Adding new skill to tracker:", skillName)
                entry = CreateSkillEntry(skillName)
                self.entries[skillName] = entry
            end

            entry:Show()
            entry:SetPoint("TOPLEFT", self.skillContainer, "TOPLEFT", 0, yOffset)

            -- Ensure we have valid values before updating progress
            if skillData and skillData.rank and skillData.max then
                entry:UpdateProgress(skillData.rank, skillData.max)
                SUP.DebugPrint(string.format("Updating skill: %s (%d/%d)", skillName, skillData.rank, skillData.max))
            else
                -- Set a default state if we don't have valid data
                entry:UpdateProgress(0, 1)
                SUP.DebugPrint(string.format("Warning: Missing data for skill: %s", skillName))
            end

            -- Ensure bar visibility and width after position update
            if entry.barBg and entry.barFg then
                entry.barBg:Show()
                entry.barFg:Show()
                -- Force bar width update
                local width = entry.barBg:GetWidth()
                if width > 0 and skillData and skillData.rank and skillData.max then
                    local progress = math.min(1, math.max(0, skillData.rank / skillData.max))
                    entry.barFg:SetWidth(math.max(1, width * progress))
                end
            end

            -- Update spacing for next entry using saved height
            local entryHeight = SUPConfig.trackerStyle.entryHeight or MIN_ENTRY_HEIGHT
            yOffset = yOffset - (entryHeight + spacing)
        end

        -- Update container height
        self.skillContainer:SetHeight(math.abs(yOffset))
        -- self:SetHeight(math.abs(yOffset) + 10)
    end

    -- Add resize update to maintain aspect ratio and update content
    frame:SetScript("OnSizeChanged", function(self, width, height)
        SUP.DebugPrint("OnSizeChanged called - width:", width, "height:", height)
        -- Calculate minimum height based on current entries
        local minHeight = GetMinimumHeight()

        if self.isSizing then
            -- Enforce minimum sizes
            width = math.max(MIN_WIDTH, width)
            height = math.max(minHeight, height)
            self:SetSize(width, height)
        end

        -- Calculate available space
        local availableHeight = height - 10 -- Account for padding
        local visibleEntries = 0
        for _, entry in pairs(self.entries) do
            if entry:IsShown() then
                visibleEntries = visibleEntries + 1
            end
        end

        -- Calculate entry height and save it
        local newEntryHeight = MIN_ENTRY_HEIGHT -- Default value
        if visibleEntries > 0 then
            local spacing = math.max(2, SUPConfig.trackerStyle.spacing or 2)
            local totalSpacing = (visibleEntries - 1) * spacing
            newEntryHeight = math.max(MIN_ENTRY_HEIGHT, (availableHeight - totalSpacing) / visibleEntries)

            -- Only update if the height actually changed
            if newEntryHeight ~= SUPConfig.trackerStyle.entryHeight then
                SUPConfig.trackerStyle.entryHeight = newEntryHeight
                -- Force an update of all entries with the new height
                for _, entry in pairs(self.entries) do
                    if entry:IsShown() then
                        entry:SetHeight(newEntryHeight)
                    end
                end
            end
        end

        -- Calculate common dimensions for all entries
        local iconSize = SUPConfig.trackerStyle.iconSize or 20.5
        local fontSize = SUPConfig.trackerStyle.fontSize or 12.0
        local spacing = SUPConfig.trackerStyle.spacing or 2

        -- Calculate bar height based on entry height
        local barHeight = math.max(1, newEntryHeight * 0.08) -- 8% of entry height, minimum 1 pixel
        SUPConfig.trackerStyle.barHeight = barHeight         -- Store the calculated height

        -- Update debug output with actual values being used
        SUP.DebugPrint(string.format("Sizes - Icon: %.1f, Font: %.1f, Bar: %.1f",
            iconSize, fontSize, SUPConfig.trackerStyle.barHeight))
        SUP.DebugPrint(string.format("Frame size: %d x %d (min height: %d)", width, height, minHeight))
        SUP.DebugPrint(string.format("Entries: %d, Entry Height: %.1f", visibleEntries, newEntryHeight))

        -- Update container size
        skillContainer:SetWidth(width - 16)

        -- Update all visible entries
        local yOffset = 0
        for _, entry in pairs(self.entries) do
            if entry:IsShown() then
                -- Clear all points first
                entry:ClearAllPoints()

                -- Set up entry frame
                entry:SetHeight(newEntryHeight)
                entry:SetPoint("TOPLEFT", skillContainer, "TOPLEFT", 0, yOffset)
                entry:SetWidth(skillContainer:GetWidth())

                -- Resize and position icon
                entry.icon:SetSize(iconSize, iconSize)
                entry.icon:ClearAllPoints()
                entry.icon:SetPoint("LEFT", entry, "LEFT", 5, 0)

                -- Update fonts
                entry.name:SetFont(entry.name:GetFont(), fontSize)
                entry.levelText:SetFont(entry.levelText:GetFont(), fontSize)

                -- Apply consistent bar dimensions to all entries
                entry.barBg:ClearAllPoints()
                entry.barBg:SetPoint("TOPLEFT", entry.icon, "BOTTOMLEFT", 0, -BAR_OFFSET)
                entry.barBg:SetPoint("RIGHT", entry, "RIGHT", -spacing, 0)
                entry.barBg:SetHeight(math.max(1, barHeight))

                entry.barFg:ClearAllPoints()
                entry.barFg:SetPoint("TOPLEFT", entry.barBg, "TOPLEFT", 0, 0)
                entry.barFg:SetHeight(math.max(1, barHeight))
                -- Ensure the bar stays within bounds
                local width = entry.barBg:GetWidth()
                if width > 0 then
                    local progress = tonumber(entry.levelText:GetText():match("(%d+)")) or 0
                    local max = tonumber(entry.levelText:GetText():match("/(%d+)")) or 1
                    local barWidth = math.max(1, width * (progress / max))
                    entry.barFg:SetWidth(barWidth)
                end

                -- Update progress
                local current, max = entry.levelText:GetText():match("(%d+)/(%d+)")
                if current and max then
                    entry:UpdateProgress(tonumber(current), tonumber(max))
                end

                -- Update spacing for next entry
                yOffset = yOffset - (newEntryHeight + spacing)
            end
        end

        -- Update container height
        local contentHeight = math.abs(yOffset)
        skillContainer:SetHeight(contentHeight)

        -- Update resize bounds
        self:SetResizeBounds(MIN_WIDTH, minHeight)

        SUP.DebugPrint(string.format("Frame size: %d x %d (min height: %d)", width, height, minHeight))
        SUP.DebugPrint(string.format("Entries: %d, Entry Height: %.1f", visibleEntries, newEntryHeight))
        SUP.DebugPrint(string.format("Sizes - Icon: %.1f, Font: %.1f, Bar: %.1f",
            iconSize, fontSize, barHeight))
    end)

    -- Initialize entries table
    frame.entries = {}

    -- Position the frame using saved position
    if SUPConfig.skillTrackerPosition then
        frame:ClearAllPoints()
        frame:SetPoint(
            SUPConfig.skillTrackerPosition.point or "CENTER",
            UIParent,
            SUPConfig.skillTrackerPosition.relativePoint or "CENTER",
            SUPConfig.skillTrackerPosition.x or 0,
            SUPConfig.skillTrackerPosition.y or 0
        )
    end

    -- Update when skills change
    frame:RegisterEvent("SKILL_LINES_CHANGED")
    frame:SetScript("OnEvent", function(self, event)
        if event == "SKILL_LINES_CHANGED" then
            self:UpdateDisplay()
        end
    end)

    -- Add debug logging for visibility changes
    frame:HookScript("OnShow", function()
        SUP.DebugPrint("Tracker frame shown")
        SUPConfig.trackerShown = true
    end)

    frame:HookScript("OnHide", function()
        SUP.DebugPrint("Tracker frame hidden")
        SUPConfig.trackerShown = false
    end)

    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- Save position
        local point, _, relativePoint, x, y = self:GetPoint()
        SUPConfig.skillTrackerPosition = {
            point = point,
            relativePoint = relativePoint,
            x = x,
            y = y
        }
    end)

    -- Set initial size using saved values
    frame:SetSize(
        SUPConfig.trackerSize.width or 200,
        SUPConfig.trackerSize.height or 150
    )

    -- Trigger an initial resize to set up entry heights
    frame:GetScript("OnSizeChanged")(frame, frame:GetWidth(), frame:GetHeight())

    return frame
end
