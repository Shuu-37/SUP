local addonName, SUP = ...
local L = SUP.Locals

function SUP.CreateAnchorFrame(positionButton)
    -- Store the anchor frame globally in SUP
    SUP.anchorFrame = L.CreateFrame("Frame", "SUPAnchorFrame", UIParent, "BackdropTemplate")
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
    anchorFrame.text = text

    -- Function to update frame size based on text
    function anchorFrame:UpdateSize()
        -- Set the font first
        self.text:SetFont(self.text:GetFont(), SUPConfig.fontSize)

        -- Let the text determine its own size without constraints
        self.text:SetWidth(0)

        -- Get the actual text dimensions
        local textWidth = self.text:GetStringWidth()
        local textHeight = self.text:GetStringHeight()

        -- Add padding for the backdrop and some breathing room
        local totalWidth = textWidth + 40 -- Extra padding for visual comfort
        local totalHeight = textHeight + 20

        -- Set the frame size
        self:SetSize(totalWidth, totalHeight)
    end

    -- Initial size update
    anchorFrame:UpdateSize()

    -- Set initial position
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
        else
            SUP.DebugPrint("Showing frame")
            self:Show()
        end
        SUP.DebugPrint("After toggle - IsShown:", self:IsShown())
    end

    -- Add a method to update both font size and frame size
    function anchorFrame:UpdateFontSize(newSize)
        -- Update the stored font size
        SUPConfig.fontSize = newSize
        -- Call UpdateSize to ensure padding is maintained
        self:UpdateSize()
    end

    return anchorFrame
end
