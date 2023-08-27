local currentBlips = {}

if Config.enable_blips then
    local blip_status = false

    RegisterNetEvent("MxDev:TOGGLELEOBLIP")
    AddEventHandler("MxDev:TOGGLELEOBLIP", function(st)
        blip_status = st
        if not blip_status then
            RemoveAnyExistingEmergencyBlips()
        end
    end)

    RegisterNetEvent("MxDev:UPDATEBLIPS")
    AddEventHandler("MxDev:UPDATEBLIPS", function(activeEmergencyPersonnel)
        if blip_status then
            RemoveAnyExistingEmergencyBlips()
            Citizen.Wait(0)
            RefreshBlips(activeEmergencyPersonnel)
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        local source = GetPlayerServerId(PlayerId())
        TriggerServerEvent('MxDev:AUTOBLIP', source)
        Citizen.Wait(15000)
    end
end)

function RemoveAnyExistingEmergencyBlips()
    for i = #currentBlips, 1, -1 do
        local b = currentBlips[i]
        if b and DoesBlipExist(b) then
            RemoveBlip(b)
        end
        table.remove(currentBlips, i)
    end
end


function RefreshBlips(activeEmergencyPersonnel)
    for src, info in pairs(activeEmergencyPersonnel) do
        if src ~= myServerId and info and info.coords then
            local playerIdx = GetPlayerFromServerId(src)
            local ped = GetPlayerPed(playerIdx)
            local heading = GetEntityHeading(ped)
            local blipType = (info.coords and IsPedInAnyVehicle(ped, false)) and GetVehicleBlipType(ped) or GetPedBlipType(ped)
            local blip = AddBlipForEntity(ped)
            SetBlipScale(blip, Config.blipscale)
            SetBlipSprite(blip, blipType)
            SetBlipCategory(blip, 7)
            SetBlipShrink(blip, true)
            SetBlipPriority(blip, 10)
            SetBlipColour(blip, Config.blipcolor)
            SetBlipAsShortRange(blip, true)
            SetBlipDisplay(blip, 6)
            --SetBlipAsFriendly(blip, true)
            SetBlipShowCone(blip, Config.blipcone)

            ShowHeadingIndicatorOnBlip(blip, Config.HeadingIndicator)
            SetBlipRotation(blip, heading)
            
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(info.name)
            EndTextCommandSetBlipName(blip)
            
            table.insert(currentBlips, blip)
        end
    end
end

function GetPedBlipType(ped)
    local health = GetEntityHealth(ped)
    if IsPedInAnyVehicle(ped, false) then
        return GetVehicleBlipType(ped)
    elseif Config.show_officer_on_foot and health == 0 then
        return 310
    elseif Config.show_officer_on_foot then
        return Config.leofootblip
    end
end

function GetVehicleBlipType(vehicle)
    local vehicleClass = GetVehicleClass(vehicle)
    if vehicleClass == 15 then
        return Config.helicopterblip
    elseif vehicleClass == 14 then
        return Config.boatblip
    elseif vehicleClass == 8 or vehicleClass == 13 then
        return Config.motorcycleblip
    elseif vehicleClass == 16 then
        return Config.planeblip
    else
        return Config.vehicleblip
    end
end