local QBCore = nil
local ESX = nil

if Config.Framework == "qbcore" then
    QBCore = exports["qb-core"]:GetCoreObject()
elseif Config.Framework == "esx" then
    ESX = exports["es_extended"]:getSharedObject()
end

RegisterNetEvent("lyric:getPlayerData", function(targetServerId)
    local src = source
    local jobLabel = "Unemployed"
    local jobGrade = "None"
    local onDuty = false
    local discordId = "N/A"
    local discordName = "N/A"
    local ping = GetPlayerPing(targetServerId) or 0

    local playerName = GetPlayerName(targetServerId) or "Unknown"

    local identifiers = GetPlayerIdentifiers(targetServerId)
    for _, id in ipairs(identifiers) do
        if string.find(id, "discord:") then
            discordId = string.gsub(id, "discord:", "")
            break
        end
    end

    if Config.Framework == "qbcore" then
        local player = QBCore.Functions.GetPlayer(targetServerId)
        if player then
            jobLabel = player.PlayerData.job.label or "Unemployed"
            jobGrade = player.PlayerData.job.grade.name or "None"
            onDuty = player.PlayerData.job.onduty or false
            discordName = player.PlayerData.charinfo and
                (player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname)
                or playerName
        end
    elseif Config.Framework == "esx" then
        local player = ESX.GetPlayerFromId(targetServerId)
        if player then
            local job = player.getJob()
            jobLabel = job.label or "Unemployed"
            jobGrade = job.grade_label or "None"
            onDuty = true
            discordName = player.getName() or playerName
        end
    else
        discordName = playerName
    end

    TriggerClientEvent("lyric:receivePlayerData", src, {
        serverID = targetServerId,
        ping = ping,
        discordId = discordId,
        discordName = discordName,
        job = {
            label = jobLabel,
            grade = jobGrade,
            onDuty = onDuty
        }
    })
end)