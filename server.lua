local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","Vrp_postbud-main")

local HoneyPot = "DIN WEBHOOK"

HT = nil

TriggerEvent('HT_base:getBaseObjects', function(obj) HT = obj end)

HT.RegisterServerCallback("Post-bud:HasPermission", function(source, cb, perm)
    local user_id = vRP.getUserId({source})



    if vRP.hasPermission({user_id, perm}) then
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent("betaling")
AddEventHandler("betaling", function(amount)
    local user_id = vRP.getUserId({source})
        
        if amount < 12000 then
            vRP.giveBankMoney({user_id,amount})
        else
            vRP.ban({user_id, 'Du forsøgte og spawne '..amount..' via' ..GetCurrentResourceName()})
            PerformHttpRequest(HoneyPot, function(err, text, headers) end, 'POST', 
            json.encode({username = 'Logs', 
            content = 'ID: '..user_id..' Forsøgte og spawne '..amount..' DKK via '..GetCurrentResourceName()}), {['Content-Type'] = 'application/json'})
        end
end)

