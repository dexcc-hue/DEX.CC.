--[[
 DEX.CC - VERSIÓN FINAL CORREGIDA (HIT EFFECT ARREGLADO)
--]]

-- ================================
-- ANTI-KICK
-- ================================
local function AntiKick()
    local d = false
    local h = {}
    local x, y

    setthreadidentity(2)

    for i, v in getgc(true) do
        if typeof(v) == "table" then
            local a = rawget(v, "Detected")
            local b = rawget(v, "Kill")
        
            if typeof(a) == "function" and not x then
                x = a
                local o; o = hookfunction(x, function(c, f, n)
                    if c ~= "_" then
                        if d then warn(`Adonis flagged\nMethod: {c}\nInfo: {f}`) end
                    end
                    return true
                end)
                table.insert(h, x)
            end

            if rawget(v, "Variables") and rawget(v, "Process") and typeof(b) == "function" and not y then
                y = b
                local o; o = hookfunction(y, function(f)
                    if d then warn(`Adonis tried to kill: {f}`) end
                end)
                table.insert(h, y)
            end
        end
    end

    local o; o = hookfunction(getrenv().debug.info, newcclosure(function(...)
        local a, f = ...
        if x and a == x then
            if d then warn(`adonis bypassed`) end
            return coroutine.yield(coroutine.running())
        end
        return o(...)
    end))

    setthreadidentity(7)
end

pcall(AntiKick)

-- ================================
-- PANTALLA DE BIENVENIDA (SPLASH)
-- ================================
local function ShowWelcomeScreen()
    local splashGui = Instance.new("ScreenGui")
    splashGui.Name = "WelcomeScreen"
    splashGui.ResetOnSpawn = false
    splashGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    splashGui.Parent = game.CoreGui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0.95, 0, 0.95, 0)
    bg.Position = UDim2.new(0.025, 0, 0.025, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.1
    bg.BorderSizePixel = 0
    bg.Parent = splashGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = bg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Position = UDim2.new(0, 0, 0.05, 0)
    title.BackgroundTransparency = 1
    title.Text = "DEX.CC (BETA)"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 28
    title.TextScaled = true
    title.Parent = bg

    local image = Instance.new("ImageLabel")
    image.Size = UDim2.new(0.6, 0, 0.6, 0)
    image.Position = UDim2.new(0.2, 0, 0.2, 0)
    image.BackgroundTransparency = 1
    image.Image = "rbxassetid://97318186884444"
    image.ScaleType = Enum.ScaleType.Fit
    image.Parent = bg

    local enterBtn = Instance.new("TextButton")
    enterBtn.Size = UDim2.new(0.3, 0, 0.08, 0)
    enterBtn.Position = UDim2.new(0.35, 0, 0.85, 0)
    enterBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    enterBtn.Text = "ENTER"
    enterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    enterBtn.Font = Enum.Font.GothamBold
    enterBtn.TextSize = 20
    enterBtn.Parent = bg
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = enterBtn
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(150, 150, 200)
    stroke.Thickness = 2
    stroke.Parent = enterBtn

    enterBtn.MouseButton1Click:Connect(function()
        splashGui:Destroy()
        if MainGUI then MainGUI.Enabled = true end
    end)

    return splashGui
end

-- ================================
-- CONFIGURACIÓN INICIAL
-- ================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInput = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================================
-- VARIABLES PRINCIPALES
-- ================================
local MasterEnabled = false
local CamlockSelected = true
local SilentSelected = true
local IndependentSilentEnabled = false

local CamlockEnabled = false
local SilentEnabled = false
local MacroSpeedEnabled = false
local MacroEnabled = false

local CamlockLockedTarget = nil
local SilentLockedTarget = nil
local ESPTarget = nil
local FOVCircle = nil
local grayPulse = 0

-- Ajustables
local AutoPrediction = false
local BasePrediction = 0.010
local PredictionValue = 0.13
local JumpOffset = -0.3
local FallOffset = 0.27
local SmoothingSpeed = 0.7
local FOVRadius = 90
local MacroSpeedValue = 120
local SilentHitChance = 100
local WallCheckEnabled = false

local AutoAirshotEnabled = false
local AirDelay = 0.22
local AirStartTime = 0

local ESPEnabled = true
local ESPMode = "Highlight"
local ESPNameText = nil

-- ESP 2D
local ESP2D = {
    Frame = nil,
    HealthBar = nil,
    HealthBg = nil,
    Active = false
}

local function Create2DESP()
    if ESP2D.Frame then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "ESP2D"
    gui.ResetOnSpawn = false
    gui.Parent = game.CoreGui

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 70, 0, 105)
    box.AnchorPoint = Vector2.new(0.5, 0.5)
    box.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    box.BackgroundTransparency = 0.65
    box.BorderSizePixel = 0
    box.Visible = false
    box.Parent = gui

    local function createDash(parent, size, position, rotation)
        local dash = Instance.new("Frame")
        dash.Size = size
        dash.Position = position
        dash.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dash.BorderSizePixel = 0
        dash.Rotation = rotation or 0
        dash.Parent = parent
        return dash
    end

    createDash(box, UDim2.new(0.2,0,0,2), UDim2.new(0.05,0,0,0))
    createDash(box, UDim2.new(0.2,0,0,2), UDim2.new(0.35,0,0,0))
    createDash(box, UDim2.new(0.2,0,0,2), UDim2.new(0.65,0,0,0))
    createDash(box, UDim2.new(0.2,0,0,2), UDim2.new(0.05,0,1,-2))
    createDash(box, UDim2.new(0.2,0,0,2), UDim2.new(0.35,0,1,-2))
    createDash(box, UDim2.new(0.2,0,0,2), UDim2.new(0.65,0,1,-2))
    createDash(box, UDim2.new(0,2,0.2,0), UDim2.new(0,0,0.1,0))
    createDash(box, UDim2.new(0,2,0.2,0), UDim2.new(0,0,0.45,0))
    createDash(box, UDim2.new(0,2,0.2,0), UDim2.new(0,0,0.8,0))
    createDash(box, UDim2.new(0,2,0.2,0), UDim2.new(1,-2,0.1,0))
    createDash(box, UDim2.new(0,2,0.2,0), UDim2.new(1,-2,0.45,0))
    createDash(box, UDim2.new(0,2,0.2,0), UDim2.new(1,-2,0.8,0))

    local healthBg = Instance.new("Frame")
    healthBg.Size = UDim2.new(0, 6, 1, 0)
    healthBg.Position = UDim2.new(0, -10, 0, 0)
    healthBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    healthBg.BorderSizePixel = 0
    healthBg.Parent = box

    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthBg

    ESP2D.Frame = box
    ESP2D.HealthBar = healthBar
    ESP2D.HealthBg = healthBg
    ESP2D.Gui = gui
end

local function Destroy2DESP()
    if ESP2D.Gui then ESP2D.Gui:Destroy() end
    ESP2D.Frame = nil
    ESP2D.HealthBar = nil
    ESP2D.HealthBg = nil
    ESP2D.Gui = nil
    ESP2D.Active = false
end

local function Update2DESP(targetPlayer)
    if not ESP2D.Frame then return end
    if not targetPlayer or not targetPlayer.Character then
        ESP2D.Frame.Visible = false
        return
    end
    local head = targetPlayer.Character:FindFirstChild("Head")
    local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not head or not hum or hum.Health <= 0 then
        ESP2D.Frame.Visible = false
        return
    end
    local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
    if not onScreen then
        ESP2D.Frame.Visible = false
        return
    end
    ESP2D.Frame.Visible = true
    local boxSize = ESP2D.Frame.AbsoluteSize
    ESP2D.Frame.Position = UDim2.new(0, pos.X, 0, pos.Y - (boxSize.Y / 2))
    local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
    ESP2D.HealthBar.Size = UDim2.new(1, 0, hp, 0)
    ESP2D.HealthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), hp)
end

-- CurrentPrediction
local CurrentPrediction = PredictionValue

-- RAGE (Target Strafe)
local TargetStrafeEnabled = false
local TargetStrafeSpeed = 5.0
local TargetStrafeRadius = 5.0
local TargetStrafeHeight = 0.0
local TargetStrafePattern = "circle"
local TargetStrafeAngle = 0.0
local TargetStrafeRandomOffset = 0.0
local TargetStrafeLastUpdate = 0
local TargetStrafeSpiralT = 0

local NoclipActive = false
local NoclipConnection = nil

local ManualTarget = nil
local PlayerListScrollingFrame = nil

local FinisherEnabled = true
local IsFinishing = false
local DeadTarget = nil
local StompKey = Enum.KeyCode.E
local WasStrafeActive = false
local StompCooldown = false

-- AURA
local AuraEnabled = false
local CurrentAuraDesign = "⭐ StarLight"
local CurrentAuraParts = {}
local AllEmitters = {}
local AuraTransparency = 0.4
local AURA_DESIGNS = {
    ["⭐ StarLight"] = "rbxassetid://134645216613107",
    ["⭐ Star"] = "rbxassetid://73754563740680",
    ["💨 Wind"] = "rbxassetid://80694081850877",
}

-- GUI Elements
local MainGUI = nil
local MainExternalButton = nil
local MacroExternalButton = nil
local WalkspeedExternalButton = nil
local MacroBtn = nil
local WalkspeedBtn = nil
local ToggleGuiButton = nil

local LastHealth = {}
local LastHitTime = {}
local HIT_COOLDOWN = 0.45
local LastGlobalHitTime = 0
local LastGlobalSoundTime = 0

-- Sonidos
local GroundHitSound = "rbxassetid://124356179581089"
local AirHitSound = "rbxassetid://134640174858937"

-- Partes
local GroundAimPart = "Head"
local AirAimPart = "RightFoot"
local GroundPartIndex = 1
local AirPartIndex = 1
local GroundPartList = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}
local AirPartList = {"RightFoot", "LeftFoot", "Head", "HumanoidRootPart"}

-- ================================
-- VARIABLES DE SONIDOS Y EFECTOS
-- ================================
local SavedSounds = {
    "rbxassetid://124356179581089",
    "rbxassetid://135478009117226",
    "rbxassetid://140721035016341",
    "rbxassetid://140367458608473",
    "rbxassetid://736191318"
}
local SavedEffects = {
    "rbxasset://textures/particles/sparkles_main.dds",
    "rbxasset://textures/particles/smoke_main.dds",
    "rbxasset://textures/particles/star_main.dds",
    "rbxasset://textures/particles/explosion_main.dds",
    "rbxasset://textures/particles/glow_main.dds"
}
local CurrentSoundId = SavedSounds[1]
local CurrentEffectId = SavedEffects[1]
local SelectedSoundSlot = 1
local SelectedEffectSlot = 1
local HitEffectEnabled = true

-- ================================
-- HIT EFFECTS AVANZADOS
-- ================================
local HitEffectStyle = "Nova Impact"
local HitEffectStyles = {
    "Nova Impact",
    "Crescent Slash",
    "Cosmic Explosion",
    "Slash",
    "Atomic Slash",
    "Coom"
}
local HitEffectTemplates = {}
local HitChamEnabled = false
local HitChamColor = Color3.fromRGB(10, 10, 10)
local HitChamDuration = 2

-- ================================
-- CÍRCULO DE PREDICCIÓN
-- ================================
local PredictionCircleEnabled = false
local PredictionCircle = nil

-- ================================
-- CAMBIADOR DE AMBIENTE Y CIELO
-- ================================
local AmbientColor = Lighting.Ambient
local SkyboxId = nil
local CurrentSky = nil

local function SetAmbientColor(color)
    AmbientColor = color
    Lighting.Ambient = color
    Lighting.OutdoorAmbient = color
end

local function SetSkybox(id)
    SkyboxId = id or ""
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Sky") then
            v:Destroy()
        end
    end
    if not id or id == "" then
        CurrentSky = nil
        return
    end
    local assetId = id:match("%d+") or id
    CurrentSky = Instance.new("Sky")
    CurrentSky.Name = "Sky"
    local url = "http://www.roblox.com/asset/?id=" .. assetId
    CurrentSky.SkyboxBk = url
    CurrentSky.SkyboxDn = url
    CurrentSky.SkyboxFt = url
    CurrentSky.SkyboxLf = url
    CurrentSky.SkyboxRt = url
    CurrentSky.SkyboxUp = url
    CurrentSky.Parent = Lighting
    Lighting.TimeOfDay = "12"
    ShowNotification("🌌 Cielo cambiado correctamente (ID: " .. assetId .. ")", 1.5)
end

-- ================================
-- FUNCIONES DE PERSISTENCIA
-- ================================
local function SaveSoundSlots()
    local data = table.concat(SavedSounds, "\n")
    writefile("DEXCC_Sounds.txt", data)
end

local function SaveEffectSlots()
    local data = table.concat(SavedEffects, "\n")
    writefile("DEXCC_Effects.txt", data)
end

