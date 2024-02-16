cooldownactive = false
bilcooldownactive = false
pakketaget = false
annulervar = true
paabegyndvar = false
parkerbilvar = true
spawnbilvar = false
player = GetPlayerPed(-1) 
biltargetvar = false

ESX = exports["es_extended"]:getSharedObject()

---------
-- thread
---------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        
        --------------
        -- spawner ped
        --------------

        if DoesEntityExist(person) == false then
            RequestModel(Config.person)
            while not HasModelLoaded(Config.person) do
                Citizen.Wait(100)
            end

            person = CreatePed(1, GetHashKey(Config.person), Config.pedCoords, true, true)
            FreezeEntityPosition(person, true)
            SetEntityInvincible(person, true)
            SetBlockingOfNonTemporaryEvents(person, true)
            TaskStandStill(person, 100000000000000000000000000000)

            local pedNetId = NetworkGetNetworkIdFromEntity(person)
            exports.ox_target:addEntity(pedNetId, Config.pedoptions)
        end

        -----------
        -- postmenu
        -----------

        lib.registerContext({
          id = 'post:menu',
          title = 'Post Menu📦',
          options = {
            {
              title = 'Oversigt',
            },
            {
              title = 'Spawn køretøj',
              description = 'her kan du spawne dit køretøj',
              icon = 'car',
              event = 'postbil',
              disabled = spawnbilvar
            },
            {
              title = 'parker køretøj',
              description = 'her kan du parkere dit køretøj',
              icon = 'car',
              event = 'postbilparker',
              disabled = parkerbilvar,
            },
            {
              title = 'Påbegynd opgave',
              description = 'Gå igang med en opgave',
              icon = 'envelope',
              event = 'startopgave',
              disabled = paabegyndvar
            },
            {
              title = 'Annuler Opgave',
              description = 'Stop din igangværende opgave',
              icon = 'xmark',
              event = 'stopopgave',
              disabled = annulervar
            },
          }
        })
        
        RegisterCommand("postmenu", function()
          if ESX.PlayerData.job.name == 'postmand' then
            lib.showContext('post:menu')
          else
            lib.notify({
              title = 'fejl',
              description = 'Du er ikke postmand',
              type = 'error'
            })
          end
        end)
    end
end)

--------------
-- info center
--------------

RegisterNetEvent("openinfocenter")
AddEventHandler("openinfocenter", function()
    if ESX.PlayerData.job.name == 'postmand' then
      local info = lib.alertDialog({
        header = "hej",
        content = 'som postmand er dit job at levere pakker til byens borgere skriv /postmenu for at komme igang',
        centered = true,
        cancel = true
    })
    else
      lib.notify({
        title = 'fejl',
        description = 'Du er ikke postmand',
        type = 'error'
    })
    end
end)

----------
-- postbil
----------

RegisterNetEvent("postbil")
AddEventHandler("postbil", function()
  local playercoords = GetEntityCoords(player)
  local forskel = GetDistanceBetweenCoords(playercoords, Config.bilspawn, true)
  
  if bilcooldownactive == false then
      if forskel <= Config.bilspawndistance then
          RequestModel(Config.bilnavn)
          while not HasModelLoaded(Config.bilnavn) do
              Citizen.Wait(500)
          end
  
          bil = CreateVehicle(GetHashKey(Config.bilnavn), Config.bilspawn, true, false)
          TriggerEvent("bilcooldown")
          spawnbilvar = true
          parkerbilvar = false
          BilNetId = NetworkGetNetworkIdFromEntity(bil)
      else
          lib.notify({
              title = 'fejl',
              description = 'Du er for langt væk',
              type = 'error'
          })
      end
  else
      lib.notify({
          title = 'fejl',
          description = 'Du skal vente lidt før at du kan spawne en ny bil',
          type = 'error'
      })
  end  
end)


-- parker function
RegisterNetEvent("postbilparker")
AddEventHandler("postbilparker", function()
    DeleteEntity(bil)
    spawnbilvar = false
    parkerbilvar = true
end)

-- bil cooldown function
RegisterNetEvent("bilcooldown")
AddEventHandler("bilcooldown", function()
    bilcooldownactive = true
    Wait(Config.cooldownbil)
    bilcooldownactive = false
end)

