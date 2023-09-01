truckConfig = {
    DespawnTime = 60000, -- The time it takes to despawn the Trolly, all the times listed are in MS remember that
    TorchTime = 5000, -- Time it takes to torch off the lock on the truck
    GrabTime = 20000, -- Ammount of time it takes to grab cash, recommended to keep this default
    RobCooldown = 120000, -- The ammount of time players cant rob the truck for after each robbery, we reccommend making this cooldown atleast a hour so people dont farm it.
    truckDespawnTime = 15000
}

truckRobItems = {
    DoorPickItem = 'lockpick', -- Item it takes to pick the lock
    DoorTorchItem = 'torch' -- Item it takes to torch the door lock off
}

maxAmmountOfCash = { -- This is the minumum and maximum ammount of cash you get per second of grabbing money
    minumim = 250,
    maximum = 600
}

--- AI Coords --
local x = 179.54
local y = -160.94
local z = 56.32
local h = 293.24
----------------

AI_Config = {
    -- Touch the numbers above if you want to change the coords for the AI, dont touch the var.
    Aicoords = vector4(x, y, z - 1, h)
}