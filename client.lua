-- Initialization of Client-side tracking table for plants.
local plantedPlants = {}

-- Command to plant a seed
RegisterCommand('plant', function()
    local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
    -- Offset data so the plant doesn't spawn inside the player's feet or floating.
    local offsetX, offsetY, offsetZ = 0.0, 2.0, -1.0
    -- Trigger the plantSeed event on the server script and pass along the coordinates.
    TriggerServerEvent('plantSeed', x + offsetX, y + offsetY, z + offsetZ)
end)

-- Callback for recieving updates to the plantedPlants tracking table from the server. 
RegisterNetEvent('updateTrackingTable')
AddEventHandler('updateTrackingTable', function(sharedPlantData)
    plantedPlants = sharedPlantData
end)

-- Create a Citizen thread to seperate infinite while loop from main thread. 
Citizen.CreateThread(function()
    -- Infinite Loop.
    while true do
        -- Mandatory Wait() to prevent infinite while loop from crashing.
        Citizen.Wait(0)
        -- For each object in the tracking table draw a marker slightly offset in-front from it.
        for _, plant in pairs(plantedPlants) do
            if plant.harvested == false then
                DrawMarker( 1, plant.markerPosition.x, plant.markerPosition.y, plant.markerPosition.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 0, 155, false, true, 2, nil, nil, false )
            end
        end
        -- For each object in the tracking table check to see if the player is in-range of the player.
        -- If so allow them to press the 'E' key to trigger harvestPlant on the server passing it the id of the nearby plant.
        for _, plant in pairs(plantedPlants) do
            local playerPosition = GetEntityCoords(GetPlayerPed(-1))
            if IsControlJustReleased(1, 38) and plant.harvested == false and Vdist(plant.markerPosition.x, plant.markerPosition.y, plant.markerPosition.z, playerPosition.x, playerPosition.y, playerPosition.z) < 1.15 then
                TriggerServerEvent('harvestPlant', plant.id)
            end
        end
    end
end)    
