local addonName, SUP = ...
local L = SUP.Locals

function SUP.CreateSkillTrackerAnchorFrame()
    if not SUPConfig then
        SUP.DebugPrint("Error: SUPConfig not initialized yet")
        return nil
    end

    -- Initialize skillTrackerPosition if it doesn't exist
    SUPConfig.skillTrackerPosition = SUPConfig.skillTrackerPosition or {
        point = "CENTER",
        relativePoint = "CENTER",
        x = 0,
        y = 0
    }

    -- Store the anchor frame globally in SUP
    SUP.skillTrackerAnchorFrame = L.CreateFrame("Frame", "SUPSkillTrackerAnchorFrame", UIParent, "BackdropTemplate")
    local anchorFrame = SUP.skillTrackerAnchorFrame
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
    text:SetText("Skill Tracker Position")
    anchorFrame.text = text

    -- Function to update frame size based on text
    function anchorFrame:UpdateSize()
        self.text:SetFont(self.text:GetFont(), SUPConfig.fontSize)
        self.text:SetWidth(0)
        local textWidth = self.text:GetStringWidth()
        local textHeight = self.text:GetStringHeight()
        local totalWidth = textWidth + 40
        local totalHeight = textHeight + 20
        self:SetSize(totalWidth, totalHeight)
    end

    -- Initial size update
    anchorFrame:UpdateSize()

    -- Set initial position from saved variable
    anchorFrame:SetPoint(
        SUPConfig.skillTrackerPosition.point or "CENTER",
        UIParent,
        SUPConfig.skillTrackerPosition.relativePoint or "CENTER",
        SUPConfig.skillTrackerPosition.x or 0,
        SUPConfig.skillTrackerPosition.y or 0
    )

    -- Make the frame draggable
    anchorFrame:SetMovable(true)
    anchorFrame:EnableMouse(true)
    anchorFrame:RegisterForDrag("LeftButton")
    anchorFrame:SetScript("OnDragStart", anchorFrame.StartMoving)
    anchorFrame:SetScript("OnDragStop", function()
        anchorFrame:StopMovingOrSizing()
        local point, _, relativePoint, x, y = anchorFrame:GetPoint()
        SUPConfig.skillTrackerPosition = {
            point = point,
            relativePoint = relativePoint,
            x = x,
            y = y
        }
        SUP.DebugPrint("Skill Tracker Position saved:", point, relativePoint, x, y)
    end)

    return anchorFrame
end
