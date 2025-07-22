if not (require and getgc and hookmetamethod and hookfunction and getstack and setstack) then
    if messagebox then
        messagebox("Executor Not Supported")
    else
        game:GetService("Players").LocalPlayer:Kick("Executor Not Supported")
    end
end 

local LoadTick = tick()
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local LocalPlayer = Players.LocalPlayer
local CoreGui = cloneref(game:GetService("CoreGui"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Workspace = cloneref(game.Workspace)
local Camera = cloneref(Workspace.Camera)
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Lighting = cloneref(game:GetService("Lighting"))
local PreRender = game:GetService("RunService").PreRender
local Debris = cloneref(game:GetService("Debris"))
local UIS = cloneref(game:GetService("UserInputService"))
local FPSModule = require(ReplicatedStorage.Modules.FPS)

local RayParams = RaycastParams.new()
RayParams.FilterDescendantsInstances = { Camera, Character }
RayParams.CollisionGroup = "WeaponRay"
RayParams.FilterType = Enum.RaycastFilterType.Exclude

local DontDesync = false
local Animator = nil
local Animation = nil
local Track = nil

LocalPlayer.CharacterAdded:Connect(function(v)
    Character = v
    DontDesync = true
    Animator = nil
    task.delay(2, function()
        RayParams.FilterDescendantsInstances = { Camera, Character }
    end)
end)

local library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Crypticpd/scripts/refs/heads/main/uis/main/B%3AD_UI_LIB.lua'))()
local theme_manager = loadstring(game:HttpGet('https://raw.githubusercontent.com/Crypticpd/scripts/refs/heads/main/uis/main/ThemeManager.lua'))()
local save_manager = loadstring(game:HttpGet('https://raw.githubusercontent.com/Crypticpd/scripts/refs/heads/main/uis/main/save.lua'))()

library.Icon = "rbxassetid://107512310306162" 

local Window = library:CreateWindow({
    Title = 'B:D',
    Center = true,
    AutoShow = true,
    TabPadding = 0,
    MenuFadeTime = 0.3
})

local Tabs = {
    MainTab = Window:AddTab('Main'),
    VisualsTab = Window:AddTab('Visuals'),
    LocalTab = Window:AddTab('Local'),
    UI_Settings = Window:AddTab('Settings'),
}

local Variables = {
    AllowPrint = false,
    Silent = {
        Enabled = false,
        Hitchance = 100,
        UndergroundResolver = false,
        HitboxOverrider = false,
        Resolving = false,
        Snapline = false,
        SnaplineOnBarrel = false,
        IncludeAI = false,
        HitPart = "Head",
        Enemy = nil,
    },
    Drawing = {
        Crosshair = {
            Enabled = false,
            Color = Color3.fromRGB(100,0,255),
            Angle = 0,
            Elapsed = 0,
        },
        FovCircleOutline = {
            Object = Drawing.new("Circle"),
        },
        FovCircle = {
            Radius = 100,
            Object = Drawing.new("Circle"),
        },
        SnaplineOutline = { Object = Drawing.new("Line") },
        Snapline = { Object = Drawing.new("Line") },
        Beam = { Color = Color3.fromRGB(100,0,255) },
        TargetInformation = {
            Object = Drawing.new("Text"),
        },
    },
    Hooks = {
        Rapidfire = false,
        NoSpread = false,
        FastHit = false,
        NoJumpCooldown = false,
        NoRecoil = false,
        Tracers = false,
        NoBlock = false,
        FastReload = false,
        FastEquip = false,
        UnlockFireModes = false,  
        InstantADS = false,   
        NoSway = false,
        MeleeMult = 1,
    },
    Player = {
        Spider = false,
        Speedhack = false,
        Speed = 1,
        Levitation = false,
        Spidering = false,
        WalkOnWater = false,
        FloatPart = nil,
    },
    PlayerVisuals = {
        GunChams = false,
        GunColor = Color3.fromRGB(100,0,255),
        GunMaterial = Enum.Material.ForceField,
    },
    Desync = {
        Enabled = false, 
    },
    Hit = {
        HitChams = false,
        HitChamsTime = 5,
        HitChamsColor = Color3.fromRGB(100,0,255),
        Hitlogs = false,
        Hitmarker = false,
        HitmarkerColor = Color3.fromRGB(100,0,255),
    },
    Camera = {
        Enabled = false,
        Zoom = false,
        NoVisor = false,
        NormalAmount = 100,
        ZoomAmount = 15,
        Old = Camera.FieldOfView,
        Thirdperson = {
            Enabled = false,
            Distance = 5,
        },
    },
    KillAura = {
        Enabled = false,
        Notify = false,
        Radius = 8,
        Delay = 0.8,
        HitPart = "Head",
        Type = "PowerAttack",
        LastHit = tick(),
    },
    Lighting = {
        FullBright = false,
    },
    Old = {
        Ambient = Lighting.Ambient,
    },
    ESP = {
        Toggles = {
            IncludeAI = false,
            Box = false,
            Name = false,
            Distance = false,
            Weapon = false,
            Flags = false,
        },
        Registry = {},
    },
}
local RunningBeams = {}
local HitMarkers = {}
local Lines = {}
local Notifications = {}

local SilentAim = Tabs['MainTab']:AddLeftGroupbox("Silent Aim")
SilentAim:AddToggle('silent_enabled', {
    Text = "Enabled",
    Default = false,
    Callback = function(value) 
        Variables.Silent.Enabled = value
    end
})

SilentAim:AddToggle('silent_hitboxoverrider', {
    Text = "Hitbox Overrider",
    Default = false,
    Callback = function(value) 
        Variables.Silent.HitboxOverrider = value
    end
})

SilentAim:AddToggle('silent_resolver', {
    Text = "Underground Resolver",
    Default = false,
    Tooltip = "Works when u shoot",
    Callback = function(value) 
        Variables.Silent.UndergroundResolver = value
    end
}):AddKeyPicker("silent_resolverkey",{Default = "Non", SyncToggleState = true,Mode = "Toggle", Text = "Resolver", NoUI = false})

SilentAim:AddToggle('silent_includeai', {
    Text = "Include AI",
    Default = false,
    Callback = function(value) 
        Variables.Silent.IncludeAI = value
    end
})

SilentAim:AddToggle('silent_fasthit', {
    Text = "Fast Hit",
    Default = false,
    Callback = function(value) 
        Variables.Hooks.FastHit = value
    end
})

SilentAim:AddToggle('silent_fovcircle', {
    Text = "Fov Circle",
    Default = false,
    Callback = function(value) 
        Variables.Drawing.FovCircle.Object.Visible = value
        Variables.Drawing.FovCircleOutline.Object.Visible = value
    end
}):AddColorPicker('fovcircle_color', {
    Default = Color3.fromRGB(100,0,255),
    Callback = function(value) 
        Variables.Drawing.FovCircle.Object.Color = value
    end
})

SilentAim:AddSlider('silent_fovradius', {
    Text = 'Fov Radius',
    Default = 100,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Suffix = "px",
    Callback = function(value)
        Variables.Drawing.FovCircle.Radius = value
    end
})

SilentAim:AddSlider('silent_hitchance', {
    Text = 'Hit Chance',
    Default = 100,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Suffix = "%",
    Callback = function(value)
        Variables.Silent.Hitchance = value
    end
})

SilentAim:AddToggle('silent_snapline', {
    Text = "Snapline",
    Default = false,
    Callback = function(value) 
        Variables.Silent.Snapline = value
    end
}):AddColorPicker('snapline_color', {
    Default = Color3.fromRGB(100,0,255),
    Callback = function(value) 
        Variables.Drawing.Snapline.Object.Color = value
    end
})

SilentAim:AddToggle('silent_snaplinebarrel', {
    Text = "Snapline On Barrel",
    Default = false,
    Callback = function(value) 
        Variables.Silent.SnaplineOnBarrel = value
    end
})

SilentAim:AddToggle('silent_tracers', {
    Text = "Bullet Tracers",
    Default = false,
    Callback = function(value) 
        Variables.Hooks.Tracers = value
    end
}):AddColorPicker('tracers_color', {
    Default = Color3.fromRGB(100,0,255),
    Callback = function(value) 
        Variables.Drawing.Beam.Color = value
    end
})

SilentAim:AddDropdown('silent_hitpart', {
    Values = {"Head","HumanoidRootPart"},
    Default = 1,
    Text = "Hit Bone",
    Callback = function(value) 
        Variables.Silent.HitPart = value 
    end
})

local KillAura = Tabs['MainTab']:AddRightGroupbox("Kill Aura")
KillAura:AddToggle('killaura_enabled', {
    Text = "Enabled",
    Default = false,
    Callback = function(value) 
        Variables.KillAura.Enabled = value
    end
})

KillAura:AddToggle('killaura_notify', {
    Text = "Notify",
    Default = false,
    Callback = function(value) 
        Variables.KillAura.Notify = value
    end
})

KillAura:AddSlider('killaura_delay', {
    Text = 'Delay',
    Default = 0.8,
    Min = 0.8,
    Max = 3,
    Rounding = 1,
    Callback = function(value)
        Variables.KillAura.Delay = value
    end
})

KillAura:AddSlider('killaura_radius', {
    Text = 'Radius',
    Default = 8,
    Min = 0,
    Max = 12,
    Rounding = 0,
    Callback = function(value)
        Variables.KillAura.Radius = value
    end
})

KillAura:AddDropdown('killaura_hitpart', {
    Values = {"Head", "HumanoidRootPart", "FaceHitBox"},
    Default = 1,
    Text = "HitPart",
    Callback = function(value) 
        Variables.KillAura.HitPart = value 
    end
})

KillAura:AddDropdown('killaura_type', {
    Values = {"PowerAttack","NormalAttack"},
    Default = 1,
    Text = "Type",
    Callback = function(value) 
        Variables.KillAura.Type = value 
    end
})

local DesyncTab = Tabs['MainTab']:AddLeftGroupbox("Desync")

DesyncTab:AddToggle('desync_enabled', {
    Text = "Underground",
    Default = false,
    Risky = true,
    Tooltip = "Possible to get detected! also dont crouch",
    Callback = function(value) 
        Variables.Desync.Enabled = value
    end
}):AddKeyPicker("desync_keybind",{Default = "Non", SyncToggleState = true,Mode = "Toggle", Text = "Desync", NoUI = false})

local Hooks = Tabs['LocalTab']:AddLeftGroupbox("Hooks")
Hooks:AddToggle('hooks_rapidfire', {
    Text = "Rapid Fire",
    Default = false,
    Callback = function(value) 
        Variables.Hooks.RapidFire = value
    end
})

Hooks:AddToggle('hooks_unlockfiremodes', {
    Text = "Unlock FireModes",
    Default = false,
    Callback = function(value) 
        Variables.Hooks.UnlockFireModes = value
    end
})

Hooks:AddToggle('hooks_instantads', {
    Text = "Instant ADS",
    Default = false,
    Callback = function(value) 
        Variables.Hooks.InstantADS = value
    end
})

Hooks:AddToggle('hooks_nosway', {
    Text = "No Sway",
    Default = false,
    Callback = function(value) 
        Variables.Hooks.NoSway = value
    end
})

Hooks:AddToggle('hooks_fastreload', {
    Text = "Fast Reload",
    Default = false,
    Callback = function(value) 
        Variables.Hooks.FastReload = value
    end
})

Hooks:AddToggle('hooks_fastequip', {
    Text = "Fast Equip",
    Default = false,
    Callback = function(value) 
        Variables.Hooks.FastEquip = value
    end
})

Hooks:AddToggle('hooks_noblock', {
    Text = "No Block",
    Default = false,
    Callback = function(value) 
        Variables.Hooks.NoBlock = value
    end
})

Hooks:AddToggle('hooks_nospread', {
    Text = "No Spread",
    Default = false,
    Callback = function(value) 
        Variables.Hooks.NoSpread = value
    end
})

Hooks:AddToggle('hooks_nojumpcooldown', {
    Text = "No Jump Cooldown",
    Default = false,
    Callback = function(value) 
        Variables.Hooks.NoJumpCooldown = value
    end
})

Hooks:AddToggle('hooks_norecoil', {
    Text = "No Recoil",
    Default = false,
    Callback = function(value) 
        if Variables.SetRecoil then
            Variables.Hooks.NoRecoil = value
            Variables.SetRecoil(value)
        end
    end
})

Hooks:AddSlider('hooks_meleespeedmult', {
    Text = 'Melee Speed Multiplier',
    Default = 1,
    Min = 1,
    Max = 30,
    Rounding = 0,
    Suffix = "%",
    Callback = function(value)
        Variables.Hooks.MeleeMult = value
    end
})

local PlayerTab = Tabs['LocalTab']:AddRightGroupbox("Player")
PlayerTab:AddToggle('player_spider', {
    Text = "Spider",
    Default = false,
    Callback = function(value) 
        Variables.Player.Spider = value
    end
}):AddKeyPicker("player_spiderkey", {Default = "Non", SyncToggleState = true, Mode = "Toggle", Text = "Spider", NoUI = false})

PlayerTab:AddToggle('player_levitation', {
    Text = "Levitation",
    Default = false,
    Callback = function(value) 
        Variables.Player.Levitation = value
        if Character and Character:FindFirstChild("Humanoid") and not value then
            Character.Humanoid.HipHeight = 2
        end
    end
}):AddKeyPicker("player_levitationkey", {Default = "Non", SyncToggleState = true, Mode = "Toggle", Text = "Levitation", NoUI = false})

PlayerTab:AddToggle('player_instantfall', {
    Text = "Instant Fall",
    Default = false,
    Callback = function(value) 
        Variables.Player.InstantFall = value
    end
})

PlayerTab:AddToggle('player_walkonwater', {
    Text = "Walk On Water",
    Default = false,
    Callback = function(value) 
        Variables.Player.WalkOnWater = value
    end
})

PlayerTab:AddDivider()

PlayerTab:AddToggle('player_speedhack', {
    Text = "Speedhack",
    Default = false,
    Callback = function(value) 
        Variables.Player.Speedhack = value
    end
})

PlayerTab:AddSlider('player_speedhackspeed', {
    Text = 'Speed',
    Default = 1,
    Min = 0,
    Max = 10,
    Rounding = 0,
    Callback = function(value)
        Variables.Player.Speed = value
    end
})

local WorldTab = Tabs['LocalTab']:AddRightGroupbox("World")

WorldTab:AddToggle('world_nograss', {
    Text = "No Grass",
    Default = false,
    Callback = function(value) 
        sethiddenproperty(workspace.Terrain, "Decoration", not value)
    end
})

local LightingTab = Tabs['VisualsTab']:AddRightGroupbox("Lighting")

LightingTab:AddToggle('lighting_fullbright', {
    Text = "Fullbright",
    Default = false,
    Callback = function(value) 
        Variables.Lighting.FullBright = value
    end
})

local ESPTab = Tabs['VisualsTab']:AddLeftGroupbox("ESP")
ESPTab:AddToggle('esp_includeai', {
    Text = "Include AI",
    Default = false,
    Callback = function(value) 
        Variables.ESP.Toggles.IncludeAI = value
    end
})

ESPTab:AddToggle('esp_box', {
    Text = "Box",
    Default = false,
    Callback = function(value) 
        Variables.ESP.Toggles.Box = value
    end
})

ESPTab:AddToggle('esp_distance', {
    Text = "Distance",
    Default = false,
    Callback = function(value) 
        Variables.ESP.Toggles.Distance = value
    end
})

ESPTab:AddToggle('esp_name', {
    Text = "Name",
    Default = false,
    Callback = function(value) 
        Variables.ESP.Toggles.Name = value
    end
})

ESPTab:AddToggle('esp_weapon', {
    Text = "Weapon",
    Default = false,
    Callback = function(value) 
        Variables.ESP.Toggles.Weapon = value
    end
})

ESPTab:AddToggle('esp_flags', {
    Text = "Flags",
    Default = false,
    Callback = function(value) 
        Variables.ESP.Toggles.Flags = value
    end
})

local PlayerVTab = Tabs['VisualsTab']:AddLeftGroupbox("LocalPlayer")
PlayerVTab:AddToggle('localplayer_gunchams', {
    Text = "Gun Chams",
    Default = false,
    Callback = function(value) 
        Variables.PlayerVisuals.GunChams = value
    end
})

PlayerVTab:AddLabel('Gun Color'):AddColorPicker('localplayer_gunchamscolor', {
    Default = Color3.fromRGB(100,0,255),
    Callback = function(value) 
        Variables.PlayerVisuals.GunColor = value
    end
})

PlayerVTab:AddDropdown('localplayer_gunmaterial', {
    Values = {"ForceField","Neon","SmoothPlastic"},
    Default = 1,
    Text = "Gun Material",
    Callback = function(value) 
        Variables.PlayerVisuals.GunMaterial = Enum.Material[value]
    end
})

local CrosshairTab = Tabs['VisualsTab']:AddRightGroupbox("Crosshair")

CrosshairTab:AddToggle('crosshair_enabled', {
    Text = "Enabled",
    Default = false,
    Callback = function(value) 
        Variables.Drawing.Crosshair.Enabled = value
    end
})

CrosshairTab:AddLabel('Color'):AddColorPicker('crosshair_color', {
    Default = Color3.fromRGB(100,0,255),
    Callback = function(value) 
        Variables.Drawing.Crosshair.Color = value
    end
})

local CameraTab = Tabs['VisualsTab']:AddLeftGroupbox("Camera")

CameraTab:AddToggle('camera_enabled', {
    Text = "Enabled",
    Default = false,
    Callback = function(value) 
        Variables.Camera.Enabled = value
    end
}):AddKeyPicker("camera_fovkey", {Default = "Non", SyncToggleState = true, Mode = "Toggle", Text = "Field Of View", NoUI = false})

CameraTab:AddToggle('camera_novisor', {
    Text = "No Visor",
    Default = false,
    Callback = function(value) 
        Variables.Camera.NoVisor = value
    end
})

CameraTab:AddToggle('camera_zoom', {
    Text = "Zoom",
    Default = false,
    Callback = function(value) 
        Variables.Camera.Zoom = value
    end
}):AddKeyPicker("camera_zoomkey", {Default = "Non", SyncToggleState = true, Mode = "Toggle", Text = "Zoom", NoUI = false})

CameraTab:AddDivider()

CameraTab:AddSlider('camera_normalamount', {
    Text = 'FOV Amount',
    Default = 100,
    Min = 30,
    Max = 120,
    Rounding = 0,
    Callback = function(value)
        Variables.Camera.NormalAmount = value
    end
})

CameraTab:AddSlider('camera_zoomamount', {
    Text = 'Zoom Amount',
    Default = 15,
    Min = 5,
    Max = 30,
    Rounding = 0,
    Callback = function(value)
        Variables.Camera.ZoomAmount = value
    end
})
 
CameraTab:AddDivider()

CameraTab:AddToggle('camera_thirdperson', {
    Text = "Third Person",
    Default = false,
    Callback = function(value) 
        Variables.Camera.Thirdperson.Enabled = value
    end
}):AddKeyPicker("camera_thirdpersonkey", {Default = "Non", SyncToggleState = true, Mode = "Toggle", Text = "Third Person", NoUI = false})

CameraTab:AddSlider('camera_thirdpersondistance', {
    Text = 'Distance',
    Default = 5,
    Min = 3,
    Max = 15,
    Rounding = 0,
    Callback = function(value)
        Variables.Camera.Thirdperson.Distance = value
    end
})

local HitTab = Tabs['VisualsTab']:AddRightGroupbox("Hit")

HitTab:AddToggle('hit_logs', {
    Text = "HitLogs",
    Default = false,
    Callback = function(value) 
        Variables.Hit.Hitlogs = value
    end
})

HitTab:AddToggle('hit_marker', {
    Text = "HitMarker",
    Default = false,
    Callback = function(value) 
        Variables.Hit.Hitmarker = value
    end
}):AddColorPicker('hit_markercolor', {
    Default = Color3.fromRGB(100,0,255),
    Callback = function(value) 
        Variables.Hit.HitmarkerColor = value
    end
})

HitTab:AddDivider()

HitTab:AddToggle('hit_chams', {
    Text = "HitChams",
    Default = false,
    Callback = function(value) 
        Variables.Hit.HitChams = value
    end
}):AddColorPicker('hit_chamscolor', {
    Default = Color3.fromRGB(100,0,255),
    Callback = function(value) 
        Variables.Hit.HitChamsColor = value
    end
})

HitTab:AddSlider('hit_chamstime', {
    Text = 'HitChams Time',
    Default = 5,
    Min = 0,
    Max = 10,
    Rounding = 0,
    Callback = function(value)
        Variables.Hit.HitChamsTime = value
    end
})

local FovCircleOutline = Variables.Drawing.FovCircleOutline.Object
FovCircleOutline.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FovCircleOutline.Radius = Variables.Drawing.FovCircle.Radius
FovCircleOutline.Color = Color3.fromRGB(0,0,0)
FovCircleOutline.Transparency = 1
FovCircleOutline.Thickness = 3
FovCircleOutline.Visible = false

local FovCircle = Variables.Drawing.FovCircle.Object
FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FovCircle.Radius = Variables.Drawing.FovCircle.Radius
FovCircle.Color = Color3.fromRGB(100,0,255)
FovCircle.Transparency = 1
FovCircle.Visible = false

local Snapline_Outline = Variables.Drawing.SnaplineOutline.Object
Snapline_Outline.Color = Color3.fromRGB(0,0,0)
Snapline_Outline.Thickness = 3
Snapline_Outline.Visible = false

local Snapline = Variables.Drawing.Snapline.Object
Snapline.Color = Color3.fromRGB(100,0,255)
Snapline.Thickness = 1
Snapline.Visible = false

for i = 1, 4 do
	local Line = Drawing.new("Line")
	Line.Thickness = 2
	Line.Color = Variables.Drawing.Crosshair.Color
	Line.Transparency = 1
	Line.Visible = false
	table.insert(Lines, Line)
end

local function InFov(Character, Middle, Max)
    if Character and Character:FindFirstChild(Variables.Silent.HitPart) then
        local Position, Visible = Camera:WorldToViewportPoint(Character[Variables.Silent.HitPart].Position)
        local Distance = (Vector2.new(Position.X, Position.Y) - Middle).Magnitude

        return Visible and Distance <= Max
    end
    return false
end

local function GetFovStatus()
    local FVariable = Variables.Camera

    if FVariable.Zoom then
        return FVariable.ZoomAmount
    elseif FVariable.Enabled then
        return FVariable.NormalAmount
    end
    
    return FVariable.Old
end

local function GetPlayer()
    local Enemy = nil
    local Closest = math.huge
    local ScreenMiddle = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for i,v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Head") then
            local Position, Visible = Camera:WorldToViewportPoint(v.Character.Head.Position)
            if Visible then
                if not InFov(v.Character, ScreenMiddle, FovCircle.Radius) then
                    continue
                end

                local Distance = (Vector2.new(Position.X, Position.Y) - ScreenMiddle).Magnitude
                if Distance < Closest then
                    Enemy = v.Character
                    Closest = Distance
                end
            end
        end
    end

    if Variables.Silent.IncludeAI then
        for i,v in pairs(workspace.AiZones:GetChildren()) do
            if v:IsA("Folder") then
                for _, v in pairs(v:GetChildren()) do
                    if v and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Head") then
                        local Position, Visible = Camera:WorldToViewportPoint(v.Head.Position)
                        if Visible then
                            if not InFov(v, ScreenMiddle, FovCircle.Radius) then
                                continue
                            end

                            local Distance = (Vector2.new(Position.X, Position.Y) - ScreenMiddle).Magnitude
                            if Distance < Closest then
                                Enemy = v
                                Closest = Distance
                            end
                        end
                    end
                end
            end
        end
    end

    return Enemy
end

local function UpdateNotifications()
    for i,v in Notifications do
        if v.Text then
            v.Text.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 1.6 + (i - 1) * 20)
        end
    end
end

local function Notify(String, Time, Color)
    Time = Time or 5
    Color = Color or Color3.fromRGB(100,0,255)

    local HalfTime = (Time / 2)

    local Text = Drawing.new("Text")
    Text.Outline = true
    Text.Center = true
    Text.Visible = true
    Text.Size = 13
    Text.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 1.6)
    Text.Font = 2
    Text.Text = String
    Text.Color = Color
    Text.Transparency = 1

    table.insert(Notifications, {Text = Text})

    UpdateNotifications()

    task.spawn(function()
        for step = 1, 26 do
			local alpha = step / 26
            Text.Transparency = alpha
			task.wait(HalfTime / 26)
		end
    end)

    task.delay(HalfTime, function()
        for step = 1, 26 do
			local alpha = 1 - (step / 26)
            Text.Transparency = alpha
			task.wait(HalfTime / 26)
		end
    end)

    task.delay(Time, function()
        for i,v in Notifications do
            if v.Text == Text then
                table.remove(Notifications, i)
                break
            end
        end

        if Text then
            Text:Destroy()
        end

        UpdateNotifications()
    end)
