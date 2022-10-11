local onNui = false
local sourcePlayer = nil

local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
xSound = exports.xsound

local syncVehicle = {
    vehId = 0
}

RegisterNetEvent("suspension:setVehData")
AddEventHandler("suspension:setVehData", function(name, neon, xenon, isOwner)
    syncVehicle["isOwner"] = isOwner
    syncVehicle["vehName"] = name
    syncVehicle["neon"] = neon
    syncVehicle["xenon"] = xenon
end)

RegisterNetEvent("suspension:opennui")
AddEventHandler("suspension:opennui", function(source)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsUsing(ped)
    if (syncVehicle["vehId"] == 0 and GetPedInVehicleSeat(veh, -1) == ped) then
        local model = GetEntityModel(veh)
        local displaytext = GetDisplayNameFromVehicleModel(model)
        local plate = GetVehicleNumberPlateText(veh)
        TriggerServerEvent("suspension:getVehDataCallback", source, plate)
        Citizen.Wait(500)
        if(syncVehicle["isOwner"]) then
            syncVehicle["vehPlate"] = plate
            syncVehicle["vehId"] = veh
            local message = "Veículo placa: "..GetVehicleNumberPlateText(veh).." Sincronizado com sucesso!"
            TriggerEvent("Notify", "verde", message, 5000)
        else
            TriggerEvent("Notify", "vermelho", "Você deve ser dono do veículo \npara sincronizar", 5000)
        end
    elseif (syncVehicle["vehId"] == 0) then
        TriggerEvent("Notify", "vermelho", "Você deve estar no banco do motorista do veículo \npara sincronizar", 5000) 
    end
    if (syncVehicle["vehId"] ~= 0) then
    local syncedVeh = syncVehicle["vehId"]
    onNui = not onNui
    sourcePlayer = source
    if onNui then
        SetNuiFocus(true, true)
        SendNUIMessage({
            show = true,
            suspValue = GetVehicleSuspensionHeight(syncedVeh, susp),
            vehicleName = syncVehicle["vehName"],
            vehiclePlate = syncVehicle["vehPlate"],
            vehicleNeon = syncVehicle["neon"],
            vehicleXenon = syncVehicle["xenon"]
        })
    else
        SetNuiFocus(false, false)
        SendNUIMessage({
            show = false
        })
    end
end
end)

RegisterNetEvent("suspension:playsound")
AddEventHandler("suspension:playsound", function(vPos)
    xSound:PlayUrlPos("name", "https://cf-media.sndcdn.com/BbbyIbHsuuJu?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiKjovL2NmLW1lZGlhLnNuZGNkbi5jb20vQmJieUliSHN1dUp1KiIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTY2MzYxNjg5Nn19fV19&Signature=aayFMIcqi2vYBfVbovdCHENtvnTvZE~PDqm-4F5rDNXmG-HUHiVMZBrsrEYWWV4wHAURCrykZtB0J5g6Oo6XfoC2SkEUfCfo0U2-1dGsnmA7Ot1kbxLKkYu1ePFtnxILT~G5NG4WHvia~MDUBecraPJrbTDO87vOVsNSN7RdTPsdlVTPamf38qch5urfIzeuImCCXUKnv2~UkaykdfsRV1kICLv8U5odaPOmsj4yHTLMS-xDybTzNAr-CZqFsTxA8NxYdF5Z7VN4JQuG9Qy3LOzGAQNrln7-2SWr4sDpoqA3Xw78~4FtxF0fN9b7iV-L0oTc471LGx4fS3VKftqIgw__&Key-Pair-Id=APKAI6TU7MMXM5DG6EPQ", 1.0,vPos, false)
end)

RegisterNetEvent("suspension:apply")
AddEventHandler("suspension:apply", function(veh, susp)
    local entityId = NetworkGetEntityFromNetworkId(veh)
    if(entityId ~= 0) then
     entityId = NetworkGetEntityFromNetworkId(veh)
     Citizen.Wait(500)
     SetVehicleSuspensionHeight(entityId, susp)
     if (susp < 0) then
        SetVehicleWheelYRotation(entityId, 0, 0)
        SetVehicleWheelYRotation(entityId, 1, 0)
        SetVehicleWheelYRotation(entityId, 2, 0)
        SetVehicleWheelYRotation(entityId, 3, 0)
     else
        SetVehicleWheelYRotation(entityId, 0, (math.abs(susp)*-1 - 0.03))
        SetVehicleWheelYRotation(entityId, 1, (susp + 0.03))
        SetVehicleWheelYRotation(entityId, 2, (math.abs(susp)*-1 - 0.01))
        SetVehicleWheelYRotation(entityId, 3, (susp + 0.01))
     end
        --SetVehicleSuspensionHeight(entityId, (math.abs(susp)*-susp) * 10)
        --SetVehicleHandlingFloat(entityId,"CHandlingData","fSuspensionraise", susp)
    end
end)

RegisterNUICallback("showSusp", function(data)
        local netId =  NetworkGetNetworkIdFromEntity(syncVehicle["vehId"]);
        TriggerServerEvent("suspension:serverSync", netId, data.susp)
end)

RegisterNUICallback("closeSusp", function() 
    SendNUIMessage({
        show = false
    })
        onNui = false
    SetNuiFocus(false, false)
end
)

RegisterNUICallback("setLightsOn", function()
    SetVehicleLights(syncVehicle["vehId"], 2)
end
)

RegisterNUICallback("setLightsOff", function() 
    SetVehicleLights(syncVehicle["vehId"], 0)
end
)

RegisterNUICallback("setNeonOn", function()
    SetVehicleNeonLightEnabled(syncVehicle["vehId"],0, true)
    SetVehicleNeonLightEnabled(syncVehicle["vehId"],1, true)
    SetVehicleNeonLightEnabled(syncVehicle["vehId"],2, true)
    SetVehicleNeonLightEnabled(syncVehicle["vehId"],3, true)
end
)

RegisterNUICallback("setNeonOff", function()
    SetVehicleNeonLightEnabled(syncVehicle["vehId"],0, false)
    SetVehicleNeonLightEnabled(syncVehicle["vehId"],1, false)
    SetVehicleNeonLightEnabled(syncVehicle["vehId"],2, false)
    SetVehicleNeonLightEnabled(syncVehicle["vehId"],3, false)
end
)

RegisterNUICallback("setEngineOn", function()
    SetVehicleEngineOn(syncVehicle["vehId"], true, true, false )
end
)

RegisterNUICallback("setEngineOff", function()
    SetVehicleEngineOn(syncVehicle["vehId"], false, false, true )
end
)

AddEventHandler("suspension:deleteVehSync", function()
    if (syncVehicle["vehId"] == 0) then
        TriggerEvent("Notify", "vermelho", "Nenhum veículo sicronizado encontrado!", 5000) 
    else
        syncVehicle["vehId"] = 0
        syncVehicle["vehName"] = ""
        syncVehicle["neon"] = false
        syncVehicle["xenon"] = false
        TriggerEvent("Notify", "verde", "Controle desincronizado com sucesso!", 5000)
        SendNUIMessage({
            show = false
        })
            onNui = false
        SetNuiFocus(false, false)
    end
end)

RegisterNUICallback('desyncVehicle', function(source, args, rawCommand)
    TriggerEvent("suspension:deleteVehSync")
end
)