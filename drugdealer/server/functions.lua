local Functions = {}

-- Remove dirty money from player inventory
Functions.RemoveDirtyMoney = function(player, amount)
    local item = player.Functions.GetItemByName(Config.DirtyMoneyItem)
    if item and item.amount >= amount then
        player.Functions.RemoveItem(Config.DirtyMoneyItem, amount)
        return true
    end
    return false
end

-- Pick a random dealer meetup location
Functions.GetRandomMeetLocation = function()
    return Config.MeetLocations[math.random(1, #Config.MeetLocations)]
end

return Functions