end

function Variables.SetRecoil(Value)
    for i,v in pairs(ReplicatedStorage.RangedWeapons:GetDescendants()) do
        if v:IsA("NumberValue") then
            if not v:GetAttribute("Old") then
                v:SetAttribute("Old", v.Value)
            end

            local OldValue = v:GetAttribute("Old")
            v.Value = Value and 0 or OldValue
        end
    end
end

function Variables.Connect(Player)
    Variables.AddRegistry(Player)
    pcall(function()
        Player.CharacterAdded:Connect(function()
            Variables.DeleteRegistry(Player)
            Variables.AddRegistry(Player)
        end)
    end)
end

function Variables.GetFlags(Player)
    local String = ""
    local First = false
    local Flags = {}
    local ReplicatedPlayer

    if ReplicatedStorage.Players:FindFirstChild(Player.Name) then
        ReplicatedPlayer = ReplicatedStorage.Players:FindFirstChild(Player.Name)
    end
    if ReplicatedPlayer and ReplicatedPlayer:FindFirstChild("Status") then
        local Journey = ReplicatedPlayer.Status:FindFirstChild("Journey")
        if Journey then
            local Statistics = Journey.Statistics
            if Statistics then
                local Kills = Statistics:GetAttribute("Kills")
                local Deaths = Statistics:GetAttribute("Deaths")
                local TimePlayed = Statistics:GetAttribute("TimePlayed") / 60
                local KD = Kills / Deaths

                if Kills == 0 or Deaths == 0 then
                    KD = Kills
                end

                local VisibleCheck = workspace:Raycast(Camera.CFrame.p, (Player.HumanoidRootPart.Position - Camera.CFrame.p).Unit * 5000, RayParams)
                if VisibleCheck and VisibleCheck.Instance then
                    if VisibleCheck.Instance:IsDescendantOf(Player) then
                        table.insert(Flags, "Visible")
                    end
                end

                if TimePlayed <= 180 and TimePlayed >= 60 then
                    table.insert(Flags, "Cheater: Suspected")
                elseif TimePlayed <= 60 then
                    table.insert(Flags, "Cheater: True")
                elseif KD >= 6 then
                    table.insert(Flags, "Cheater: Suspected")
                end

                table.insert(Flags, "KD: " .. string.format("%.2f", KD))
            end
        end
    else
        table.insert(Flags, "NPC")
    end

    if Player:FindFirstChild("Humanoid") then
        table.insert(Flags, "Health: " .. math.floor(Player.Humanoid.Health))
    end

    for i,v in Flags do
        if not First then
            First = true
            String = v
        else
            String = String .. "\n" .. v
        end
    end

    return String
