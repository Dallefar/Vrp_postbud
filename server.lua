local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

lib.callback.register('post-bud:hasPermission', function(src)
    local user_id = vRP.getUserId({source})

    if vRP.hasPermission({user_id, Config.perm}) then
        return true
    else
        return false
    end
end)

local personCodes = {}

RegisterNetEvent('personcode', function(code)
    local src = source
    if personCodes[src] ~= nil then
        vRP.ban({user_id, 'Lua Menu detected! Skrid ud lorteunge.'})
    end
    
    personCodes[src] = code
end)

RegisterNetEvent("post-bud:betaling", function(personCode)
    local amount = math.random(Config.betaling[1], Config.betaling[2])
    local src = source
    local user_id = vRP.getUserId({src})

    if personCodes[src] ~= personCode then
        vRP.ban({user_id, 'Lua Menu detected! Skrid ud lorteunge.'})
        PerformHttpRequest(Config.WEBHOOK, function(err, text, headers) end, 'POST', 
        json.encode({
            username = 'Logs', 
            content = 'ID: '..user_id..' Forsøgte og spawne '..amount..' DKK via '..GetCurrentResourceName()
        }), {['Content-Type'] = 'application/json'})
    end
    
    vRP.giveBankMoney({user_id, amount})
end)

