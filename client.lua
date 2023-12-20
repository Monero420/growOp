-- Initialization of Client-side tracking table for plants.
local plantedPlants = {}

-- Command to plant a seed
RegisterCommand('plant', function()
    local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
    local offsetX, offsetY, offsetZ = 0.0, 2.0, -1.0
    TriggerServerEvent('plantSeed', x + offsetX, y + offsetY, z + offsetZ)
end)

RegisterNetEvent('updateTrackingTable')
AddEventHandler('updateTrackingTable', function(sharedPlantData)
    plantedPlants = sharedPlantData
end)

-- Thread used to draw a marker in front of each planted plant. Also checks to see if the user is close enough to harvest the plant and if they're requesting to do so.
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for _, plant in pairs(plantedPlants) do
            if plant.harvested == false then
                DrawMarker( 1, plant.markerPosition.x, plant.markerPosition.y, plant.markerPosition.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 0, 155, false, true, 2, nil, nil, false )
            end
        end
        for _, plant in pairs(plantedPlants) do
            local playerPosition = GetEntityCoords(GetPlayerPed(-1))
            
            if IsControlJustReleased(1, 38) and plant.harvested == false and Vdist(plant.markerPosition.x, plant.markerPosition.y, plant.markerPosition.z, playerPosition.x, playerPosition.y, playerPosition.z) < 1.15 then
                TriggerServerEvent('harvestPlant', plant.id)
            end
        end
    end
end)    