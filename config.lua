Config = {}

Config.MinimumMethJobPolice = 0 -- Police Needed
Config.AlertChance = 100 -- Dispatch Chance

Config.Dispatch = {
    Enabled = true,
    Function = function(coords)
        exports.tk_dispatch:addCall({ 
            title = 'Suspicious Activity', 
            code = '10-66', 
            priority = 'Priority 2', 
            coords = coords, 
            showLocation = true, 
            showGender = true, 
            playSound = true, 
            blip = { 
                color = 3, 
                sprite = 205, 
                scale = 1.0, 
            }, 
            jobs = {'police'}, 
        }) 
    end
}

Config.SearchBody = true -- Set to true to allow searching dead bodies

Config.ProgressArgue = 8000 -- 8 seconds
Config.ProgressLoot = 5000 -- 5 seconds

Config.NeedCash = false -- Cash to start?
Config.RunCost = 6000 -- Amount of cash
Config.NeedItem = "phone" -- Item to start
Config.RemoveItem = false --  Remove Item

Config.GiveItems = {
    {item = "meth", maxAmount = 5},
    {item = "coke", maxAmount = 5},
    {item = "cannabis", maxAmount = 5},
    -- Add more items and their maximum amounts as needed
}

Config.StartModels = {
    "a_m_y_hipster_01",
    "a_m_y_business_03",
    "a_m_y_cyclist_01",
    -- Add more models as needed
}

Config.StartCoordsList = {
    vector4(-1414.55, -93.31, 51.51, 25.09),
    -- vector4(-1464.30, -506.57, 32.81, 35.55),
    -- vector4(-988.03, -725.21, 20.93, 1.22),
    -- vector4(-1093.37, -944.20, 2.39, 35.72),
    -- vector4(-80.06, -1341.09, 29.27, 315.74),
    -- vector4(459.30, -1703.40, 29.43, 319.89),
    -- vector4(1178.95, -414.94, 67.46, 169.61),
    -- vector4(-104.89, 34.86, 71.45, 64.33),
    -- vector4(-360.64, -236.46, 36.08, 145.51),
    -- Add more coordinates as needed
}

Config.RewardItems = {
    { item = 'cash', minAmount = 50, maxAmount = 100, chance = 50 },
    { item = 'bandage', minAmount = 1, maxAmount = 3, chance = 50 },
    { item = 'water_bottle', minAmount = 1, maxAmount = 2, chance = 50 },
    { item = 'weapon_knife', minAmount = 1, maxAmount = 1, chance = 50 }
}

Config.RatDialog = { 
    { 
        id = 'initial_rat_talk', 
        job = 'Stranger', 
        name = 'Stranger', 
        text = 'What do you want?', 
        buttons = { 
            { 
                id = 'leave1', 
                label = 'Do you have drugs?', 
                nextDialog = 'rat_2', -- switch to second dialog 
            }, 
        }, 
    }, 
    { 
        id = 'rat_2', 
        job = 'Stranger', 
        name = 'Stranger', 
        text = 'NO! Get away from me!', 
        buttons = { 
            { 
                id = 'leave2', 
                label = 'I think youre lying..', 
                nextDialog = 'rat_3', 
            }, 
        }, 
    }, 
    { 
        id = 'rat_3', 
        job = 'Stranger', 
        name = 'Stranger', 
        text = 'THAT IS IT!', 
        buttons = { 
            { 
                id = 'leave2', 
                label = 'C\'mon man', 
                nextDialog = 'rat_talk_end', 
            }, 
        }, 
    }, 
    { 
        id = 'rat_talk_end', 
        job = 'Stranger', 
        name = 'Stranger', 
        text = 'I SAID GET AWAY FROM ME!!', 
        buttons = { 
            { 
                id = 'end', 
                label = 'Just give me the drugs', 
                close = true, 
                onSelect = function()
                    TriggerEvent('GLDNRMZ-rat:client:start')
                end
            }, 
        }, 
    }, 
}
