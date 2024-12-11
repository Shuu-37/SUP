local addonName, SUP = ...
local L = SUP.Locals

-- Define sound options with Classic Era sound IDs
SUP.SOUND_OPTIONS = {
    ["Skill Up"] = 6295,      -- Default profession skill up sound
    ["Level Up"] = 888,       -- Level up sound
    ["Quest Complete"] = 878, -- Quest complete sound
    ["Ready Check"] = 8960,   -- Ready check sound
    ["Map Ping"] = 3175,      -- Map ping sound
    ["Auction Open"] = 5274,  -- Auction house open sound
    ["Raid Warning"] = 8959,  -- Raid warning alert
    ["Duel Request"] = 8582,  -- Duel challenge sound
    ["PvP Flag"] = 8174,      -- PvP flag capture
    ["Whisper"] = 3081,       -- Whisper received
    ["Mail"] = 3338,          -- New mail notification
    ["Coin"] = 120,           -- Money received/spent
    ["Graveyard"] = 7355,     -- Spirit healer sound
    ["Forge"] = 3787,         -- Blacksmith hammer sound
    ["Thunder"] = 6454,       -- Thunder clap sound
    ["Bell"] = 6594,          -- Town bell sound
    ["Work Work"] = 6197,     -- War drums sound
}

-- Set default sound if not already set
if not _G.SUPConfig then
    _G.SUPConfig = {}
end

if not _G.SUPConfig.sound then
    _G.SUPConfig.sound = "Skill Up"
end

-- Validate saved sound exists in options
if _G.SUPConfig.sound and not SUP.SOUND_OPTIONS[_G.SUPConfig.sound] then
    _G.SUPConfig.sound = "Skill Up" -- Reset to default if saved sound is invalid
end
