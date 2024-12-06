local addonName, SUP = ...
SUP.activeNotifications = {}
SUP.nextNotificationId = 1

local CreateFrame = CreateFrame
local UIParent = UIParent
local table = table
local string = string
local PlaySound = PlaySound
local SOUNDKIT = SOUNDKIT

function SUP.CalculateNotificationWidth(fontSize, text, showIcon)
    local textWidth = text:GetStringWidth()
    local iconWidth = showIcon and (fontSize * 1.7 + 5) or 0 -- Icon width + padding if shown
    return textWidth + iconWidth
end

function SUP.CreateNotificationFrame()
    SUP.DebugPrint("1. Starting frame creation")
    -- Create unique frame
    local frame = CreateFrame("Frame", "SUPNotificationFrame" .. SUP.nextNotificationId, UIParent)
    SUP.DebugPrint("2. Frame created")
    SUP.nextNotificationId = SUP.nextNotificationId + 1

    frame:SetSize(250, 50)
    frame:SetFrameStrata("HIGH")
    frame:SetPoint(
        "CENTER",
        UIParent,
        "CENTER",
        SUPConfig.position.x or 0,
        SUPConfig.position.y or 0
    )
    SUP.DebugPrint("2a. Frame positioned at:", SUPConfig.position.x, SUPConfig.position.y)

    SUP.DebugPrint("3. Creating icon")
    -- Create icon texture (only if showIcon is enabled)
    local icon = frame:CreateTexture(nil, "OVERLAY")
    local iconSize = SUPConfig.fontSize * 1.7
    icon:SetSize(iconSize, iconSize)
    icon:SetPoint("LEFT", frame, "CENTER", -120, 0)
    frame.icon = icon

    SUP.DebugPrint("4. Creating text")
    -- Create text only
    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    if SUPConfig.showIcon then
        text:SetPoint("LEFT", icon, "RIGHT", 5, 0)
    else
        text:SetPoint("CENTER", frame, "CENTER")
        icon:Hide()
    end

    local fontPath, fontSize = text:GetFont()
    text:SetFont(fontPath or "Fonts/FRIZQT__.TTF", SUPConfig.fontSize)
    frame.text = text

    -- Calculate total width using helper function instead of duplicate calculation
    local totalWidth = SUP.CalculateNotificationWidth(SUPConfig.fontSize, text, SUPConfig.showIcon)
    local height = SUPConfig.fontSize * 2

    -- Set frame size
    frame:SetSize(totalWidth, height)

    -- Set initial position based on SUPConfig.position
    frame:ClearAllPoints()
    frame:SetPoint(
        SUPConfig.position.point or "CENTER",
        UIParent,
        SUPConfig.position.relativePoint or "CENTER",
        SUPConfig.position.x or 0,
        SUPConfig.position.y or 0
    )

    SUP.DebugPrint("5. Setting up animation")
    -- Create animation group
    frame.animGroup = frame:CreateAnimationGroup()
    frame.animGroup:SetToFinalAlpha(true)

    -- Add fade in
    local fadeIn = frame.animGroup:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.2) -- Quick fade in

    -- Add translation
    local translate = frame.animGroup:CreateAnimation("Translation")
    translate:SetOffset(0, 30)
    translate:SetDuration(1.5)
    translate:SetSmoothing("OUT")

    -- Add fade out
    local fadeOut = frame.animGroup:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.5)
    fadeOut:SetStartDelay(1.0)

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

    SUP.DebugPrint("B. Setting frame position")
    frame:SetPoint(
        SUPConfig.position.point or "CENTER",
        UIParent,
        SUPConfig.position.relativePoint or "CENTER",
        SUPConfig.position.x,
        SUPConfig.position.y
    )

    SUP.DebugPrint("C. Adding to active notifications")
    table.insert(SUP.activeNotifications, frame)

    SUP.DebugPrint("D. Setting icon and text")
    -- Set default icon if none exists for this skill
    local iconPath = SUP.skillIcons[skillName] or "Interface\\Icons\\INV_Misc_QuestionMark"

    if SUPConfig.showIcon then
        frame.icon:SetTexture(iconPath)
        frame.icon:Show()
    else
        frame.icon:Hide()
    end

    frame.text:SetText(string.format("|CFFFFFFFF%s|r increased to |CFFFFFFFF%d|r!", skillName, newLevel))
    frame:Show()

    SUP.DebugPrint("E. Starting animation")
    frame.animGroup:Play()

    if SUPConfig.playSound then
        PlaySound(SUPConfig.soundKitID or 3175) -- 3175 is the Classic Era achievement sound
    end
end
