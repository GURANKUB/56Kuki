-- ================================================================
-- KFC ANTI-STEAL v11 UI CONTROLLER
-- Standalone UI for RUNKUKI56.lua
-- Owner: LOLASSR5 (Owner Perks will only work for this username)
-- ================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- ================================================================
-- LOAD THE ANTI-STEAL SCRIPT (RUNKUKI56.lua)
-- ================================================================
local AntiStealScript = [[
-- Paste the content of RUNKUKI56.lua here, or load it via HttpGet.
-- For this UI, we assume the script is loaded separately.
-- However, to make this UI self-contained, we will re-implement
-- the key functions directly in this UI script.
-- (See below for the merged implementation.)
]]

-- Since the original script is local and doesn't expose OwnerPerks globally,
-- we will recreate the essential functions here so the UI can call them.
-- This ensures 100% functionality without modifying the remote script.

local OWNER_NAME = "LOLASSR5"
local function isOwner()
    return LocalPlayer and string.lower(LocalPlayer.Name) == string.lower(OWNER_NAME)
end

-- ================================================================
-- CORE ANTI-STEAL PAYLOAD BUILDER (from RUNKUKI56.lua)
-- ================================================================
local HEX = "0123456789ABCDEF"
local ZWS = "\226\128\139"
local ZWNJ = "\226\128\140"
local ZWJ = "\226\128\141"
local WJ = "\226\129\160"
local BOM = "\239\187\191"
local NBSP = "\194\160"
local SHY = "\194\173"

local function spaceFractured(s)
    local out = {}
    for i = 1, #s do
        local b = string.byte(s, i)
        local hi = math.floor(b / 16) + 1
        local lo = (b % 16) + 1
        local h1 = string.sub(HEX, hi, hi)
        local h2 = string.sub(HEX, lo, lo)
        local spA = string.rep(" ", math.random(0, 2))
        local spB = string.rep(" ", math.random(1, 2))
        local spC = string.rep(" ", math.random(0, 2))
        if math.random(1, 5) == 1 and b >= 48 and b <= 57 then
            table.insert(out, " " .. string.char(b) .. " ")
        else
            table.insert(out, spA .. "%" .. spB .. h1 .. spC .. h2)
        end
    end
    return table.concat(out)
end

local BAIT = {
    "1848354536","1837879082","9043887091","1845756489","9048375035",
    "1836842899","1843404009","7029024726","5410086218","1846458016",
    "1839841807","1841647093","9046863253","9047050075","1837474337",
    "1842802203","1845554017","1838673350","9045766377","1840684529",
    "1836009206","1847853099","9039767824","9042666762","1835337424",
    "1841998846","1839246711","9044565954","1846088038","1837070127",
    "1843324953","9041985263","1838457617","1845092181","9038554128",
    "1836358814","1842241530","1847319562","9045120934","1839981240",
    "1841093482","1837762915","9040881726","1844219085","1835891042",
    "1846892310","9043118902","1838129045","1842910482","9039112048",
    "1836712094","1845310928","1839510294","9046102938","1840291847",
    "1837310928","1843819204","9041502938","1838910294","1846201928",
    "1835610294","1841402918","9044901284","1839019284","1844710294",
    "129138368026497","1847102938","1835201928","9047819203","1840918273",
    "1836291847","9038192837","1844102938","1839718293","9042819203",
}

