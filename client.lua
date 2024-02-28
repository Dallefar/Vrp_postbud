local cooldownactive = false
local bilcooldownactive = false
local pakketaget = false
local annulervar = true
local paabegyndvar = false
local parkerbilvar = true
local spawnbilvar = false
local biltargetvar = false
local player = PlayerPedId() -- Changed from GetPlayerPed(-1)
local biltargetvar = false
local person = nil
local bil = nil
local modtager = nil
local prop = nil
local randomX, randomY, randomZ, randomH = 0, 0, 0, 0
local playergotocoords = vector3(0, 0, 0)
local BilNetId = nil

local HT = nil

Citizen.CreateThread(function()
    while HT == nil do
        TriggerEvent('HT_base:getBaseObjects', function(obj) HT = obj end)
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    if not DoesEntityExist(person) then
        RequestModel(Config.person)
        while not HasModelLoaded(Config.person) do
            Citizen.Wait(100)
        end

        person = CreatePed(1, GetHashKey(Config.person), Config.pedCoords, true, true)
        FreezeEntityPosition(person, true)
        SetEntityInvincible(person, true)
        SetBlockingOfNonTemporaryEvents(person, true)
        FreezeEntityPosition(person, true)
        local pedNetId = NetworkGetNetworkIdFromEntity(person)
        exports.ox_target:addEntity(pedNetId, Config.pedoptions)
    end
end)

RegisterCommand("postmenu", function(source)
    HT.TriggerServerCallback('Post-bud:HasPermission', function(result)
        if result then
            postmenu()
        else 
            notifyerror()
        end
    end, Config.perm)
end)

function postmenu()
    lib.registerContext({
        id = 'post:menu',
        title = 'Post Menu📦',
        options = {
            {
                title = 'Postbud - Oversigt',
            },
            {
                title = 'Spawn køretøj',
                description = 'Her kan du hente dit køretøj.',
                icon = 'car',
                event = 'postbil',
                disabled = spawnbilvar
            },
            {
                title = 'Parker køretøj',
                description = 'Du skal være henne ved posthuset for at parkere bilen.',
                icon = 'car',
                event = 'postbilparker',
                disabled = parkerbilvar,
            },
            {
                title = 'Påbegynd opgave',
                description = 'Start en opgave.',
                icon = 'envelope',
                event = 'startopgave',
                disabled = paabegyndvar
            },
            {
                title = 'Annuller Opgave',
                description = 'Stop din nuværende opgave.',
                icon = 'xmark',
                event = 'stopopgave',
                disabled = annulervar
            },
        }
    })
    lib.showContext('post:menu')
end

RegisterNetEvent("openinfocenter")
AddEventHandler("openinfocenter", function(source)
    HT.TriggerServerCallback('Post-bud:HasPermission', function(result)
        if result then
            local info = lib.alertDialog({
                header = "Postbud - Chef",
                content = 'Som postbud er dit job at levere pakker til byens borgere brug "/postmenu" for at komme igang.',
                centered = true,
                cancel = true
            })
        else
            notifyerror()
        end
    end, Config.perm)
end)

RegisterNetEvent("postbil")
AddEventHandler("postbil", function()
    local ped = PlayerPedId()
    local playercoords = GetEntityCoords(ped)
    local forskel = Vdist(playercoords.x, playercoords.y, playercoords.z, Config.bilspawn.x, Config.bilspawn.y, Config.bilspawn.z)
  
    if not bilcooldownactive then
        if forskel <= Config.bilspawndistance then
            RequestModel(Config.bilnavn)
            while not HasModelLoaded(Config.bilnavn) do
                Citizen.Wait(500)
            end
  
            bil = CreateVehicle(GetHashKey(Config.bilnavn), Config.bilspawn, true, false)
            carcooldown()
            spawnbilvar = true
            parkerbilvar = false
            BilNetId = NetworkGetNetworkIdFromEntity(bil)
        else
            lib.notify({
                title = 'Postbud',
                description = 'Du er for langt væk.',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'Postbud',
            description = 'Du skal vente lidt før at du kan hente en ny bil.',
            type = 'error'
        })
    end  
end)

RegisterNetEvent("postbilparker")
AddEventHandler("postbilparker", function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local distance = GetDistanceBetweenCoords(playerCoords, Config.bilspawn.x, Config.bilspawn.y, Config.bilspawn.z, true)

    if distance <= Config.maxDistanceToRemoveCar then
        if IsPedInVehicle(playerPed, bil, false) then
            TaskLeaveVehicle(playerPed, bil, 0)
            Citizen.Wait(1000) 
        end

        DoScreenFadeOut(1000) 
        Citizen.Wait(1000) 

        if DoesEntityExist(bil) then
            DeleteEntity(bil)
            spawnbilvar = false
            parkerbilvar = true
        end

        Citizen.Wait(1000)
        DoScreenFadeIn(1000) 
    else
        lib.notify({
            title = 'Postbud',
            description = 'Du er for langt væk til at fjerne bilen.',
            type = 'error'
        })
    end
end)



function carcooldown()
    bilcooldownactive = true
    Citizen.Wait(Config.cooldownbil)
    bilcooldownactive = false
end

RegisterNetEvent("pakkeud")
AddEventHandler("pakkeud", function()
    pakketaget = true
    local boneIndex = GetPedBoneIndex(player, 60309)

    RequestAnimDict("anim@heists@box_carry@")
    while not HasAnimDictLoaded("anim@heists@box_carry@") do
        Citizen.Wait(100)
    end

    TaskPlayAnim(player, "anim@heists@box_carry@", "idle", 8.0, -8, -1, 49, 0, false, false, false)

    Citizen.Wait(500)

    local modelHash = GetHashKey("hei_prop_heist_box")
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(100)
    end

    prop = CreateObject(modelHash, 0.0, 0.0, 0.0, true, true, false)
    AttachEntityToEntity(prop, player, boneIndex, 0.025, 0.08, 0.255, -145.0, 290.0, 0.0, true, true, false, true, 1, true)
    local xRotation, yRotation, zRotation = 0.0, 0.0, 90.0

    SetEntityRotation(prop, xRotation, yRotation, zRotation, 2, true)
    print(pakketaget)
end)


