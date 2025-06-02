local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass("Humanoid")

-- Функция уничтожения персонажа
local function killCharacter()
    if humanoid then
        humanoid.Health = 0
    end
end

-- Уничтожаем текущего персонажа
killCharacter()

-- Обработчик для нового персонажа
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    
    -- Немного ждем, чтобы персонаж появился полностью
    wait(1)
    
    -- Активируем полет
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = rootPart
    
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.Parent = rootPart
    
    -- Управление полетом (например, вперед)
    local runService = game:GetService("RunService")
    local flying = true
    
    local connection
    connection = runService.Heartbeat:Connect(function()
        if not flying then
            connection:Disconnect()
            bodyVelocity:Destroy()
            bodyGyro:Destroy()
            return
        end
        -- Просто летим вперед по камере
        local camera = workspace.CurrentCamera
        local direction = camera.CFrame.LookVector
        local speed = 50
        bodyVelocity.Velocity = direction * speed
        bodyGyro.CFrame = camera.CFrame
    end)
end)
