local detectionThread = nil
local detectionActive = false
local currentSurfaceHash = 0
local lastFallTime = 0
local offroadStartTime = 0
local currentSurfaceIsOffroad = false
local surfaceDebugText = ""
local showDebug = false

RegisterCommand("surfacedetection", function()
    showDebug = not showDebug

    local status = showDebug and "^2ENABLED" or "^1DISABLED"
    TriggerEvent('chat:addMessage', {
        color = {255, 255, 0},
        args = {"[SURFACE_DETECTION]", "Debug mode " .. status}
    })

    if showDebug then
        Citizen.CreateThread(function()
            while showDebug do
                Wait(0)
                SetTextFont(0)
                SetTextScale(0.35, 0.35)
                SetTextColour(255, 255, 255, 215)
                SetTextOutline()
                SetTextEntry("STRING")
                AddTextComponentString(surfaceDebugText)
                DrawText(0.015, 0.955)
            end
        end)
    end
end)

local function IsBlacklistedMotorcycleModel(vehicle)
    local model = GetEntityModel(vehicle)
    return BlacklistedMotorcycleModels and BlacklistedMotorcycleModels[model] == true
end

local function GetSurfaceMaterialBelowVehicle(vehicle)
    local pos = GetEntityCoords(vehicle)
    local ray = StartShapeTestRay(pos.x, pos.y, pos.z + 1.0, pos.x, pos.y, pos.z - 5.0, 1, vehicle, 0)
    local _, hit, _, _, matHash = GetShapeTestResultIncludingMaterial(ray)
    return hit and matHash or nil
end

local function StartDetectionThread(vehicle)
    if detectionActive then return end
    detectionActive = true

    detectionThread = Citizen.CreateThread(function()
        local shakeActive = false

        while detectionActive and vehicle and DoesEntityExist(vehicle) and IsPedInVehicle(PlayerPedId(), vehicle, false) do
            Wait(BikeOffroadConfig.RefreshRate)

            local speed = GetEntitySpeed(vehicle)
            local isOnGround = IsVehicleOnAllWheels(vehicle)

            if isOnGround then
                local mat = GetSurfaceMaterialBelowVehicle(vehicle)
                if mat then
                    local kmh = speed * 3.6
                    currentSurfaceHash = mat
                    currentSurfaceIsOffroad = SurfaceMaterialMap[mat] == true
                    local shouldShake = currentSurfaceIsOffroad and kmh > BikeOffroadConfig.shakeMinSpeed
                    local intensity = math.min(kmh / BikeOffroadConfig.shakeSpeedFactor, 1.0)

                    if currentSurfaceIsOffroad then
                        if offroadStartTime == 0 then
                            offroadStartTime = GetGameTimer()
                        end
                    else
                        offroadStartTime = 0
                    end

                    surfaceDebugText = string.format("Surface Hash: %s | Offroad: %s | Speed: %.1f km/h", tostring(mat), tostring(currentSurfaceIsOffroad), kmh)

                    if shouldShake and not shakeActive then
                        ShakeGameplayCam(BikeOffroadConfig.shakeType, intensity)
                        shakeActive = true
                    elseif (not currentSurfaceIsOffroad or kmh <= BikeOffroadConfig.shakeMinSpeed) and shakeActive then
                        StopGameplayCamShaking(true)
                        shakeActive = false
                    end

                    if currentSurfaceIsOffroad and kmh > 5.0 then
                        local health = GetVehicleEngineHealth(vehicle)
                        local newHealth = health - BikeOffroadConfig.damageRatePerTick
                        if newHealth > 300.0 then
                            SetVehicleEngineHealth(vehicle, newHealth)

                            if BikeOffroadConfig.debugEnabled then
                                print(string.format("Offroad damage applied: %.2f → %.2f", health, newHealth))
                            end
                        end
                    end
                end
            elseif shakeActive then
                StopGameplayCamShaking(true)
                shakeActive = false
            end
        end

        if shakeActive then
            StopGameplayCamShaking(true)
        end

        detectionActive = false
        detectionThread = nil
    end)
end

local function StopDetectionThread()
    detectionActive = false
end

AddEventHandler('baseevents:enteredVehicle', function(vehicle, seat)
    if seat ~= -1 then return end
    if GetVehicleClass(vehicle) ~= 8 then return end
    if IsBlacklistedMotorcycleModel(vehicle) then return end

    if BikeOffroadConfig.debugEnabled then
        print("Detection Thread started for vehicle:", vehicle)
    end

    StartDetectionThread(vehicle)
end)

AddEventHandler('baseevents:leftVehicle', function(vehicle, seat)
    if seat == -1 then
        if BikeOffroadConfig.debugEnabled then
            print("Detection Thread stopped for vehicle:", vehicle)
        end
        StopDetectionThread()
    end
end)
