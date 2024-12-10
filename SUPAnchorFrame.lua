local addonName, SUP = ...
local CreateFrame = CreateFrame
local UIParent = UIParent

function SUP.CreateAnchorFrame(positionButton)
    -- Store the anchor frame globally in SUP
    SUP.anchorFrame = CreateFrame("Frame", "SUPAnchorFrame", UIParent, "BackdropTemplate")
    local anchorFrame = SUP.anchorFrame
    anchorFrame:Hide()

    -- Set backdrop
    anchorFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    anchorFrame:SetBackdropColor(0, 0, 0, 0.8)
    anchorFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

    -- Add text
    local text = anchorFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("CENTER", anchorFrame, "CENTER", 0, 0)
    text:SetText("Notification Position")
    text:SetFont(text:GetFont(), SUPConfig.fontSize)
    anchorFrame.text = text

    -- Set initial size and position
    local width = SUP.CalculateNotificationWidth(SUPConfig.fontSize, text, false) * 1.2
    local height = SUPConfig.fontSize * 2.5
    anchorFrame:SetSize(width, height)
    anchorFrame:SetPoint(
        SUPConfig.position.point or "CENTER",
        UIParent,
        SUPConfig.position.relativePoint or "CENTER",
        SUPConfig.position.x or 0,
        SUPConfig.position.y or 0
    )

    -- Make the frame draggable
    anchorFrame:SetMovable(true)
    anchorFrame:EnableMouse(true)
    anchorFrame:RegisterForDrag("LeftButton")
    anchorFrame:SetScript("OnDragStart", anchorFrame.StartMoving)
    anchorFrame:SetScript("OnDragStop", function()
        anchorFrame:StopMovingOrSizing()
        local point, _, relativePoint, x, y = anchorFrame:GetPoint()
        SUPConfig.position = {
            point = point,
            relativePoint = relativePoint,
            x = x,
            y = y
        }
        SUP.DebugPrint("Position saved:", point, relativePoint, x, y)
    end)

    anchorFrame:SetAlpha(1)

    -- Add toggle functionality
    function anchorFrame:ToggleVisibility()
        if self:IsShown() then
            SUP.DebugPrint("Hiding frame")
            self:Hide()
            if positionButton then
                positionButton:SetText("Edit Position")
            end
        else
            SUP.DebugPrint("Showing frame")
            self:Show()
            if positionButton then
                positionButton:SetText("Save Position")
            end
        end
        SUP.DebugPrint("After toggle - IsShown:", self:IsShown())
    end

    return anchorFrame
end