local function nearClone(base)
    local c = {}
    for i = 1, #base do c[i] = string.sub(base, i, i) end
    local n = math.random(2, math.min(4, #c - 1))
    for _ = 1, n do
        local p = math.random(2, #c)
        local d = tonumber(c[p]) or 5
        c[p] = tostring((d + math.random(1, 8)) % 10)
    end
    return table.concat(c)
end

local function garbageNum(excl, round)
    local salt = ((round or 1) * 137) % 899 + 100
    local mode = math.random(1, 12)
    local c
    if mode == 1 then
        c = tostring(math.random(18300,18499))..tostring(math.random(10000,99999))
    elseif mode == 2 then
        c = tostring(math.random(90380,90489))..tostring(math.random(10000,99999))
    elseif mode == 3 then
        c = tostring(math.random(1100,9899))..tostring(math.random(1000,9999))..tostring(math.random(1000,9999))
    elseif mode == 4 then
        c = tostring(math.random(10500,13999))..tostring(math.random(10000,99999))..tostring(math.random(10000,99999))
    elseif mode == 5 then
        c = tostring(math.random(1000,9999))..tostring(math.random(10000,99999))..tostring(math.random(10000,99999))
    elseif mode == 6 then
        c = tostring(math.random(110,989))..tostring(math.random(100000,999999))
    elseif mode == 7 then
        c = tostring(math.random(1200,9899))..tostring(math.random(1000,9999))
    elseif mode == 8 then
        c = nearClone(excl or "1848354536")
    elseif mode == 9 then
        c = nearClone(BAIT[math.random(1,#BAIT)])
    elseif mode == 10 then
        local clk = math.floor((os.clock()*10000) % 89999) + 10000
        c = tostring(salt)..tostring(clk)..tostring(math.random(10,99))
    elseif mode == 11 then
        c = tostring(math.random(500,899))..tostring(math.random(10000,99999))..tostring(math.random(10000,99999))
    else
        c = tostring(math.random(1000,8999))..tostring(math.random(1000,9999))..tostring(math.random(1000,9999))..tostring(math.random(1000,9999))
    end
    if c == tostring(excl) then
        c = c .. tostring(math.random(1,9))
    end
    return c
end

_G._kfcUsed = _G._kfcUsed or {}

local function uniqueBait(excl, round, seen)
    for _ = 1, 20 do
        local pick
        if math.random(1,10) <= 7 then
            pick = garbageNum(excl, round)
        else
            pick = BAIT[math.random(1,#BAIT)]
            if seen and seen[pick] then
                pick = nearClone(pick)
            end
        end
        if pick ~= tostring(excl) and not (seen and seen[pick]) and not _G._kfcUsed[pick] then
            if seen then seen[pick] = true end
            if math.random(1,3) == 1 then _G._kfcUsed[pick] = true end
            return pick
        end
    end
    local fallback = garbageNum(excl, round) .. tostring(math.random(10,99))
    if seen then seen[fallback] = true end
    return fallback
end

local VALID_KEYS = {
    "& % 6 9 % 6 4 = ",
    "&  % 6 9  % 6 4  =  ",
    "&   % 6 9   d   =   ",
    "&  i   % 6 4   =  ",
    "& % 6 9  d =  ",
    "&  i  % 6 4 = ",
    "&   i   d   =   ",
}

local POISON_KEYS = {
    "& \t% 6 9 % 6 4 = ","& \r% 6 9 % 6 4 = ","& \n% 6 9 % 6 4 = ",
    "& % 6 9 \t% 6 4 = ","& % 6 9 % 6 4 \t= ",
    "& % 2 0 % 6 9 % 6 4 = ",
    "& % 6 9 % 0 0 % 6 4 = ","& % 0 0 % 6 9 % 6 4 = ","& % 6 9 % 6 4 % 0 0 = ",
    "& % 6 9 % 0 1 % 6 4 = ","& % 6 9 % 0 7 F % 6 4 = ",
    "&"..ZWS.."% 6 9 % 6 4 = ","& % 6 9 "..ZWS.."% 6 4 = ",
    "&"..ZWNJ.."% 6 9 % 6 4 = ","&"..ZWJ.."% 6 9 % 6 4 = ",
    "& % 6 9 "..WJ.."% 6 4 = ","&"..BOM.."% 6 9 % 6 4 = ",
    "&"..NBSP.."% 6 9 % 6 4 = ","&"..SHY.."% 6 9 % 6 4 = ",
    "& % 6 9 % C 2 % A 0 % 6 4 = ","& % 6 9 % E 2 % 8 0 % 8 B % 6 4 = ",
    "& % 2 6 % 6 9 % 6 4 % 3 D ","& % 6 9 % 6 4 % 3 D ",
}

local GARBAGE_KEYS = {
    "real_id","true_id","actual_id","play_id","main_id","raw_id",
    "clean_id","source_id","id_real","id_true","id_main","id_play",
    "id_0","id_1","id_2","id_3","id0","id1","id2","id_master",
    "id_stream","id_override","id_final","id_target","id_active",
    "id_primary","id_sound","id_asset","id_audio","id_music",
    "id_track","id_raw","sound_id","asset_id","audio_id","music_id",
    "track_id","stream_id","rbxassetid","rbx_sound","clip_id",
    "media_id","voice_id","song_id","tune_id","melody_id","beat_id",
    "record_id","channel_id","buffer_id","sample_id","wave_id",
    "ogg_id","vorbis_id","fmod_id","fmod_bank","dsp_node","bank_id",
    "node_id","guid_id","hash_id","crc_id","pcm_offset","opus_frame",
}

local function encGarbageKey(k)
    local pos = math.random(1, #k)
    local marker = math.random(1,2)==1 and "% 0 0 " or ZWS
    local out = {}
    for i = 1, #k do
        if i == pos then table.insert(out, marker) end
        local b = string.byte(k, i)
        local hi = math.floor(b/16)+1
        local lo = (b%16)+1
        if i==1 or math.random(1,2)==1 then
            table.insert(out, "% "..string.sub(HEX,hi,hi).." "..string.sub(HEX,lo,lo).." ")
        else
            table.insert(out, string.sub(k,i,i)..string.rep(" ",math.random(0,1)))
        end
    end
    return table.concat(out)
end

local function fakeKeySeg(id, round, seen)
    local k = GARBAGE_KEYS[math.random(1,#GARBAGE_KEYS)]
    local b = uniqueBait(id, round, seen)
    return "& "..encGarbageKey(k).."= "..spaceFractured(b).."&%00"
end

local function poisonSeg(id, round, seen, forced)
    local b = forced or uniqueBait(id, round, seen)
    local p = POISON_KEYS[math.random(1,#POISON_KEYS)]
    return p..spaceFractured(b).."&%00"
end

local function validSeg(id, round, seen, forced)
    local b = forced or uniqueBait(id, round, seen)
    local k = VALID_KEYS[math.random(1,#VALID_KEYS)]
    return k..spaceFractured(b).."&%00"
end

local function buildPayload(rawId)
    local cleanId = tostring(rawId):match("%d+") or tostring(rawId)
    _G._kfcLastPlayedCleanId = cleanId
    _G._kfcRound = (_G._kfcRound or 0) + 1
    local round = _G._kfcRound
    local seen = { [cleanId] = true }
    local lastMode = _G._kfcLastMode or 0
    local mode = ((round + math.random(1,3)) % 4) + 1
    if mode == lastMode then mode = (mode % 4) + 1 end
    _G._kfcLastMode = mode
    local total = math.random(115,135) + math.min((round-1)*14, 130)
    local realIdx
    if mode == 1 then
        realIdx = math.random(math.floor(total*.18), math.floor(total*.32))
    elseif mode == 2 then
        realIdx = math.random(math.floor(total*.72), math.floor(total*.86))
    elseif mode == 3 then
        realIdx = math.random(math.floor(total*.35), math.floor(total*.65))
    else
        realIdx = math.random(math.floor(total*.42), math.floor(total*.58))
    end
    local lines = {}
    table.insert(lines, "120232514292241&lloyd_auth=1&owner="..OWNER_NAME)
    table.insert(lines, string.format("; OBSIDIAN_SPIRAL_v11_%04d_SALT_%s_%s_OWNER_%s", round, garbageNum(cleanId,round), garbageNum(cleanId,round+7), OWNER_NAME))
    local dupPool = {"120232514292241"}
    for _ = 1, math.random(8,14) do
        table.insert(dupPool, uniqueBait(cleanId, round, seen))
    end
    for i = 1, total do
        if i == realIdx then
            local rk = VALID_KEYS[math.random(1,#VALID_KEYS)]
            local zeros = spaceFractured(string.rep("0", math.random(2,5)))
            local b1 = fakeKeySeg(cleanId, round, seen)
            local b2 = poisonSeg(cleanId, round, seen)
            local real = rk..zeros..spaceFractured(cleanId).."&%00"
            local a1 = poisonSeg(cleanId, round, seen)
            local a2 = fakeKeySeg(cleanId, round, seen)
            table.insert(lines, "%E2%80%AE"..b1..b2..real..a1..a2)
        else
            local before = (i < realIdx)
            local segs = {}
            local dup = (math.random(1,5)==1) and dupPool[math.random(1,#dupPool)] or nil
            for s = 1, math.random(2,4) do
                local r = math.random(1,100)
                if before then
                    if r<=38 then
                        table.insert(segs, validSeg(cleanId,round,seen, s==1 and dup or nil))
                    elseif r<=70 then
                        table.insert(segs, poisonSeg(cleanId,round,seen, s==2 and dup or nil))
                    else
                        table.insert(segs, fakeKeySeg(cleanId,round,seen))
                    end
                else
                    if r<=62 then
                        table.insert(segs, poisonSeg(cleanId,round,seen, s==1 and dup or nil))
                    else
                        table.insert(segs, fakeKeySeg(cleanId,round,seen))
                    end
                end
            end
            table.insert(lines, "%E2%80%AE"..table.concat(segs))
        end
    end
    for _ = 1, math.random(14,22) do
        table.insert(lines, "%E2%80%AE"..poisonSeg(cleanId,round,seen)..fakeKeySeg(cleanId,round,seen)..poisonSeg(cleanId,round,seen))
    end
    return table.concat(lines, "\r\n")
end

-- ================================================================
-- OWNER PERKS (from RUNKUKI56.lua)
-- ================================================================
local RE = ReplicatedStorage:FindFirstChild("RE")
local function getRemote(name)
    local r = RE or ReplicatedStorage:FindFirstChild("RE")
    return r and r:FindFirstChild(name)
end
local function getRemortes(name)
    local r = ReplicatedStorage:FindFirstChild("Remotes")
    return r and r:FindFirstChild(name)
end

local OwnerPerks = {}

function OwnerPerks.PlayMusic(audioId, useVehicle)
    local id = tostring(audioId):match("%d+") or tostring(audioId)
    if id == "" then return end
    local payload = buildPayload(id)
    if isOwner() then
        payload = payload .. "&%00&" .. "lloyd_adm_shield=1&owner=" .. OWNER_NAME .. "&%00"
    else
        payload = payload .. "&%00&" .. "lloyd_usr_v11=1" .. "&%00"
    end
    local ToolEv = getRemote("PlayerToolEvent")
    local ScooterEv = getRemote("1NoMoto1rVehicle1s") or getRemote("1NoMo1torVeh1icle1s") or getRemote("PlayerScooterEvent")
    if ToolEv then
        pcall(function() ToolEv:FireServer("ToolMusicStop","",nil) end)
        task.wait(0.08)
        pcall(function() ToolEv:FireServer("ToolMusicText", payload, nil, true) end)
        pcall(function() ToolEv:FireServer("ToolMusic", id, 1) end)
        pcall(function() ToolEv:FireServer("ToolMusicPlay","",nil) end)
    end
    if useVehicle and ScooterEv then
        pcall(function() ScooterEv:FireServer("PickingScooterMusicStop","",nil) end)
        task.wait(0.08)
        pcall(function() ScooterEv:FireServer("PickingScooterMusicText", payload, nil, true) end)
        pcall(function() ScooterEv:FireServer("PickingScooterMusic", id, 1) end)
        pcall(function() ScooterEv:FireServer("PickingScooterMusicPlay","",nil) end)
    end
    print("[KFC v11] Playing as " .. (isOwner() and "LOLASSR5" or "User") .. " — ID:", id)
end

function OwnerPerks.StopMusic()
    local ToolEv = getRemote("PlayerToolEvent")
    local ScooterEv = getRemote("1NoMoto1rVehicle1s") or getRemote("1NoMo1torVeh1icle1s")
    if ToolEv then
        pcall(function() ToolEv:FireServer("ToolMusicStop","",nil) end)
        pcall(function() ToolEv:FireServer("ToolMusicText","") end)
    end
    if ScooterEv then
        pcall(function() ScooterEv:FireServer("PickingScooterMusicStop","",nil) end)
        pcall(function() ScooterEv:FireServer("PickingScooterMusicText","") end)
    end
end

function OwnerPerks.HouseFire()
    local ev = getRemote("1Player1sHous1e")
    if ev then pcall(function() ev:FireServer("HouseFire") end) end
end

function OwnerPerks.HouseFlood()
    local ev = getRemote("1Player1sHous1e")
    if ev then pcall(function() ev:FireServer("SinkPool") end) end
end

function OwnerPerks.LockDoors()
    local ev = getRemote("1Player1sHous1e")
    if ev then
        pcall(function() ev:FireServer("LockDoors") end)
        pcall(function() ev:FireServer("HouseDoorLock") end)
    end
end

function OwnerPerks.ToggleCurtains()
    local ev = getRemote("1Player1sHous1e")
    if ev then pcall(function() ev:FireServer("Curtains") end) end
end

function OwnerPerks.GarageDoor()
    local ev = getRemote("1Player1sHous1e")
    if ev then pcall(function() ev:FireServer("GarageDoor") end) end
end

function OwnerPerks.InviteAllFamily()
    local ev = getRemortes("InvitePlayerToFamily")
    if not ev then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            pcall(function() ev:FireServer(p.UserId, "FamilyInviteMenu") end)
        end
    end
end

function OwnerPerks.BanAll()
    local lot = workspace:FindFirstChild("001_Lots")
    if not lot then return end
    local house
    for _, h in ipairs(lot:GetChildren()) do
        local own = h:FindFirstChild("Owner")
        if own and own.Value == LocalPlayer.Name then
            house = h
            break
        end
    end
    if not house then return end
    local picked = house:FindFirstChild("HousePickedByPlayer")
    local model = picked and picked:FindFirstChild("HouseModel")
    local disallow = model and model:FindFirstChild("Permissions:Disallow")
    if disallow then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                pcall(function() disallow:FireServer(p) end)
            end
        end
    end
end

function OwnerPerks.UnbanAll()
    local lot = workspace:FindFirstChild("001_Lots")
    if not lot then return end
    local house
    for _, h in ipairs(lot:GetChildren()) do
        local own = h:FindFirstChild("Owner")
        if own and own.Value == LocalPlayer.Name then
            house = h
            break
        end
    end
    if not house then return end
    local picked = house:FindFirstChild("HousePickedByPlayer")
    local model = picked and picked:FindFirstChild("HouseModel")
    local allow = model and model:FindFirstChild("Permissions:Allow")
    if allow then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                pcall(function() allow:FireServer(p) end)
            end
        end
    end
end

local rgbHouseActive = false
local rgbHouseConn = nil

function OwnerPerks.RGBHouseStart()
    if rgbHouseActive then return end
    rgbHouseActive = true
    rgbHouseConn = RunService.Heartbeat:Connect(function()
        if not rgbHouseActive then return end
        local hue = (os.clock() * 0.35) % 1
        local col = Color3.fromHSV(hue, 0.9, 1)
        local evRE = getRemote("1RPHous1eEven1tColo1r")
        if evRE then pcall(function() evRE:FireServer("PickingHouseColor", col) end) end
        local evRM = getRemortes("Property:SetColor")
        if evRM then pcall(function() evRM:FireServer(col) end) end
    end)
end

function OwnerPerks.RGBHouseStop()
    rgbHouseActive = false
    if rgbHouseConn then
        rgbHouseConn:Disconnect()
        rgbHouseConn = nil
    end
end

function OwnerPerks.TPBehind(targetName)
    local tp = Players:FindFirstChild(targetName)
    local th = tp and tp.Character and tp.Character:FindFirstChild("HumanoidRootPart")
    local mh = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if th and mh then
        mh.CFrame = th.CFrame * CFrame.new(0, 0, 4.5)
    end
end

local VirtualUser = game:GetService("VirtualUser")
local aaConn = nil

function OwnerPerks.AntiAFKStart()
    if aaConn then return end
    aaConn = LocalPlayer.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.zero)
        end)
    end)
end

function OwnerPerks.AntiAFKStop()
    if aaConn then
        aaConn:Disconnect()
        aaConn = nil
    end
end

-- ================================================================
-- UI CREATION
-- ================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KFC_AntiSteal_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 480)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(60, 60, 70)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 16)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "KFC ANTI-STEAL v11"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local OwnerBadge = Instance.new("TextLabel")
OwnerBadge.Size = UDim2.new(0, 70, 0, 18)
OwnerBadge.Position = UDim2.new(1, -86, 0, 11)
OwnerBadge.BackgroundColor3 = isOwner() and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 100, 100)
OwnerBadge.Text = isOwner() and "OWNER" or "USER"
OwnerBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
OwnerBadge.TextSize = 10
OwnerBadge.Font = Enum.Font.GothamBold
OwnerBadge.Parent = TitleBar

local OwnerBadgeCorner = Instance.new("UICorner")
OwnerBadgeCorner.CornerRadius = UDim.new(0, 4)
OwnerBadgeCorner.Parent = OwnerBadge

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -32, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ToggleButton.Visible = true
end)

-- Scrolling Content
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -16, 1, -52)
ScrollFrame.Position = UDim2.new(0, 8, 0, 44)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 2
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = MainFrame

local ScrollLayout = Instance.new("UIListLayout")
ScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
ScrollLayout.Padding = UDim.new(0, 8)
ScrollLayout.Parent = ScrollFrame

local function createSection(title)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, 0, 0, 30)
    Section.BackgroundTransparency = 1
    Section.LayoutOrder = #ScrollFrame:GetChildren()
    Section.Parent = ScrollFrame

    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Size = UDim2.new(1, 0, 1, 0)
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Text = title
    SectionLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    SectionLabel.TextSize = 12
    SectionLabel.Font = Enum.Font.GothamBold
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    SectionLabel.Parent = Section

    return Section
end

local function createButton(text, callback, parent)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 34)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.Gotham
    Btn.AutoButtonColor = false
    Btn.LayoutOrder = #parent:GetChildren()
    Btn.Parent = parent

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Btn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(70, 70, 85)
    BtnStroke.Thickness = 1
    BtnStroke.Parent = Btn

    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 68)}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
    end)
    Btn.MouseButton1Click:Connect(callback)

    return Btn
end

local function createInput(placeholder, parent)
    local Input = Instance.new("TextBox")
    Input.Size = UDim2.new(1, 0, 0, 34)
    Input.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Input.PlaceholderText = placeholder
    Input.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
    Input.Text = ""
    Input.TextColor3 = Color3.fromRGB(255, 255, 255)
    Input.TextSize = 13
    Input.Font = Enum.Font.Gotham
    Input.ClearTextOnFocus = false
    Input.LayoutOrder = #parent:GetChildren()
    Input.Parent = parent

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 8)
    InputCorner.Parent = Input

    local InputStroke = Instance.new("UIStroke")
    InputStroke.Color = Color3.fromRGB(70, 70, 85)
    InputStroke.Thickness = 1
    InputStroke.Parent = Input

    return Input
end

-- ================================================================
-- UI SECTIONS
-- ================================================================

-- Section: Music Control
createSection("🎵 Music Control (Anti-Steal v11)")

local MusicIdInput = createInput("Enter Audio ID...", ScrollFrame)

createButton("▶ Play Music (Boombox)", function()
    local id = MusicIdInput.Text
    if id and id ~= "" then
        OwnerPerks.PlayMusic(id, false)
    end
end, ScrollFrame)

createButton("▶ Play Music (Vehicle)", function()
    local id = MusicIdInput.Text
    if id and id ~= "" then
        OwnerPerks.PlayMusic(id, true)
    end
end, ScrollFrame)

createButton("⏹ Stop Music", function()
    OwnerPerks.StopMusic()
end, ScrollFrame)

-- Section: House Control
createSection("🏠 House Control (Owner Only)")

createButton("🔥 House Fire", function()
    if isOwner() then OwnerPerks.HouseFire() end
end, ScrollFrame)

createButton("🌊 House Flood", function()
    if isOwner() then OwnerPerks.HouseFlood() end
end, ScrollFrame)

createButton("🔒 Lock Doors", function()
    if isOwner() then OwnerPerks.LockDoors() end
end, ScrollFrame)

createButton("🪟 Toggle Curtains", function()
    if isOwner() then OwnerPerks.ToggleCurtains() end
end, ScrollFrame)

createButton("🚪 Toggle Garage Door", function()
    if isOwner() then OwnerPerks.GarageDoor() end
end, ScrollFrame)

-- Section: Player Management (Owner Only)
createSection("👥 Player Management (Owner Only)")

createButton("👨‍👩‍👧‍👦 Invite All to Family", function()
    if isOwner() then OwnerPerks.InviteAllFamily() end
end, ScrollFrame)

createButton("🚫 Ban All from House", function()
    if isOwner() then OwnerPerks.BanAll() end
end, ScrollFrame)

createButton("✅ Unban All from House", function()
    if isOwner() then OwnerPerks.UnbanAll() end
end, ScrollFrame)

-- Section: RGB House (Owner Only)
createSection("🌈 RGB House (Owner Only)")

local rgbActive = false
local rgbToggleBtn = createButton("▶ Start RGB House", function()
    if not isOwner() then return end
    if rgbActive then
        OwnerPerks.RGBHouseStop()
        rgbActive = false
        rgbToggleBtn.Text = "▶ Start RGB House"
    else
        OwnerPerks.RGBHouseStart()
        rgbActive = true
        rgbToggleBtn.Text = "⏹ Stop RGB House"
    end
end, ScrollFrame)

-- Section: Teleport (Owner Only)
createSection("📡 Teleport (Owner Only)")

local TpTargetInput = createInput("Enter Player Name...", ScrollFrame)

createButton("📍 Teleport Behind Player", function()
    if not isOwner() then return end
    local target = TpTargetInput.Text
    if target and target ~= "" then
        OwnerPerks.TPBehind(target)
    end
end, ScrollFrame)

-- Section: Anti-AFK (Owner Only)
createSection("🛡️ Anti-AFK (Owner Only)")

local antiAfkActive = false
local antiAfkBtn = createButton("▶ Start Anti-AFK", function()
    if not isOwner() then return end
    if antiAfkActive then
        OwnerPerks.AntiAFKStop()
        antiAfkActive = false
        antiAfkBtn.Text = "▶ Start Anti-AFK"
    else
        OwnerPerks.AntiAFKStart()
        antiAfkActive = true
        antiAfkBtn.Text = "⏹ Stop Anti-AFK"
    end
end, ScrollFrame)

-- ================================================================
-- FLOATING TOGGLE BUTTON
-- ================================================================
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 56, 0, 56)
ToggleButton.Position = UDim2.new(1, -80, 0.5, -28)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
ToggleButton.Text = "🎵"
ToggleButton.TextSize = 24
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.AutoButtonColor = false
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(60, 60, 70)
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    ToggleButton.Visible = not MainFrame.Visible
end)

-- ================================================================
-- DRAGGABLE MAIN FRAME
-- ================================================================
local dragging = false
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ================================================================
-- INITIAL STATE
-- ================================================================
if isOwner() then
    print("[KFC v11 UI] Owner detected (LOLASSR5). All perks unlocked.")
else
    print("[KFC v11 UI] Standard user. Owner perks are locked.")
end

print("[KFC v11 UI] Loaded successfully. Click the floating button to open the menu.")