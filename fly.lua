local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- GUI для мобильного управления
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlightControls"
screenGui.Parent = player.PlayerGui

-- Кнопка включения/выключения полета
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleFlight"
toggleButton.Size = UDim2.new(0.15, 0, 0.1, 0)
toggleButton.Position = UDim2.new(0.8, 0, 0.7, 0)
toggleButton.BackgroundColor3 = Color3.new(0.2, 0.6, 1)
toggleButton.Text = "✈️ Вкл/Выкл"
toggleButton.TextScaled = true
toggleButton.Parent = screenGui

-- Панель управления движением
local controlFrame = Instance.new("Frame")
controlFrame.Name = "FlightPad"
controlFrame.Size = UDim2.new(0.3, 0, 0.3, 0)
controlFrame.Position = UDim2.new(0.1, 0, 0.5, 0)
controlFrame.BackgroundTransparency = 0.7
controlFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
controlFrame.Visible = false
controlFrame.Parent = screenGui

-- Зоны управления
local directions = {
    {Name = "Up", Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(0.3, 0, 0.3, 0)},
    {Name = "Down", Position = UDim2.new(0.5, 0, 0.7, 0), Size = UDim2.new(0.3, 0, 0.3, 0)},
    {Name = "Left", Position = UDim2.new(0, 0, 0.35, 0), Size = UDim2.new(0.3, 0, 0.3, 0)},
    {Name = "Right", Position = UDim2.new(0.7, 0, 0.35, 0), Size = UDim2.new(0.3, 0, 0.3, 0)},
    {Name = "Forward", Position = UDim2.new(0.35, 0, 0.35, 0), Size = UDim2.new(0.3, 0, 0.3, 0)}
}

local touchControls = {}
for _, dir in ipairs(directions) do
    local button = Instance.new("TextButton")
    button.Name = dir.Name
    button.Size = dir.Size
    button.Position = dir.Position
    button.BackgroundTransparency = 0.5
    button.BackgroundColor3 = Color3.new(0.3, 0.7, 1)
    button.Text = dir.Name
    button.TextScaled = true
    button.Parent = controlFrame
    touchControls[dir.Name] = false
end

-- Функция для убийства персонажа
local function killCharacter()
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Health = 0
    end
end

-- Функция активации полета
local function enableFlight()
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
    -- Показываем элементы управления
    controlFrame.Visible = true
    
    -- Создаем физические компоненты
    local bodyGyro = Instance.new("BodyGyro")
    local bodyVelocity = Instance.new("BodyVelocity")
    
    bodyGyro.P = 10000
    bodyGyro.D = 1000
    bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.Parent = rootPart
    
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    bodyVelocity.Parent = rootPart
    
    -- Настройки полета
    local FLY_SPEED = 25
    local flying = true
    
    -- Обработка нажатий на кнопки
    for name, button in pairs(controlFrame:GetChildren()) do
        if button:IsA("TextButton") then
            button.MouseButton1Down:Connect(function()
                touchControls[name] = true
            end)
            
            button.MouseButton1Up:Connect(function()
                touchControls[name] = false
            end)
            
            button.TouchTap:Connect(function()
                touchControls[name] = not touchControls[name]
            end)
        end
    end
    
    -- Кнопка переключения режима
    toggleButton.MouseButton1Click:Connect(function()
        flying = not flying
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    end)
    
    toggleButton.TouchTap:Connect(function()
        flying = not flying
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    end)
    
    -- Обновление движения
    RunService.Heartbeat:Connect(function()
        if not flying then return end
        
        local direction = Vector3.new()
        local camera = workspace.CurrentCamera
        
        -- Определение направления движения
        if touchControls["Forward"] then
            direction = direction + camera.CFrame.LookVector
        end
        if touchControls["Left"] then
            direction = direction - camera.CFrame.RightVector
        end
        if touchControls["Right"] then
            direction = direction + camera.CFrame.RightVector
        end
        if touchControls["Up"] then
            direction = direction + Vector3.new(0, 1, 0)
        end
        if touchControls["Down"] then
            direction = direction + Vector3.new(0, -1, 0)
        end
        
        -- Нормализация и применение скорости
        if direction.Magnitude > 0 then
            direction = direction.Unit * FLY_SPEED
        end
        
        bodyVelocity.Velocity = direction
        bodyGyro.CFrame = camera.CFrame
    end)
    
    -- Визуальные эффекты
    local flightParticles = Instance.new("ParticleEmitter")
    flightParticles.Color = ColorSequence.new(Color3.new(0, 1, 1))
    flightParticles.Size = NumberSequence.new(0.5)
    flightParticles.Acceleration = Vector3.new(0, -5, 0)
    flightParticles.Lifetime = NumberRange.new(0.5)
    flightParticles.Rate = 50
    flightParticles.Speed = NumberRange.new(5)
    flightParticles.Parent = rootPart
    
    -- Отключение гравитации
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
end

-- Основная логика
killCharacter() -- Убиваем текущего персонажа

-- Обработка возрождения
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    character:WaitForChild("Humanoid")
    wait(1) -- Даем время на появление
    enableFlight() -- Активируем полет
end)

-- Автоматическая очистка при выходе
player.CharacterRemoving:Connect(function()
    if screenGui then
        screenGui:Destroy()
    end
end)
