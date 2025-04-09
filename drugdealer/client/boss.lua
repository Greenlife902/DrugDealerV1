-- client/boss.lua

local lib = lib or exports.ox_lib

-- Boss Ped Spawn
CreateThread(function()
    local model = Config.BossLocation.model
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local boss = CreatePed(0, model, Config.BossLocation.coords.x, Config.BossLocation.coords.y, Config.BossLocation.coords.z - 1.0, Config.BossLocation.coords.w, false, true)
    FreezeEntityPosition(boss, true)
    SetEntityInvincible(boss, true)
    SetBlockingOfNonTemporaryEvents(boss, true)

    if Config.Target == "ox" then
        exports.ox_target:addLocalEntity(boss, {
            {
                icon = 'fa-solid fa-user-tie',
                label = 'Manage Dealers',
                onSelect = function()
                    openBossMenu()
                end
            }
        })
    elseif Config.Target == "qb" then
        exports['qb-target']:AddTargetEntity(boss, {
            options = {
                {
                    icon = "fas fa-user-tie",
                    label = "Manage Dealers",
                    action = function()
                        openBossMenu()
                    end
                }
            },
            distance = 2.5
        })
    end
end)

-- Boss UI Menu
function openBossMenu()
    lib.callback('scheduled2:getDealers', false, function(dealers)
        if not dealers or #dealers == 0 then
            Config.Notify(nil, "You don't have any dealers yet.", "error")
            return
        end

        local options = {}
        for _, dealer in ipairs(dealers) do
            table.insert(options, {
                title = string.format("Dealer #%d - %s", dealer.dealer_index, dealer.name),
                description = string.format("Cash: $%d | Sold: $%d", dealer.cash, dealer.total_earned),
                icon = "fa-solid fa-people-arrows",
                onSelect = function()
                    openDealerActions(dealer.dealer_index)
                end
            })
        end

        lib.registerContext({
            id = 'dealer_boss_menu',
            title = 'Your Dealers',
            options = options
        })
        lib.showContext('dealer_boss_menu')
    end)
end

function openDealerActions(dealerIndex)
    lib.registerContext({
        id = 'dealer_action_'..dealerIndex,
        title = 'Dealer #'..dealerIndex..' Options',
        menu = 'dealer_boss_menu',
        options = {
            {
                title = "Book a Meet",
                icon = "fa-solid fa-location-dot",
                onSelect = function()
                    TriggerServerEvent("scheduled2:meetDealer", dealerIndex)
                end
            }
        }
    })
    lib.showContext('dealer_action_'..dealerIndex)
end
