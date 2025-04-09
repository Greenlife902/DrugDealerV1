local QBCore = exports['qb-core']:GetCoreObject()
local Functions = require 'server.functions'

-- Callback to get player’s dealers
lib.callback.register('scheduled2:getDealers', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return {} end
    local cid = Player.PlayerData.citizenid
    local result = exports.oxmysql:query_async('SELECT * FROM player_dealers WHERE citizenid = ?', {cid})
    return result or {}
end)

RegisterServerEvent('scheduled2:attemptHire', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local cid = Player.PlayerData.citizenid
    local dealers = exports.oxmysql:query_async('SELECT * FROM player_dealers WHERE citizenid = ?', {cid})
    local count = #dealers

    if count >= Config.MaxDealers then
        Config.Notify(src, "You already have the max number of dealers.", "error")
        return
    end

    local nextIndex = count + 1
    local unlockReq = Config.DealerUnlocks[nextIndex]
    if not unlockReq then
        Config.Notify(src, "Invalid dealer slot.", "error")
        return
    end

    if unlockReq.cost > 0 then
        if not Functions.RemoveDirtyMoney(Player, unlockReq.cost) then
            Config.Notify(src, "You need $"..unlockReq.cost.." in dirty money to hire this dealer.", "error")
            return
        end
    end

    local randomName = Config.RealisticNames[math.random(1, #Config.RealisticNames)]
    exports.oxmysql:execute_async('INSERT INTO player_dealers (citizenid, dealer_index, name) VALUES (?, ?, ?)', {
        cid, nextIndex, randomName
    })
    Config.Notify(src, "You hired Dealer #" .. nextIndex .. " (" .. randomName .. ")", "success")
end)

RegisterServerEvent("scheduled2:meetDealer", function(dealerIndex)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local cid = Player.PlayerData.citizenid
    local result = exports.oxmysql:query_async('SELECT * FROM player_dealers WHERE citizenid = ? AND dealer_index = ?', {cid, dealerIndex})
    if not result or not result[1] then
        Config.Notify(src, "You don't own this dealer.", "error")
        return
    end
    local coords = Functions.GetRandomMeetLocation()
    TriggerClientEvent("scheduled2:spawnDealerPed", src, result[1], coords)
    Config.Notify(src, "Waypoint set to meet Dealer #"..dealerIndex, "success")
end)

RegisterNetEvent("scheduled2:submitDrugLoad", function(dealerId, drugData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local cid = Player.PlayerData.citizenid
    local result = exports.oxmysql:query_async('SELECT * FROM player_dealers WHERE citizenid = ? AND dealer_index = ?', {cid, dealerId})
    if not result or not result[1] then
        Config.Notify(src, "Dealer not found.", "error")
        return
    end

    for drug, amount in pairs(drugData) do
        local item = Player.Functions.GetItemByName(drug)
        if not item or item.amount < amount then
            Config.Notify(src, "You don't have enough of the drugs.", "error")
            return
        end
    end

    for drug, amount in pairs(drugData) do
        Player.Functions.RemoveItem(drug, amount)
    end

    exports.oxmysql:execute_async('UPDATE player_dealers SET drugs = ? WHERE citizenid = ? AND dealer_index = ?', {
        json.encode(drugData), cid, dealerId
    })
    Config.Notify(src, "Dealer loaded with product.", "success")
end)

RegisterServerEvent("scheduled2:collectDealerCash", function(dealerId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local cid = Player.PlayerData.citizenid
    local result = exports.oxmysql:query_async('SELECT * FROM player_dealers WHERE citizenid = ? AND dealer_index = ?', {cid, dealerId})
    if not result or not result[1] then
        Config.Notify(src, "Dealer not found.", "error")
        return
    end

    local cash = result[1].cash or 0
    if cash <= 0 then
        Config.Notify(src, "This dealer has no dirty money for you yet.", "error")
        return
    end

    Player.Functions.AddItem(Config.DirtyMoneyItem, cash)
    exports.oxmysql:execute_async('UPDATE player_dealers SET cash = 0 WHERE id = ?', {result[1].id})
    Config.Notify(src, "Collected $" .. cash .. " in dirty money.", "success")
end)

-- Passive selling loop
CreateThread(function()
    while true do
        Wait(60000)
        local dealers = exports.oxmysql:query_async('SELECT * FROM player_dealers', {})
        for _, dealer in pairs(dealers) do
            if dealer.drugs then
                local drugStock = json.decode(dealer.drugs)
                local earned = 0
                for drug, amount in pairs(drugStock) do
                    if Config.SellableDrugs[drug] and amount > 0 then
                        local sellAmount = math.random(1, 3)
                        if sellAmount > amount then sellAmount = amount end
                        local saleValue = sellAmount * Config.SellableDrugs[drug].pricePerUnit
                        earned = earned + saleValue
                        drugStock[drug] = amount - sellAmount
                    end
                end
                if earned > 0 then
                    local payoutTier = Config.PayoutTiers[dealer.dealer_index] or 60
                    local playerCut = math.floor(earned * (payoutTier / 100))
                    exports.oxmysql:execute_async('UPDATE player_dealers SET drugs = ?, cash = cash + ?, total_earned = total_earned + ? WHERE id = ?', {
                        json.encode(drugStock), playerCut, playerCut, dealer.id
                    })
                end
            end
        end
    end
end)
