local addonName, SUP = ...
local L = SUP.Locals

SUP.Utils = {}

-- Helper functions for frame management
function SUP.Utils.GetElement(frame, path)
    if not frame then return nil end

    local current = frame
    for _, key in ipairs({ strsplit(".", path) }) do
        if not current[key] then
            SUP.DebugPrint("Failed to find element:", key, "in path:", path)
            return nil
        end
        current = current[key]
    end
    return current
end

-- Shorthand for common elements
function SUP.Utils.GetSettingsElement(frame, path)
    return SUP.Utils.GetElement(frame, "settingsContainer." .. path)
end

-- For elements that are direct children of the main frame
function SUP.Utils.GetFrameElement(frame, elementName)
    return SUP.Utils.GetElement(frame, elementName)
end