local function LoadSavedData()
    if isfile("DEXCC_Sounds.txt") then
        local content = readfile("DEXCC_Sounds.txt")
        local lines = {}
        for line in content:gmatch("[^\n]+") do
            table.insert(lines, line)
        end
        for i = 1, math.min(5, #lines) do
            SavedSounds[i] = lines[i]
        end
        CurrentSoundId = SavedSounds[1]
    end
    if isfile("DEXCC_Effects.txt") then
        local content = readfile("DEXCC_Effects.txt")
        local lines = {}
        for line in content:gmatch("[^\n]+") do
            table.insert(lines, line)
        end
        for i = 1, math.min(5, #lines) do
            SavedEffects[i] = lines[i]
        end
        CurrentEffectId = SavedEffects[1]
    end
end

-- ================================
-- CARGAR PLANTILLAS DE HIT EFFECTS
-- ================================
local function LoadHitEffectTemplates()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local function createEffect(name, setupFunction)
        local part = Instance.new("Part")
        part.Parent = ReplicatedStorage
        part.Name = "HitEffect_" .. name
        part.Transparency = 1
        part.Anchored = true
        part.CanCollide = false
        part.Size = Vector3.new(0,0,0)
        local att = Instance.new("Attachment", part)
        setupFunction(att)
        HitEffectTemplates[name] = att
    end

    -- Nova Impact
    createEffect("Nova Impact", function(att)
        local p1 = Instance.new("ParticleEmitter")
        p1.Acceleration = Vector3.new(0,0,1)
        p1.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
            ColorSequenceKeypoint.new(0.495, Color3.fromRGB(255,0,0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
        })
        p1.Lifetime = NumberRange.new(0.5,0.5)
        p1.LightEmission = 1
        p1.LockedToPart = true
        p1.Rate = 1
        p1.Rotation = NumberRange.new(0,360)
        p1.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0,1),
            NumberSequenceKeypoint.new(1,10),
        })
        p1.Speed = NumberRange.new(0,0)
        p1.Texture = "rbxassetid://1084991215"
        p1.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0,0),
            NumberSequenceKeypoint.new(0.1,0.1),
            NumberSequenceKeypoint.new(0.25,0.25),
            NumberSequenceKeypoint.new(1,0.5),
        })
        p1.ZOffset = 1
        p1.Parent = att
        local p2 = p1:Clone()
        p2.Acceleration = Vector3.new(0,1,-0.001)
        p2.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
        p2.Parent = att
    end)

    -- Crescent Slash
    createEffect("Crescent Slash", function(att)
        local Glow = Instance.new("ParticleEmitter")
        Glow.Lifetime = NumberRange.new(0.16,0.16)
        Glow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.142,0.618),NumberSequenceKeypoint.new(1,1)})
        Glow.Color = ColorSequence.new(Color3.fromRGB(91,177,252))
        Glow.Speed = NumberRange.new(0,0)
        Glow.Brightness = 5
        Glow.Size = NumberSequence.new(9.18,16.5)
        Glow.ZOffset = -0.056
        Glow.Rate = 50
        Glow.Texture = "rbxassetid://8708637750"
        Glow.Parent = att

        local Gradient1 = Instance.new("ParticleEmitter")
        Gradient1.Lifetime = NumberRange.new(0.3,0.3)
        Gradient1.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.15,0.3),NumberSequenceKeypoint.new(1,1)})
        Gradient1.Color = ColorSequence.new(Color3.fromRGB(115,201,255))
        Gradient1.Speed = NumberRange.new(0,0)
        Gradient1.Brightness = 6
        Gradient1.Size = NumberSequence.new(0,11.62)
        Gradient1.ZOffset = 0.918
        Gradient1.Rate = 50
        Gradient1.Texture = "rbxassetid://8196169974"
        Gradient1.Parent = att

        local Shards = Instance.new("ParticleEmitter")
        Shards.Lifetime = NumberRange.new(0.19,0.7)
        Shards.SpreadAngle = Vector2.new(-90,90)
        Shards.Color = ColorSequence.new(Color3.fromRGB(108,184,255))
        Shards.Drag = 10
        Shards.VelocitySpread = -90
        Shards.Squash = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.57,0.412),NumberSequenceKeypoint.new(1,-0.937)})
        Shards.Speed = NumberRange.new(97.75,146.99)
        Shards.Brightness = 4
        Shards.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.284,1.238,0.153),NumberSequenceKeypoint.new(1,0)})
        Shards.Acceleration = Vector3.new(0,-56.96,0)
        Shards.ZOffset = 0.57
        Shards.Rate = 50
        Shards.Texture = "rbxassetid://8030734851"
        Shards.Rotation = NumberRange.new(90,90)
        Shards.Orientation = Enum.ParticleOrientation.VelocityParallel
        Shards.Parent = att

        local Crescents = Instance.new("ParticleEmitter")
        Crescents.Lifetime = NumberRange.new(0.19,0.38)
        Crescents.SpreadAngle = Vector2.new(-360,360)
        Crescents.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.193,0),NumberSequenceKeypoint.new(0.778,0),NumberSequenceKeypoint.new(1,1)})
        Crescents.LightEmission = 1
        Crescents.Color = ColorSequence.new(Color3.fromRGB(92,161,252))
        Crescents.VelocitySpread = -360
        Crescents.Speed = NumberRange.new(0.082,0.082)
        Crescents.Brightness = 20
        Crescents.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.398,8.802,2.283),NumberSequenceKeypoint.new(1,11.47,1.86)})
        Crescents.ZOffset = 0.454
        Crescents.Rate = 50
        Crescents.Texture = "rbxassetid://12509373457"
        Crescents.RotSpeed = NumberRange.new(800,1000)
        Crescents.Rotation = NumberRange.new(-360,360)
        Crescents.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
        Crescents.Parent = att
    end)

    -- Cosmic Explosion
    createEffect("Cosmic Explosion", function(att)
        local Glow = Instance.new("ParticleEmitter")
        Glow.Lifetime = NumberRange.new(0.16,0.16)
        Glow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.142,0.618),NumberSequenceKeypoint.new(1,1)})
        Glow.Color = ColorSequence.new(Color3.fromRGB(173,82,252))
        Glow.Speed = NumberRange.new(0,0)
        Glow.Brightness = 5
        Glow.Size = NumberSequence.new(9.18,16.5)
        Glow.ZOffset = -0.056
        Glow.Rate = 50
        Glow.Texture = "rbxassetid://8708637750"
        Glow.Parent = att

        local Effect = Instance.new("ParticleEmitter")
        Effect.Lifetime = NumberRange.new(0.4,0.7)
        Effect.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
        Effect.SpreadAngle = Vector2.new(360,-360)
        Effect.LockedToPart = true
        Effect.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.107,0.193),NumberSequenceKeypoint.new(0.776,0.881),NumberSequenceKeypoint.new(1,1)})
        Effect.LightEmission = 1
        Effect.Color = ColorSequence.new(Color3.fromRGB(173,82,252))
        Effect.Drag = 1
        Effect.VelocitySpread = 360
        Effect.Speed = NumberRange.new(0.0036,0.0036)
        Effect.Brightness = 2.1
        Effect.Size = NumberSequence.new(6.96,9.92)
        Effect.ZOffset = 0.477
        Effect.Rate = 50
        Effect.Texture = "rbxassetid://9484012464"
        Effect.RotSpeed = NumberRange.new(-150,-150)
        Effect.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
        Effect.Rotation = NumberRange.new(50,50)
        Effect.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
        Effect.Parent = att

        local Crescents = Instance.new("ParticleEmitter")
        Crescents.Lifetime = NumberRange.new(0.19,0.38)
        Crescents.SpreadAngle = Vector2.new(-360,360)
        Crescents.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.193,0),NumberSequenceKeypoint.new(0.778,0),NumberSequenceKeypoint.new(1,1)})
        Crescents.LightEmission = 10
        Crescents.Color = ColorSequence.new(Color3.fromRGB(160,96,255))
        Crescents.VelocitySpread = -360
        Crescents.Speed = NumberRange.new(0.082,0.082)
        Crescents.Brightness = 4
        Crescents.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.398,8.802,2.283),NumberSequenceKeypoint.new(1,11.47,1.86)})
        Crescents.ZOffset = 0.454
        Crescents.Rate = 50
        Crescents.Texture = "rbxassetid://12509373457"
        Crescents.RotSpeed = NumberRange.new(800,1000)
        Crescents.Rotation = NumberRange.new(-360,360)
        Crescents.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
        Crescents.Parent = att
    end)

    -- Slash
    createEffect("Slash", function(att)
        local Crescents = Instance.new("ParticleEmitter")
        Crescents.Lifetime = NumberRange.new(0.19,0.38)
        Crescents.SpreadAngle = Vector2.new(-360,360)
        Crescents.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.193,0),NumberSequenceKeypoint.new(0.778,0),NumberSequenceKeypoint.new(1,1)})
        Crescents.LightEmission = 10
        Crescents.Color = ColorSequence.new(Color3.fromRGB(160,96,255))
        Crescents.VelocitySpread = -360
        Crescents.Speed = NumberRange.new(0.082,0.082)
        Crescents.Brightness = 4
        Crescents.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.398,8.802,2.283),NumberSequenceKeypoint.new(1,11.47,1.86)})
        Crescents.ZOffset = 0.454
        Crescents.Rate = 50
        Crescents.Texture = "rbxassetid://12509373457"
        Crescents.RotSpeed = NumberRange.new(800,1000)
        Crescents.Rotation = NumberRange.new(-360,360)
        Crescents.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
        Crescents.Parent = att
    end)

    -- Atomic Slash
    createEffect("Atomic Slash", function(att)
        local Crescents = Instance.new("ParticleEmitter")
        Crescents.Lifetime = NumberRange.new(0.19,0.38)
        Crescents.SpreadAngle = Vector2.new(-360,360)
        Crescents.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.193,0),NumberSequenceKeypoint.new(0.778,0),NumberSequenceKeypoint.new(1,1)})
        Crescents.LightEmission = 10
        Crescents.Color = ColorSequence.new(Color3.fromRGB(160,96,255))
        Crescents.VelocitySpread = -360
        Crescents.Speed = NumberRange.new(0.082,0.082)
        Crescents.Brightness = 4
        Crescents.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.398,8.802,2.283),NumberSequenceKeypoint.new(1,11.47,1.86)})
        Crescents.ZOffset = 0.454
        Crescents.Rate = 50
        Crescents.Texture = "rbxassetid://12509373457"
        Crescents.RotSpeed = NumberRange.new(800,1000)
        Crescents.Rotation = NumberRange.new(-360,360)
        Crescents.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
        Crescents.Parent = att

        local Glow = Instance.new("ParticleEmitter")
        Glow.Lifetime = NumberRange.new(0.16,0.16)
        Glow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.142,0.618),NumberSequenceKeypoint.new(1,1)})
        Glow.Color = ColorSequence.new(Color3.fromRGB(173,82,252))
        Glow.Speed = NumberRange.new(0,0)
        Glow.Brightness = 5
        Glow.Size = NumberSequence.new(9.18,16.5)
        Glow.ZOffset = -0.056
        Glow.Rate = 50
        Glow.Texture = "rbxassetid://8708637750"
        Glow.Parent = att
    end)

    -- Coom
    createEffect("Coom", function(att)
        local Foam = Instance.new("ParticleEmitter")
        Foam.LightInfluence = 0.5
        Foam.Lifetime = NumberRange.new(1,1)
        Foam.SpreadAngle = Vector2.new(360,-360)
        Foam.VelocitySpread = 360
        Foam.Squash = NumberSequence.new(1)
        Foam.Speed = NumberRange.new(20,20)
        Foam.Brightness = 2.5
        Foam.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.101,0.65),NumberSequenceKeypoint.new(0.649,1.42),NumberSequenceKeypoint.new(1,0)})
        Foam.Acceleration = Vector3.new(0,-66.04,0)
        Foam.Rate = 100
        Foam.Texture = "rbxassetid://8297030850"
        Foam.Rotation = NumberRange.new(-90,-90)
        Foam.Orientation = Enum.ParticleOrientation.VelocityParallel
        Foam.Parent = att
    end)
end

LoadHitEffectTemplates()

-- ================================
-- FUNCIÓN MEJORADA DE HIT SOUND Y EFFECT
-- ================================
local function PlayHitSoundAndEffect(targetPlayer)
    if not HitEffectEnabled then return end
    if not targetPlayer or not targetPlayer.Character then return end

    local now = tick()
    if now - (LastGlobalSoundTime or 0) < 0.65 then return end
    LastGlobalSoundTime = now

    local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local isInAir = hum.FloorMaterial == Enum.Material.Air 
                 or hum:GetState() == Enum.HumanoidStateType.Freefall 
                 or hum:GetState() == Enum.HumanoidStateType.Jumping

    local soundIdToUse = isInAir and AirHitSound or CurrentSoundId
    local sound = Instance.new("Sound")
    sound.SoundId = soundIdToUse
    sound.Volume = 1.8
    sound.Parent = workspace.CurrentCamera
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 1)

    local attachTo = targetPlayer.Character:FindFirstChild("HumanoidRootPart") or targetPlayer.Character:FindFirstChild("Head")
    if attachTo then
        local template = HitEffectTemplates[HitEffectStyle]
        if template then
            local effectClone = template:Clone()
            effectClone.Parent = attachTo
            for _, emitter in ipairs(effectClone:GetDescendants()) do
                if emitter:IsA("ParticleEmitter") then
                    emitter.Enabled = true
                    emitter:Emit(emitter.Rate or 50)
                end
            end
            game:GetService("Debris"):AddItem(effectClone, 2.5)
        end
    end

    if HitChamEnabled and targetPlayer.Character then
        local char = targetPlayer.Character
        local clone = char:Clone()
        clone.Parent = workspace
        clone.Name = "HitClone_" .. targetPlayer.Name
        for _, v in ipairs(clone:GetDescendants()) do
            if v:IsA("Accessory") or v:IsA("Tool") then
                v:Destroy()
            elseif v:IsA("BasePart") then
                v.Anchored = true
                v.CanCollide = false
                v.Material = Enum.Material.ForceField
                v.Color = HitChamColor
                v.Transparency = 0.5
            end
        end
        local highlight = Instance.new("Highlight")
        highlight.Parent = clone
        highlight.FillColor = HitChamColor
        highlight.OutlineColor = Color3.fromRGB(255,255,255)
        highlight.OutlineTransparency = 0
        highlight.FillTransparency = 0.5
        highlight.Adornee = clone
        clone:PivotTo(char:GetPivot())
        game:GetService("Debris"):AddItem(clone, HitChamDuration)
    end

    local flash = Instance.new("Frame")
    flash.Size = UDim2.new(1, 0, 1, 0)
    flash.BackgroundColor3 = isInAir and Color3.fromRGB(100, 180, 255) or Color3.fromRGB(255, 200, 150)
    flash.BackgroundTransparency = 0.6
    flash.Parent = LocalPlayer:WaitForChild("PlayerGui")
    TweenService:Create(flash, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
    game:GetService("Debris"):AddItem(flash, 0.4)

    if isInAir then
        ShowNotification("💨 AIR HIT!", 0.8)
    end
end

-- ================================
-- NOTIFICACIÓN
-- ================================
local function ShowNotification(text, duration)
    duration = duration or 1.5
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local notificationGui = playerGui:FindFirstChild("NotificationContainer")
    if not notificationGui then
        notificationGui = Instance.new("ScreenGui")
        notificationGui.Name = "NotificationContainer"
        notificationGui.ResetOnSpawn = false
        notificationGui.Parent = playerGui
    end
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 180, 0, 36)
    frame.Position = UDim2.new(0.9, -190, 0.05, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Parent = notificationGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 120, 255)
    stroke.Thickness = 1.5
    stroke.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = frame
    
    frame.BackgroundTransparency = 0.15
    local fadeOut = TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 1})
    local fadeText = TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 1})
    
    task.spawn(function()
        task.wait(duration)
        fadeOut:Play()
        fadeText:Play()
        fadeOut.Completed:Connect(function()
            frame:Destroy()
        end)
    end)
