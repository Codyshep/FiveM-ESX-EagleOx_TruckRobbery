ESX = exports['es_extended']:getSharedObject()

require('config')

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    print('^6The resource "^4' .. resourceName .. '^6" has been started.')
end)

RegisterServerEvent('TruckRobber:RemovePick')
AddEventHandler('TruckRobber:RemovePick', function()
    
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem(truckRobItems.DoorPickItem, 1)
	
end)

RegisterServerEvent('TruckRobber:HasPick')
AddEventHandler('TruckRobber:HasPick', function()
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)

    local hasPick = xPlayer.getInventoryItem(truckRobItems.DoorPickItem).count > 0
    local hasTorch = xPlayer.getInventoryItem(truckRobItems.DoorTorchItem).count > 0

    if hasPick and hasTorch then
        xPlayer.removeInventoryItem(truckRobItems.DoorTorchItem, 1)
        TriggerClientEvent('TruckRobber:startRobbery', playerId)
    else
        TriggerClientEvent('TruckRobber:noProperItems', playerId)
    end
end)

local grabbing = false

RegisterServerEvent('TruckRobber:Winner')
AddEventHandler('TruckRobber:Winner', function()
    local playerId = source 
    local xPlayer = ESX.GetPlayerFromId(playerId)
    TriggerClientEvent('TruckRobber:grabbingCash', playerId)

    grabbing = true
    local grabCount = 0

    local targetPlayerId = playerId
    
    while grabbing == true and grabCount < truckConfig.GrabTime/1000 do
        Citizen.Wait(1000)
        xPlayer.addInventoryItem('money', math.random(maxAmmountOfCash.minumim, maxAmmountOfCash.maximum))
        grabCount = grabCount + 1
    end

    grabbing = false
end)