end

function Variables.GetTool(Player)
    local ReplicatedPlayer

    if ReplicatedStorage.Players:FindFirstChild(Player.Name) then
        ReplicatedPlayer = ReplicatedStorage.Players:FindFirstChild(Player.Name)
    end
    if ReplicatedPlayer then
        local GameplayVariables = ReplicatedPlayer.Status:FindFirstChild("GameplayVariables")
        if GameplayVariables and GameplayVariables:FindFirstChild("EquippedTool") then
            return tostring(GameplayVariables.EquippedTool.Value) or "None"
        end
    end

    return "None"
end

function Variables.AddRegistry(Player)
    local Cache = {}

    local BoxOutline = Drawing.new("Square")
    BoxOutline.Filled = false
    BoxOutline.Color = Color3.fromRGB(0,0,0)
    BoxOutline.Thickness = 3

    local Box = Drawing.new("Square")
    Box.Filled = false
    Box.Color = Color3.fromRGB(255,255,255)

    local NameText = Drawing.new("Text")
    NameText.Size = 13
    NameText.Outline = true
    NameText.Text = Player.Name
    NameText.Font = 2

    local DistanceText = Drawing.new("Text")
    DistanceText.Size = 13
    DistanceText.Outline = true
    DistanceText.Font = 2

    local WeaponText = Drawing.new("Text")
    WeaponText.Size = 13
    WeaponText.Outline = true
    WeaponText.Font = 2

    local FlagsText = Drawing.new("Text")
    FlagsText.Size = 13
    FlagsText.Outline = true
    FlagsText.Font = 2

    table.insert(Cache, { NameText, Box, BoxOutline, DistanceText, FlagsText, WeaponText })

    function Update()
        local PlayerCharacter
        local IsNPC = false

        local _, Error = pcall(function()
            PlayerCharacter = Player.Character
        end)
        if Error then
            PlayerCharacter = Player
            IsNPC = true
        end

        if PlayerCharacter and PlayerCharacter:FindFirstChild("HumanoidRootPart") then
            local Position, Visible = Camera:WorldToViewportPoint(PlayerCharacter.HumanoidRootPart.Position)
            local Distance
            local Scale = 1 / (Position.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 100
			local Width, Height = math.floor(38 * Scale), math.floor(60 * Scale)

            if Character and Character:FindFirstChild("HumanoidRootPart") then
                Distance = (Character.HumanoidRootPart.Position - PlayerCharacter.HumanoidRootPart.Position).Magnitude * 0.28
            else
                Distance = 0
            end

            Box.Position = Vector2.new(Position.X - Box.Size.X / 2, Position.Y - Box.Size.Y / 2.3)
            Box.Size = Vector2.new(Width, Height)
            Box.Visible = Variables.ESP.Toggles.Box and Visible and (not IsNPC or Variables.ESP.Toggles.IncludeAI)

            BoxOutline.Position = Box.Position
            BoxOutline.Size = Vector2.new(Width, Height)
            BoxOutline.Visible = Variables.ESP.Toggles.Box and Visible and (not IsNPC or Variables.ESP.Toggles.IncludeAI)
            
            NameText.Position = Vector2.new(
                Position.X - NameText.TextBounds.X / 2,
                Box.Position.Y - NameText.TextBounds.Y
            )
            NameText.Visible = Variables.ESP.Toggles.Name and Visible and (not IsNPC or Variables.ESP.Toggles.IncludeAI)

            WeaponText.Position = Vector2.new(
                Position.X - WeaponText.TextBounds.X / 2,
                Box.Position.Y + Box.Size.Y + 16
            )
            WeaponText.Text = Variables.GetTool(PlayerCharacter)
            WeaponText.Visible = Variables.ESP.Toggles.Weapon and Visible and (not IsNPC or Variables.ESP.Toggles.IncludeAI)

            DistanceText.Position = Vector2.new(
                Position.X - DistanceText.TextBounds.X / 2,
                Box.Position.Y + Box.Size.Y + 2
            )
            DistanceText.Text = math.floor(Distance) .. "m"
            DistanceText.Visible = Variables.ESP.Toggles.Distance and Visible and (not IsNPC or Variables.ESP.Toggles.IncludeAI)

            FlagsText.Position = Vector2.new(
                Box.Position.X + Box.Size.X + 4,
                Box.Position.Y
            )
            FlagsText.Text = Variables.GetFlags(PlayerCharacter)
            FlagsText.Visible = Variables.ESP.Toggles.Flags and Visible and (not IsNPC or Variables.ESP.Toggles.IncludeAI)
        else
            NameText.Visible = false
            Box.Visible = false 
            BoxOutline.Visible = false 
            DistanceText.Visible = false
            FlagsText.Visible = false
            WeaponText.Visible = false
        end
    end

    Variables.ESP.Registry[Player] = {
        Drawing = Cache,
        Player = Player,
        Update = Update,
    }
end

function Variables.DeleteRegistry(Player)
    if Variables.ESP.Registry[Player] then
        for i,v in Variables.ESP.Registry[Player].Drawing do
            for _,DrawingObject in v do
                DrawingObject:Destroy()
            end
        end
        Variables.ESP.Registry[Player] = nil
    end
end

local function CreateHitMarker(MarkerPosition)
    local Marker = {}
    Marker.Position = MarkerPosition
    Marker.StartTime = tick()

    local Line1 = Drawing.new("Line")
    local Line2 = Drawing.new("Line")
    local Line3 = Drawing.new("Line")
    local Line4 = Drawing.new("Line")

    for i,v in ipairs({Line1, Line2, Line3, Line4}) do
        v.Visible = true
        v.Color = Variables.Hit.HitmarkerColor
        v.Thickness = 1
        v.Transparency = 1
    end

    task.spawn(function()
        for i,v in ipairs({Line1, Line2, Line3, Line4}) do
            for Step = 1, 26 do
                local Alpha = Step / 26
                v.Transparency = Alpha
                task.wait(1 / 26)
            end
        end
    end)

    task.delay(1, function()
        for i,v in ipairs({Line1, Line2, Line3, Line4}) do
            for Step = 1, 26 do
                local Alpha = 1 - (Step / 26)
                v.Transparency = Alpha
                task.wait(1 / 26)
            end
        end
    end)


    Marker.Lines = {Line1, Line2, Line3, Line4}

    table.insert(HitMarkers, Marker)
end

local function IsAlive(Character)
    if Character and Character:FindFirstChild("Humanoid") then
        if Character.Humanoid.Health > 0.1 then
            return true
        end
    end
    return false
end

local function LoopChange(Model, Color, Material)
    for i,v in Model:GetDescendants() do
        if v:IsA("BasePart") then
            if Color then
                v.Color = Color
            end
            if Material then
                v.Material = Material
            end
        end
        if v:IsA("SurfaceAppearance") then
            v:Destroy()
        end
    end
end

local function GetBarrel()
    if Camera:FindFirstChild("ViewModel") and Camera.ViewModel:FindFirstChild("Item") then
        local Item = Camera.ViewModel.Item
        local Extra = 1.5
        if Item:FindFirstChild("Barrel") then
            return Item.Barrel.Position + Item.Barrel.CFrame.LookVector * Extra
        elseif Item:FindFirstChild("Attachments") and Item.Attachments:FindFirstChild("Front") then
            return Item.Attachments.Front.Position + Item.Attachments.Front.CFrame.LookVector * Extra
        else
            return Camera.CFrame.Position + Camera.CFrame.LookVector * Extra
        end
    end
    return nil
end

local function CreateChatMessage(String)
    game:GetService("TextChatService").TextChannels.RBXGeneral:DisplaySystemMessage(String)
end

local function CloneCharacter(Character)
    for i,v in Character:GetChildren() do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            coroutine.wrap(function()
                local Part = Instance.new("Part")
                Part.Anchored = true
                Part.Size = v.Size
                Part.Name = tostring(math.random())
                Part.Material = Enum.Material.Neon
                Part.CanCollide = false
                Part.CanQuery = false
                Part.CanTouch = false
                Part.CFrame = v.CFrame
                Part.Color = Variables.Hit.HitChamsColor
                Part.Parent = workspace.Terrain

                spawn(function()
                    for Step = 1, 26 do
                        local Alpha = Step / 26
                        Part.Transparency = Alpha
                        task.wait(Variables.Hit.HitChamsTime / 26)
                    end
                    Part:Destroy()
                end)
            end)()
        end
    end
end

local Bullet = require(game:GetService("ReplicatedStorage").Modules.FPS.Bullet)
local OldBullet = Bullet.CreateBullet
Bullet.CreateBullet = function(...)
    local Args = {...}

    if Variables.Silent.UndergroundResolver and not Variables.Silent.Resolving then
        Variables.Silent.Resolving = true
        task.spawn(function()
            local OldCFrame = Character.HumanoidRootPart.CFrame
            
            Character.HumanoidRootPart.Velocity = Vector3.new(0,-2000,0)
            
            task.wait(0.05)

            Character.HumanoidRootPart.Anchored = true
            Character.HumanoidRootPart.CFrame = OldCFrame - Vector3.new(0,16,0)

            task.wait(0.5)

            Character.HumanoidRootPart.Anchored = false
            Character.HumanoidRootPart.Velocity = Vector3.zero
            Variables.Silent.Resolving = false
        end)
    end

    local Origin = Args[5]
    if Variables.Silent.Enabled and Variables.Silent.Enemy and Variables.Silent.Enemy and math.random(1,100) <= Variables.Silent.Hitchance and not Variables.Hooks.FastHit then
        local Target = Variables.Silent.Enemy:FindFirstChild(Variables.Silent.HitPart)
        if Target then
            Origin.CFrame = CFrame.new(Origin.Position, Target.Position)
        end
    end

    if Variables.Hooks.Tracers and Camera:FindFirstChild("ViewModel") and Camera.ViewModel:FindFirstChild("Item") then
        local Barrel = GetBarrel()
        if Barrel then
            local Result = Workspace:Raycast(Origin.Position, Origin.CFrame.LookVector * 5000, RayParams)

            if Result and Result.Position then
                local Dir
                if Variables.Hooks.FastHit and Variables.Silent.Enabled and Variables.Silent.Enemy and Variables.Silent.Enemy[Variables.Silent.HitPart] then
                    Dir = Variables.Silent.Enemy[Variables.Silent.HitPart].Position
                else
                    Dir = Result.Position
                end

                local A0 = Instance.new("Attachment")
                A0.WorldPosition = Barrel
                A0.Name = "AT0"
                A0.Parent = Workspace.Terrain

                local A1 = Instance.new("Attachment")
                A1.WorldPosition = Dir
                A1.Name = "AT1"
                A1.Parent = Workspace.Terrain

                local Beam = Instance.new("Beam")
                Beam.Attachment0 = A0
                Beam.Attachment1 = A1
                Beam.Width0 = 0.3
                Beam.Width1 = 0.3
                Beam.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Variables.Drawing.Beam.Color),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
                }
                Beam.LightEmission = 1
                Beam.Transparency = NumberSequence.new(1)
                Beam.FaceCamera = true
                Beam.Segments = 2
                Beam.Parent = Workspace

                local LifeTime = 2

                Debris:AddItem(Beam, LifeTime)
                Debris:AddItem(A0, LifeTime)
                Debris:AddItem(A1, LifeTime)

                table.insert(RunningBeams, {
                    Beam = Beam,
                    A0 = A0,
                    A1 = A1,
                    StartTime = tick(),
                    LifeTime = LifeTime,
                })
            end
        end
    end
    
    return OldBullet(unpack(Args))