end

-- ================================
-- PING Y PREDICCIÓN
-- ================================
local function CreateMovablePingDisplay()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PingDisplay"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    local mainButton = Instance.new("TextButton")
    mainButton.Size = UDim2.new(0, 100, 0, 34)
    mainButton.Position = UDim2.new(0, 20, 0, 120)
    mainButton.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    mainButton.BackgroundTransparency = 0.1
    mainButton.BorderSizePixel = 0
    mainButton.AutoButtonColor = false
    mainButton.Text = ""
    mainButton.Name = "PingButton"
    mainButton.Parent = screenGui

    local dragging, dragInput, dragStart, startPos
    mainButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainButton.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    mainButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            mainButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                           startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = mainButton
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 120, 255)
    stroke.Thickness = 1.5
    stroke.Parent = mainButton

    local pingIcon = Instance.new("TextLabel")
    pingIcon.Size = UDim2.new(0, 24, 1, 0)
    pingIcon.Position = UDim2.new(0, 4, 0, 0)
    pingIcon.BackgroundTransparency = 1
    pingIcon.Text = "📡"
    pingIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    pingIcon.TextSize = 14
    pingIcon.Font = Enum.Font.Gotham
    pingIcon.Name = "PingIcon"
    pingIcon.Parent = mainButton

    local pingText = Instance.new("TextLabel")
    pingText.Size = UDim2.new(1, -32, 1, 0)
    pingText.Position = UDim2.new(0, 28, 0, 0)
    pingText.BackgroundTransparency = 1
    pingText.Text = "... ms"
    pingText.TextColor3 = Color3.fromRGB(255, 255, 255)
    pingText.TextSize = 11
    pingText.Font = Enum.Font.GothamBold
    pingText.TextXAlignment = Enum.TextXAlignment.Left
    pingText.Name = "PingValue"
    pingText.Parent = mainButton

    local tooltip = Instance.new("TextLabel")
    tooltip.Size = UDim2.new(0, 90, 0, 22)
    tooltip.Position = UDim2.new(0, 0, -1.2, 0)
    tooltip.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    tooltip.BackgroundTransparency = 0.1
    tooltip.Text = ""
    tooltip.TextColor3 = Color3.fromRGB(200, 200, 255)
    tooltip.TextSize = 10
    tooltip.Font = Enum.Font.Gotham
    tooltip.Visible = false
    tooltip.Name = "PingQuality"
    tooltip.Parent = mainButton
    local tooltipCorner = Instance.new("UICorner")
    tooltipCorner.CornerRadius = UDim.new(0, 5)
    tooltipCorner.Parent = tooltip

    mainButton.MouseEnter:Connect(function()
        tooltip.Visible = true
        TweenService:Create(tooltip, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    mainButton.MouseLeave:Connect(function()
        TweenService:Create(tooltip, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
        task.wait(0.2)
        tooltip.Visible = false
    end)

    return pingText, tooltip
end

local function GetExactPing()
    local function safeGetPing(method)
        local success, ping = pcall(method)
        return success and ping and ping > 0 and ping < 4000 and ping or nil
    end
    local methods = {
        function() return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() end,
        function() return game:GetService("Stats").PerformanceStats.Ping:GetValue() * 1000 end,
        function()
            local networkClient = game:GetService("NetworkClient")
            local connection = networkClient and networkClient:FindFirstChild("ClientReplicator")
            local pingValue = connection and (connection:GetAttribute("Ping") or connection:GetAttribute("RoundTripTime"))
            return pingValue and pingValue * 1000
        end
    }
    for _, method in ipairs(methods) do
        local ping = safeGetPing(method)
        if ping then return ping end
    end
    return 50
end

local function GetPingQuality(ping)
    if ping < 30 then return "🟢 EXCELENTE", Color3.fromRGB(0, 255, 0)
    elseif ping < 60 then return "🟢 BUENO", Color3.fromRGB(100, 255, 100)
    elseif ping < 100 then return "🟡 ACEPTABLE", Color3.fromRGB(255, 255, 0)
    elseif ping < 150 then return "🟡 REGULAR", Color3.fromRGB(255, 200, 0)
    elseif ping < 250 then return "🟠 ALTO", Color3.fromRGB(255, 100, 0)
    else return "🔴 MUY ALTO", Color3.fromRGB(255, 50, 50) end
end

local PredictionMode = "PingBased"
local function UpdatePrediction()
    if PredictionMode == "Manual" then
        CurrentPrediction = PredictionValue
    elseif PredictionMode == "PingBased" then
        CurrentPrediction = (GetExactPing() / 1000) + BasePrediction
    elseif PredictionMode == "Blatant" then
        local ping = GetExactPing()
        if ping < 30 then
        CurrentPrediction = 0.1188     -- Muy bajo ping → predicción baja y precisa
    elseif ping < 60 then
        CurrentPrediction = 0.1270     -- 30-59 ping (el rango más común)
    elseif ping < 90 then
        CurrentPrediction =0.1355
    elseif ping < 120 then
        CurrentPrediction = 0.1507
    elseif ping < 150 then
        CurrentPrediction = 0.1563
    else
        CurrentPrediction = 0.1663     -- 150+ ping (máximo estable)
    end
  end
end

local pingText, pingTooltip = CreateMovablePingDisplay()
coroutine.wrap(function()
    while task.wait(0.5) do
        local ping = GetExactPing()
        local quality, color = GetPingQuality(ping)
        if pingText then
            pingText.Text = string.format("%d ms", ping)
            pingText.TextColor3 = color
        end
        if pingTooltip then
            pingTooltip.Text = quality
            pingTooltip.TextColor3 = color
        end
        local icon = pingText and pingText.Parent:FindFirstChild("PingIcon")
        if icon then
            if ping < 60 then icon.Text = "📡"
            elseif ping < 120 then icon.Text = "📶"
            else icon.Text = "⚠️" end
        end
    end
end)()

-- ================================
-- FUNCIONES AUXILIARES
-- ================================
local function GetRootPart(character)
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Head")
end

local function IsDead(character)
    local hum = character:FindFirstChildOfClass("Humanoid")
    return not hum or hum.Health <= 0
end

local function IsValidTarget(player)
    if not player.Character then return false end
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    return GetRootPart(player.Character) ~= nil
end

-- ================================
-- RESOLVER
-- ================================
local ResolverEnabled = false
local ResolverMode = "Velocity"
local ResolverLastPos = {}
local ResolverLastTick = {}
local ResolverVelocityCache = {}

local function GetResolvedVelocity(character)
    if not ResolverEnabled then
        local root = GetRootPart(character)
        return root and root.AssemblyLinearVelocity or Vector3.new()
    end
    
    local root = GetRootPart(character)
    if not root then return Vector3.new() end
    local hum = character:FindFirstChildOfClass("Humanoid")
    
    if ResolverMode == "Velocity" then
        local vel = root.AssemblyLinearVelocity
        return vel * 1.15          -- ← CAMBIA ESTE NÚMERO (1.0 = normal, 1.15 = más fuerte)
        
    elseif ResolverMode == "MoveDirection" then
        if hum and hum.MoveDirection.Magnitude > 0 then
            local speed = 22      -- ← CAMBIA ESTE NÚMERO (normal es 16)
            return hum.MoveDirection * speed
        else
            return Vector3.new()
        end
        elseif ResolverMode == "TimeBased" then
        local now = tick()
        local lastPos = ResolverLastPos[character] or root.Position
        local lastTick = ResolverLastTick[character] or now
        local dt = now - lastTick

        if dt > 0.001 and dt < 0.2 then   -- evita lag spikes
            local calculatedVel = (root.Position - lastPos) / dt
            ResolverVelocityCache[character] = calculatedVel
        end

        ResolverLastPos[character] = root.Position
        ResolverLastTick[character] = now

        -- ← ESTO ES LO IMPORTANTE:
        local finalVel = ResolverVelocityCache[character] or root.AssemblyLinearVelocity
        return finalVel
       end
    return Vector3.new()
end

local function GetVelocity(character)
    return GetResolvedVelocity(character)
end

local function GetPredictedPosition(character, part)
    local vel = GetVelocity(character)
    local predicted = part.Position + Vector3.new(vel.X * CurrentPrediction, vel.Y * CurrentPrediction, vel.Z * CurrentPrediction)
    if vel.Y > 15 then
        predicted = predicted + Vector3.new(0, JumpOffset, 0)
    elseif vel.Y < -10 then
        predicted = predicted + Vector3.new(0, FallOffset, 0)
    end
    return predicted
end

local function GetAimPart(player)
    if not player or not player.Character then return nil end
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    local isInAir = hum and (hum.FloorMaterial == Enum.Material.Air or hum:GetState() == Enum.HumanoidStateType.Freefall)
    local partName = isInAir and AirAimPart or GroundAimPart
    local part = player.Character:FindFirstChild(partName)
    if not part then part = player.Character:FindFirstChild("Head") or GetRootPart(player.Character) end
    return part
end

local function WallCheck(part)
    if not WallCheckEnabled then return true end
    local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * (part.Position - Camera.CFrame.Position).Magnitude)
    local hit = workspace:FindPartOnRay(ray, LocalPlayer.Character)
    return hit == nil or hit:IsDescendantOf(part.Parent)
end

local function GetClosestTargetInFOV()
    local closest, closestDist = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsValidTarget(player) then
            local part = GetAimPart(player)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (center - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if dist < closestDist and dist <= FOVRadius and WallCheck(part) then
                        closestDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

-- ================================
-- SILENT AIM
-- ================================
local NoGroundShotEnabled = false

local function Chance(percent) return math.random(100) <= percent end

local oldIndex
oldIndex = hookmetamethod(game, "__index", function(t, k)
    if t:IsA("Mouse") and (k == "Hit" or k == "Target") then
        local target = nil
        if IndependentSilentEnabled then
            target = GetClosestTargetInFOV()
        elseif SilentEnabled then
            target = SilentLockedTarget
        end
        if target and target.Character and Chance(SilentHitChance) then
            if NoGroundShotEnabled then
                local hum = target.Character:FindFirstChildOfClass("Humanoid")
                local root = GetRootPart(target.Character)
                if hum and root then
                    local vel = root.AssemblyLinearVelocity
                    local isFalling = vel.Y < -3 and hum.FloorMaterial == Enum.Material.Air
                    if isFalling then
                        return oldIndex(t, k)
                    end
                end
            end
            
            local part = GetAimPart(target)
            if part then
                local predictedPos = GetPredictedPosition(target.Character, part)
                if k == "Hit" then
                    return CFrame.new(predictedPos)
                end
            end
        end
    end
    return oldIndex(t, k)
end)

-- ================================
-- CAMLOCK
-- ================================
local function UpdateCamlock()
    if not CamlockEnabled then
        CamlockLockedTarget = nil
        return
    end
    if not CamlockLockedTarget or not CamlockLockedTarget.Character or IsDead(CamlockLockedTarget.Character) then
        CamlockLockedTarget = GetClosestTargetInFOV()
        if CamlockLockedTarget then
            ShowNotification("DEX.CC ON " .. CamlockLockedTarget.Name, 1)
        end
        return
    end
    if not IsValidTarget(CamlockLockedTarget) then
        CamlockLockedTarget = nil
        return
    end
    local part = GetAimPart(CamlockLockedTarget)
    if not part then return end
    local targetPos = GetPredictedPosition(CamlockLockedTarget.Character, part)
    local goal = CFrame.new(Camera.CFrame.Position, targetPos)
    Camera.CFrame = Camera.CFrame:Lerp(goal, SmoothingSpeed)
end

-- ================================
-- SILENT NORMAL
-- ================================
local function UpdateSilentAim()
    if not SilentEnabled then
        SilentLockedTarget = nil
        return
    end
    if not SilentLockedTarget or not SilentLockedTarget.Character or IsDead(SilentLockedTarget.Character) then
        SilentLockedTarget = GetClosestTargetInFOV()
        if SilentLockedTarget then
            ShowNotification("DEX.CC ON " .. SilentLockedTarget.Name, 1)
        end
    elseif not IsValidTarget(SilentLockedTarget) then
        SilentLockedTarget = nil
    end
end

-- ================================
-- TARGET ESP
-- ================================
local function UpdateTargetESP()
    if not ESPEnabled then
        if ESPTarget and ESPTarget.Character then
            local highlight = ESPTarget.Character:FindFirstChildOfClass("Highlight")
            if highlight then highlight:Destroy() end
        end
        if ESPNameText then 
            ESPNameText:Remove() 
            ESPNameText = nil 
        end
        ESPTarget = nil
        if ESP2D.Frame then ESP2D.Frame.Visible = false end
        return
    end
    
    local newTarget = nil
    if CamlockEnabled and CamlockLockedTarget and IsValidTarget(CamlockLockedTarget) then
        newTarget = CamlockLockedTarget
    elseif SilentEnabled and SilentLockedTarget and IsValidTarget(SilentLockedTarget) then
        newTarget = SilentLockedTarget
    elseif IndependentSilentEnabled then
        newTarget = GetClosestTargetInFOV()
    end
    
    if newTarget ~= ESPTarget then
        if ESPTarget and ESPTarget.Character then
            local oldHighlight = ESPTarget.Character:FindFirstChildOfClass("Highlight")
            if oldHighlight then oldHighlight:Destroy() end
        end
        ESPTarget = newTarget
    end
    
    if not ESPTarget or not ESPTarget.Character then
        if ESPNameText then ESPNameText.Visible = false end
        if ESP2D.Frame then ESP2D.Frame.Visible = false end
        return
    end
    
    if ESPMode == "Highlight" then
        if ESPNameText then 
            ESPNameText:Remove() 
            ESPNameText = nil 
        end
        if ESP2D.Frame then ESP2D.Frame.Visible = false end
        local highlight = ESPTarget.Character:FindFirstChildOfClass("Highlight")
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Adornee = ESPTarget.Character
            highlight.FillTransparency = 0.4
            highlight.OutlineColor = Color3.fromRGB(30,30,30)
            highlight.OutlineTransparency = 0.2
            highlight.Parent = ESPTarget.Character
        end
        local gray = 0.4 + math.sin(grayPulse) * 0.2
        highlight.FillColor = Color3.fromRGB(gray*255, gray*255, gray*255)
    
    elseif ESPMode == "Name" then
        if ESPTarget.Character:FindFirstChildOfClass("Highlight") then
            ESPTarget.Character:FindFirstChildOfClass("Highlight"):Destroy()
        end
        if ESP2D.Frame then ESP2D.Frame.Visible = false end
        local head = ESPTarget.Character:FindFirstChild("Head")
        local posPart = head or GetRootPart(ESPTarget.Character)
        if posPart then
            local screenPos, onScreen = Camera:WorldToViewportPoint(posPart.Position)
            if onScreen then
                if not ESPNameText then
                    ESPNameText = Drawing.new("Text")
                    ESPNameText.Center = true
                    ESPNameText.Outline = true
                    ESPNameText.OutlineColor = Color3.fromRGB(0,0,0)
                    ESPNameText.Size = 13
                    ESPNameText.Font = 2
                end
                ESPNameText.Position = Vector2.new(screenPos.X, screenPos.Y - 22)
                ESPNameText.Text = ESPTarget.Name
                local gray = 0.4 + math.sin(grayPulse) * 0.2
                ESPNameText.Color = Color3.fromRGB(gray*255, gray*255, gray*255)
                ESPNameText.Visible = true
            else
                if ESPNameText then ESPNameText.Visible = false end
            end
        end
    
    elseif ESPMode == "2DBox" then
        if ESPNameText then ESPNameText.Visible = false end
        if ESPTarget.Character:FindFirstChildOfClass("Highlight") then
            ESPTarget.Character:FindFirstChildOfClass("Highlight"):Destroy()
        end
        if not ESP2D.Frame then Create2DESP() end
        Update2DESP(ESPTarget)
    end
end

-- ================================
-- ACTUALIZACIÓN DE ESTADOS
-- ================================
local function UpdateEnabledStates()
    if MasterEnabled then
        CamlockEnabled = CamlockSelected
        SilentEnabled = SilentSelected
    else
        CamlockEnabled = false
        SilentEnabled = false
        CamlockLockedTarget = nil
        SilentLockedTarget = nil
        ShowNotification("DEX.CC OFF", 1.2)
    end
    if MainExternalButton then
        MainExternalButton.Image = MasterEnabled and "rbxassetid://284402752" or "rbxassetid://284402785"
    end
end

-- ================================
-- MACRO, WALKSPEED, AIRSHOT
-- ================================
local function UpdateWalkspeed()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if MacroSpeedEnabled then
        if hum.FloorMaterial ~= Enum.Material.Air then
            hum.WalkSpeed = MacroSpeedValue
        end
    else
        if hum.WalkSpeed == MacroSpeedValue then hum.WalkSpeed = 16 end
    end
end

local macroConnection = nil
local function UpdateMacro()
    if MacroEnabled then
        if not macroConnection then
            macroConnection = RunService.RenderStepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    local root = GetRootPart(char)
                    if root then
                        local flatLook = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z).Unit
                        root.CFrame = CFrame.new(root.Position, root.Position + flatLook)
                    end
                end
            end)
        end
    else
        if macroConnection then macroConnection:Disconnect() macroConnection = nil end
    end
end

local function HasMeleeWeapon()
    local char = LocalPlayer.Character
    if not char then return false end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if not tool then return false end
    local name = tool.Name:lower()
    local keywords = {"katana","cuchillo","knife","sword","machete","bat","hacha"}
    for _, kw in ipairs(keywords) do
        if name:find(kw) then return true end
    end
    return false
end

local function IsInAir(humanoid)
    if not humanoid then return false end
    return humanoid.FloorMaterial == Enum.Material.Air or humanoid:GetState() == Enum.HumanoidStateType.Freefall or humanoid:GetState() == Enum.HumanoidStateType.Jumping
end

local function TryAutoAirshot()
    local char = LocalPlayer.Character
    if not char then return end
    
    local tool = char:FindFirstChildWhichIsA("Tool")
    if not tool then return end
    
    if HasMeleeWeapon() then return end
    
    local target = nil
    if IndependentSilentEnabled then
        target = GetClosestTargetInFOV()
    elseif CamlockEnabled then
        target = CamlockLockedTarget
    elseif SilentEnabled then
        target = SilentLockedTarget
    end
    
    if not target or not target.Character then return end
    
    local hum = target.Character:FindFirstChildOfClass("Humanoid")
    if hum and IsInAir(hum) then
        tool:Activate()
        task.delay(0.02, function()
            if tool and tool.Parent then tool:Activate() end
        end)
     end
end

-- ================================
-- NOCLIP
-- ================================
local function EnableNoclip()
    if NoclipActive then return end
    NoclipActive = true
    if NoclipConnection then NoclipConnection:Disconnect() end
    NoclipConnection = RunService.Stepped:Connect(function()
        if not TargetStrafeEnabled then
            DisableNoclip()
            return
        end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
    ShowNotification("🔓 Noclip activado", 1)
end

local function DisableNoclip()
    if not NoclipActive then return end
    NoclipActive = false
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
    ShowNotification("🔒 Noclip desactivado", 1)
end

-- ================================
-- RAGE (Target Strafe)
-- ================================
local function UpdateTargetStrafe(dt, targetRoot, rootPart)
    TargetStrafeAngle = TargetStrafeAngle + (TargetStrafeSpeed * 2 * math.pi * dt)
    if TargetStrafeAngle > 2 * math.pi then TargetStrafeAngle = TargetStrafeAngle - 2 * math.pi end
    local angle = TargetStrafeAngle
    local radius = TargetStrafeRadius
    local height = TargetStrafeHeight
    local x, z = 0, 0
    if TargetStrafePattern == "circle" then
        x = math.cos(angle) * radius
        z = math.sin(angle) * radius
    elseif TargetStrafePattern == "random" then
        local now = tick()
        if now - TargetStrafeLastUpdate > 0.2 then
            TargetStrafeRandomOffset = math.random() * 2 * math.pi
            TargetStrafeLastUpdate = now
        end
        angle = angle + TargetStrafeRandomOffset
        x = math.cos(angle) * radius
        z = math.sin(angle) * radius
    elseif TargetStrafePattern == "figure8" then
        local t = TargetStrafeAngle
        x = math.sin(t) * radius
        z = math.sin(2 * t) * radius
    elseif TargetStrafePattern == "square" then
        local t = angle % (2 * math.pi)
        if t < math.pi/2 then
            x, z = radius, radius * (t / (math.pi/2))
        elseif t < math.pi then
            x, z = radius * (1 - (t-math.pi/2)/(math.pi/2)), radius
        elseif t < 3*math.pi/2 then
            x, z = -radius, radius * (1 - (t-math.pi)/(math.pi/2))
        else
            x, z = -radius * ((t-3*math.pi/2)/(math.pi/2)), -radius
        end
    elseif TargetStrafePattern == "star" then
        local r = radius * (0.5 + 0.5 * math.sin(5 * angle))
        x = math.cos(angle) * r
        z = math.sin(angle) * r
    elseif TargetStrafePattern == "spiral" then
        TargetStrafeSpiralT = TargetStrafeSpiralT + dt * TargetStrafeSpeed
        local r = radius * (TargetStrafeSpiralT % 1)
        x = math.cos(angle * 2) * r
        z = math.sin(angle * 2) * r
    end
    local targetPos = targetRoot.Position + Vector3.new(x, height, z)
    rootPart.CFrame = CFrame.new(targetPos, targetRoot.Position)
    rootPart.AssemblyLinearVelocity = Vector3.zero
end

local function PerformStompOnManualTarget()
    if not ManualTarget or not ManualTarget.Character then 
        IsFinishing = false
        return 
    end
    local targetChar = ManualTarget.Character
    local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health > 0 then
        IsFinishing = false
        return
    end
    IsFinishing = true
    StompCooldown = true
    ShowNotification("💀 INTENTANDO STOMP en " .. ManualTarget.Name, 1.2)
    local character = LocalPlayer.Character
    if not character then 
        IsFinishing = false 
        StompCooldown = false
        return 
    end
    local myRoot = GetRootPart(character)
    local bodyRoot = GetRootPart(targetChar)
    if myRoot and bodyRoot then
        local rayOrigin = bodyRoot.Position + Vector3.new(0, 12, 0)
        local rayDirection = Vector3.new(0, -40, 0)
        local ray = Ray.new(rayOrigin, rayDirection)
        local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {character, targetChar})
        local stompY = pos and (pos.Y + 3.2) or (bodyRoot.Position.Y + 2.8)
        local stompPos = Vector3.new(bodyRoot.Position.X, stompY, bodyRoot.Position.Z)
        myRoot.CFrame = CFrame.new(stompPos)
        myRoot.AssemblyLinearVelocity = Vector3.new(0, 18, 0)
        task.wait(0.09)
        for i = 1, 4 do
            VirtualInput:SendKeyEvent(true, StompKey, false, game)
            task.wait(0.03)
            VirtualInput:SendKeyEvent(false, StompKey, false, game)
            task.wait(0.04)
        end
        ShowNotification("✅ STOMP EJECUTADO en " .. ManualTarget.Name, 1.3)
    else
        ShowNotification("❌ No se pudo encontrar el cuerpo para stomp", 1)
    end
    task.wait(1.8)
    IsFinishing = false
    StompCooldown = false
end

local function PauseRageMode()
    WasStrafeActive = TargetStrafeEnabled
    TargetStrafeEnabled = false
    DisableNoclip()
end

local function ResumeRageMode()
    if WasStrafeActive then
        TargetStrafeEnabled = true
        EnableNoclip()
        ShowNotification("🔄 Target Strafe reactivado", 1)
    end
    WasStrafeActive = false
end

local function UpdateRageModes(dt)
    if not ManualTarget or not ManualTarget.Character then return end
    local target = ManualTarget
    local targetRoot = GetRootPart(target.Character)
    if not targetRoot then return end
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = GetRootPart(character)
    if not rootPart then return end
    if IsDead(target.Character) then
        if FinisherEnabled and not IsFinishing and not StompCooldown then
            StompCooldown = true
            DeadTarget = target.Character
            if TargetStrafeEnabled then 
                PauseRageMode() 
            end
            PerformStompOnManualTarget()
            task.wait(2.2)
            if WasStrafeActive then 
                ResumeRageMode() 
            end
            StompCooldown = false
        end
        return
    else
        if DeadTarget == target.Character then
            DeadTarget = nil
            if WasStrafeActive and not TargetStrafeEnabled then ResumeRageMode() end
        end
    end
    if not TargetStrafeEnabled then return end
    UpdateTargetStrafe(dt, targetRoot, rootPart)
end

-- ================================
-- AURA
-- ================================
local function UpdateAuraTransparency()
    local seq = NumberSequence.new(AuraTransparency)
    for _, emitter in ipairs(AllEmitters) do
        if emitter and emitter.Parent then
            emitter.Transparency = seq
        end
    end
end

local function ApplyAura(designName)
    for _, obj in ipairs(CurrentAuraParts) do
        if obj and obj.Parent then obj:Destroy() end
    end
    CurrentAuraParts = {}
    AllEmitters = {}
    if not AuraEnabled then return end
    local character = LocalPlayer.Character
    if not character then return end
    local assetId = AURA_DESIGNS[designName]
    if not assetId then return end
    local success, auraModel = pcall(function() return game:GetObjects(assetId)[1] end)
    if not success or not auraModel then
        warn("No se pudo cargar el aura:", assetId)
        return
    end
    for _, modelPart in ipairs(auraModel:GetChildren()) do
        local targetPart = character:FindFirstChild(modelPart.Name) or character:FindFirstChild(string.gsub(modelPart.Name, " ", ""))
        if targetPart then
            for _, child in ipairs(modelPart:GetChildren()) do
                local clone = child:Clone()
                clone.Parent = targetPart
                table.insert(CurrentAuraParts, clone)
            end
        end
    end
    auraModel:Destroy()
    for _, obj in ipairs(CurrentAuraParts) do
        if obj and obj.Parent then
            for _, emitter in ipairs(obj:GetDescendants()) do
                if emitter:IsA("ParticleEmitter") then
                    table.insert(AllEmitters, emitter)
                end
            end
        end
    end
    UpdateAuraTransparency()
end

local function SetAuraEnabled(enabled)
    AuraEnabled = enabled
    if AuraEnabled then
        ApplyAura(CurrentAuraDesign)
        ShowNotification("✨ Aura activada: " .. CurrentAuraDesign, 1)
    else
        for _, obj in ipairs(CurrentAuraParts) do
            if obj and obj.Parent then obj:Destroy() end
        end
        CurrentAuraParts = {}
        AllEmitters = {}
        ShowNotification("✨ Aura desactivada", 1)
    end
end

local function SetAuraDesign(designName)
    CurrentAuraDesign = designName
    if AuraEnabled then
        ApplyAura(designName)
        ShowNotification("🎨 Aura cambiada a: " .. designName, 1)
    end
end

local function SetAuraTransparency(value)
    AuraTransparency = math.clamp(value, 0, 1)
    if AuraEnabled then UpdateAuraTransparency() end
end

-- ================================
-- LISTA DE JUGADORES
-- ================================
local function RefreshPlayerList()
    for _, child in ipairs(PlayerListScrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local players = Players:GetPlayers()
    table.sort(players, function(a,b) return a.Name < b.Name end)
    local yOffset = 5
    for _, plr in ipairs(players) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 28)
            btn.Position = UDim2.new(0, 5, 0, yOffset)
            btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
            btn.Text = plr.Name
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 12
            btn.Parent = PlayerListScrollingFrame
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 5)
            corner.Parent = btn
            btn.MouseButton1Click:Connect(function()
                ManualTarget = plr
                ShowNotification("🎯 Objetivo manual: " .. plr.Name, 1.5)
                for _, b in ipairs(PlayerListScrollingFrame:GetChildren()) do
                    if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(40,40,50) end
                end
                btn.BackgroundColor3 = Color3.fromRGB(80,120,80)
            end)
            yOffset = yOffset + 32
        end
    end
    PlayerListScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