-- tag pakke ud af bil function
RegisterNetEvent("pakkeud")
AddEventHandler("pakkeud", function()
    pakketaget = true
    local ped = GetPlayerPed(-1)
    local boneIndex = GetPedBoneIndex(ped, 60309)

    RequestAnimDict("anim@heists@box_carry@")
    while not HasAnimDictLoaded("anim@heists@box_carry@") do
        Citizen.Wait(100)
    end

    TaskPlayAnim(ped, "anim@heists@box_carry@", "idle", 8.0, -8, -1, 49, 0, false, false, false)

    Citizen.Wait(500)

    local modelHash = GetHashKey("hei_prop_heist_box")
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(100)
    end

    prop = CreateObject(modelHash, 0.0, 0.0, 0.0, true, true, false)
    AttachEntityToEntity(prop, ped, boneIndex, 0.025, 0.08, 0.255, -145.0, 290.0, 0.0, true, true, false, true, 1, true)
    local xRotation = 0.0
    local yRotation = 0.0
    local zRotation = 90.0

    SetEntityRotation(prop, xRotation, yRotation, zRotation, 2, true)
end)

-- remove target
RegisterNetEvent("respawncar")
AddEventHandler("respawncar", function()
  DeleteVehicle(bil)

    RequestModel(Config.bilnavn)
          while not HasModelLoaded(Config.bilnavn) do
              Citizen.Wait(500)
          end

    bil = CreateVehicle(GetHashKey(Config.bilnavn), carspawn, true, false)
end)

---------------
-- post opgaver
---------------

-- opgave start
RegisterNetEvent("startopgave")

AddEventHandler("startopgave", function()
    if DoesEntityExist(bil) then
        if cooldownactive == false then
            local totalCoords = #Config.coords
            local randomIndex = math.random(1, totalCoords)
            randomCoords = Config.coords[randomIndex]
            randomX = randomCoords[1]
            randomY = randomCoords[2]
            randomZ = randomCoords[3]
            randomH = randomCoords[4]
            SetNewWaypoint(randomX, randomY)

            exports.ox_target:addEntity(BilNetId, Config.pakkeoptions)
            
            parkerbilvar = true
            paabegyndvar = true
            annulervar = false
            biltargetvar = true
            
            TriggerEvent("cooldown")

            lib.notify({
                title = 'Du startede en opgave',
                description = 'Kør hen til huset på din gps og aflever pakken',
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
            TaskStandStill(modtager, 100000000000000000000000000000)

            playergotocoords = GetOffsetFromEntityInWorldCoords(modtager, 0.0, 1.0, 0.0)
            local ModtagerNetId = NetworkGetNetworkIdFromEntity(modtager)

            exports.ox_target:addEntity(ModtagerNetId, Config.modtageroptions)
        else
            lib.notify({
                title = 'fejl',
                description = 'du skal vente før at du kan starte endu en opgave',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'fejl',
            description = 'du skal have en postbil for at starte en opgave',
            type = 'error'
        })
    end
end)

-- opgave færdig
RegisterNetEvent("opgavefærdig")
AddEventHandler("opgavefærdig", function()
    carspawn = GetEntityCoords(bil)
    local boneIndex2 = GetPedBoneIndex(GetPlayerPed(-1), 57005)
    local boneIndex3 = GetPedBoneIndex(modtager, 57005)
    local oppositeHeading = (randomH + 180) % 360
    local player = GetPlayerPed(-1)
    TaskGoStraightToCoord(player, playergotocoords, 1, -1, oppositeHeading, 0.1)
    SetEntityHeading(GetPlayerPed(-1), oppositeHeading)

    Wait(2000)

    RequestAnimDict("mp_common")
  while not HasAnimDictLoaded("mp_common") do
      Citizen.Wait(100)
  end

  DetachEntity(prop, true, true)
  AttachEntityToEntity(prop, GetPlayerPed(-1), boneIndex2, 0.025, 0.08, 0.255, -145.0, 290.0, 0.0, true, true, false, true, 1, true)

  ClearPedTasks(GetPlayerPed(-1))
  ClearPedTasks(modtager)

  TaskPlayAnim(GetPlayerPed(-1), "mp_common", "givetake1_a", 8.0, -8, -1, 0, 0, false, false, false)
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

    TriggerEvent("respawncar")
    TriggerServerEvent("betaling", source)
    lib.notify({title = 'Færdig', description = 'Du færdig gjorde din opgave', type = 'succes'})
end)

-- stop opgave
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
    TriggerEvent("respawncar")
    else
      lib.notify({title = 'Info', description = 'Du fortsatte med din opgave', type = 'info'})
    end
end)

-- Opgave cooldown
RegisterNetEvent("cooldown")
AddEventHandler("cooldown", function()
    cooldownactive = true
    Wait(Config.cooldown)
    cooldownactive = false
end)

RegisterCommand("test", function()
  TriggerServerEvent("betaling")
end)