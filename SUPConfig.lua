local addonName, SUP = ...
local CreateFrame = CreateFrame
local UIParent = UIParent
local math = math
local string = string
local table = table

function SUP.CreateConfigFrame()
    -- Create main config frame
    local frame = CreateFrame("Frame", "SUPConfigFrame", UIParent, "SUPConfigFrameTemplate")
    SUP.configFrame = frame

    -- Make frame movable
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- Declare anchorFrame at the top level of the function
    local anchorFrame = nil

    -- Initialize font slider
    frame.controlsContainer.FontSlider:SetValue(SUPConfig.fontSize)
    frame.controlsContainer.FontSlider:SetScript("OnValueChanged", function(self, value)
        SUPConfig.fontSize = value
        SUP.DebugPrint("Font size set to:", value)
        -- Update any active notifications
        for _, notification in ipairs(SUP.activeNotifications) do
            local fontPath = notification.text:GetFont()
            notification.text:SetFont(fontPath, value)
            notification.icon:SetSize(value * 1.7, value * 1.7)
        end

        -- Update anchor frame if it exists and is shown
        if anchorFrame and anchorFrame:IsShown() then
            for _, region in ipairs({ anchorFrame:GetRegions() }) do
                if region.GetObjectType and region:GetObjectType() == "FontString" then
                    local fontPath = region:GetFont()
                    region:SetFont(fontPath, value)

                    local width = SUP.CalculateNotificationWidth(value, region, false) * 1.2
                    local height = value * 2.5
                    anchorFrame:SetSize(width, height)
                    break
                end
            end
        end
    end)

    -- Initialize checkboxes
    frame.checkboxContainer.iconCheckbox:SetChecked(SUPConfig.showIcon)
    frame.checkboxContainer.soundCheckbox:SetChecked(SUPConfig.playSound)
    frame.checkboxContainer.debugCheckbox:SetChecked(SUPConfig.debugMode)

    -- Setup checkbox scripts
    frame.checkboxContainer.iconCheckbox:SetScript("OnClick", function(self)
        SUPConfig.showIcon = self:GetChecked()
    end)

    frame.checkboxContainer.soundCheckbox:SetScript("OnClick", function(self)
        SUPConfig.playSound = self:GetChecked()
    end)

    frame.checkboxContainer.debugCheckbox:SetScript("OnClick", function(self)
        SUPConfig.debugMode = self:GetChecked()
    end)

    -- Setup test button
    local testButton = _G[frame:GetName() .. "TestButton"]
    testButton:SetScript("OnClick", function()
        local randomSkill = SUP.trackableSkills[math.random(#SUP.trackableSkills)]
        local randomLevel = math.random(1, 300)
        SUP.ShowNotification(randomSkill, randomLevel)
    end)

    -- Setup position button and anchor frame
    local positionButton = frame.controlsContainer.positionButton

    positionButton:SetScript("OnClick", function()
        local fontSize = SUPConfig.fontSize
        local height = fontSize * 2.5

        -- Debugging: Log font size and calculated height
        SUP.DebugPrint("Font Size:", fontSize, "Calculated Height:", height)

        if not anchorFrame then
            -- Create the anchor frame
            anchorFrame = CreateFrame("Frame", "SUPAnchorFrame", UIParent, "BackdropTemplate")
            anchorFrame:Hide() -- Add this line right after frame creation

            -- Set backdrop
            anchorFrame:SetBackdrop({
                bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                tile = true,
                tileSize = 16,
                edgeSize = 16,
                insets = { left = 4, right = 4, top = 4, bottom = 4 },
            })
            anchorFrame:SetBackdropColor(0, 0, 0, 0.8) -- Black background with 80% opacity
            anchorFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

            -- Debugging: Confirm frame creation
            SUP.DebugPrint("Anchor frame created!")

            -- Add text
            local text = anchorFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            text:SetPoint("CENTER", anchorFrame, "CENTER", 0, 0)
            text:SetText("Notification Position")
            text:SetFont(text:GetFont(), fontSize)
            anchorFrame.text = text

            -- Set initial size and position
            local width = SUP.CalculateNotificationWidth(fontSize, text, false) * 1.2
            anchorFrame:SetSize(width, height)
            anchorFrame:SetPoint(
                SUPConfig.position.point or "CENTER",
                UIParent,
                SUPConfig.position.relativePoint or "CENTER",
                SUPConfig.position.x or 0,
                SUPConfig.position.y or 0
            )

            -- Debugging: Log position
            local point, relativeTo, relativePoint, xOfs, yOfs = anchorFrame:GetPoint()
            SUP.DebugPrint("Anchor Frame Position:", point, relativePoint, xOfs, yOfs)

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

                -- Debugging: Log saved position
                SUP.DebugPrint("Position saved:", point, relativePoint, x, y)
            end)

            -- Apply all properties and force visibility
            anchorFrame:SetAlpha(1)
        end

        -- Update size and font dynamically
        local width = SUP.CalculateNotificationWidth(fontSize, anchorFrame.text, false) * 1.2
        anchorFrame:SetSize(width, height)
        anchorFrame.text:SetFont(anchorFrame.text:GetFont(), fontSize)

        -- Debugging: Log frame size and visibility toggle
        SUP.DebugPrint("Frame size updated:", "Width:", width, "Height:", height, "Visible:", anchorFrame:IsShown())

        -- Toggle visibility
        SUP.DebugPrint("Before toggle - IsShown:", anchorFrame:IsShown())
        if anchorFrame:IsShown() then
            SUP.DebugPrint("Hiding frame")
            anchorFrame:Hide()
            positionButton:SetText("Edit Position")
        else
            SUP.DebugPrint("Showing frame")
            anchorFrame:Show()
            positionButton:SetText("Save Position")
        end
        SUP.DebugPrint("After toggle - IsShown:", anchorFrame:IsShown())
    end)
end