end

-- ================================
-- FUNCIONES DE GUI (genéricas)
-- ================================
local function CreateNumberInput(parent, xPos, yPos, width, labelText, initialValue, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, width, 0, 32)
    frame.Position = UDim2.new(0, xPos, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -5, 0.4, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(200,200,200)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 9
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, 0, 0.5, 0)
    inputBox.Position = UDim2.new(0, 0, 0.4, 0)
    inputBox.BackgroundColor3 = Color3.fromRGB(30,30,35)
    inputBox.Text = tostring(initialValue)
    inputBox.TextColor3 = Color3.new(1,1,1)
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 9
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = frame
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = inputBox
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(70,70,80)
    stroke.Thickness = 1
    stroke.Parent = inputBox
    local lastValidText = tostring(initialValue)
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local num = tonumber(inputBox.Text)
            if num ~= nil then
                lastValidText = inputBox.Text
                callback(num)
            else
                inputBox.Text = lastValidText
            end
        end
    end)
    return {frame, inputBox}
end

local function CreateCheckbox(parent, xPos, yPos, width, text, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, width, 0, 28)
    frame.Position = UDim2.new(0, xPos, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    local checkBox = Instance.new("ImageLabel")
    checkBox.Size = UDim2.new(0, 18, 0, 18)
    checkBox.Position = UDim2.new(0, 0, 0.5, -9)
    checkBox.BackgroundColor3 = Color3.fromRGB(40,40,45)
    checkBox.Image = defaultValue and "rbxassetid://3926305904" or ""
    checkBox.ScaleType = Enum.ScaleType.Fit
    checkBox.Parent = frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = checkBox
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -24, 1, 0)
    label.Position = UDim2.new(0, 24, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220,220,220)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    local value = defaultValue
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = frame
    button.MouseButton1Click:Connect(function()
        value = not value
        checkBox.Image = value and "rbxassetid://3926305904" or ""
        callback(value)
    end)
    return {frame, checkBox, value}
