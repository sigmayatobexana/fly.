local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

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
    
    -- Создаем физические компоненты для полета
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
    local FLY_SPEED = 50
    local flying = true
    
    -- Управление полетом
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Space then
            flying = not flying
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end)
    
    -- Обновление движения
    game:GetService("RunService").Heartbeat:Connect(function()
        if not flying then return end
        
        local direction = Vector3.new()
        
        -- Определение направления движения
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction = direction + rootPart.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction = direction - rootPart.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction = direction + rootPart.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction = direction - rootPart.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then
            direction = direction + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            direction = direction + Vector3.new(0, -1, 0)
        end
        
        -- Нормализация и применение скорости
        if direction.Magnitude > 0 then
            direction = direction.Unit * FLY_SPEED
        end
        
        bodyVelocity.Velocity = direction
        bodyGyro.CFrame = rootPart.CFrame
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

-- Основная логика скрипта
killCharacter() -- Убиваем текущего персонажа

-- Ожидаем возрождения
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    character:WaitForChild("Humanoid")
    wait(1) -- Даем время на появление персонажа
    enableFlight() -- Активируем полет
end)
