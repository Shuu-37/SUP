local addonName, SUP = ...
local L = SUP.Locals

SUP.Utils = {}

-- Helper functions for frame management
function SUP.Utils.GetElement(frame, path)
    if not frame then
        SUP.DebugPrint("GetElement: Frame is nil")
        return nil
    end

    local current = frame
    for _, key in ipairs({ strsplit(".", path) }) do
        if not current then
            SUP.DebugPrint("GetElement: Lost path at", key)
            return nil
        end
        -- Try both direct key access and GetName() based lookup
        if current[key] then
            current = current[key]
        else
            -- Try to find by concatenated name
            local elementName = current:GetName() and (current:GetName() .. key) or nil
            if elementName and _G[elementName] then
                current = _G[elementName]
            else
                SUP.DebugPrint("GetElement: Failed to find", key, "in", current:GetName() or "unnamed frame")
                return nil
            end
        end
    end
    return current
end

-- Shorthand for common elements
function SUP.Utils.GetSettingsElement(frame, path)
    local element = SUP.Utils.GetElement(frame, "notificationsContent.settingsContainer." .. path)
    if not element then
        SUP.DebugPrint("GetSettingsElement: Failed to find", path)
    end
    return element
end

-- For elements that are direct children of the main frame
function SUP.Utils.GetFrameElement(frame, elementName)
    -- Replace $parent with the actual frame name
    local actualName = elementName:gsub("$parent", frame:GetName())
    -- Try to get the element by name first
    local element = _G[actualName]
    if element then
        return element
    end
    -- Fallback to direct child lookup if global lookup fails
    return SUP.Utils.GetElement(frame, elementName)
end