end

local function CreateButton(parent, xPos, yPos, width, text, bgColor, callback, hoverColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, width, 0, 28)
    btn.Position = UDim2.new(0, xPos, 0, yPos)
    btn.BackgroundColor3 = bgColor or Color3.fromRGB(45,45,55)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80,80,90)
    stroke.Thickness = 1
    stroke.Parent = btn
    local originalColor = bgColor or Color3.fromRGB(45,45,55)
    local hover = hoverColor or Color3.fromRGB(70,70,85)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {BackgroundColor3 = hover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {BackgroundColor3 = originalColor}):Play()
    end)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function CreateDropdown(parent, xPos, yPos, width, text, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, width, 0, 28)
    frame.Position = UDim2.new(0, xPos, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, width*0.4, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220,220,220)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local current = default or options[1]
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, width*0.6, 1, 0)
    btn.Position = UDim2.new(0, width*0.4, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
    btn.Text = current
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 10
    btn.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn
    
    local dropdownList = nil
    
    local function closeDropdown()
        if dropdownList then
            dropdownList:Destroy()
            dropdownList = nil
        end
    end
    
    btn.MouseButton1Click:Connect(function()
        if dropdownList then
            closeDropdown()
            return
        end
        
        dropdownList = Instance.new("Frame")
        dropdownList.Size = UDim2.new(0, btn.AbsoluteSize.X, 0, #options * 24)
        dropdownList.Position = UDim2.new(0, btn.AbsolutePosition.X, 0, btn.AbsolutePosition.Y + btn.AbsoluteSize.Y)
        dropdownList.BackgroundColor3 = Color3.fromRGB(30,30,35)
        dropdownList.BorderSizePixel = 0
        dropdownList.Parent = parent
        dropdownList.ZIndex = 100
        
        local listCorner = Instance.new("UICorner")
        listCorner.CornerRadius = UDim.new(0, 5)
        listCorner.Parent = dropdownList
        
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 24)
            optBtn.Position = UDim2.new(0, 0, 0, (i-1)*24)
            optBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
            optBtn.Text = opt
            optBtn.TextColor3 = Color3.new(1,1,1)
            optBtn.Font = Enum.Font.Gotham
            optBtn.TextSize = 10
            optBtn.Parent = dropdownList
            optBtn.ZIndex = 101
            
            local optCorner = Instance.new("UICorner")
            optCorner.CornerRadius = UDim.new(0, 4)
            optCorner.Parent = optBtn
            
            optBtn.MouseButton1Click:Connect(function()
                current = opt
                btn.Text = opt
                callback(opt)
                closeDropdown()
            end)
        end
        
        local con
        con = game:GetService("UserInputService").InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                local dropdownPos = dropdownList.AbsolutePosition
                local dropdownSize = dropdownList.AbsoluteSize
                local btnPos = btn.AbsolutePosition
                local btnSize = btn.AbsoluteSize
                
                local inDropdown = mousePos.X >= dropdownPos.X and mousePos.X <= dropdownPos.X + dropdownSize.X
                    and mousePos.Y >= dropdownPos.Y and mousePos.Y <= dropdownPos.Y + dropdownSize.Y
                local inBtn = mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X
                    and mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y
                
                if not inDropdown and not inBtn then
                    closeDropdown()
                    con:Disconnect()
                end
            end
        end)
        
        task.delay(5, function()
            if dropdownList then
                closeDropdown()
                if con then con:Disconnect() end
            end
        end)
    end)
    
    return {frame, btn}
end

-- ================================
-- BOTONES EXTERNOS
-- ================================
local function CreateToggleGuiButton()
    if ToggleGuiButton then return end
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = playerGui:FindFirstChild("ExternalButtons") or Instance.new("ScreenGui")
    screenGui.Name = "ExternalButtons"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(0, 64, 0, 64)
    btn.Position = UDim2.new(0.02, 0, 0.02, 0)
    btn.BackgroundTransparency = 1
    btn.Image = "rbxassetid://97318186884444"
    btn.Parent = screenGui
    btn.Draggable = true
    btn.Active = true
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100,100,110)
    stroke.Thickness = 2
    stroke.Parent = btn
    btn.MouseButton1Click:Connect(function()
        if MainGUI then MainGUI.Enabled = not MainGUI.Enabled end
    end)
    ToggleGuiButton = btn
end

local function CreateLockButton()
    if MainExternalButton then return end
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = playerGui:FindFirstChild("ExternalButtons") or (function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "ExternalButtons"
        sg.ResetOnSpawn = false
        sg.Parent = playerGui
        return sg
    end)()
    
    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(0, 80, 0, 80)
    btn.Position = UDim2.new(0.91, 0, 0.65, 0)
    btn.BackgroundTransparency = 1
    btn.Image = "rbxassetid://284402785"
    btn.Parent = screenGui
    btn.Draggable = true
    btn.Active = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 0)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 100, 110)
    stroke.Thickness = 2
    stroke.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        MasterEnabled = not MasterEnabled
        if MainExternalButton then
            MainExternalButton.Image = MasterEnabled and "rbxassetid://284402752" or "rbxassetid://284402785"
        end
        UpdateEnabledStates()
    end)
    
    MainExternalButton = btn
    UpdateEnabledStates()
end

local function CreateWalkspeedButton()
    if WalkspeedExternalButton then return end
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = playerGui:FindFirstChild("ExternalButtons") or (function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "ExternalButtons"
        sg.ResetOnSpawn = false
        sg.Parent = playerGui
        return sg
    end)()
    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(0, 64, 0, 64)
    btn.Position = UDim2.new(0.91, 0, 0.77, 0)
    btn.BackgroundTransparency = 1
    btn.Image = "rbxassetid://8167283965"
    btn.Parent = screenGui
    btn.Draggable = true
    btn.Active = true
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100,100,110)
    stroke.Thickness = 2
    stroke.Parent = btn
    btn.MouseButton1Click:Connect(function()
        MacroSpeedEnabled = not MacroSpeedEnabled
        btn.Image = MacroSpeedEnabled and "rbxassetid://6724857700" or "rbxassetid://8167283965"
        if WalkspeedBtn then WalkspeedBtn.Text = "Walkspeed: " .. (MacroSpeedEnabled and "ON" or "OFF") end
        UpdateWalkspeed()
    end)
    WalkspeedExternalButton = btn
end

local function CreateMacroButton()
    if MacroExternalButton then return end
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = playerGui:FindFirstChild("ExternalButtons") or (function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "ExternalButtons"
        sg.ResetOnSpawn = false
        sg.Parent = playerGui
        return sg
    end)()
    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(0, 64, 0, 64)
    btn.Position = UDim2.new(0.91, 0, 0.89, 0)
    btn.BackgroundTransparency = 1
    btn.Image = "rbxassetid://8167283965"
    btn.Parent = screenGui
    btn.Draggable = true
    btn.Active = true
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100,100,110)
    stroke.Thickness = 2
    stroke.Parent = btn
    btn.MouseButton1Click:Connect(function()
        MacroEnabled = not MacroEnabled
        btn.Image = MacroEnabled and "rbxassetid://6724857700" or "rbxassetid://8167283965"
        if MacroBtn then MacroBtn.Text = "Macro: " .. (MacroEnabled and "ON" or "OFF") end
        UpdateMacro()
    end)
    MacroExternalButton = btn
end

