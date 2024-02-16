ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent("betaling")
AddEventHandler("betaling", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addAccountMoney('bank', 1000)
end)
