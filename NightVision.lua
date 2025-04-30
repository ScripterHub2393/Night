--// Universal Aimbot Module by Exunys © CC0 1.0 Universal (2023 - 2024)
--// GitHub: https://github.com/Exunys

--// Cache
local game, workspace = game, workspace
local getrawmetatable, getmetatable, setmetatable, pcall, getgenv, next, tick = getrawmetatable, getmetatable, setmetatable, pcall, getgenv, next, tick
local Vector2new, Vector3zero, CFramenew, Color3fromRGB, Color3fromHSV, Drawingnew, TweenInfonew = Vector2.new, Vector3.zero, CFrame.new, Color3.fromRGB, Color3.fromHSV, Drawing.new, TweenInfo.new
local getupvalue, mousemoverel, tablefind, tableremove, stringlower, stringsub, mathclamp = debug.getupvalue, mousemoverel or (Input and Input.MouseMove), table.find, table.remove, string.lower, string.sub, math.clamp

--// Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

--// Variables
local LocalPlayer = Players.LocalPlayer
local FOVCircle = Drawingnew("Circle")
local FOVCircleOutline = Drawingnew("Circle")
local nightVisionEnabled = false
local nightVisionTransparency = 0.7  -- Adjusted transparency for a darker night vision effect (without tint)
local ESPObjects = {}

--// Aimbot Settings (Exunys Aimbot integration)
local aimbotSettings = {
    Enabled = true,
    TeamCheck = false,
    LockPart = "Head",
    TriggerKey = Enum.UserInputType.MouseButton2,
    LockMode = 1,
    Sensitivity = 0,
    Sensitivity2 = 3.5,
}

--// Night Vision ESP Toggle
local ESP_ToggleButton = Instance.new("TextButton")
ESP_ToggleButton.Parent = game.Players.LocalPlayer.PlayerGui
ESP_ToggleButton.Size = UDim2.new(0, 200, 0, 50)
ESP_ToggleButton.Position = UDim2.new(0, 10, 0, 10)
ESP_ToggleButton.Text = "Toggle Night Vision"
ESP_ToggleButton.TextSize = 18
ESP_ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ESP_ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)

--// Function to enable/disable Night Vision
local function toggleNightVision()
    nightVisionEnabled = not nightVisionEnabled
    if nightVisionEnabled then
        ESP_ToggleButton.Text = "Disable Night Vision"
    else
        ESP_ToggleButton.Text = "Enable Night Vision"
    end
end

ESP_ToggleButton.MouseButton1Click:Connect(toggleNightVision)

--// Core Functions for Aimbot and ESP
local function GetClosestPlayer()
    local closestPlayer, minDist = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(aimbotSettings.LockPart) then
            local char = player.Character
            local head = char[aimbotSettings.LockPart]
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            local dist = (Vector2new(screenPos.X, screenPos.Y) - Vector2new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)).Magnitude
            if onScreen and dist < minDist then
                closestPlayer, minDist = player, dist
            end
        end
    end
    return closestPlayer
end

local function AimAtPlayer(player)
    local char = player.Character
    if char and char:FindFirstChild(aimbotSettings.LockPart) then
        local targetPosition = char[aimbotSettings.LockPart].Position
        local direction = (targetPosition - Camera.CFrame.Position).unit
        local newCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPosition)
        Camera.CFrame = newCFrame
    end
end

--// Night Vision ESP
local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)

            if onScreen then
                if not ESPObjects[player] then
                    local espBox = Drawingnew("Line")
                    espBox.From = Vector2new(screenPos.X, screenPos.Y)
                    espBox.To = Vector2new(screenPos.X, screenPos.Y + 10)
                    espBox.Color = nightVisionEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 255, 255)
                    espBox.Transparency = nightVisionEnabled and nightVisionTransparency or 1  -- Transparency for dark effect
                    espBox.Thickness = 2
                    ESPObjects[player] = espBox
                end
            elseif ESPObjects[player] then
                ESPObjects[player]:Remove()
                ESPObjects[player] = nil
            end
        end
    end
end

--// Aimbot and ESP Execution Loop
RunService.RenderStepped:Connect(function()
    if aimbotSettings.Enabled then
        local closestPlayer = GetClosestPlayer()
        if closestPlayer then
            AimAtPlayer(closestPlayer)
        end
    end

    UpdateESP() -- Update the ESP each frame
end)

--// External ESP Integration (Loadstring for External ESP)
loadstring(game:HttpGet("https://raw.githubusercontent.com/wa0101/Roblox-ESP/refs/heads/main/esp.lua", true))()

