
local bloxFruitsPlaces = {
    [7449423635] = true,
    [2753915549] = true,
    [4442272183] = true,
    [122478697296975] = true,
    [73902483975735] = true
}

local placeId = game.PlaceId
local universeId = game.GameId 

local function runScript(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then
        warn("Lỗi tải script: " .. tostring(result))
    end
end

if bloxFruitsPlaces[placeId] or universeId == 994732206 then
    runScript("https://api.luarmor.net/files/v4/loaders/e86ed284a22672d29e906214e7bbf8b9.lua")
elseif universeId == 10200395747 then
    runScript("https://raw.githubusercontent.com/Teddyseetink/Haidepzai/refs/heads/main/growagadern2.lua")
end
