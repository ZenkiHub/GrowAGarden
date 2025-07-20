-// Services and Player
local players = game:GetService("Players")
local collectionService = game:GetService("CollectionService")
local localPlayer = players.LocalPlayer or players:GetPlayers()[1]

--// Pet Chance Table
local eggChances = {
    ["Common Egg"] = {["Dog"] = 33, ["Bunny"] = 33, ["Golden Lab"] = 33},
    ["Uncommon Egg"] = {["Black Bunny"] = 25, ["Chicken"] = 25, ["Cat"] = 25, ["Deer"] = 25},
    ["Rare Egg"] = {["Orange Tabby"] = 33.33, ["Spotted Deer"] = 25, ["Pig"] = 16.67, ["Rooster"] = 16.67, ["Monkey"] = 8.33},
    ["Legendary Egg"] = {["Cow"] = 42.55, ["Silver Monkey"] = 42.55, ["Sea Otter"] = 10.64, ["Turtle"] = 2.13, ["Polar Bear"] = 2.13},
    ["Mythic Egg"] = {["Grey Mouse"] = 37.5, ["Brown Mouse"] = 26.79, ["Squirrel"] = 26.79, ["Red Giant Ant"] = 8.93, ["Red Fox"] = 0},
    ["Bug Egg"] = {["Snail"] = 40, ["Giant Ant"] = 35, ["Caterpillar"] = 25, ["Praying Mantis"] = 0, ["Dragon Fly"] = 0},
    ["Night Egg"] = {["Hedgehog"] = 47, ["Mole"] = 23.5, ["Frog"] = 21.16, ["Echo Frog"] = 8.35, ["Night Owl"] = 0, ["Raccoon"] = 0},
    ["Bee Egg"] = {["Bee"] = 65, ["Honey Bee"] = 20, ["Bear Bee"] = 10, ["Petal Bee"] = 5, ["Queen Bee"] = 0},
    ["Anti Bee Egg"] = {["Wasp"] = 55, ["Tarantula Hawk"] = 31, ["Moth"] = 14, ["Butterfly"] = 0, ["Disco Bee"] = 0},
    ["Common Summer Egg"] = {["Starfish"] = 50, ["Seafull"] = 25, ["Crab"] = 25},
    ["Rare Summe Egg"] = {["Flamingo"] = 30, ["Toucan"] = 25, ["Sea Turtle"] = 20, ["Orangutan"] = 15, ["Seal"] = 10},
    ["Paradise Egg"] = {["Ostrich"] = 43, ["Peacock"] = 33, ["Capybara"] = 24, ["Scarlet Macaw"] = 3, ["Mimic Octopus"] = 1},
    ["Premium Nighrt Egg"] = {["Hedgehog"] = 50, ["Mole"] = 26, ["Frog"] = 14, ["Echo Frog"] = 10},
    ["Dinosaur Egg"] = {["Raptor"] = 33, ["Triceratops"] = 33, ["T-Rex"] = 1, ["Stegosaurus"] = 33, ["Pterodactyl"] = 33, ["Brontosaurus"] = 33}
}

local realESP = {
    ["Common Egg"] = true, ["Uncommon Egg"] = true, ["Rare Egg"] = true,
    ["Common Summer Egg"] = true, ["Rare Summer Egg"] = true
}

local displayedEggs = {}
local autoRandomizeOn = true
local espOn = true

--// Utility Functions
local function weightedRandom(options)
    local valid = {}
    for pet, chance in pairs(options) do
        if chance > 0 then table.insert(valid, {pet = pet, chance = chance}) end
    end
    if #valid == 0 then return nil end
    local total = 0
    for _, v in ipairs(valid) do total += v.chance end
    local roll = math.random() * total
    local cumulative = 0
    for _, v in ipairs(valid) do
        cumulative += v.chance
        if roll <= cumulative then return v.pet end
    end
    return valid[1].pet
end

local function getNonRepeatingRandomPet(eggName, lastPet)
    local pool = eggChances[eggName]
    if not pool then return nil end
    local tries, selectedPet = 0, lastPet
    while tries < 5 do
        local pet = weightedRandom(pool)
        if not pet then return nil end
        if pet ~= lastPet or math.random() < 0.3 then
            selectedPet = pet
            break
        end
        tries += 1
    end
    return selectedPet
end

