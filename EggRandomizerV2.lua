-- GUI Variables
local autoStopOn = true
local espEnabled = true
local autoRandomize = false

-- Create the GUI
local gui = Instance.new("ScreenGui")
gui.Name = "PetRandomizerUI"
gui.ResetOnSpawn = false
gui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 160)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(35, 25, 15)
frame.BorderSizePixel = 0
frame.Parent = gui

-- Title Label
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "✨ Pet Randomizer"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = frame

-- Subtitle (Made by)
local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, 0, 0, 15)
subtitle.Position = UDim2.new(0, 0, 0, 30)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Made by - Zenki"
subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
subtitle.Font = Enum.Font.Gotham
subtitle.TextScaled = true
subtitle.Parent = frame

-- Randomize Pets Button
local randomBtn = Instance.new("TextButton")
randomBtn.Size = UDim2.new(1, -20, 0, 35)
randomBtn.Position = UDim2.new(0, 10, 0, 50)
randomBtn.BackgroundColor3 = Color3.fromRGB(255, 153, 51)
randomBtn.Text = "🎲 Randomize Pets"
randomBtn.TextColor3 = Color3.new(1, 1, 1)
randomBtn.Font = Enum.Font.GothamBold
randomBtn.TextScaled = true
randomBtn.Parent = frame

randomBtn.MouseButton1Click:Connect(function()
    for objectId, data in pairs(displayedEggs) do
        local pet = getNonRepeatingRandomPet(data.eggName, data.lastPet)
        if pet and data.label then
            data.label.Text = data.eggName .. " | " .. pet
            data.lastPet = pet
        end
    end
end)

-- ESP Toggle Button
local espBtn = Instance.new("TextButton")
espBtn.Size = UDim2.new(1, -20, 0, 25)
espBtn.Position = UDim2.new(0, 10, 0, 90)
espBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
espBtn.Text = "👁 ESP: ON"
espBtn.TextColor3 = Color3.new(1, 1, 1)
espBtn.Font = Enum.Font.GothamBold
espBtn.TextScaled = true
espBtn.Parent = frame

espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "👁 ESP: ON" or "👁 ESP: OFF"

    for objectId, data in pairs(displayedEggs) do
        if data.gui then
            data.gui.Enabled = espEnabled
        end
    end
end)

-- Auto Randomize Button
local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(1, -20, 0, 25)
autoBtn.Position = UDim2.new(0, 10, 0, 120)
autoBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
autoBtn.Text = "✅ Auto Randomize: OFF"
autoBtn.TextColor3 = Color3.new(1, 1, 1)
autoBtn.Font = Enum.Font.GothamBold
autoBtn.TextScaled = true
autoBtn.Parent = frame

autoBtn.MouseButton1Click:Connect(function()
    autoRandomize = not autoRandomize
    autoBtn.Text = autoRandomize and "✅ Auto Randomize: ON" or "✅ Auto Randomize: OFF"
end)

-- Background loop to handle auto randomization
task.spawn(function()
    while true do
        if autoRandomize then
            for objectId, data in pairs(displayedEggs) do
                local pet = getNonRepeatingRandomPet(data.eggName, data.lastPet)
                if pet and data.label then
                    data.label.Text = data.eggName .. " | " .. pet
                    data.lastPet = pet
                end
            end
        end
        task.wait(3) -- repeat every 3 seconds
    end
end)
