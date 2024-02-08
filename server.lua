local plantedPlants = {}

RegisterServerEvent('plantSeed')
AddEventHandler('plantSeed', function(originX, originY, originZ)
    local playerID = source
    local plantID = #plantedPlants + 1
    local markerOffsetX = 1.0


    plantedPlants[plantID] = {
        id = plantID,
        growthStage = 1,
        playerID = playerID,
        harvested = false,
        position = vector3(originX, originY, originZ),
        markerPosition = vector3(originX - markerOffsetX, originY, originZ),
        object = CreateObject(GetHashKey('bkr_prop_weed_01_small_01a'), originX, originY, originZ, true, false, false)
    }

    print("Plant ID: " .. plantedPlants[plantID].id .. ", planted.")

    local sharedPlantData = plantedPlants
    TriggerClientEvent('updateTrackingTable', -1, sharedPlantData)
end)


RegisterServerEvent('harvestPlant')
AddEventHandler('harvestPlant', function(id)
    
    for _, plant in pairs(plantedPlants) do
        if plant.id == id then
            if plant.harvested == false and plant.growthStage == 3 then
                print("Plant ID: " .. plant.id .. ", harvested.")

                DeleteEntity(plant.object)

                plant.harvested = true
                plant.position = nil
                plant.markerPosition = nil

                local sharedPlantData = plantedPlants
                TriggerClientEvent('updateTrackingTable', -1, sharedPlantData)
				
				local itemData = { key = "marijuana", amount = 180 }
				TriggerClientEvent('updateInventory', source, itemData)
                return
            else
                TriggerClientEvent('msgClient', source, "This plant has already been harvested or is not ready yet!")
                return
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        local updatedGrowthStages = {}

        for _, plant in pairs(plantedPlants) do
            if plant.harvested == false and plant.growthStage < 3 then
                plant.growthStage = plant.growthStage + 1
                DeleteEntity(plant.object)

                if plant.growthStage == 2 then
                    plant.object = CreateObject(GetHashKey('bkr_prop_weed_med_01a'), plant.position.x, plant.position.y, plant.position.z - 2.5, true, false, false)
                elseif plant.growthStage == 3 then
                    plant.object = CreateObject(GetHashKey('bkr_prop_weed_lrg_01a'), plant.position.x, plant.position.y, plant.position.z - 2.5, true, false, false)
                end

                updatedGrowthStages[plant.id] = plant.growthStage
            end
        end

        -- Trigger the client event directly with the updated growth stages
        TriggerClientEvent('updateGrowthStages', -1, updatedGrowthStages)
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        -- Loop through each plant in the plantedPlants table
        for _, plant in pairs(plantedPlants) do
            -- Check if the plant's object entity exists and delete it
            if DoesEntityExist(plant.object) then
                DeleteEntity(plant.object)
                print("Deleted entity for plant ID: " .. plant.id)
            end
        end
    end
end)
