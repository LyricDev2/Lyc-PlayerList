local isOpen = false
local refreshTimer = false

RegisterCommand(Config.Key, function()
    if isOpen then
        CloseUI()
    else
        OpenUI()
    end
end)

RegisterKeyMapping(Config.Key, "Player List", "keyboard", Config.Key)

function OpenUI()
    isOpen = true
    local players = GetOnlinePlayers()
    SendNUIMessage({
        action = "openF10",
        players = players,
        accentColor = Config.AccentColor,
        resourceName = GetCurrentResourceName()
    })
    SetNuiFocus(true, true)
    StartRefreshTimer()
end

function CloseUI()
    isOpen = false
    refreshTimer = false
    SendNUIMessage({ action = "close" })
    SetNuiFocus(false, false)
end

function StartRefreshTimer()
    if refreshTimer then return end
    refreshTimer = true
    CreateThread(function()
        while refreshTimer do
            Wait(Config.RefreshInterval)
            if not refreshTimer then break end
            local players = GetOnlinePlayers()
            SendNUIMessage({
                action = "updatePlayers",
                players = players
            })
        end
    end)
end

function GetOnlinePlayers()
    local players = {}
    for _, playerId in ipairs(GetActivePlayers()) do
        local serverId = GetPlayerServerId(playerId)
        local name = GetPlayerName(playerId)

        players[#players + 1] = {
            serverID = serverId,
            name = name,
            ping = 0,
            discordId = "...",
            discordName = "...",
            job = {
                label = "Unemployed",
                grade = "None",
                onDuty = false
            }
        }

        TriggerServerEvent("lyric:getPlayerData", serverId)
    end
    return players
end

RegisterNetEvent("lyric:receivePlayerData", function(data)
    if not isOpen then return end
    SendNUIMessage({
        action = "patchPlayer",
        data = data
    })
end)

RegisterNUICallback("closeUI", function(_, cb)
    isOpen = false
    refreshTimer = false
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("refreshData", function(_, cb)
    local players = GetOnlinePlayers()
    cb(players)
end)