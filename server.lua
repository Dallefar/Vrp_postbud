local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","Vrp-postbud")

HT = nil

TriggerEvent('HT_base:getBaseObjects', function(obj) HT = obj end)

HT.RegisterServerCallback("Postbud:hasgruop", function(source,cb, gruop)
    local user_id = vRP.getUserId(source)

    if vRP.hasGroup(userid, gruop) then
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent("betaling")
AddEventHandler("betaling", function()
    local xPlayer = vRP.getUserId(source)
    vRP.giveBankMoney(xPlayer,Config.lua)
end)
