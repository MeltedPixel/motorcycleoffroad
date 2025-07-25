BikeOffroadConfig = {
    debugEnabled = true,             -- Default state for debug command
    RefreshRate = 250,                -- ms between surface checks
    damageRatePerTick = 2,            -- Minimal engine damage per tick (every 500ms)
    shakeSpeedFactor = 60.0,          -- Speed where shake maxes out
    shakeMinSpeed = 15.0,             -- Minimum speed to allow shake
    shakeType = "SKY_DIVING_SHAKE",   -- Type of camera shake to use
}

SurfaceMaterialMap = {
    [-1833527165] = false,  -- Asphalt
    [1187676648]  = false,  -- Concrete
    [-1286696947] = true,   -- Cobblestone
    [951832588]   = true,   -- Gravel
    [-1907520769] = true,   -- Gravel
    [-1281679678] = true,   -- Loose Gravel
    [-1502843622] = true,   -- Muddy Gravel
    [-1320876379] = true,   -- Muddy Dirt
    [-1281679678] = true,   -- Loose Gravel
    [2138002236]  = true,   -- Muddy Sand
    [-1942898710] = true,   -- Loose Gravel
    [223086562]   = true,   -- Mud
    [-1595148316] = true,   -- Sand
    [-700658213]  = true,   -- Dirt
    [1925605558] = true,    -- Loose Dirt
    [1333033863]  = true,   -- Grass
    [510490462] = true,     -- Short Grass / Turf
    [2128369009] = true,    -- Tall Grass
    [-1885547121] = true,   -- Rock
    [-1931024423] = true,   -- Snow
    [-786060715]  = true,   -- Ice
    [435688960]   = true,   -- Shallow Water
}

BlacklistedMotorcycleModels = {
    [`enduro`] = true,
    [`sanchez`] = true,
    [`bf400`] = true,
}