end

local FPS = require(game:GetService("ReplicatedStorage").Modules.FPS)
local OldClient = FPS.updateClient
FPS.updateClient = function(...)
    local Args = {...}

    if typeof(Args[1]) == "table" then
        if Variables.Hooks.NoRecoil then
            Args[1].springs.cameraRecoil.Force = 0
            Args[1].springs.cameraRecoil.Speed = 0
            Args[1].springs.recoilRot.Force = 0
            Args[1].springs.recoilRot.Speed = 0
        end
        if Variables.Hooks.NoSway then
            Args[1].springs.sway.Position = Vector3.zero
            Args[1].springs.sway.Speed = 0
            Args[1].swayMult = 0
        end
        if Variables.Hooks.NoBlock then
            Args[1].springs.wallTouchTilt.Speed = 0
            Args[1].springs.wallTouchTilt.Force = 0
        end
        if Variables.Hooks.InstantADS then
            Args[1].AimInSpeed = 0
            Args[1].AimOutSpeed = 0
        end
        if Variables.Hooks.UnlockFireModes then
            Args[1].FireModes = { "Auto", "Semi" }
        end
        if Variables.Hooks.RapidFire then
            Args[1].FireRate = 0.001
        end
    end

    return OldClient(unpack(Args))
end

Camera.ChildAdded:Connect(function(f)
    if f.Name == "ViewModel" and f:FindFirstChild("Humanoid") then
        local Humanoid = f.Humanoid
        Humanoid.Animator.AnimationPlayed:Connect(function(Animation)
            if string.find(Animation.Name, "Reload") and Variables.Hooks.FastReload then 
                Animation:AdjustSpeed(5)
            elseif string.find(Animation.Name, "Equip") and Variables.Hooks.FastEquip then
                Animation:AdjustSpeed(9e9)
            elseif (Animation.Name == "Use" or Animation.Name == "UseAlt" or Animation.Name == "Stab") then
                Animation:AdjustSpeed(1 * Variables.Hooks.MeleeMult)
            end
        end)
    end
end)

