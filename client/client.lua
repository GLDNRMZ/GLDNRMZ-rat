local QBCore = exports['qb-core']:GetCoreObject()
local VehicleCoords = nil
local CurrentCops = 0
local startboss = nil
local spawnDelay = 180000

RegisterNetEvent('police:SetCopCount', function(amount)
    CurrentCops = amount
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        PlayerJob = QBCore.Functions.GetPlayerData().job
        StartJobPed()
    end
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
    StartJobPed()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

function loadAnimDict(dict) 
    while (not HasAnimDictLoaded(dict)) do 
        RequestAnimDict(dict) 
        Wait(0) 
    end 
end

function StartJobPed()
    if not DoesEntityExist(startboss) then
        local coords = Config.StartCoordsList[math.random(#Config.StartCoordsList)]
        
        -- Randomly select a model from the list
        local selectedModel = Config.StartModels[math.random(#Config.StartModels)]

        RequestModel(selectedModel)
        while not HasModelLoaded(selectedModel) do
            Wait(0)
        end

        -- Create the ped with the specified heading
        startboss = CreatePed(0, selectedModel, coords.xyz, coords.w or 0.0, false, false)

        SetEntityAsMissionEntity(startboss)
        SetPedFleeAttributes(startboss, 0, 0)
        SetBlockingOfNonTemporaryEvents(startboss, true)
        SetEntityInvincible(startboss, true)
        FreezeEntityPosition(startboss, false)

        loadAnimDict("amb@world_human_leaning@female@wall@back@holding_elbow@idle_a")
        TaskPlayAnim(startboss, "amb@world_human_leaning@female@wall@back@holding_elbow@idle_a", "idle_a", 8.0, -1, -1, 1, 0, 0, 0, 0)

        -- Check if the ped is dead or dying before allowing targeting
        if not IsPedDeadOrDying(startboss, true) then
            exports['qb-target']:AddTargetEntity(startboss, { 
                options = {
                    { 
                        type = "client",
                        event = "GLDNRMZ-rat:client:menu",
                        icon = "fas fa-circle",
                        label = "Talk to Stranger",
                        item = Config.NeedItem,
                    },
                }, 
                distance = 1.5, 
            })
        end
    end
end


RegisterNetEvent('GLDNRMZ-rat:client:menu', function()
    if CurrentCops >= Config.MinimumMethJobPolice then
        exports['qb-menu']:openMenu({
            {
                header = "PLEASE, NO NOT talk to me",
                isMenuHeader = true
            },
            {
                header = "",
                txt = "Do you have drugs?",
                icon = "fa-sharp fa-solid fa-chart-pie",
                params = {
                    isServer = false,
                    event = "GLDNRMZ-rat:client:menu2",
                }
            },
        })
    else
        QBCore.Functions.Notify("Not enough police on duty", 'error')
    end
end)

RegisterNetEvent('GLDNRMZ-rat:client:menu2', function()
    exports['qb-menu']:openMenu({
        {
            header = "NO!",
            isMenuHeader = true
        },
        {
            header = "",
            txt = "I think you're lying",
            icon = "fa-sharp fa-solid fa-chart-pie",
            params = {
                isServer = false,
                event = "GLDNRMZ-rat:client:menu3",
            }
        },
    })
end)

RegisterNetEvent('GLDNRMZ-rat:client:menu3', function()
    exports['qb-menu']:openMenu({
        {
            header = "GET AWAY FROM ME",
            isMenuHeader = true
        },
        {
            header = "",
            txt = "C'mon man",
            icon = "fa-sharp fa-solid fa-chart-pie",
            params = {
                isServer = false,
                event = "GLDNRMZ-rat:client:start",
            }
        },
    })
end)

RegisterNetEvent('GLDNRMZ-rat:client:start', function()
    PoliceAlert()

    -- Remove the target entity from qb-target when the event is triggered
    exports['qb-target']:RemoveTargetEntity(startboss)

    TaskStartScenarioInPlace(startboss, "WORLD_HUMAN_STAND_MOBILE_CLUBHOUSE", 0, true)

    QBCore.Functions.Progressbar("start_job", "Arguing with stranger", Config.ProgressArgue, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@amb@casino@brawl@fights@argue@",
        anim = "arguement_loop_mp_m_brawler_01",
        flag = 16,
    }, {}, {}, function()
        TriggerServerEvent('GLDNRMZ-rat:server:startr')

        -- Make ped vulnerable before fleeing
        SetEntityInvincible(startboss, false)

        QBCore.Functions.Notify("SOMBODY HELP!!")
        ClearPedTasksImmediately(startboss)

        local pedCoords = GetEntityCoords(startboss)
        local radius = 50.0
        local fleeCoords = vector3(
            pedCoords.x + math.random(-radius, radius),
            pedCoords.y + math.random(-radius, radius),
            pedCoords.z
        )

        TaskReactAndFleePed(startboss, PlayerPedId())

        SetTimeout(60000, function()
            if DoesEntityExist(startboss) then
                DeleteEntity(startboss)
            end
            -- Respawn ped after 3 minutes
            SetTimeout(180000, function()
                StartJobPed()
            end)
        end)
    end, function()
        ClearPedTasksImmediately(startboss)
        QBCore.Functions.Notify(Lang:t("error.canceled"), 'error')
    end)
end)


function PoliceAlert()
    if math.random(1,100) >= Config.AlertChance then return end
    exports["ps-dispatch"]:Informant()
end

function TargetDeadPed()
    if DoesEntityExist(startboss) and IsPedDeadOrDying(startboss, true) then
        -- Check if searching bodies is enabled in the config
        if Config.SearchBody then
            exports['qb-target']:AddTargetEntity(startboss, { 
                options = {
                    { 
                        type = "client",
                        event = "GLDNRMZ-rat:client:deadInteraction",
                        icon = "fas fa-skull",
                        label = "Investigate Dead Body",
                    },
                }, 
                distance = 1.5, 
            })
        end
    end
end

RegisterNetEvent('GLDNRMZ-rat:client:deadInteraction', function()
    if Config.SearchBody then
        -- Start the search with progress bar and animation
        QBCore.Functions.Progressbar("search_body", "Searching the body...", Config.ProgressLoot, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "amb@medic@standing@kneel@base",
            anim = "base",
            flag = 49,
        }, {}, {}, function() -- On success
            -- Give items to player (you can randomize or set specific items here)
            TriggerServerEvent('GLDNRMZ-rat:server:giveRewardFromDead')

            -- Remove the target entity after searching
            exports['qb-target']:RemoveTargetEntity(startboss)

            -- Clear the ped's tasks and stop the animation
            ClearPedTasksImmediately(PlayerPedId())
        end, function() -- On cancel
            ClearPedTasksImmediately(PlayerPedId())
            QBCore.Functions.Notify("Search cancelled", "error")
        end)
    end
end)


CreateThread(function()
    while true do
        Wait(1000) -- Check every second
        if DoesEntityExist(startboss) and IsPedDeadOrDying(startboss, true) then
            TargetDeadPed()
            break -- Stop checking once the ped is dead
        end
    end
end)


