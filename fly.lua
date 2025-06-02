-- ... предыдущий код без изменений ...

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
    
    -- НАСТРОЙКА СКОРОСТИ ИЗМЕНЕНА ЗДЕСЬ: 25 -> 5
    local FLY_SPEED = 5  -- ⭐⭐⭐ Измененная скорость ⭐⭐⭐
    local flying = true
    
    -- ... остальной код без изменений ...
end

-- ... оставшаяся часть кода без изменений ...