local MetaMethod
MetaMethod = hookmetamethod(game, "__namecall", newcclosure(function(self,...)
    local Method = getnamecallmethod()
    local Args = {...}

    if not checkcaller() then
        if Method == "GetAttribute" and Args[1] == "AccuracyDeviation" and Variables.Hooks.NoSpread then 
            return 0
        end

        if Method == "GetAttribute" and Args[1] == "BlockADS" and Variables.Hooks.NoBlock then
            return false
        end

        if Method == "InvokeServer" and self.Name == "Reload" and Variables.Hooks.FastReload then 
            if Args[2] then
                Args[1] = nil
                Args[2] = 0/0
                Args[3] = nil
            end
            return MetaMethod(self,unpack(Args))
        end

        if Method == "FireServer" and self.Name == "ProjectileInflict" then
            if Args[1] == Character.PrimaryPart then 
                return task.wait(9e9)
            end
            if Variables.Hooks.FastHit then
                Args[4] = 0/0
                return MetaMethod(self,unpack(Args))
            end
        end

        if Method == "Raycast" and Variables.Hooks.FastHit and Variables.Silent.Enabled and string.find(debug.getinfo(3).short_src, "Bullet") then
            if self == workspace and Variables.Silent.Enemy and math.random(1,100) <= Variables.Silent.Hitchance then
                Args[2] = (Variables.Silent.Enemy[Variables.Silent.HitPart].Position - Args[1]).Unit * 5000
                return MetaMethod(self, unpack(Args))
            end
        end
    end

    return MetaMethod(self,...)
end))