-- ================================
-- GUI PRINCIPAL
-- ================================
local function CreateGUI()
    if MainGUI then return end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DEX.CC"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    MainGUI = screenGui
    MainGUI.Enabled = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 680, 0, 680)
    mainFrame.Position = UDim2.new(0.02, 0, 0.05, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(12,12,16)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60,60,70)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.4
    stroke.Parent = mainFrame
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 32)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(20,20,25)
    header.BackgroundTransparency = 0.2
    header.Parent = mainFrame
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "DEX.CC"
    title.TextColor3 = Color3.fromRGB(220,220,230)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = header
    
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 28)
    tabContainer.Position = UDim2.new(0, 0, 0, 32)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame
    
    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, -20, 1, -76)
    contentContainer.Position = UDim2.new(0, 10, 0, 64)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = mainFrame
    
    local function CreateScrollPanel(name)
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, 0, 1, 0)
        scroll.Position = UDim2.new(0, 0, 0, 0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 5
        scroll.ScrollBarImageColor3 = Color3.fromRGB(80,80,90)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.Name = name
        scroll.Parent = contentContainer
        scroll.Visible = false
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 3)
        padding.PaddingRight = UDim.new(0, 3)
        padding.PaddingTop = UDim.new(0, 2)
        padding.PaddingBottom = UDim.new(0, 2)
        padding.Parent = scroll
        return scroll
    end
    
    local panelAimbot = CreateScrollPanel("Aimbot")
    local panelAir = CreateScrollPanel("Air")
    local panelEspMisc = CreateScrollPanel("EspMisc")
    local panelRage = CreateScrollPanel("Rage")
    local panelPlayerList = CreateScrollPanel("PlayerList")
    
    local function CreateTab(name, panel, xPos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 95, 1, -3)
        btn.Position = UDim2.new(0, xPos, 0, 2)
        btn.BackgroundColor3 = Color3.fromRGB(30,30,36)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(200,200,210)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.Parent = tabContainer
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 5)
        btnCorner.Parent = btn
        btn.MouseButton1Click:Connect(function()
            panelAimbot.Visible = false
            panelAir.Visible = false
            panelEspMisc.Visible = false
            panelRage.Visible = false
            panelPlayerList.Visible = false
            panel.Visible = true
            for _, child in ipairs(tabContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = Color3.fromRGB(30,30,36)
                    child.TextColor3 = Color3.fromRGB(200,200,210)
                end
            end
            btn.BackgroundColor3 = Color3.fromRGB(55,55,70)
            btn.TextColor3 = Color3.fromRGB(255,255,255)
        end)
        return btn
    end
    
    CreateTab("AIMBOT", panelAimbot, 5)
    CreateTab("AIR", panelAir, 108)
    CreateTab("ESP/MISC", panelEspMisc, 211)
    CreateTab("RAGE", panelRage, 314)
    CreateTab("TARGET LIST", panelPlayerList, 417)
    
    -- ========== AIMBOT ==========
    local aimbotY = 2
    local colW = 260
    local col1_x = 5
    local col2_x = col1_x + colW + 8
    
    CreateCheckbox(panelAimbot, col1_x, aimbotY, colW, "Camlock", true, function(val)
        CamlockSelected = val
        UpdateEnabledStates()
    end)
    CreateCheckbox(panelAimbot, col2_x, aimbotY, colW, "Silent Aim", true, function(val)
        SilentSelected = val
        UpdateEnabledStates()
    end)
    aimbotY = aimbotY + 30
    
    CreateCheckbox(panelAimbot, col1_x, aimbotY, colW, "Silent FOV (independiente)", IndependentSilentEnabled, function(val)
        IndependentSilentEnabled = val
        ShowNotification("Silent FOV: " .. (val and "ON (cambia automáticamente)" or "OFF"), 1)
    end)
    aimbotY = aimbotY + 34
    
    local groundLabel = Instance.new("TextLabel")
    groundLabel.Size = UDim2.new(0, colW, 0, 18)
    groundLabel.Position = UDim2.new(0, col1_x, 0, aimbotY)
    groundLabel.BackgroundTransparency = 1
    groundLabel.Text = "Ground Part: " .. GroundAimPart
    groundLabel.TextColor3 = Color3.fromRGB(220,220,230)
    groundLabel.Font = Enum.Font.GothamSemibold
    groundLabel.TextSize = 9
    groundLabel.TextXAlignment = Enum.TextXAlignment.Left
    groundLabel.Parent = panelAimbot
    
    CreateButton(panelAimbot, col1_x, aimbotY + 20, 45, "◀", Color3.fromRGB(45,45,55), function()
        GroundPartIndex = GroundPartIndex - 1
        if GroundPartIndex < 1 then GroundPartIndex = #GroundPartList end
        GroundAimPart = GroundPartList[GroundPartIndex]
        groundLabel.Text = "Ground Part: " .. GroundAimPart
    end)
    CreateButton(panelAimbot, col1_x + colW - 45, aimbotY + 20, 45, "▶", Color3.fromRGB(45,45,55), function()
        GroundPartIndex = GroundPartIndex + 1
        if GroundPartIndex > #GroundPartList then GroundPartIndex = 1 end
        GroundAimPart = GroundPartList[GroundPartIndex]
        groundLabel.Text = "Ground Part: " .. GroundAimPart
    end)
    aimbotY = aimbotY + 44
    
    CreateNumberInput(panelAimbot, col1_x, aimbotY, colW, "FOV Radius:", FOVRadius, function(val) FOVRadius = val; if FOVCircle then FOVCircle.Radius = FOVRadius end end)
    CreateNumberInput(panelAimbot, col2_x, aimbotY, colW, "Smoothing (Camlock):", SmoothingSpeed, function(val) SmoothingSpeed = val end)
    aimbotY = aimbotY + 34
    
    CreateDropdown(panelAimbot, col1_x, aimbotY, colW, "Prediction Mode:", {"Manual", "PingBased", "Blatant"}, "PingBased", function(val)
        PredictionMode = val
        UpdatePrediction()
    end)
    aimbotY = aimbotY + 34
    
    CreateCheckbox(panelAimbot, col1_x, aimbotY, colW, "Auto Prediction (legacy)", AutoPrediction, function(val) AutoPrediction = val; UpdatePrediction() end)
    CreateNumberInput(panelAimbot, col2_x, aimbotY, colW, "Base Prediction:", BasePrediction, function(val) BasePrediction = val; UpdatePrediction() end)
    aimbotY = aimbotY + 34
    
    CreateNumberInput(panelAimbot, col1_x, aimbotY, colW, "Prediction Value:", PredictionValue, function(val)
        PredictionValue = val
        if PredictionMode == "Manual" then UpdatePrediction() end
    end)
    aimbotY = aimbotY + 34
    
    CreateNumberInput(panelAimbot, col1_x, aimbotY, colW, "Hit Chance %:", SilentHitChance, function(val) SilentHitChance = val end)
    aimbotY = aimbotY + 34
    
    CreateCheckbox(panelAimbot, col1_x, aimbotY, colW, "Wall Check", WallCheckEnabled, function(val) WallCheckEnabled = val end)
    aimbotY = aimbotY + 34
    
    CreateCheckbox(panelAimbot, col1_x, aimbotY, colW, "Resolver Enabled", ResolverEnabled, function(val) ResolverEnabled = val end)
    aimbotY = aimbotY + 34
    
    CreateDropdown(panelAimbot, col1_x, aimbotY, colW, "Resolver Mode:", {"Velocity", "MoveDirection", "TimeBased"}, "Velocity", function(val) ResolverMode = val end)
    aimbotY = aimbotY + 34
    
    CreateCheckbox(panelAimbot, col1_x, aimbotY, colW, "No Ground Shot", NoGroundShotEnabled, function(val) NoGroundShotEnabled = val end)
    aimbotY = aimbotY + 34
    
    CreateCheckbox(panelAimbot, col1_x, aimbotY, colW, "Círculo de predicción", false, function(val)
        PredictionCircleEnabled = val
        if not val and PredictionCircle then PredictionCircle.Visible = false end
    end)
    aimbotY = aimbotY + 40
    
    panelAimbot.CanvasSize = UDim2.new(0, 0, 0, aimbotY + 5)
    
    -- ========== AIR ==========
    local airY = 2
    CreateCheckbox(panelAir, col1_x, airY, colW, "Auto Airshot", false, function(val) AutoAirshotEnabled = val end)
    CreateNumberInput(panelAir, col2_x, airY, colW, "Air Delay:", AirDelay, function(val) AirDelay = val end)
    airY = airY + 34
    
    local airLabel = Instance.new("TextLabel")
    airLabel.Size = UDim2.new(0, colW, 0, 18)
    airLabel.Position = UDim2.new(0, col1_x, 0, airY)
    airLabel.BackgroundTransparency = 1
    airLabel.Text = "Air Part: " .. AirAimPart
    airLabel.TextColor3 = Color3.fromRGB(220,220,230)
    airLabel.Font = Enum.Font.GothamSemibold
    airLabel.TextSize = 9
    airLabel.TextXAlignment = Enum.TextXAlignment.Left
    airLabel.Parent = panelAir
    
    CreateButton(panelAir, col1_x, airY + 20, 45, "◀", Color3.fromRGB(45,45,55), function()
        AirPartIndex = AirPartIndex - 1
        if AirPartIndex < 1 then AirPartIndex = #AirPartList end
        AirAimPart = AirPartList[AirPartIndex]
        airLabel.Text = "Air Part: " .. AirAimPart
    end)
    CreateButton(panelAir, col1_x + colW - 45, airY + 20, 45, "▶", Color3.fromRGB(45,45,55), function()
        AirPartIndex = AirPartIndex + 1
        if AirPartIndex > #AirPartList then AirPartIndex = 1 end
        AirAimPart = AirPartList[AirPartIndex]
        airLabel.Text = "Air Part: " .. AirAimPart
    end)
    airY = airY + 44
    
    CreateNumberInput(panelAir, col1_x, airY, colW, "Jump Offset:", JumpOffset, function(val) JumpOffset = val end)
    CreateNumberInput(panelAir, col2_x, airY, colW, "Fall Offset:", FallOffset, function(val) FallOffset = val end)
    airY = airY + 34
    
    panelAir.CanvasSize = UDim2.new(0, 0, 0, airY + 5)
    
    -- ========== ESP/MISC ==========
    local miscY = 2
    CreateCheckbox(panelEspMisc, col1_x, miscY, colW, "Habilitar ESP", ESPEnabled, function(val) ESPEnabled = val end)
    miscY = miscY + 30
    
    local highlightBtn = CreateButton(panelEspMisc, col1_x, miscY, colW-8, "Highlight (3D)", Color3.fromRGB(45,45,55), function()
        ESPMode = "Highlight"
        highlightBtn.BackgroundColor3 = Color3.fromRGB(75,75,90)
        nameBtn.BackgroundColor3 = Color3.fromRGB(45,45,55)
        box2dBtn.BackgroundColor3 = Color3.fromRGB(45,45,55)
        if ESP2D.Frame then ESP2D.Frame.Visible = false end
    end)
    local nameBtn = CreateButton(panelEspMisc, col2_x+8, miscY, colW-8, "Name ESP", Color3.fromRGB(45,45,55), function()
        ESPMode = "Name"
        nameBtn.BackgroundColor3 = Color3.fromRGB(75,75,90)
        highlightBtn.BackgroundColor3 = Color3.fromRGB(45,45,55)
        box2dBtn.BackgroundColor3 = Color3.fromRGB(45,45,55)
        if ESP2D.Frame then ESP2D.Frame.Visible = false end
    end)
    local box2dBtn = CreateButton(panelEspMisc, col1_x, miscY + 35, colW, "2D Box (gris + rayitas)", Color3.fromRGB(45,45,55), function()
        ESPMode = "2DBox"
        box2dBtn.BackgroundColor3 = Color3.fromRGB(75,75,90)
        highlightBtn.BackgroundColor3 = Color3.fromRGB(45,45,55)
        nameBtn.BackgroundColor3 = Color3.fromRGB(45,45,55)
        Create2DESP()
    end)
    highlightBtn.BackgroundColor3 = Color3.fromRGB(75,75,90)
    miscY = miscY + 70
    
    CreateNumberInput(panelEspMisc, col1_x, miscY, colW, "Walkspeed Value:", MacroSpeedValue, function(val) MacroSpeedValue = val; if MacroSpeedEnabled then UpdateWalkspeed() end end)
    miscY = miscY + 34
    
    WalkspeedBtn = CreateButton(panelEspMisc, col1_x, miscY, colW, "Walkspeed: OFF", Color3.fromRGB(45,45,55), function()
        MacroSpeedEnabled = not MacroSpeedEnabled
        WalkspeedBtn.Text = "Walkspeed: " .. (MacroSpeedEnabled and "ON" or "OFF")
        if WalkspeedExternalButton then WalkspeedExternalButton.Image = MacroSpeedEnabled and "rbxassetid://6724857700" or "rbxassetid://8167283965" end
        UpdateWalkspeed()
    end)
    MacroBtn = CreateButton(panelEspMisc, col2_x, miscY, colW, "Macro: OFF", Color3.fromRGB(45,45,55), function()
        MacroEnabled = not MacroEnabled
        MacroBtn.Text = "Macro: " .. (MacroEnabled and "ON" or "OFF")
        if MacroExternalButton then MacroExternalButton.Image = MacroEnabled and "rbxassetid://6724857700" or "rbxassetid://8167283965" end
        UpdateMacro()
    end)
    miscY = miscY + 34
    
    CreateButton(panelEspMisc, col1_x, miscY, colW, "Create Lock Button", Color3.fromRGB(50,50,60), CreateLockButton)
    CreateButton(panelEspMisc, col2_x, miscY, colW, "Create Macro", Color3.fromRGB(50,50,60), CreateMacroButton)
    miscY = miscY + 34
    CreateButton(panelEspMisc, col1_x, miscY, colW, "Create Walkspeed", Color3.fromRGB(50,50,60), CreateWalkspeedButton)
    miscY = miscY + 40

    -- ========== AMBIENTE Y CIELO ==========
    local ambientHeader = Instance.new("TextLabel")
    ambientHeader.Size = UDim2.new(0, colW*2+8, 0, 20)
    ambientHeader.Position = UDim2.new(0, col1_x, 0, miscY)
    ambientHeader.BackgroundTransparency = 1
    ambientHeader.Text = "🌎 Ambiente y Cielo"
    ambientHeader.TextColor3 = Color3.fromRGB(200,200,255)
    ambientHeader.Font = Enum.Font.GothamBold
    ambientHeader.TextSize = 11
    ambientHeader.TextXAlignment = Enum.TextXAlignment.Left
    ambientHeader.Parent = panelEspMisc
    miscY = miscY + 22

    local colorPickerBtn = CreateButton(panelEspMisc, col1_x, miscY, colW, "Seleccionar color ambiente", Color3.fromRGB(50,70,90), function()
        local colorFrame = Instance.new("Frame")
        colorFrame.Size = UDim2.new(0, 260, 0, 200)
        colorFrame.Position = UDim2.new(0.5, -130, 0.3, 0)
        colorFrame.BackgroundColor3 = Color3.fromRGB(30,30,40)
        colorFrame.BackgroundTransparency = 0.1
        colorFrame.Parent = MainGUI
        local colorCorner = Instance.new("UICorner")
        colorCorner.CornerRadius = UDim.new(0, 8)
        colorCorner.Parent = colorFrame
        
        local preview = Instance.new("Frame")
        preview.Size = UDim2.new(0, 50, 0, 50)
        preview.Position = UDim2.new(0, 10, 0, 10)
        preview.BackgroundColor3 = AmbientColor
        preview.BorderSizePixel = 0
        preview.Parent = colorFrame
        local previewCorner = Instance.new("UICorner")
        previewCorner.CornerRadius = UDim.new(0, 6)
        previewCorner.Parent = preview
        
        local r, g, b = AmbientColor.R, AmbientColor.G, AmbientColor.B
        
        local function updateColor()
            local newColor = Color3.new(r, g, b)
            SetAmbientColor(newColor)
            preview.BackgroundColor3 = newColor
            redValBox.Text = string.format("%.2f", r)
            greenValBox.Text = string.format("%.2f", g)
            blueValBox.Text = string.format("%.2f", b)
        end
        
        local function createColorSlider(y, colorComp, initial, callback)
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(0, 220, 0, 32)
            sliderFrame.Position = UDim2.new(0, 20, 0, y)
            sliderFrame.BackgroundTransparency = 1
            sliderFrame.Parent = colorFrame
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0, 20, 1, 0)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = colorComp
            label.TextColor3 = Color3.fromRGB(255,255,255)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 11
            label.Parent = sliderFrame
            
            local sliderBg = Instance.new("Frame")
            sliderBg.Size = UDim2.new(1, -90, 1, 0)
            sliderBg.Position = UDim2.new(0, 25, 0, 0)
            sliderBg.BackgroundColor3 = Color3.fromRGB(50,50,60)
            sliderBg.BorderSizePixel = 0
            sliderBg.Parent = sliderFrame
            local sliderBgCorner = Instance.new("UICorner")
            sliderBgCorner.CornerRadius = UDim.new(0, 4)
            sliderBgCorner.Parent = sliderBg
            
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(initial, 0, 1, 0)
            fill.BackgroundColor3 = colorComp == "R" and Color3.fromRGB(255,0,0) or (colorComp == "G" and Color3.fromRGB(0,255,0) or Color3.fromRGB(0,0,255))
            fill.BorderSizePixel = 0
            fill.Parent = sliderBg
            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(0, 4)
            fillCorner.Parent = fill
            
            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 8, 0, 16)
            knob.Position = UDim2.new(initial, -4, 0.5, -8)
            knob.BackgroundColor3 = Color3.fromRGB(220,220,220)
            knob.BorderSizePixel = 0
            knob.Parent = sliderBg
            local knobCorner = Instance.new("UICorner")
            knobCorner.CornerRadius = UDim.new(1, 0)
            knobCorner.Parent = knob
            
            local valueBox = Instance.new("TextBox")
            valueBox.Size = UDim2.new(0, 50, 1, 0)
            valueBox.Position = UDim2.new(1, -55, 0, 0)
            valueBox.BackgroundColor3 = Color3.fromRGB(40,40,50)
            valueBox.Text = string.format("%.2f", initial)
            valueBox.TextColor3 = Color3.new(1,1,1)
            valueBox.Font = Enum.Font.Gotham
            valueBox.TextSize = 10
            valueBox.Parent = sliderFrame
            local valueCorner = Instance.new("UICorner")
            valueCorner.CornerRadius = UDim.new(0, 4)
            valueCorner.Parent = valueBox
            
            local dragging = false
            local function updateFromMouse(mouseX)
                local relative = (mouseX - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
                local newVal = math.clamp(relative, 0, 1)
                fill.Size = UDim2.new(newVal, 0, 1, 0)
                knob.Position = UDim2.new(newVal, -4, 0.5, -8)
                callback(newVal)
                updateColor()
            end
            
            sliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateFromMouse(input.Position.X)
                end
            end)
            sliderBg.InputEnded:Connect(function() dragging = false end)
            sliderBg.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateFromMouse(input.Position.X)
                end
            end)
            
            valueBox.FocusLost:Connect(function(enter)
                if enter then
                    local num = tonumber(valueBox.Text)
                    if num then
                        local newVal = math.clamp(num, 0, 1)
                        callback(newVal)
                        fill.Size = UDim2.new(newVal, 0, 1, 0)
                        knob.Position = UDim2.new(newVal, -4, 0.5, -8)
                        updateColor()
                    else
                        valueBox.Text = string.format("%.2f", callback())
                    end
                end
            end)
            
            return valueBox
        end
        
        local redValBox = createColorSlider(70, "R", r, function(v) r = v end)
        local greenValBox = createColorSlider(110, "G", g, function(v) g = v end)
        local blueValBox = createColorSlider(150, "B", b, function(v) b = v end)
        
        local closeBtn = CreateButton(colorFrame, 20, 185, 220, "Cerrar", Color3.fromRGB(100,50,50), function()
            colorFrame:Destroy()
        end)
    end)
    miscY = miscY + 34

    local skyIdBox = Instance.new("TextBox")
    skyIdBox.Size = UDim2.new(0, colW - 70, 0, 28)
    skyIdBox.Position = UDim2.new(0, col1_x, 0, miscY)
    skyIdBox.BackgroundColor3 = Color3.fromRGB(40,40,50)
    skyIdBox.Text = ""
    skyIdBox.PlaceholderText = "ID de cielo (ej: 1234567890)"
    skyIdBox.TextColor3 = Color3.fromRGB(255,255,255)
    skyIdBox.Font = Enum.Font.Gotham
    skyIdBox.TextSize = 10
    skyIdBox.Parent = panelEspMisc
    local skyCorner = Instance.new("UICorner")
    skyCorner.CornerRadius = UDim.new(0, 5)
    skyCorner.Parent = skyIdBox
    
    local applySkyBtn = CreateButton(panelEspMisc, col1_x + colW - 65, miscY, 60, "Aplicar", Color3.fromRGB(60,80,100), function()
        local id = skyIdBox.Text
        if id ~= "" then
            SetSkybox(id)
        end
    end)
    miscY = miscY + 34

    -- ========== HITSOUNDS (SLOTS) ==========
    local soundHeader = Instance.new("TextLabel")
    soundHeader.Size = UDim2.new(0, colW*2+8, 0, 20)
    soundHeader.Position = UDim2.new(0, col1_x, 0, miscY)
    soundHeader.BackgroundTransparency = 1
    soundHeader.Text = "🔊 HITSOUNDS (Slots)"
    soundHeader.TextColor3 = Color3.fromRGB(255,200,100)
    soundHeader.Font = Enum.Font.GothamBold
    soundHeader.TextSize = 11
    soundHeader.TextXAlignment = Enum.TextXAlignment.Left
    soundHeader.Parent = panelEspMisc
    miscY = miscY + 22

    local soundSlots = {}
    for i = 1, 5 do
        local slotBtn = Instance.new("TextButton")
        slotBtn.Size = UDim2.new(0, colW - 10, 0, 22)
        slotBtn.Position = UDim2.new(0, col1_x, 0, miscY + (i-1)*24)
        slotBtn.BackgroundColor3 = Color3.fromRGB(45,45,55)
        slotBtn.Text = string.sub(SavedSounds[i], 1, 30)
        slotBtn.TextColor3 = Color3.fromRGB(255,255,255)
        slotBtn.Font = Enum.Font.Gotham
        slotBtn.TextSize = 9
        slotBtn.Parent = panelEspMisc
        local slotCorner = Instance.new("UICorner")
        slotCorner.CornerRadius = UDim.new(0, 4)
        slotCorner.Parent = slotBtn
        slotBtn.MouseButton1Click:Connect(function()
            SelectedSoundSlot = i
            CurrentSoundId = SavedSounds[i]
            ShowNotification("Sonido cambiado a slot " .. i, 0.8)
            for _, b in ipairs(soundSlots) do b.BackgroundColor3 = Color3.fromRGB(45,45,55) end
            slotBtn.BackgroundColor3 = Color3.fromRGB(75,75,90)
        end)
        soundSlots[i] = slotBtn
    end
    miscY = miscY + 5*24 + 5

    local customSoundBox = Instance.new("TextBox")
    customSoundBox.Size = UDim2.new(0, colW - 70, 0, 22)
    customSoundBox.Position = UDim2.new(0, col1_x, 0, miscY)
    customSoundBox.BackgroundColor3 = Color3.fromRGB(40,40,50)
    customSoundBox.Text = ""
    customSoundBox.PlaceholderText = "Sound ID (ej: 9120381536)"
    customSoundBox.TextColor3 = Color3.fromRGB(255,255,255)
    customSoundBox.Font = Enum.Font.Gotham
    customSoundBox.TextSize = 9
    customSoundBox.ClearTextOnFocus = true
    customSoundBox.Parent = panelEspMisc
    local customCorner = Instance.new("UICorner")
    customCorner.CornerRadius = UDim.new(0, 4)
    customCorner.Parent = customSoundBox

    CreateButton(panelEspMisc, col1_x + colW - 65, miscY, 60, "Aplicar", Color3.fromRGB(60,80,100), function()
        local id = customSoundBox.Text
        if id ~= "" then
            if not id:match("^rbxassetid://") then
                id = "rbxassetid://" .. id:gsub("%D", "")
            end
            CurrentSoundId = id
            ShowNotification("Sonido temporal aplicado", 0.8)
        end
    end)
    miscY = miscY + 28

    CreateButton(panelEspMisc, col1_x, miscY, colW-10, "Guardar en slot", Color3.fromRGB(70,100,70), function()
        local id = customSoundBox.Text
        if id == "" then return end
        if not id:match("^rbxassetid://") then
            id = "rbxassetid://" .. id:gsub("%D", "")
        end
        SavedSounds[SelectedSoundSlot] = id
        soundSlots[SelectedSoundSlot].Text = string.sub(id, 1, 30)
        SaveSoundSlots()
        ShowNotification("Sonido guardado en slot " .. SelectedSoundSlot, 0.8)
    end)
    CreateButton(panelEspMisc, col2_x, miscY, colW-10, "Reset slots", Color3.fromRGB(100,60,60), function()
        SavedSounds = {
            "rbxassetid://124356179581089",
            "rbxassetid://135478009117226",
            "rbxassetid://140721035016341",
            "rbxassetid://140367458608473",
            "rbxassetid://736191318"
        }
        for i = 1, 5 do
            soundSlots[i].Text = string.sub(SavedSounds[i], 1, 30)
        end
        CurrentSoundId = SavedSounds[1]
        SaveSoundSlots()
        ShowNotification("Sonidos restaurados", 0.8)
    end)
    miscY = miscY + 34

    -- ========== HIT EFFECTS AVANZADOS ==========
    local hitEffectHeader = Instance.new("TextLabel")
    hitEffectHeader.Size = UDim2.new(0, colW*2+8, 0, 20)
    hitEffectHeader.Position = UDim2.new(0, col1_x, 0, miscY)
    hitEffectHeader.BackgroundTransparency = 1
    hitEffectHeader.Text = "✨ HIT EFFECTS (AVANZADO)"
    hitEffectHeader.TextColor3 = Color3.fromRGB(255,200,100)
    hitEffectHeader.Font = Enum.Font.GothamBold
    hitEffectHeader.TextSize = 11
    hitEffectHeader.TextXAlignment = Enum.TextXAlignment.Left
    hitEffectHeader.Parent = panelEspMisc
    miscY = miscY + 22

    local styleLabel = Instance.new("TextLabel")
    styleLabel.Size = UDim2.new(0, colW, 0, 20)
    styleLabel.Position = UDim2.new(0, col1_x, 0, miscY)
    styleLabel.BackgroundTransparency = 1
    styleLabel.Text = "Estilo actual: Nova Impact"
    styleLabel.TextColor3 = Color3.fromRGB(220,220,230)
    styleLabel.Font = Enum.Font.GothamSemibold
    styleLabel.TextSize = 11
    styleLabel.TextXAlignment = Enum.TextXAlignment.Left
    styleLabel.Parent = panelEspMisc

    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Size = UDim2.new(0, colW, 0, 32)
    dropdownBtn.Position = UDim2.new(0, col1_x, 0, miscY + 22)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(45,45,55)
    dropdownBtn.Text = "▼ Nova Impact"
    dropdownBtn.TextColor3 = Color3.fromRGB(255,255,255)
    dropdownBtn.Font = Enum.Font.GothamBold
    dropdownBtn.TextSize = 12
    dropdownBtn.Parent = panelEspMisc

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = dropdownBtn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100,100,120)
    stroke.Thickness = 1.5
    stroke.Parent = dropdownBtn

    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(0, colW, 0, 0)
    dropdownFrame.Position = UDim2.new(0, col1_x, 0, miscY + 56)
    dropdownFrame.BackgroundColor3 = Color3.fromRGB(30,30,40)
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Visible = false
    dropdownFrame.Parent = panelEspMisc

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 6)
    listCorner.Parent = dropdownFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = dropdownFrame

    for _, styleName in ipairs(HitEffectStyles) do
        local optionBtn = Instance.new("TextButton")
        optionBtn.Size = UDim2.new(1, -8, 0, 28)
        optionBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
        optionBtn.Text = styleName
        optionBtn.TextColor3 = Color3.fromRGB(255,255,255)
        optionBtn.Font = Enum.Font.Gotham
        optionBtn.TextSize = 11
        optionBtn.Parent = dropdownFrame
        
        local optCorner = Instance.new("UICorner")
        optCorner.CornerRadius = UDim.new(0, 4)
        optCorner.Parent = optionBtn
        
        optionBtn.MouseButton1Click:Connect(function()
            HitEffectStyle = styleName
            styleLabel.Text = "Estilo actual: " .. styleName
            dropdownBtn.Text = "▼ " .. styleName
            dropdownFrame.Visible = false
            ShowNotification("✨ Hit Effect cambiado a: " .. styleName, 1.5)
        end)
    end

    dropdownBtn.MouseButton1Click:Connect(function()
        dropdownFrame.Visible = not dropdownFrame.Visible
        if dropdownFrame.Visible then
            dropdownFrame.Size = UDim2.new(0, colW, 0, #HitEffectStyles * 30 + 6)
        end
    end)

    miscY = miscY + 110
    
    CreateCheckbox(panelEspMisc, col1_x, miscY, colW, "Hit Cham (Clon)", HitChamEnabled, function(val) HitChamEnabled = val end)
    miscY = miscY + 28
    
    CreateNumberInput(panelEspMisc, col1_x, miscY, colW, "Duración Cham (s):", HitChamDuration, function(val) HitChamDuration = math.max(0.5, val) end)
    miscY = miscY + 34
    
    panelEspMisc.CanvasSize = UDim2.new(0, 0, 0, miscY + 10)
    
    -- ========== RAGE (TARGET STRAFE) ==========
    local rageY = 2
    local colW2 = 270
    local colR1 = 5
    local colR2 = colR1 + colW2 + 8
    
    local strafeHeader = Instance.new("TextLabel")
    strafeHeader.Size = UDim2.new(0, colW2, 0, 20)
    strafeHeader.Position = UDim2.new(0, colR1, 0, rageY)
    strafeHeader.BackgroundTransparency = 1
    strafeHeader.Text = "🎯 TARGET STRAFE (con noclip)"
    strafeHeader.TextColor3 = Color3.fromRGB(255,200,100)
    strafeHeader.Font = Enum.Font.GothamBold
    strafeHeader.TextSize = 12
    strafeHeader.TextXAlignment = Enum.TextXAlignment.Left
    strafeHeader.Parent = panelRage
    
    local strafeBtn = CreateButton(panelRage, colR1, rageY + 22, colW2, "Target Strafe: OFF", Color3.fromRGB(70,40,40), function()
        if TargetStrafeEnabled then
            TargetStrafeEnabled = false
            strafeBtn.Text = "Target Strafe: OFF"
            strafeBtn.BackgroundColor3 = Color3.fromRGB(70,40,40)
            DisableNoclip()
        else
            TargetStrafeEnabled = true
            strafeBtn.Text = "Target Strafe: ON"
            strafeBtn.BackgroundColor3 = Color3.fromRGB(100,50,50)
            EnableNoclip()
        end
    end)
    rageY = rageY + 54
    
    CreateNumberInput(panelRage, colR1, rageY, colW2, "Velocidad (vueltas/seg):", TargetStrafeSpeed, function(val) TargetStrafeSpeed = math.max(0.5, val) end)
    CreateNumberInput(panelRage, colR2, rageY, colW2, "Radio:", TargetStrafeRadius, function(val) TargetStrafeRadius = math.max(1, val) end)
    rageY = rageY + 34
    CreateNumberInput(panelRage, colR1, rageY, colW2, "Altura (offset Y):", TargetStrafeHeight, function(val) TargetStrafeHeight = val end)
    
    local patternLabel = Instance.new("TextLabel")
    patternLabel.Size = UDim2.new(0, colW2, 0, 18)
    patternLabel.Position = UDim2.new(0, colR1, 0, rageY + 34)
    patternLabel.BackgroundTransparency = 1
    patternLabel.Text = "Patrón: " .. TargetStrafePattern
    patternLabel.TextColor3 = Color3.fromRGB(220,220,230)
    patternLabel.Font = Enum.Font.GothamSemibold
    patternLabel.TextSize = 9
    patternLabel.TextXAlignment = Enum.TextXAlignment.Left
    patternLabel.Parent = panelRage
    
    CreateButton(panelRage, colR1, rageY + 54, 45, "◀", Color3.fromRGB(45,45,55), function()
        local patterns = {"circle", "random", "figure8", "square", "star", "spiral"}
        local idx = table.find(patterns, TargetStrafePattern) or 1
        idx = idx - 1
        if idx < 1 then idx = #patterns end
        TargetStrafePattern = patterns[idx]
        patternLabel.Text = "Patrón: " .. TargetStrafePattern
    end)
    CreateButton(panelRage, colR1 + colW2 - 45, rageY + 54, 45, "▶", Color3.fromRGB(45,45,55), function()
        local patterns = {"circle", "random", "figure8", "square", "star", "spiral"}
        local idx = table.find(patterns, TargetStrafePattern) or 1
        idx = idx + 1
        if idx > #patterns then idx = 1 end
        TargetStrafePattern = patterns[idx]
        patternLabel.Text = "Patrón: " .. TargetStrafePattern
    end)
    rageY = rageY + 88
    
    local sep1 = Instance.new("Frame")
    sep1.Size = UDim2.new(1, -10, 0, 2)
    sep1.Position = UDim2.new(0, 5, 0, rageY)
    sep1.BackgroundColor3 = Color3.fromRGB(80,80,90)
    sep1.BorderSizePixel = 0
    sep1.Parent = panelRage
    rageY = rageY + 10
    
    local velSpoofHeader = Instance.new("TextLabel")
    velSpoofHeader.Size = UDim2.new(0, colW2, 0, 20)
    velSpoofHeader.Position = UDim2.new(0, colR1, 0, rageY)
    velSpoofHeader.BackgroundTransparency = 1
    velSpoofHeader.Text = "🛡️ VELOCITY SPOOFER"
    velSpoofHeader.TextColor3 = Color3.fromRGB(200,150,255)
    velSpoofHeader.Font = Enum.Font.GothamBold
    velSpoofHeader.TextSize = 12
    velSpoofHeader.TextXAlignment = Enum.TextXAlignment.Left
    velSpoofHeader.Parent = panelRage
    rageY = rageY + 20
    
    local VelocitySpooferEnabled = false
    local VelocitySpooferMode = "Underground"
    local VelocitySpooferX, VelocitySpooferY, VelocitySpooferZ = 0, -50, 0
    
    CreateCheckbox(panelRage, colR1, rageY, colW2, "Enabled", false, function(val) VelocitySpooferEnabled = val end)
    rageY = rageY + 28
    
    CreateDropdown(panelRage, colR1, rageY, colW2, "Mode:", {"Underground", "Sky", "Prediction Breaker", "Custom"}, "Underground", function(val) VelocitySpooferMode = val end)
    rageY = rageY + 34
    
    CreateNumberInput(panelRage, colR1, rageY, colW2/3-5, "X", VelocitySpooferX, function(v) VelocitySpooferX = v end)
    CreateNumberInput(panelRage, colR1+colW2/3, rageY, colW2/3-5, "Y", VelocitySpooferY, function(v) VelocitySpooferY = v end)
    CreateNumberInput(panelRage, colR1+2*colW2/3, rageY, colW2/3-5, "Z", VelocitySpooferZ, function(v) VelocitySpooferZ = v end)
    rageY = rageY + 34
    
    CreateCheckbox(panelRage, colR1, rageY, colW2, "Remate automático (Stomp/E)", FinisherEnabled, function(val) FinisherEnabled = val end)
    rageY = rageY + 34
    
    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, -10, 0, 50)
    infoText.Position = UDim2.new(0, 5, 0, rageY)
    infoText.BackgroundTransparency = 1
    infoText.Text = "⚠️ Los modos Rage funcionan con el objetivo manual (Target List)."
    infoText.TextColor3 = Color3.fromRGB(200,200,100)
    infoText.Font = Enum.Font.Gotham
    infoText.TextSize = 9
    infoText.TextWrapped = true
    infoText.Parent = panelRage
    rageY = rageY + 55
    panelRage.CanvasSize = UDim2.new(0, 0, 0, rageY + 10)
    
    -- ========== TARGET LIST ==========
    local listY = 2
    CreateButton(panelPlayerList, col1_x, listY, colW, "Refrescar lista", Color3.fromRGB(50,50,60), function()
        RefreshPlayerList()
        ShowNotification("Lista actualizada", 1)
    end)
    listY = listY + 34
    CreateButton(panelPlayerList, col2_x, listY-34, colW, "Limpiar objetivo", Color3.fromRGB(60,40,40), function()
        ManualTarget = nil
        ShowNotification("Objetivo manual eliminado", 1)
        RefreshPlayerList()
    end)
    PlayerListScrollingFrame = Instance.new("ScrollingFrame")
    PlayerListScrollingFrame.Size = UDim2.new(1, 0, 1, -80)
    PlayerListScrollingFrame.Position = UDim2.new(0, 0, 0, 40)
    PlayerListScrollingFrame.BackgroundColor3 = Color3.fromRGB(20,20,25)
    PlayerListScrollingFrame.BorderSizePixel = 0
    PlayerListScrollingFrame.ScrollBarThickness = 5
    PlayerListScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    PlayerListScrollingFrame.Parent = panelPlayerList
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 6)
    listCorner.Parent = PlayerListScrollingFrame
    RefreshPlayerList()
    
    panelAimbot.Visible = true
