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
    -- Get text width only if there's actual text content
    local textWidth = text:GetText() and text:GetStringWidth() or 0
    local iconWidth = showIcon and (fontSize * 1.7 + 5) or 0 -- Icon width + padding if shown
    -- Ensure minimum width when text is empty
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
    -- Create text
    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    if SUPConfig.showIcon then
        text:SetPoint("LEFT", icon, "RIGHT", 5, 0)
    else
        text:SetPoint("CENTER", frame, "CENTER")
    end
    icon:SetShown(SUPConfig.showIcon)

    local fontPath, fontSize = text:GetFont()
    text:SetFont(fontPath or "Fonts/FRIZQT__.TTF", SUPConfig.fontSize)
    frame.text = text

    -- Calculate total width and adjust frame size
    local totalWidth = 250 -- Default width until text is set
    local height = SUPConfig.fontSize * 2
    frame:SetSize(totalWidth, height)

    -- Adjust frame position
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

    local totalDuration = SUPConfig.duration or 1.5
    local fadeInDuration = totalDuration * 0.2  -- First 20% for fade in
    local visibleDuration = totalDuration * 0.6 -- Middle 60% for full visibility
    local fadeOutDuration = totalDuration * 0.2 -- Last 20% for fade out

    -- Add translation (runs entire duration)
    local translate = frame.animGroup:CreateAnimation("Translation")
    translate:SetOffset(0, 40)
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

    -- Set the text first
    frame.text:SetText(string.format("|CFFFFFFFF%s|r increased to |CFFFFFFFF%d|r!", skillName, newLevel))

    -- Now recalculate the frame size based on the actual text
    local totalWidth = SUP.CalculateNotificationWidth(SUPConfig.fontSize, frame.text, SUPConfig.showIcon)
    local height = SUPConfig.fontSize * 2
    frame:SetSize(totalWidth, height)

    -- Show/hide icon after setting text
    if SUPConfig.showIcon then
        frame.icon:SetTexture(iconPath)
        frame.icon:Show()
    else
        frame.icon:Hide()
    end

    frame:Show()
    frame.animGroup:Play()

    if SUPConfig.playSound then
        PlaySound(6295, "Master")
    end
end