local OldRandom
OldRandom = hookfunction(math.random, function(...)
    local Args = {...}

    if Variables.Hooks.NoRecoil and (Args[1] == -5 and Args[2] == 5) or (Args[1] == 5 and Args[2] == 10) then
        return 0
    end

    return OldRandom(unpack(Args))
end)

local OldTick
OldTick = hookfunction(tick, function(Number)
    local L = debug.info(3,"l")
    local Info = debug.info(debug.info(3,"f"), "l")
    if Info == 521 and L == 678 then
        if typeof(getstack(3, 13)) == "Instance" and getstack(3, 13).Name == "ProjectileInflict" then
            if Variables.Hit.HitboxOverrider then 
                setstack(3,4, getstack(3, 4).Parent.Head)
                setstack(3,15, getstack(3, 15).Parent.Head)
            end

            local HitPosition = getstack(3, 5)
            local HitPart = getstack(3, 4).Name
            local PlayerName = getstack(3, 10).Name

            if Variables.Hit.Hitlogs then
                Notify("Hit " .. PlayerName .. " On " .. HitPart, 3, Color3.fromRGB(100,0,255))
            end

            if Variables.Hit.HitChams then 
                CloneCharacter(getstack(3, 4).Parent)
            end

            if Variables.Hit.Hitmarker then
                CreateHitMarker(HitPosition)
            end
        end
    end
    return OldTick(Number)
end)