--// ESP Drawing
local function createEspGui(object, labelText)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "FakePetESP"
    billboard.Adornee = object:FindFirstChildWhichIsA("BasePart") or object.PrimaryPart or object
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Text = labelText
    label.Parent = billboard

    billboard.Parent = object
    return billboard
end

local function addESP(egg)
    if egg:GetAttribute("OWNER") ~= localPlayer.Name then return end
    local eggName = egg:GetAttribute("EggName")
    local objectId = egg:GetAttribute("OBJECT_UUID")
    if not eggName or not objectId or displayedEggs[objectId] then return end

    local labelText, firstPet
    if realESP[eggName] then
        labelText = eggName
    else
        firstPet = getNonRepeatingRandomPet(eggName, nil)
        labelText = eggName .. " | " .. (firstPet or "?")
    end

    local espGui = createEspGui(egg, labelText)
    displayedEggs[objectId] = {
        egg = egg,
        gui = espGui,
        label = espGui:FindFirstChild("TextLabel"),
        eggName = eggName,
        lastPet = firstPet
    }
end

local function removeESP(egg)
    local objectId = egg:GetAttribute("OBJECT_UUID")
    if objectId and displayedEggs[objectId] then
        displayedEggs[objectId].gui:Destroy()
        displayedEggs[objectId] = nil
    end
end

--// ESP Signal Hooks
for _, egg in collectionService:GetTagged("PetEggServer") do
    addESP(egg)
end
collectionService:GetInstanceAddedSignal("PetEggServer"):Connect(addESP)
collectionService:GetInstanceRemovedSignal("PetEggServer"):Connect(removeESP)

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "PetRandomizerUI"
gui.ResetOnSpawn = false
gui.Parent = localPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 180)
frame.Position = UDim2.new(0, 20, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(35, 25, 25)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "ðŸ¾ Pet Randomizer âœ¨\nMade by - zeno daddy "
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.TextWrapped = true
title.Font = Enum.Font.SourceSansBold

local randomBtn = Instance.new("TextButton", frame)
randomBtn.Size = UDim2.new(1, -20, 0, 40)
randomBtn.Position = UDim2.new(0, 10, 0, 50)
randomBtn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
randomBtn.Text = "ðŸŽ² Randomize Pets"
randomBtn.TextColor3 = Color3.new(1, 1, 1)
randomBtn.TextScaled = true
randomBtn.Font = Enum.Font.SourceSansBold

local espBtn = Instance.new("TextButton", frame)
espBtn.Size = UDim2.new(1, -20, 0, 30)
espBtn.Position = UDim2.new(0, 10, 0, 95)
espBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
espBtn.Text = "ðŸ‘ï¸ ESP: ON"
espBtn.TextColor3 = Color3.new(1, 1, 1)
espBtn.TextScaled = true
espBtn.Font = Enum.Font.SourceSansBold

local autoBtn = Instance.new("TextButton", frame)
autoBtn.Size = UDim2.new(1, -20, 0, 30)
autoBtn.Position = UDim2.new(0, 10, 0, 130)
autoBtn.BackgroundColor3 = Color3.fromRGB(50, 160, 50)
autoBtn.Text = "âœ… Auto Randomize: ON"
autoBtn.TextColor3 = Color3.new(1, 1, 1)
autoBtn.TextScaled = true
autoBtn.Font = Enum.Font.SourceSansBold

--// GUI Button Logic
randomBtn.MouseButton1Click:Connect(function()
    for objectId, data in pairs(displayedEggs) do
        local pet = getNonRepeatingRandomPet(data.eggName, data.lastPet)
        if pet and data.label then
            data.label.Text = data.eggName .. " | " .. pet
            data.lastPet = pet
        end
    end
end)

autoBtn.MouseButton1Click:Connect(function()
    autoRandomizeOn = not autoRandomizeOn
    autoBtn.Text = autoRandomizeOn and "âœ… Auto Randomize: ON" or "âœ… Auto Randomize: OFF"
end)

espBtn.MouseButton1Click:Connect(function()
    espOn = not espOn
    espBtn.Text = espOn and "ðŸ‘ï¸ ESP: ON" or "ðŸ‘ï¸ ESP: OFF"
    for _, data in pairs(displayedEggs) do
        if data.gui then
            data.gui.Enabled = espOn
        end
    end
end)
