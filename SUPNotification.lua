local addonName, SUP = ...
local L = SUP.Locals

L.PlaySound = PlaySound

SUP.activeNotifications = {}
SUP.nextNotificationId = 1

function SUP.CalculateNotificationWidth(fontSize, text, showIcon)
    local textWidth = text:GetText() and text:GetStringWidth() or 0
    local iconWidth = showIcon and (fontSize * 1.7 + 5) or 0
    return math.max(textWidth + iconWidth, 50)
end

function SUP.CreateNotificationFrame()
    SUP.DebugPrint("1. Starting frame creation")
    -- Create unique frame
    local frame = CreateFrame("Frame", "SUPNotificationFrame" .. SUP.nextNotificationId, UIParent)
    SUP.DebugPrint("2. Frame created")
    SUP.nextNotificationId = SUP.nextNotificationId + 1

    frame:SetSize(250, 50)
    frame:SetFrameStrata("HIGH")

    -- Set the initial position relative to the anchor frame
    if SUP.anchorFrame then
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", SUP.anchorFrame, "CENTER", 0, 0)
        SUP.DebugPrint("2a. Frame positioned relative to anchor frame")
    else
        -- Fallback to center if anchor frame doesn't exist
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        SUP.DebugPrint("2a. Frame positioned at center (no anchor frame)")
    end

    SUP.DebugPrint("3. Creating icon")
    -- Create icon texture
    local icon = frame:CreateTexture(nil, "OVERLAY")
    local iconSize = _G.SUPConfig.fontSize * 1.7
    icon:SetSize(iconSize, iconSize)
    icon:SetPoint("LEFT", frame, "LEFT", 5, 0)
    icon:Hide() -- Always hide initially
    frame.icon = icon

    SUP.DebugPrint("4. Creating text")
    -- Create text with initial center position
    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    text:SetPoint("CENTER", frame, "CENTER")
    frame.text = text

    local fontPath, fontSize = text:GetFont()
    text:SetFont(fontPath or "Fonts/FRIZQT__.TTF", _G.SUPConfig.fontSize)

    -- Calculate total width and adjust frame size
    local totalWidth = 250 -- Default width until text is set
    local height = _G.SUPConfig.fontSize * 2
    frame:SetSize(totalWidth, height)

    -- No need to adjust position again since we already set it relative to anchor frame

    SUP.DebugPrint("5. Setting up animation")
    -- Create animation group
    frame.animGroup = frame:CreateAnimationGroup()
    frame.animGroup:SetToFinalAlpha(true)

    local totalDuration = _G.SUPConfig.duration or 1.5
    local fadeInDuration = totalDuration * 0.2  -- First 20% for fade in
    local visibleDuration = totalDuration * 0.6 -- Middle 60% for full visibility
    local fadeOutDuration = totalDuration * 0.2 -- Last 20% for fade out

    -- Add translation (runs entire duration)
    local translate = frame.animGroup:CreateAnimation("Translation")
    translate:SetOffset(0, 60)
    translate:SetDuration(totalDuration)
    translate:SetSmoothing("OUT")
    translate:SetOrder(1)

    -- Add fade in
    local fadeIn = frame.animGroup:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(fadeInDuration)
    fadeIn:SetOrder(1)

    -- Add fade out
    local fadeOut = frame.animGroup:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(fadeOutDuration)
    fadeOut:SetStartDelay(fadeInDuration + visibleDuration) -- Start after fade in and visible duration
    fadeOut:SetOrder(1)

    SUP.DebugPrint("6. Setting up OnFinished")
    frame.animGroup:SetScript("OnFinished", function()
        for i, notification in ipairs(SUP.activeNotifications) do
            if notification == frame then
                table.remove(SUP.activeNotifications, i)
                break
            end
        end
        frame:Hide()
        frame:SetParent(nil)
    end)

    SUP.DebugPrint("7. Frame creation complete")

    return frame
end

function SUP.ShowNotification(skillName, newLevel)
    -- Input validation
    if not skillName or not newLevel then
        SUP.DebugPrint("Error: Invalid notification parameters", skillName, newLevel)
        return
    end

    SUP.DebugPrint("A. Creating notification frame")
    local frame = SUP.CreateNotificationFrame()

    SUP.DebugPrint("C. Adding to active notifications")
    table.insert(SUP.activeNotifications, frame)

    SUP.DebugPrint("D. Setting icon and text")
    -- Set the text first
    frame.text:SetText(string.format("|CFFFFFFFF%s|r increased to |CFFFFFFFF%d|r!", skillName, newLevel))

    -- Calculate initial frame size based on text
    local totalWidth = SUP.CalculateNotificationWidth(_G.SUPConfig.fontSize, frame.text, _G.SUPConfig.showIcon)
    local height = _G.SUPConfig.fontSize * 2
    frame:SetSize(totalWidth, height)

    -- Position relative to anchor frame
    if SUP.anchorFrame then
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", SUP.anchorFrame, "CENTER", 0, 0)
    end

    SUP.DebugPrint("Creating notification with showIcon:", _G.SUPConfig.showIcon)
    if not _G.SUPConfig.showIcon then
        SUP.DebugPrint("Icon should be hidden - Checking icon state:")
        SUP.DebugPrint("Icon IsShown:", frame.icon:IsShown())
        SUP.DebugPrint("Icon GetTexture:", frame.icon:GetTexture() and "has texture" or "no texture")
    end

    -- Handle icon and text positioning
    if _G.SUPConfig.showIcon then
        -- Only set texture and show icon if enabled
        frame.icon:SetTexture(SUP.skillIcons[skillName] or "Interface\\Icons\\INV_Misc_QuestionMark")
        frame.icon:ClearAllPoints()
        frame.icon:SetPoint("LEFT", frame, "LEFT", 5, 0)
        frame.icon:Show()

        frame.text:ClearAllPoints()
        frame.text:SetPoint("LEFT", frame.icon, "RIGHT", 5, 0)
    else
        frame.icon:Hide()
        frame.icon:SetTexture(nil)
        frame.icon:ClearAllPoints()
        frame.icon:SetSize(0, 0)

        frame.text:ClearAllPoints()
        frame.text:SetPoint("CENTER", frame, "CENTER")
    end

    -- Play sound first, before any visual effects
    SUP.DebugPrint("Sound check - playSound enabled:", _G.SUPConfig.playSound)
    if _G.SUPConfig.playSound then
        local soundID = SUP.SOUND_OPTIONS[_G.SUPConfig.sound]
        SUP.DebugPrint("Sound check - selected sound:", _G.SUPConfig.sound, "ID:", soundID)
        if soundID then
            L.PlaySound(soundID, "Master", false)
        end
    end

    frame:Show()
    frame.animGroup:Play()
end
