local ESX = exports['es_extended']:getSharedObject()

require('config')

local carSpawned = false

local BankTruck = 'stockade'
local TrollyProp = 'ch_prop_cash_low_trolly_01c'
local robbed = false

exports.ox_target:addModel(BankTruck, {{
    label = 'Rob Truck!',
    distance = 3,
    icon = 'fa-solid fa-vault',
    onSelect = function()
        if robbed == false then
            TriggerServerEvent('TruckRobber:HasPick')
        else
            lib.notify({
                title = 'Bank Notification',
                description = 'You have already robbed this truck.',
                duration = 5000,
                icon = 'ban',
                iconColor = '#C53030'
            })
        end
    end
}})

RegisterNetEvent('TruckRobber:noProperItems')
AddEventHandler('TruckRobber:noProperItems', function()
    lib.notify({
        title = 'Bank Notification',
        description = 'Make sure you have the proper items: '..truckRobItems.DoorPickItem..' and '..truckRobItems.DoorTorchItem,
        duration = 5000,
        icon = 'ban',
        iconColor = '#C53030'
    })
end)

RegisterNetEvent('TruckRobber:grabbingCash')
AddEventHandler('TruckRobber:grabbingCash', function()
    lib.progressBar({
        duration = truckConfig.GrabTime,
        label = 'Grabbing Cash From Trolly',
        canCancel = false,
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped'
        },
        disable = {
            move = true,
            combat = true
        }
    })
    robbed = true
    lib.notify({
        title = 'Bank Notification',
        description = 'You are now on a '.. truckConfig.RobCooldown/1000 ..' cooldown!',
        duration = 5000,
        icon = 'ban',
        iconColor = '#C53030'
    })
    Citizen.Wait(truckConfig.RobCooldown)
    lib.notify({
        title = 'Bank Notification',
        description = 'You are now off your '.. truckConfig.RobCooldown/1000 ..' cooldown!',
        duration = 5000,
        icon = 'ban',
        iconColor = '#C53030'
    })
    robbed = false
end)

RegisterNetEvent('TruckRobber:startRobbery')
AddEventHandler('TruckRobber:startRobbery', function()
    lib.progressBar({
        duration = truckConfig.TorchTime,
        label = 'Cutting locks with torch',
        canCancel = true,
        anim = {
            dict = 'amb@world_human_welding@male@base',
            clip = 'base'
        },
        prop = {
            model = 'prop_weld_torch',
            bone = 28422,
            pos = vec3(0.00, 0.00, 0.00),
            rot = vec3(0.0, 00.0, 0.0)
        },
        disable = {
            move = true,
            combat = true
        }
    })
    local playerPedId = PlayerPedId()
    local coords = GetEntityCoords(playerPedId)

    local vehicle = ESX.Game.GetClosestVehicle(coords, nil)

    local success = exports["t3_lockpick"]:startLockpick(truckRobItems.DoorPickItem, 2, 1)
    if success and DoesEntityExist(vehicle) and IsVehicleModel(vehicle, GetHashKey(BankTruck)) then
        OpenRearDoors(vehicle)
        SpawnTrollyProp(vehicle)
    else
        lib.notify({
            title = 'Bank Notification',
            description = 'Lockpick Broke',
            icon = 'fa-solid fa-circle-exclamation',
            iconColor = '#C53030'
        })
        TriggerServerEvent('TruckRobber:RemovePick')
    end
end)

function OpenRearDoors(vehicle)
    local trunkIndex = GetEntityBoneIndexByName(vehicle, 'door_dside_r') -- Rear left door
    local trunkIndex2 = GetEntityBoneIndexByName(vehicle, 'door_pside_r') -- Rear right door

    if trunkIndex ~= -1 and trunkIndex2 ~= -1 then
        SetVehicleDoorOpen(vehicle, 2, false, false) -- Rear left door
        SetVehicleDoorOpen(vehicle, 3, false, false) -- Rear right door
    end
end

function CloseRearDoors(vehicle)
    local trunkIndex = GetEntityBoneIndexByName(vehicle, 'door_dside_r') -- Rear left door
    local trunkIndex2 = GetEntityBoneIndexByName(vehicle, 'door_pside_r') -- Rear right door

    if trunkIndex ~= -1 and trunkIndex2 ~= -1 then
        SetVehicleDoorShut(vehicle, 2, false) -- Rear left door
        SetVehicleDoorShut(vehicle, 3, false) -- Rear right door
    end
end

