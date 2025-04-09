Config = {}

Config.Target = "ox" -- or "qb"
Config.Phone = "lb" -- "lb", "qb", or "qs"
Config.DirtyMoneyItem = "dirtymoney"

Config.MaxDealers = 5

-- Unlock milestones (index = dealer slot)
Config.DealerUnlocks = {
    [1] = { cost = 10000 },
    [2] = { cost = 25000 },
    [3] = { cost = 50000 },
    [4] = { cost = 100000 },
    [5] = { cost = 200000 },
}

-- Dealer payout tiers (by index)
Config.PayoutTiers = {
    [1] = 60,
    [2] = 70,
    [3] = 80,
    [4] = 85,
    [5] = 90,
}

-- Sellable drugs
Config.SellableDrugs = {
    ["ls_banana_kush_bag"] = { label = "Banana bud", pricePerUnit = 80 },
    ["cured_meth"] = { label = "Bagged meth", pricePerUnit = 245 },
    ["oxy"]  = { label = "Oxy", pricePerUnit = 75 },
    ["ls_purple_haze_bag"] = { label = "Purple bud", pricePerUnit = 125 }
}

-- Max amount you can give per drug
Config.MaxPerDrug = 50

-- Realistic names for dealers
Config.RealisticNames = {
    "Trey", "Darnell", "Carlos", "Benny", "Jaylen", "Ty", "Malik", "Dom", "Ant", "Manny"
}

-- Hiring NPCs (the people who let you hire dealers)
Config.HiringLocations = {
    {
        coords = vector4(-146.6955, -1635.3938, 33.0574, 255.5078),
        pedModel = 'g_m_y_mexgoon_02'
    }
}

-- Boss NPC who manages your hired dealers
Config.BossLocation = {
    coords = vector4(-149.6033, -1632.2372, 33.0617, 266.1650),
    model = 's_m_m_bouncer_01'
}

-- Possible dealer meetup spots
Config.MeetLocations = {
    vector4(-478.7520, -732.2304, 23.9032, 88.6631),
    vector4(-667.4382, 84.1024, 51.9333, 191.0941),
    vector4(105.9920, -1925.9623, 20.7953, 120.6262),
    vector4(-56.6644, -1755.9647, 29.1396, 162.7001),
    vector4(-452.5486, -1680.4503, 19.0291, 235.5671)
}

-- Notification wrapper
Config.Notify = function(src, msg, type)
    if src == nil then
        lib.notify({ description = msg, type = type or "info" })
    else
        TriggerClientEvent('ox_lib:notify', src, { description = msg, type = type or "info" })
    end
end