end

-- ================================
-- FOV CIRCLE
-- ================================
local function CreateFOVCircle()
    local success, circle = pcall(function() return Drawing.new("Circle") end)
    if success and circle then
        FOVCircle = circle
        FOVCircle.Thickness = 2
        FOVCircle.NumSides = 100
        FOVCircle.Radius = FOVRadius
        FOVCircle.Filled = false
        FOVCircle.Color = Color3.fromRGB(80,80,90)
        FOVCircle.Visible = true
    end
end

-- ================================
-- INICIALIZACIÓN
-- ================================
LoadSavedData()
CreateGUI()
CreateFOVCircle()
CreateToggleGuiButton()
UpdatePrediction()
ShowWelcomeScreen()

-- ================================
-- RENDER LOOP
-- ================================
local lastTime = tick()
RunService.RenderStepped:Connect(function()
    local now = tick()
    local dt = math.min(0.033, now - lastTime)
    lastTime = now
    
    UpdatePrediction()
    grayPulse = grayPulse + 0.03
    if FOVCircle then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local gray = 80 + math.sin(grayPulse) * 30
        FOVCircle.Color = Color3.fromRGB(gray, gray, gray)
        FOVCircle.Radius = FOVRadius
    end
    
    if VelocitySpooferEnabled and LocalPlayer.Character then
        local root = GetRootPart(LocalPlayer.Character)
        if root then
            local originalVel = root.Velocity
            if VelocitySpooferMode == "Underground" then
                root.Velocity = originalVel + Vector3.new(0, -50, 0)
            elseif VelocitySpooferMode == "Sky" then
                root.Velocity = originalVel + Vector3.new(0, 100, 0)
            elseif VelocitySpooferMode == "Prediction Breaker" then
                root.Velocity = Vector3.new(0, 0, 0)
            elseif VelocitySpooferMode == "Custom" then
                root.Velocity = Vector3.new(VelocitySpooferX, VelocitySpooferY, VelocitySpooferZ)
            end
        end
    end
    
    UpdateCamlock()
    UpdateSilentAim()
    UpdateTargetESP()
    UpdateWalkspeed()
    UpdateRageModes(dt)
    
    if PredictionCircleEnabled then
        local target = nil
        if IndependentSilentEnabled then
            target = GetClosestTargetInFOV()
        elseif CamlockEnabled and CamlockLockedTarget then
            target = CamlockLockedTarget
        elseif SilentEnabled and SilentLockedTarget then
            target = SilentLockedTarget
        end
        
        if target and target.Character then
            local part = GetAimPart(target)
            if part then
                local predictedPos = GetPredictedPosition(target.Character, part)
                local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
                if onScreen then
                    if not PredictionCircle then
                        local success, circle = pcall(function() return Drawing.new("Circle") end)
                        if success and circle then
                            PredictionCircle = circle
                            PredictionCircle.Thickness = 2
                            PredictionCircle.NumSides = 40
                            PredictionCircle.Filled = false
                            PredictionCircle.Color = Color3.fromRGB(255, 255, 255)
                        end
                    end
                    if PredictionCircle then
                        local distance = (Camera.CFrame.Position - predictedPos).Magnitude
                        local radius = math.clamp(200 / (distance + 20), 8, 50)
                        local pulse = 0.5 + math.sin(tick() * 10) * 0.2
                        PredictionCircle.Radius = radius * (0.8 + pulse * 0.4)
                        PredictionCircle.Position = Vector2.new(screenPos.X, screenPos.Y)
                        PredictionCircle.Visible = true
                        local brightness = 200 + math.sin(tick() * 8) * 55
                        PredictionCircle.Color = Color3.fromRGB(brightness, brightness, 255)
                    end
                else
                    if PredictionCircle then PredictionCircle.Visible = false end
                end
            else
                if PredictionCircle then PredictionCircle.Visible = false end
            end
        else
            if PredictionCircle then PredictionCircle.Visible = false end
        end
    else
        if PredictionCircle then PredictionCircle.Visible = false end
    end
    
    local currentTarget = nil
    if IndependentSilentEnabled then
        currentTarget = GetClosestTargetInFOV()
    elseif CamlockEnabled and CamlockLockedTarget then
        currentTarget = CamlockLockedTarget
    elseif SilentEnabled and SilentLockedTarget then
        currentTarget = SilentLockedTarget
    end

    if currentTarget and currentTarget.Character then
        local hum = currentTarget.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            local lastHealth = LastHealth[currentTarget] or hum.Health
            local damageDone = lastHealth - hum.Health

            if damageDone > 0.05 then
                local now = tick()
                local lastGlobal = LastGlobalHitTime or 0
                local lastThis = LastHitTime[currentTarget] or 0

                if (now - lastGlobal) >= 0.45 and (now - lastThis) >= 0.45 then
                    PlayHitSoundAndEffect(currentTarget)
                    LastHitTime[currentTarget] = now
                    LastGlobalHitTime = now
                end
            end

            LastHealth[currentTarget] = hum.Health
        end
    end

    for ply, _ in pairs(LastHealth) do
        if not ply or not ply.Character or not ply.Character:FindFirstChildOfClass("Humanoid") then
            LastHealth[ply] = nil
            LastHitTime[ply] = nil
        end
    end
    
    if AutoAirshotEnabled then
        local target = nil
        if IndependentSilentEnabled then
            target = GetClosestTargetInFOV()
        elseif CamlockEnabled then
            target = CamlockLockedTarget
        elseif SilentEnabled then
            target = SilentLockedTarget
        end
        if target and target.Character then
            local hum = target.Character:FindFirstChildOfClass("Humanoid")
            if hum and IsInAir(hum) then
                if AirStartTime == 0 then AirStartTime = tick() end
                if tick() - AirStartTime >= AirDelay then
                    TryAutoAirshot()
                    AirStartTime = tick()
                end
            else
                AirStartTime = 0
            end
        else
            AirStartTime = 0
        end
    else
        AirStartTime = 0
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    if MacroEnabled then UpdateMacro() end
    if AuraEnabled then ApplyAura(CurrentAuraDesign) end
    if TargetStrafeEnabled then EnableNoclip() end
end)

print("✅ DEX.CC COMPLETO CARGADO")