function SpawnTrollyProp(vehicle)
    lib.notify({
        title = 'Bank Notification',
        description = 'BankTruck Trolly Spawned',
        icon = 'fa-solid fa-building-columns',
        iconColor = '#00ff00'
    })

    local truckCoords = GetEntityCoords(vehicle)
    local truckForwardVector = GetEntityForwardVector(vehicle)
    local spawnOffset = -4.5 -- Distance behind the truck to spawn the prop

    -- Calculate the position behind the truck
    local propX = truckCoords.x + (spawnOffset * truckForwardVector.x)
    local propY = truckCoords.y + (spawnOffset * truckForwardVector.y)
    local propZ = truckCoords.z

    -- Create the prop at the calculated position
    local prop = CreateObject(GetHashKey(TrollyProp), propX, propY, propZ, true, true, true)

    if prop ~= 0 then
        PlaceObjectOnGroundProperly(prop)
        print("Prop spawned successfully")
        exports.ox_target:addLocalEntity(prop, {
            label = 'Start Grabbing Cash',
            icon = 'fa-solid fa-hand',
            distance = 5,
            onSelect = function()
                if robbed == false then
                    TriggerServerEvent('TruckRobber:Winner')
                elseif robbed == true then
                    lib.notify({
                        title = 'Bank Notification',
                        description = 'BankTruck Trolly is already robbed please wait: '..truckConfig.RobCooldown/1000,
                        duration = 5000,
                        icon = 'ban',
                        iconColor = '#C53030'
                    })
                    Citizen.Wait(truckConfig.RobCooldown)
                end
            end
        })
        Citizen.Wait(truckConfig.DespawnTime)
        print("Despawn time elapsed")
        DeleteEntity(prop)
        exports.ox_target:removeEntity(prop)
        CloseRearDoors(vehicle)
        lib.notify({
            title = 'Bank Notification',
            description = 'BankTruck Trolly Despawned, Truck despawning in '..truckConfig.DespawnTime/1000 ..' seconds!',
            duration = 5000,
            icon = 'fa-solid fa-check',
            iconColor = '#00ff00'
        })
        Citizen.Wait(truckConfig.truckDespawnTime)
        carSpawned = false
        DeleteEntity(vehicle)
    else
        lib.notify({
            title = 'Bank Notification',
            description = 'BankTrolly Failed To Spawn',
            duration = 5000,
            icon = 'ban',
            iconColor = '#C53030'
        })
    end
end

local AI_Coords = AI_Config.Aicoords

-- vector4(1171.64, 2726.18, 38.0, 87.32)

local function TruckAlreadySpawned()
    lib.notify({
        title = 'Bank Notification',
        description = 'A bank truck is already spawned.',
        duration = 5000,
        icon = 'ban',
        iconColor = '#C53030'
    })
end

local spawnedVehicles = {}

local function spawnBankTruck()
    local TruckModel = 'stockade'
    local spawnPoints = {
        { x = 317.0, y = -202.9, z = 54.09, heading = 65.99 },
        { x = 229.84, y = 118.66, z = 102.6, heading = 158.48},
        { x = -26.5, y = -84.65, z = 57.25, heading = 249.83}
        -- Add other spawn points here
    }

    if carSpawned == true then
        TruckAlreadySpawned()
    end

    if carSpawned == false then
        local randomSpawnIndex = math.random(1, #spawnPoints)
        local spawnPoint = spawnPoints[randomSpawnIndex]

        local vehicle = ESX.Game.SpawnVehicle(TruckModel, vector3(spawnPoint.x, spawnPoint.y, spawnPoint.z), spawnPoint.heading, function(vehicle)
            SetEntityInvincible(vehicle, true) -- Make the vehicle invincible
            SetVehicleDoorsLockedForAllPlayers(vehicle, true) -- Lock all doors to make it impossible to get in
            
            -- Add a blip for the spawned vehicle
            local blip = AddBlipForEntity(vehicle)

            SetBlipSprite(blip, 225) -- Set blip to blue color
            SetBlipDisplay(blip, 2) -- Show the blip on both the minimap and the main map
            SetBlipScale(blip, 1.1) -- Set the blip size (1.0 is default)
            SetBlipColour(blip, 6) -- Set the blip color (3 is blue)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('Bank Truck') -- Set the blip's name
            EndTextCommandSetBlipName(blip)
            table.insert(spawnedVehicles, { vehicle = vehicle, blip = blip })
        end)
        
        carSpawned = true
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Check every second
        for i, spawnedVehicle in ipairs(spawnedVehicles) do
            local vehicle = spawnedVehicle.vehicle
            local blip = spawnedVehicle.blip

            if DoesEntityExist(vehicle) then
                local vehicleCoords = GetEntityCoords(vehicle)
                SetBlipCoords(blip, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z)
            else
                RemoveBlip(blip)
                table.remove(spawnedVehicles, i)
            end
        end
    end
end)




exports.ox_target:addBoxZone({
    coords = AI_Coords,
    size = vec3(1,1,6),
    rotation = 0,
    drawSprite = false,
    options = {
        {
            label = 'Collect Truck Location',
            icon = 'fa-regular fa-map',
            iconColor = 'skyblue',
            onSelect = function()
                spawnBankTruck()
            end
        }
    }
})

local function pedSpawn()
    local model = 'a_m_y_vinewood_02'
    local coords = AI_Coords

    -- Check if the model is valid
    if IsModelInCdimage(model) and IsModelValid(model) then
        -- Load the model
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(10)
        end

        -- Create the ped
        local ped = CreatePed(0, model, coords, false, true)
        SetEntityAlpha(ped, 0, false)
        Wait(50)
        SetEntityAlpha(ped, 255, false)

        -- Configure the ped's behavior
        SetPedFleeAttributes(ped, 2)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedCanRagdollFromPlayerImpact(ped, false)
        SetPedDiesWhenInjured(ped, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetPedCanPlayAmbientAnims(ped, false)
    end
end

-- Call the pedSpawn function
Citizen.CreateThread(function()
    pedSpawn()
end)