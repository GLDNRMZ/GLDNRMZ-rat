local QBCore = exports['qb-core']:GetCoreObject() 
local Cooldown = false

RegisterServerEvent('GLDNRMZ-rat:server:startr', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    -- Randomly select an item and amount from the configuration list
    local randomItem = Config.GiveItems[math.random(#Config.GiveItems)]
    local itemToGive = randomItem.item
    local amountToGive = math.random(1, randomItem.maxAmount)

    if Config.NeedCash then
        if Player.PlayerData.money['cash'] >= Config.RunCost then
            Player.Functions.RemoveMoney('cash', Config.RunCost)
            Player.Functions.AddItem(itemToGive, amountToGive)
            
            if Config.RemoveItem then
                Player.Functions.RemoveItem(Config.NeedItem, 1)
                TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[Config.NeedItem], "remove")
            end

            TriggerClientEvent("GLDNRMZ-rat:server:runactivate", src)
        else
            TriggerClientEvent('QBCore:Notify', src, Lang:t("error.you_dont_have_enough_money"), 'error')
        end
    else
        Player.Functions.AddItem(itemToGive, amountToGive)
        
        if Config.RemoveItem then
            Player.Functions.RemoveItem(Config.NeedItem, 1)
            TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[Config.NeedItem], "remove")
        end

        TriggerClientEvent("GLDNRMZ-rat:server:runactivate", src)
    end
end)

RegisterServerEvent('GLDNRMZ-rat:server:giveRewardFromDead', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    -- Iterate through the configured reward items
    for _, itemData in ipairs(Config.RewardItems) do
        if math.random(1, 100) <= itemData.chance then -- Adjust chance to give each item
            local amount = math.random(itemData.minAmount, itemData.maxAmount)
            Player.Functions.AddItem(itemData.item, amount)
            TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[itemData.item], "add")
        end
    end
end)


