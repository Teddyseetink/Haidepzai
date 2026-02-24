loadstring(game:HttpGet("https://raw.githubusercontent.com/Teddyseetink/Haidepzai/refs/heads/main/kaitun%20v4-obfuscated.lua"))()
local P = game:GetService("Players")
local L = P.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local W = workspace
local M = RS:WaitForChild("Modules")
local CU = pcall(require, M:WaitForChild("CombatUtil")) and require(M.CombatUtil) or nil
local WD = pcall(require, M:WaitForChild("WeaponData")) and require(M.WeaponData) or nil
if not CU then return end
local N = M:FindFirstChild("Net")
local RA = N and (N:FindFirstChild("RE/RegisterAttack") or N:FindFirstChild("RegisterAttack"))
local RH = N and (N:FindFirstChild("RE/RegisterHit") or N:FindFirstChild("RegisterHit"))	
local IS
do
    local PS = L:WaitForChild("PlayerScripts")
    for _, s in next, PS:GetChildren() do
        if s:IsA("LocalScript") then
            local ok, env = pcall(getsenv, s)
            if ok and env and env._G and typeof(env._G.SendHitsToServer) == "function" then
                IS = env._G.SendHitsToServer
                break
            end
        end
    end
    if not IS and _G.SendHitsToServer then
        IS = _G.SendHitsToServer
    end
end

pcall(function()
    hookfunction(CU.GetComboPaddingTime, function()
        return 0
    end)
    hookfunction(CU.GetAttackCancelMultiplier, function()
        return 0
    end)
    hookfunction(CU.CanAttack, function()
        return true
    end)
end)

local HList = {
    "RightLowerArm",
    "RightUpperArm",
    "LeftLowerArm",
    "LeftUpperArm",
    "RightHand",
    "LeftHand",
    "HumanoidRootPart",
    "Head",
    "UpperTorso",
    "LowerTorso"
}

okm = function(m)
    local h = m:FindFirstChildWhichIsA("Humanoid")
    return h and h.Health > 0 and m:FindFirstChild("HumanoidRootPart") and not m:FindFirstChild("VehicleSeat")
end

hpt = function(m)
    for _ = 1, 2 do
        local p = m:FindFirstChild(HList[math.random(1, #HList)])
        if p then
            return p
        end
    end
    return m:FindFirstChild("HumanoidRootPart")
end

near = function(r, maxN)
    local out, ch = {}, L.Character
    if not ch then
        return out
    end

    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hrp then
        return out
    end
    local p0 = hrp.Position

    for _, grp in next, {
        W:FindFirstChild("Enemies"),
        W:FindFirstChild("Characters")
    } do
        if grp then
            for _, v in next, grp:GetChildren() do
                if #out >= maxN then
                    break
                end
                if v ~= ch and okm(v) then
                    local hr = v:FindFirstChild("HumanoidRootPart")
                    if hr and (hr.Position - p0).Magnitude <= r then
                        out[#out + 1] = v
                    end
                end
            end
        end
    end

    for _, pl in next, P:GetPlayers() do
        if #out >= maxN then
            break
        end
        if pl ~= L and pl.Character and okm(pl.Character) then
            local hr = pl.Character:FindFirstChild("HumanoidRootPart")
            if hr and (hr.Position - p0).Magnitude <= r then
                out[#out + 1] = pl.Character
            end
        end
    end

    return out
end

pkg = function(t)
    local main, hits = nil, {}
    for _, v in next, t do
        if okm(v) then
            local p = hpt(v)
            if p then
                if not main then
                    main = p
                end
                hits[#hits + 1] = {
                    v,
                    p
                }
            end
        end
    end
    return main, hits
end

send = function(main, hits)
    if main and #hits > 0 then
        if IS then
            IS(main, hits)
        elseif RH then
            RH:FireServer(main, hits)
        end
    end
end

local AC, HM = {}, nil

setH = function(c)
    local h = c:FindFirstChildWhichIsA("Humanoid")
    if h then
        HM = h;
        AC = {}
    end
end

if L.Character then
    setH(L.Character)
end
L.CharacterAdded:Connect(function(c)
    c:WaitForChild("Humanoid")
    setH(c)
end)

anim = function(tool)
    if not (HM and tool and WD) then
        return
    end
    local wn = CU:GetWeaponName(tool)
    local data = WD[wn] or WD[string.lower(wn)] or WD[CU:GetPureWeaponName(wn)]
    if not (data and data.Moveset and data.Moveset.Basic) then
        return
    end

    local mv = data.Moveset.Basic
    local a = mv[math.random(1, #mv)]
    if not (a and a.AnimationId) then
        return
    end

    if not AC[a.AnimationId] then
        local n = Instance.new("Animation")
        n.AnimationId = a.AnimationId
        AC[a.AnimationId] = HM:LoadAnimation(n)
    end

    local tr = AC[a.AnimationId]
    if tr then
        tr:Play(1, 1, 0.2)
    end
end

spawn(function()
    while task.wait(0.019) do
        local ok, err = pcall(function()
            local ch = L.Character
            if not ch then
                return
            end

            local tool = ch:FindFirstChildOfClass("Tool")
            if not tool then
                return
            end

            local tg = near(60, 20)
            if #tg == 0 then
                return
            end

            local main, hits = pkg(tg)
            if not main then
                return
            end

            if RA then
                RA:FireServer(0)
            end
			if _G.Animation then
            	anim(tool)
			end
			if _G.Seriality then
				if tool.ToolTip == "Blox Fruit" then
					if tg then
						local LeftClickRemote = tool:FindFirstChild('LeftClickRemote');
						if LeftClickRemote then
							LeftClickRemote:FireServer(Vector3.new(0.01, - 500, 0.01), 1, true);
							LeftClickRemote:FireServer(false)
						end
					end
				end
            end
            task.defer(function()
                pcall(function()
                    CU:AttackStart(main, 1)
                    CU:RunHitDetection(main.Parent or main, 1, {
                        _Object = {
                            Length = 0.02,
                            IsPlaying = true
                        }
                    })
                end)
            end)

            send(main, hits)
        end)
    end
end)
