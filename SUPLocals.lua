local addonName, SUP = ...

-- Initialize locals table
SUP.Locals = {
    -- Frame Creation
    CreateFrame = CreateFrame,
    UIParent = UIParent,

    -- Skill Related
    GetSkillLineInfo = _G.GetSkillLineInfo,
    GetNumSkillLines = _G.GetNumSkillLines,

    -- Sound Related
    PlaySound = PlaySound,

    -- UI Related
    UIDropDownMenu_SetWidth = UIDropDownMenu_SetWidth,
    UIDropDownMenu_SetText = UIDropDownMenu_SetText,
    UIDropDownMenu_Initialize = UIDropDownMenu_Initialize,
    UIDropDownMenu_CreateInfo = UIDropDownMenu_CreateInfo,
    UIDropDownMenu_AddButton = UIDropDownMenu_AddButton,
    UIDropDownMenu_SetSelectedValue = UIDropDownMenu_SetSelectedValue,

    -- Other
    print = print,
    GetAddOnMetadata = (rawget(_G, "C_AddOns") and _G.C_AddOns.GetAddOnMetadata) or rawget(_G, "GetAddOnMetadata"),
}
