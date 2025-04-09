local lib = lib or exports.ox_lib
local spawnedDealers = {}

-- Hiring NPC Setup
CreateThread(function()
    for _, loc in pairs(Config.HiringLocations) do
        RequestModel(loc.pedModel)
        while not HasModelLoaded(loc.pedModel) do Wait(0) end

        local ped = CreatePed(0, loc.pedModel, loc.coords.x, loc.coords.y, loc.coords.z - 1.0, loc.coords.w, false, true)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        if Config.Target == "ox" then
            exports.ox_target:addLocalEntity(ped, {
                {
                    icon = 'fa-solid fa-user-plus',
                    label = 'Hire Dealer',
                    onSelect = function()
                        TriggerServerEvent('scheduled2:attemptHire')
                    end
                }
            })
        elseif Config.Target == "qb" then
            exports['qb-target']:AddTargetEntity(ped, {
                options = {
                    {
                        icon = "fas fa-user-plus",
                        label = "Hire Dealer",
                        action = function()
                            TriggerServerEvent('scheduled2:attemptHire')
                        end
                    }
                },
                distance = 2.5
            })
        end
    end
end)

-- Dealer Load UI
RegisterNetEvent("scheduled2:openDrugLoader", function(dealerId)
    local inputs = {}

    for drug, data in pairs(Config.SellableDrugs) do
        table.insert(inputs, {
            type = "number",
            label = "Amount of " .. data.label .. " (Max: " .. Config.MaxPerDrug .. ")",
            name = drug
        })
    end

    local result = lib.inputDialog("Load Dealer #" .. dealerId, inputs)
    if not result then return end

    local drugData = {}
    local index = 1
    for drug, _ in pairs(Config.SellableDrugs) do
        local amount = tonumber(result[index]) or 0
        if amount > 0 and amount <= Config.MaxPerDrug then
            drugData[drug] = amount
        end
        index = index + 1
    end

    TriggerServerEvent("scheduled2:submitDrugLoad", dealerId, drugData)
end)

-- Spawn Dealer for Meet
RegisterNetEvent("scheduled2:spawnDealerPed", function(dealerData, coords)
    local model = Config.DealerPedModel or 'g_m_y_mexgoon_02'
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local ped = CreatePed(0, model, coords.x, coords.y, coords.z - 1.0, coords.w, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 514)
    SetBlipScale(blip, 0.9)
    SetBlipColour(blip, 2)
    SetBlipDisplay(blip, 4)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Meet Dealer #" .. dealerData.dealer_index)
    EndTextCommandSetBlipName(blip)

    SetNewWaypoint(coords.x, coords.y)

    spawnedDealers[dealerData.dealer_index] = {
        ped = ped,
        blip = blip
    }

    local function finishMeet()
        local data = spawnedDealers[dealerData.dealer_index]
        if data then
            RemoveBlip(data.blip)
            ClearPedTasks(data.ped)
            FreezeEntityPosition(data.ped, false)
            TaskWanderStandard(data.ped, 10.0, 10)
            SetTimeout(15000, function()
                DeleteEntity(data.ped)
                spawnedDealers[dealerData.dealer_index] = nil
            end)
        end
    end

    -- Target Options
    if Config.Target == "ox" then
        exports.ox_target:addLocalEntity(ped, {
            {
                icon = 'fa-solid fa-box',
                label = 'Open Stash: ' .. dealerData.name,
                onSelect = function()
                    TriggerEvent("scheduled2:openDrugLoader", dealerData.dealer_index)
                end
            },
            {
                icon = 'fa-solid fa-sack-dollar',
                label = 'Collect Cash: ' .. dealerData.name,
                onSelect = function()
                    TriggerServerEvent("scheduled2:collectDealerCash", dealerData.dealer_index)
                end
            },
            {
                icon = 'fa-solid fa-check',
                label = 'Finish Meet',
                onSelect = finishMeet
            }
        })
    elseif Config.Target == "qb" then
        exports['qb-target']:AddTargetEntity(ped, {
            options = {
                {
                    icon = "fas fa-box",
                    label = "Open Stash",
                    action = function()
                        TriggerEvent("scheduled2:openDrugLoader", dealerData.dealer_index)
                    end
                },
                {
                    icon = "fas fa-dollar-sign",
                    label = "Collect Earnings",
                    action = function()
                        TriggerServerEvent("scheduled2:collectDealerCash", dealerData.dealer_index)
                    end
                },
                {
                    icon = "fas fa-check",
                    label = "Finish Meet",
                    action = finishMeet
                }
            },
            distance = 2.5
        })
    end
end)