RegisterNetEvent("startopgave")
AddEventHandler("startopgave", function()
    if DoesEntityExist(bil) then
        if not cooldownactive then
            local totalCoords = #Config.coords
            local randomIndex = math.random(1, totalCoords)
            randomCoords = Config.coords[randomIndex]
            randomX, randomY, randomZ, randomH = randomCoords[1], randomCoords[2], randomCoords[3], randomCoords[4]
            SetNewWaypoint(randomX, randomY)

            exports.ox_target:addEntity(BilNetId, Config.pakkeoptions)
            
            parkerbilvar = true
            paabegyndvar = true
            annulervar = false
            biltargetvar = true
            
            TriggerEvent("cooldown")

            lib.notify({
                title = 'Du startede en opgave',
                description = 'Kør hen til huset på din gps og aflever pakken.',
                type = 'info'
            })

            RequestModel(Config.modtager)

            while not HasModelLoaded(Config.modtager) do
                Citizen.Wait(100)
            end

            modtager = CreatePed(1, GetHashKey(Config.modtager), randomX, randomY, randomZ - 1, randomH, true, true)
            FreezeEntityPosition(modtager, true)
            SetEntityInvincible(modtager, true)
            SetBlockingOfNonTemporaryEvents(modtager, true)
            FreezeEntityPosition(modtager, true)

            playergotocoords = GetOffsetFromEntityInWorldCoords(modtager, 0.0, 1.0, 0.0)
            local ModtagerNetId = NetworkGetNetworkIdFromEntity(modtager)

            exports.ox_target:addEntity(ModtagerNetId, { 
                label = Config.modtageroptions.label, -- lablet der står på manden man aflevere pakken hos
                icon = Config.modtageroptions.icon, -- iconet ved siden af lablet
                distance = Config.modtageroptions.distance, -- hvor tæt man skal være på for at kunne se targetet på postmanden
                onSelect = function(data)
                    if pakketaget then
                        TriggerEvent("opgavefærdig") -- ik ændre i det her
                    else
                        lib.notify({title = 'Post-Bud', description = 'Du mangler at hente pakken i din bil', type = 'error'})
                    end
                end})
        else
            lib.notify({
                title = 'Postbud',
                description = 'Du skal vente før at du kan starte endu en opgave',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'Postbud',
            description = 'Du skal have en postbil for at starte en opgave',
            type = 'error'
        })
    end
end)

RegisterNetEvent("opgavefærdig")
AddEventHandler("opgavefærdig", function()
    print(pakketaget)
    local oppositeHeading = (randomH + 180) % 360
    TaskGoStraightToCoord(player, playergotocoords, 1, -1, oppositeHeading, 0.1)
    SetEntityHeading(player, oppositeHeading)

    Wait(2000)

    RequestAnimDict("mp_common")
    while not HasAnimDictLoaded("mp_common") do
        Citizen.Wait(100)
    end

    DetachEntity(prop, true, true)
    AttachEntityToEntity(prop, player, boneIndex2, 0.025, 0.08, 0.255, -145.0, 290.0, 0.0, true, true, false, true, 1, true)

    ClearPedTasks(player)
    ClearPedTasks(modtager)

    TaskPlayAnim(player, "mp_common", "givetake1_a", 8.0, -8, -1, 0, 0, false, false, false)
    TaskPlayAnim(modtager, "mp_common", "givetake1_b", 8.0, -8, -1, 0, 0, false, false, false)
    Citizen.Wait(1000)
    DetachEntity(prop, true, true)
    AttachEntityToEntity(prop, modtager, boneIndex3, 0.025, 0.08, 0.255, -145.0, 290.0, 0.0, true, true, false, true, 1, true)
    Wait(2000)
    DeleteEntity(modtager)
    DeleteEntity(prop)
    DoScreenFadeIn(1000)

    parkerbilvar = false
    paabegyndvar = false
    annulervar = true
    biltargetvar = false

    local amount = math.random(Config.betaling[1], Config.betaling[2])
    TriggerServerEvent("betaling",amount)
    lib.notify({title = 'Færdig', description = 'Du færdig gjorde din opgave og tjente ' .. amount .. 'kr', type = 'succes'})
end)

RegisterNetEvent("stopopgave")
AddEventHandler("stopopgave", function()
    biltargetvar = false
    local alert = lib.alertDialog({
        header = 'Stop opgave',
        content = 'Vil du gerne stoppe din nuværende opgave',
        centered = true,
        cancel = true
    })
    if alert == "confirm" then
        parkerbilvar = false
        annulervar = true
        paabegyndvar = false
        DeletePed(modtager)
        DeleteWaypoint()
        DeleteEntity(prop)
        lib.notify({title = 'Stop', description = 'Du stoppede din opgave', type = 'info'})
    else
        lib.notify({title = 'Info', description = 'Du fortsatte med din opgave', type = 'info'})
    end
end)

RegisterNetEvent("cooldown")
AddEventHandler("cooldown", function()
    cooldownactive = true
    Citizen.Wait(Config.cooldown)
    cooldownactive = false
end)

function notifyerror()
    lib.notify({
        title = 'Postbud',
        description = 'Du er ikke postmand',
        type = 'error'
    })
end
