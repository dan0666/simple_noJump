local debugMode = false  -- Set to true to enable debug messages
local showMessage = true -- Set to false to disable the "Jumping is not allowed here." message



local restrictedZones = {
    {
        name = "YOUR LOCATION",
        points = {
            vector2(-1591.5594, -399.3680),
            vector2(-1565.3947, -364.8755),
            vector2(-1541.3962, -386.4533),
            vector2(-1567.9528, -418.1160),
        }
    },
    -- Add more restricted zones with their corner points
    --[[{
        name = "YOUR LOCATION",
        points = {
            vector2(00.00, 00.00),
            vector2(00.00, 00.00),
            vector2(00.00, 00.00),
            vector2(00.00, 00.00),
        }
    },]]
}

function pointInPolygon(point, polygon)
    local oddNodes = false
    local j = #polygon
    
    for i = 1, #polygon do
        if (
            (polygon[i].y < point.y and polygon[j].y >= point.y)
            or (polygon[j].y < point.y and polygon[i].y >= point.y)
        ) then
            if (
                polygon[i].x + (point.y - polygon[i].y) / (polygon[j].y - polygon[i].y) * (polygon[j].x - polygon[i].x) < point.x
            ) then
                oddNodes = not oddNodes
            end
        end
        j = i
    end
    
    return oddNodes
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local playerPosition = vector2(playerCoords.x, playerCoords.y)

        local wasInsideRestrictedZone = insideRestrictedZone
        insideRestrictedZone = false

        for _, zone in ipairs(restrictedZones) do
            local isInsideZone = pointInPolygon(playerPosition, zone.points)

            if isInsideZone then
                insideRestrictedZone = true

                if not wasInsideRestrictedZone then
                    enterTime = GetGameTimer()
                end
                DisableControlAction(0, 22, true) -- Disable the jump action (control ID 22)
            end
        end

        if wasInsideRestrictedZone and not insideRestrictedZone then
            RemoveRestrictedZoneMessage()
        end

        if showMessage and insideRestrictedZone then
            local elapsedTime = GetGameTimer() - enterTime
            if elapsedTime <= 3000 then
                local remainingTime = 3000 - elapsedTime
                DrawText3D(playerCoords.x, playerCoords.y, playerCoords.z, string.format("🚷"))
                --DrawText3D(playerCoords.x, playerCoords.y, playerCoords.z, "🚷YOUR MESSAGE OR ICON")
            end
        end
    end
end)

function RemoveRestrictedZoneMessage()
    ClearPrints()
end



function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropShadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextCentre(1)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

