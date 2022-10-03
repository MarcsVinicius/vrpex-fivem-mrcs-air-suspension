-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
xSound = exports.xsound

local mockInstance = {
    id = 1,
    susp = 0.2
   }
local runningInstances = {mockInstance}


function getSavedMods(source, vehicle_plate)
    local vehicle_owner_id = vRP.getVehiclePlate(vehicle_plate)
    local user_id = vRP.getUserId(source)
    local vehicle = vRP.query("vRP/get_vehicle",{ user_id = parseInt(user_id) })
    local found = false
    for k,v in pairs(vehicle) do
    if (vehicle[k].plate == vehicle_plate) then
        local custom = json.decode(vRP.getSData("custom:"..parseInt(user_id)..":"..v.vehicle))
        if (custom) then
            found = true
            TriggerClientEvent("suspension:setVehData",user_id, vRP.vehicleName(v.vehicle), custom.neon, custom["mods"]["22"]["mod"], true)
        else
            found = true
            TriggerClientEvent("suspension:setVehData",user_id, vRP.vehicleName(v.vehicle), false, false, true)
        end
    elseif (found == false) then
        TriggerClientEvent("suspension:setVehData",user_id, vRP.vehicleName(v.vehicle), false, false, false)
    end
    end
   -- return json.decode(vRP.getSData("custom:"..vehicle_owner_id..":"..tostring(vehicle_name)) or {}) or {}
end

RegisterServerEvent("suspension:getVehDataCallback")
AddEventHandler("suspension:getVehDataCallback", function(source, vehicle_plate)
    getSavedMods(source, vehicle_plate)
end)

TriggerClientEvent('chat:addSuggestion', '/susp', 'comando para trocar a placa do seu veículo')

RegisterCommand('susp', function(source, args, rawCommand)
    TriggerClientEvent("suspension:opennui", source, source)
end
)

RegisterServerEvent("suspension:sendServerVehHeight")
AddEventHandler("suspension:sendServerVehHeight",function(height)
    newHeight = height
end)

RegisterServerEvent('suspension:serverSync')
AddEventHandler("suspension:serverSync",function(vehNetId,susp)
   local isInvalid
   local newInstance = {
    id = vehNetId,
    susp = susp
   }
   for i, instance in ipairs(runningInstances) do
    if (instance["id"] == vehNetId) then
        instance["id"] = vehNetId
        instance["susp"] = susp
    else
        table.insert(runningInstances, newInstance)
    end
   end
   local v = NetworkGetEntityFromNetworkId(vehNetId)
   local vPos = GetEntityCoords(v, false)
   TriggerClientEvent("suspension:playsound", -1, vPos)
	while true do
        local vehicleEntity = NetworkGetEntityFromNetworkId(vehNetId)
        for i, instance in ipairs(runningInstances) do
            if (instance["id"] == vehNetId and instance["susp"] ~= susp) then
                isInvalid = true
            end
        end
        if (vehicleEntity ~= 0 and not isInvalid) then
            for _, playerId in ipairs(GetPlayers()) do
                local ped = GetPlayerPed(playerId)
                local vehicleCoords = GetEntityCoords(vehicleEntity, false)
                local pedCoords = GetEntityCoords(ped, false)
                local distance = #(vehicleCoords.xy - pedCoords.xy)
                if(distance <= 500) then
                   TriggerClientEvent("suspension:apply", playerId, vehNetId, susp)
                end
            end
        else
            break
        end
        Citizen.Wait(1000)
    end
end)