Camera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
    if (Variables.Camera.Zoom or Variables.Camera.Enabled) then
        Camera.FieldOfView = GetFovStatus()
    end
end)

for i,v in Players:GetPlayers() do
    if v ~= LocalPlayer then
        Variables.Connect(v)
    end
end

Players.PlayerAdded:Connect(function(Player)
    Variables.Connect(Player)
end)

Players.PlayerRemoving:Connect(function(Player)
    Variables.DeleteRegistry(Player)
end)

for i,v in pairs(workspace.AiZones:GetChildren()) do
    if v:IsA("Folder") then
        for _, v in pairs(v:GetChildren()) do
            if v and v:FindFirstChild("Humanoid") and v:FindFirstChild("Head") then
                v:SetAttribute("ESP", true)
                Variables.Connect(v)
            end
        end
    end
end

workspace.AiZones.DescendantRemoving:Connect(function(v)
    if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("Head") then
        Variables.DeleteRegistry(v)
    end
end)

task.spawn(function()
    while task.wait(3) do
        if Variables.ESP.Toggles.IncludeAI then
            for i,v in pairs(workspace.AiZones:GetChildren()) do
                if v:IsA("Folder") then
                    for _, v in pairs(v:GetChildren()) do
                        if v and v:FindFirstChild("Humanoid") and v:FindFirstChild("Head") and not v:GetAttribute("ESP") then
                            v:SetAttribute("ESP", true)
                            Variables.Connect(v)
                        end
                    end
                end
            end
        end
    end
end)

local First = true
RunService.Heartbeat:Connect(function()
    if (DontDesync or First) and Character and Character:FindFirstChild("Humanoid") and not Animator then
        First = false
        if Animation then
            Animation = nil
        end
        if Track then
            Track = nil
        end

        if Variables.AllowPrint then
            print("[DEBUG] Reloaded Animation")
        end

        Animator = Character.Humanoid:FindFirstChild("Animator") or Instance.new("Animator", Character.Humanoid)

        Animation = Instance.new("Animation")
        Animation.AnimationId = "rbxassetid://18524313628"

        Track = Animator:LoadAnimation(Animation)
        Track.Looped = true
        Track:Play()
        Track:AdjustSpeed(0)

        DontDesync = false
    end

    if Variables.Desync.Enabled and Character and Character:FindFirstChild("HumanoidRootPart") and IsAlive(Character) and Animator and Animation and Track and not DontDesync then
        if not Track.IsPlaying then
            Track:Play()
        end

        local OldPosition = Character.HumanoidRootPart.CFrame

        Character.HumanoidRootPart.CFrame -= Vector3.new(0,2.4,0)
        Character.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame * CFrame.Angles(math.rad(-71.5),0,0)

        RunService.RenderStepped:Wait()

        Character.HumanoidRootPart.CFrame = OldPosition

        Track.TimePosition = 9

        if Variables.Camera.Thirdperson.Enabled then
            Camera.CFrame += Vector3.new(0,4,0)
        else
            Camera.CFrame += Vector3.new(0,2.7,0)
        end
    elseif Character and Character:FindFirstChild("HumanoidRootPart") and Animator and Animation and Track and not Variables.Desync.Enabled and not DontDesync then
        if Track.IsPlaying then
            Track:Stop()
        end
    end
end)

