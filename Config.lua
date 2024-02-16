Config = {}

Config.betaling = 1000 -- hvor meget man bliver betalt for at udføre en opgave

Config.bilspawn = vector4(60.3270, 124.2754, 79.1249, 160.9626) -- lokationen bilen skal spawne

Config.bilnavn = "boxville2" -- navnet på postbilen

Config.bilspawndistance = 20 -- hvor tæt man skal være for bilen for at den kan spawne

Config.cooldownbil = 600 -- længden på cooldown før at man kan spawne en bil igen (talet er milisekunder så 1000 = 1 sekund)

Config.person = "s_m_m_postal_01" -- peden på postmanden

Config.modtager = "s_m_m_lifeinvad_01" -- peden på npcen som modtager pakker

Config.pedCoords = vector4(69.2403, 127.7394, 79.2142 - 1, 154.0445) -- lokationen på din postmand

Config.cooldown = 600 -- længden på cooldown mellem missioner (talet er milisekunder så 1000 = 1 sekund)

Config.coords = {
    {101.0699, -1115.1877, 29.3018, 172.2791},
    {-25.1239, -988.7296, 29.2621, 63.1027},
    {315.0745, -128.4106, 69.9770, 328.9842},
    {88.0393, 214.0404, 108.2602, 255.2819},
    {290.2101, -269.1329, 54.0071, 342.4252},
    {1301.6125, -572.0880, 71.6452, 332.1333},
    {1144.5509, -1000.1694, 45.3191, 274.1880},
    {410.5126, -1910.7041, 25.4527, 81.1398},
    {488.1046, -873.5748, 25.3921, 262.8842},
    {8.4904, -1600.1423, 29.3885, 47.7676}, -- kordinaterne på de forskellige steder man kan aflevere pakker
    {98.3272, -1308.8533, 29.2772, 116.1462},
    {-297.4230, -829.2942, 32.4158, 199.5448},
    {-582.1641, -986.4705, 22.3297, 264.1880},
    {-817.5043, -622.3060, 29.2216, 138.4506},
    {-1388.1868, -422.0641, 36.6155, 348.6631},
    {-1561.5616, -210.1235, 55.5362, 4.4458},
    {-773.9561, 313.0688, 85.6981, 178.7185},
    {-286.1031, 281.4526, 89.8874, 172.5043},
    {231.7671, 365.1120, 106.0091, 157.7444},
}

Config.pedoptions = {
    label = "åben post info centeret", -- det der står på target ved postmanden / lablet
    icon = "fas fa-user", -- iconet ved siden lablet
    distance = 3, -- hvor tæt man skal være på for at kunne se targetet på postmanden
    onSelect = function(data)
        TriggerEvent("openinfocenter") -- ik ændre i det her
    end
}

Config.modtageroptions = {
    label = "Aflever pakke", -- lablet der står på manden man aflevere pakken hos
    icon = "box", -- iconet ved siden af lablet
    distance = 2, -- hvor tæt man skal være på for at kunne se targetet på postmanden
    onSelect = function(data)
        if pakketaget == true then
        TriggerEvent("opgavefærdig") -- ik ændre i det her
        else
        lib.notify({title = 'fejl', description = 'Du mangler at hente pakken i din bil', type = 'error'})
        end
    end
}

Config.pakkeoptions = {
    label = "Tag pakken ud",
    icon = "box",
    distance = 3,
    onSelect = function(data)
        TriggerEvent("pakkeud")
        exports.ox_target:removeEntity(BilNetId, Config.pakkeoptions)
    end
}