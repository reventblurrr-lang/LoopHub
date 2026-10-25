-- [[ SAE PRO SNIPER - DEEP REPLICATED STORAGE EDITION ]] --

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- Altes UI entfernen
local existing = CoreGui:FindFirstChild("SAE_ProHub") or player.PlayerGui:FindFirstChild("SAE_ProHub")
if existing then existing:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SAE_ProHub"
screenGui.ResetOnSpawn = false
pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then
	screenGui.Parent = player:WaitForChild("PlayerGui")
end

-- Hauptfenster
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 480, 0, 440)
mainFrame.Position = UDim2.new(0.08, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 42)
titleBar.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local fixCover = Instance.new("Frame")
fixCover.Size = UDim2.new(1, 0, 0, 10)
fixCover.Position = UDim2.new(0, 0, 1, -10)
fixCover.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
fixCover.BorderSizePixel = 0
fixCover.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.6, 0, 1, 0)
titleText.Position = UDim2.new(0, 14, 0, 0)
titleText.Text = "⚡ SAE PRO HUB | SCRIPT v2"
titleText.TextColor3 = Color3.fromRGB(255, 215, 0)
titleText.BackgroundTransparency = 1
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 14
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, 0, 1, -42)
contentContainer.Position = UDim2.new(0, 0, 0, 42)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

-- Schließen-Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 26)
closeBtn.Position = UDim2.new(1, -38, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Minimieren-Button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 32, 0, 26)
minimizeBtn.Position = UDim2.new(1, -76, 0, 8)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Text = "-"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 14
minimizeBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minimizeBtn

local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	contentContainer.Visible = not isMinimized
	if isMinimized then
		mainFrame.Size = UDim2.new(0, 480, 0, 42)
		minimizeBtn.Text = "+"
	else
		mainFrame.Size = UDim2.new(0, 480, 0, 440)
		minimizeBtn.Text = "-"
	end
end)

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -16, 1, -12)
scrollingFrame.Position = UDim2.new(0, 8, 0, 6)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.ScrollBarThickness = 5
scrollingFrame.Parent = contentContainer

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 8)
uiListLayout.Parent = scrollingFrame

local RARITY_PRIORITY = {
	["Eternal"] = 4,
	["Divine"] = 3,
	["Secret"] = 2
}

-- Sucht nach dem echten RemoteEvent für Interaktionen im Spiel
local function getBestRemote()
	for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
		if v:IsA("RemoteEvent") then
			local name = v.Name:lower()
			if name:find("steal") or name:find("interact") or name:find("egg") or name:find("collect") then
				return v
			end
		end
	end
	return nil
end

local function scanGameObjects()
	local foundData = {}
	pcall(function()
		-- Scannt den gesamten Workspace nach Objekten mit Seltenheits-Attributen
		for _, obj in ipairs(Workspace:GetDescendants()) do
			local rarity = obj:GetAttribute("Rarity") or obj:GetAttribute("Tier")
			if type(rarity) == "string" and RARITY_PRIORITY[rarity] then
				local pos = Vector3.zero
				local valid = false
				
				if obj:IsA("Model") then
					local ok, p = pcall(function() return obj:GetPivot().Position end)
					if ok then pos = p valid = true end
				elseif obj:IsA("BasePart") then
					pos = obj.Position
					valid = true
				end
				
				if valid and pos ~= Vector3.zero then
					local petName = obj:GetAttribute("PetName") or obj:GetAttribute("Pet") or obj.Name
					table.insert(foundData, {
						Instance = obj,
						Name = obj.Name,
						Rarity = rarity,
						PetName = tostring(petName),
						Priority = RARITY_PRIORITY[rarity],
						Position = pos
					})
				end
			end
		end
	end)
	
	table.sort(foundData, function(a, b)
		return a.Priority > b.Priority
	end)
	
	return foundData
end

local function updateUI()
	if isMinimized then return end
	
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	local items = scanGameObjects()
	local count = 0
	
	for _, data in ipairs(items) do
		count += 1
		
		local itemFrame = Instance.new("Frame")
		itemFrame.Size = UDim2.new(1, 0, 0, 60)
		itemFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
		itemFrame.BorderSizePixel = 0
		itemFrame.Parent = scrollingFrame
		
		local itemCorner = Instance.new("UICorner")
		itemCorner.CornerRadius = UDim.new(0, 8)
		itemCorner.Parent = itemFrame
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(0.45, 0, 1, 0)
		label.Position = UDim2.new(0, 10, 0, 0)
		label.Text = string.format("[%s] %s\nPet: %s", data.Rarity, data.Name, data.PetName)
		label.TextColor3 = Color3.fromRGB(240, 240, 240)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamSemibold
		label.TextSize = 10
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = itemFrame
		
		-- Server Hop Button (Roblox API)
		local hopBtn = Instance.new("TextButton")
		hopBtn.Size = UDim2.new(0.24, 0, 0.7, 0)
		hopBtn.Position = UDim2.new(0.47, 0, 0.15, 0)
		hopBtn.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
		hopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		hopBtn.Text = "Server Hop"
		hopBtn.Font = Enum.Font.GothamBold
		hopBtn.TextSize = 11
		hopBtn.Parent = itemFrame
		
		local hopCorner = Instance.new("UICorner")
		hopCorner.CornerRadius = UDim.new(0, 6)
		hopCorner.Parent = hopBtn
		
		hopBtn.MouseButton1Click:Connect(function()
			pcall(function()
				local response = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
				local decoded = HttpService:JSONDecode(response)
				if decoded and decoded.data then
					for _, s in ipairs(decoded.data) do
						if s.id ~= game.JobId and s.playing < s.maxPlayers then
							TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, player)
							break
						end
					end
				end
			end)
		end)
		
		-- Instant Steal / Teleport Button
		local stealBtn = Instance.new("TextButton")
		stealBtn.Size = UDim2.new(0.24, 0, 0.7, 0)
		stealBtn.Position = UDim2.new(0.73, 0, 0.15, 0)
		stealBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
		stealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		stealBtn.Text = "Instant Steal"
		stealBtn.Font = Enum.Font.GothamBold
		stealBtn.TextSize = 11
		stealBtn.Parent = itemFrame
		
		local stealCorner = Instance.new("UICorner")
		stealCorner.CornerRadius = UDim.new(0, 6)
		stealCorner.Parent = stealBtn
		
		stealBtn.MouseButton1Click:Connect(function()
			local char = player.Character
			if char and char:FindFirstChild("HumanoidRootPart") and data.Instance and data.Instance.Parent then
				local hrp = char.HumanoidRootPart
				if data.Instance:IsA("Model") then
					hrp.CFrame = data.Instance:GetPivot()
				elseif data.Instance:IsA("BasePart") then
					hrp.CFrame = data.Instance.CFrame
				end
				
				local remote = getBestRemote()
				if remote then
					pcall(function()
						remote:FireServer(data.Instance)
					end)
				end
			end
		end)
	end
	
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, count * 68)
end

task.spawn(function()
	while true do
		pcall(updateUI)
		task.wait(2)
	end
end)

print("SAE Pro Hub erfolgreich initialisiert!")