PreRender:Connect(function(Delta)
    Lighting.Ambient = Variables.Lighting.FullBright and Color3.fromRGB(255,255,255) or Variables.Old.Ambient
    if Character and Character:FindFirstChild("HumanoidRootPart") and Character:FindFirstChild("Humanoid") then
        if Variables.Player.Levitation and not Variables.Desync.Enabled then
            Character.Humanoid.HipHeight = 5
        end
        if Variables.Player.WalkOnWater then
            local RC = workspace:Raycast(Character.HumanoidRootPart.Position - Vector3.new(0,2,0), -Character.HumanoidRootPart.CFrame.UpVector * 10, RayParams)
            if RC and RC.Material == Enum.Material.Water then
                if not Variables.Player.FloatPart then
                    Variables.Player.FloatPart = Instance.new("Part")
                    Variables.Player.FloatPart.Anchored = true
                    Variables.Player.FloatPart.Transparency = 1
                    Variables.Player.FloatPart.Material = Enum.Material.Air
                    Variables.Player.FloatPart.Name = "FloatPart"
                    Variables.Player.FloatPart.Size = Vector3.new(15,0.3,15)
                    Variables.Player.FloatPart.Parent = workspace
                end

                Variables.Player.FloatPart.CFrame = CFrame.new(RC.Position)
            end
        else
            Variables.Player.FloatPart = nil
            if Variables.Player.FloatPart then
                Variables.Player.FloatPart:Destroy()
            end
        end

        if Variables.Player.Speedhack and Character.Humanoid.MoveDirection.Magnitude ~= 0 then
            local HRP = Character.HumanoidRootPart
            HRP.CFrame += Character.Humanoid.MoveDirection / 100 * Variables.Player.Speed
        end

        if Variables.PlayerVisuals.GunChams then
            if Camera:FindFirstChild("ViewModel") and Camera.ViewModel:FindFirstChild("Item") then
                LoopChange(Camera.ViewModel.Item, Variables.PlayerVisuals.GunColor, Variables.PlayerVisuals.GunMaterial)
            end
        end

        if Variables.Player.Spider and not Variables.Desync.Enabled then
            local RC = workspace:Raycast(Character.HumanoidRootPart.Position - Vector3.new(0,2,0), Character.HumanoidRootPart.CFrame.LookVector * 2, RayParams)
            if RC and RC.Instance then
                Variables.Player.Spidering = true
                Character.HumanoidRootPart.CFrame += Vector3.new(0,0.5,0)
            else
                Variables.Player.Spidering = false
            end
        else
            Variables.Player.Spidering = false
        end

        if Variables.Player.InstantFall and not Variables.Desync.Enabled and not Variables.Player.Spidering then
            local RC = workspace:Raycast(Character.HumanoidRootPart.Position - Vector3.new(0,2,0), -Character.HumanoidRootPart.CFrame.UpVector * 10, RayParams)
            if not RC then
                local DR = workspace:Raycast(Character.HumanoidRootPart.Position, -Character.HumanoidRootPart.CFrame.UpVector * 100, RayParams)
                if DR and DR.Instance then
                    Character.HumanoidRootPart.CFrame = CFrame.new(DR.Position + Vector3.new(0,2,0))
                end
            end
        end

        for i,v in Variables.ESP.Registry do
            local UpdateFunction = v.Update
            if UpdateFunction then
                UpdateFunction()
            end
        end

        LocalPlayer.CameraMode = Variables.Camera.Thirdperson.Enabled and Enum.CameraMode.Classic or Enum.CameraMode.LockFirstPerson
        LocalPlayer.CameraMinZoomDistance = Variables.Camera.Thirdperson.Distance
        LocalPlayer.CameraMaxZoomDistance = Variables.Camera.Thirdperson.Distance
        UIS.MouseBehavior = "LockCenter"

        local CurrentTick = tick()

        for i = #HitMarkers, 1, -1 do
            local Marker = HitMarkers[i]
            local Position, Visible = Camera:WorldToViewportPoint(Marker.Position)

            if Visible then
                local x, y = Position.X, Position.Y

                local Lines = Marker.Lines

                Lines[1].From = Vector2.new(x - 10, y - 10)
                Lines[1].To = Vector2.new(x - 4, y - 4)

                Lines[2].From = Vector2.new(x + 10, y + 10)
                Lines[2].To = Vector2.new(x + 4, y + 4)

                Lines[3].From = Vector2.new(x + 10, y - 10)
                Lines[3].To = Vector2.new(x + 4, y - 4)

                Lines[4].From = Vector2.new(x - 10, y + 10)
                Lines[4].To = Vector2.new(x - 4, y + 4)

                for i,v in ipairs(Lines) do
                    v.Visible = true
                end
            else
                for i,v in ipairs(Marker.Lines) do
                    v.Visible = false
                end
            end

            if CurrentTick - Marker.StartTime > 2 then
                for i,v in ipairs(Marker.Lines) do
                    v.Visible = false
                    v:Remove()
                end
                table.remove(HitMarkers, i)
            end
        end

        if (Variables.Camera.Zoom or Variables.Camera.Enabled) then
            Camera.FieldOfView = GetFovStatus()
        end

        LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.Visible = not Variables.Camera.NoVisor

        local CX = Camera.ViewportSize.X / 2
	    local CY = Camera.ViewportSize.Y / 2

        Variables.Drawing.Crosshair.Elapsed += Delta
        Variables.Drawing.Crosshair.Angle += 90 * Delta

        local Offset = math.sin(Variables.Drawing.Crosshair.Elapsed * math.pi * 1) * 4
        local Gap = 6 + Offset
        local Length = 10 + Offset

        local Rad = math.rad(Variables.Drawing.Crosshair.Angle)

        for i = 0, 3 do
            local OA = Rad + math.rad(i * 90)
            local SX = math.cos(OA) * Gap
            local SY = math.sin(OA) * Gap
            local EX = math.cos(OA) * (Gap + Length)
            local EY = math.sin(OA) * (Gap + Length)

            local Line = Lines[i + 1]
            Line.From = Vector2.new(CX + SX,CY + SY)
            Line.To = Vector2.new(CX + EX,CY + EY)
            Line.Color = Variables.Drawing.Crosshair.Color
            Line.Visible = Variables.Drawing.Crosshair.Enabled
        end

        FovCircle.Radius = Variables.Drawing.FovCircle.Radius
        FovCircleOutline.Radius = Variables.Drawing.FovCircle.Radius

        if Variables.KillAura.Enabled and Character and Character:FindFirstChild("HumanoidRootPart") then
            local DistanceFromTick = tick() - Variables.KillAura.LastHit
            if DistanceFromTick >= Variables.KillAura.Delay then
                for i,v in pairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Variables.KillAura.HitPart) then
                        local Distance = (Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                        if Distance <= Variables.KillAura.Radius then
                            ReplicatedStorage.Remotes.MeleeReplicate:FireServer(
                                v.Character[Variables.KillAura.HitPart],
                                v.Character[Variables.KillAura.HitPart].Position,
                                v.Character[Variables.KillAura.HitPart].Position
                            )

                            ReplicatedStorage.Remotes.MeleeInflict:FireServer(
                                v.Character,
                                v.Character[Variables.KillAura.HitPart],
                                Variables.KillAura.Type
                            )

                            if Variables.KillAura.Notify then
                                library:Notify("Hit " .. v.Name, 1.5)
                            end

                            Variables.KillAura.LastHit = tick()
                        end
                    end
                end
            end
        end

        Variables.Silent.Enemy = GetPlayer()

        if Variables.Silent.Snapline and Variables.Silent.Enemy and Variables.Silent.Enemy:FindFirstChild("Head") then
            local Barrel = GetBarrel()
            if Barrel and Variables.Silent.SnaplineOnBarrel then
                local Position, Visible = Camera:WorldToViewportPoint(Variables.Silent.Enemy.Head.Position)
                local ScreenBarrel = Camera:WorldToViewportPoint(Barrel)
                if Visible then
                    Snapline.Visible = true
                    Snapline.From = Vector2.new(ScreenBarrel.X, ScreenBarrel.Y)
                    Snapline.To = Vector2.new(Position.X, Position.Y)

                    Snapline_Outline.Visible = true
                    Snapline_Outline.From = Vector2.new(ScreenBarrel.X, ScreenBarrel.Y)
                    Snapline_Outline.To = Vector2.new(Position.X, Position.Y)
                else
                    Snapline.Visible = false
                    Snapline_Outline.Visible = false
                end
            else
                local Position, Visible = Camera:WorldToViewportPoint(Variables.Silent.Enemy.Head.Position)
                if Visible then
                    Snapline.Visible = true
                    Snapline.From = UIS:GetMouseLocation()
                    Snapline.To = Vector2.new(Position.X, Position.Y)

                    Snapline_Outline.Visible = true
                    Snapline_Outline.From = UIS:GetMouseLocation()
                    Snapline_Outline.To = Vector2.new(Position.X, Position.Y)
                else
                    Snapline.Visible = false
                    Snapline_Outline.Visible = false
                end
            end
        else
            Snapline.Visible = false
            Snapline_Outline.Visible = false
        end

        if Character and Character:FindFirstChild("Humanoid") and Variables.Hooks.NoJumpCooldown then
            Character.Humanoid:SetAttribute("JumpCooldown", 0)
        end

        for i = #RunningBeams, 1, -1 do
            local Data = RunningBeams[i]
            local Elapsed = tick() - Data.StartTime
            local Fade = math.clamp(Elapsed / Data.LifeTime, 0, 1)

            if Data.Beam then
                Data.Beam.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, Fade),
                    NumberSequenceKeypoint.new(1, Fade)
                })
            end

            if Fade >= 1 then
                if Data.Beam then Data.Beam:Destroy() end
                if Data.A0 then Data.A0:Destroy() end
                if Data.A1 then Data.A1:Destroy() end
                table.remove(RunningBeams, i)
            end
        end
    end
end)

library:SetWatermarkVisibility(true)

library:SetWatermark(' B:D ')

library.KeybindFrame.Visible = false

library:OnUnload(function()
    library.Unloaded = true
end)

local menu_group = Tabs.UI_Settings:AddRightGroupbox('Menu')
menu_group:AddButton('Unload', function() library:Unload() end)
menu_group:AddLabel('Menu bind'):AddKeyPicker('menu_keybind', {
    Default = 'RightShift',
    NoUI = true,
    Text = 'Menu keybind'
})
menu_group:AddToggle('showkeybinds', {
    Text = "Show Keybinds",
    Default = false,
    Callback = function(value)
        library.KeybindFrame.Visible = value
    end
})

library.ToggleKeybind = Options.menu_keybind

theme_manager:SetLibrary(library)
save_manager:SetLibrary(library)
save_manager:IgnoreThemeSettings()
save_manager:SetIgnoreIndexes({ 'menu_keybind' })
theme_manager:SetFolder('B:D')
save_manager:SetFolder('B:D/ProjectDelta')
save_manager:BuildConfigSection(Tabs.UI_Settings)
theme_manager:ApplyToTab(Tabs.UI_Settings)
save_manager:LoadAutoloadConfig()

CreateChatMessage("[B:D] Loaded in " .. (tick() - LoadTick) .. " Seconds")
