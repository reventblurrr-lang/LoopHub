--[================================================================]--
--       STEAL AN EGG - DELTA MOBILE / PC EXPLOIT GUI             --
--[================================================================]--

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Altes UI entfernen, falls es schon offen ist
if CoreGui:FindFirstChild("StealAnEggHub") then
	CoreGui.StealAnEggHub:Destroy()
end

-- Hauptfenster (ScreenGui) erstellen
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealAnEggHub"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true

-- Hauptrahmen (Design)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 380)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Kann auf dem Bildschirm verschoben werden!
MainFrame.Parent = ScreenGui

-- Abgerundete Ecken für das Fenster
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Titelbalken
local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
TitleBar.Text = "🥚 Steal an Egg Hub"
TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.TextSize = 18
TitleBar.Font = Enum.Font.GothamBold
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

-- Schließen-Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -40, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- Container für Buttons
local ButtonContainer = Instance.new("ScrollingFrame")
ButtonContainer.Size = UDim2.new(1, -20, 1, -60)
ButtonContainer.Position = UDim2.new(0, 10, 0, 50)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.CanvasSize = UDim2.new(0, 0, 0, 300)
ButtonContainer.ScrollBarThickness = 4
ButtonContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = ButtonContainer

-- Hilfsfunktion zum Erstellen von modernen Buttons
local function createButton(text, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 45)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 15
	btn.Font = Enum.Font.GothamMedium
	btn.Parent = ButtonContainer

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	btn.MouseButton1Click:Connect(callback)
	return btn
end

-- --- FUNKTIONEN ---

-- 1. Auto Collect / Steal Eier
local autoCollectEnabled = false
createButton("Auto Collect Eggs: OFF", function(btn)
	autoCollectEnabled = not autoCollectEnabled
	btn.Text = "Auto Collect Eggs: " .. (autoCollectEnabled and "ON" | "OFF")
	btn.BackgroundColor3 = autoCollectEnabled and Color3.fromRGB(50, 180, 80) or Color3.fromRGB(45, 45, 60)
end)

RunService.RenderStepped:Connect(function()
	if autoCollectEnabled then
		pcall(function()
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local eggsFolder = Workspace:FindFirstChild("Eggs")
			
			if root and eggsFolder then
				for _, egg in ipairs(eggsFolder:GetChildren()) do
					if egg:IsA("BasePart") then
						-- Teleportiert den Spieler kurz zum Ei, um es sofort einzusammeln
						root.CFrame = egg.CFrame + Vector3.new(0, 1, 0)
						task.wait(0.05)
					end
				end
			end
		end)
	end
end)

-- 2. Speed Hack
local speedEnabled = false
createButton("Speed Hack (WalkSpeed 32): OFF", function(btn)
	speedEnabled = not speedEnabled
	btn.Text = "Speed Hack: " .. (speedEnabled and "ON" | "OFF")
	btn.BackgroundColor3 = speedEnabled and Color3.fromRGB(50, 180, 80) or Color3.fromRGB(45, 45, 60)
	
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = speedEnabled and 32 or 16
	end
end)

-- 3. Zu eigener Basis / Safezone teleportieren
createButton("Teleport to My Base", function()
	pcall(function()
		local char = LocalPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local basesFolder = Workspace:FindFirstChild("Bases")
		
		if root and basesFolder then
			local myBase = basesFolder:FindFirstChild(LocalPlayer.Name .. "_Base")
			if myBase then
				root.CFrame = myBase.CFrame + Vector3.new(0, 3, 0)
			end
		end
	end)
end)

-- 4. ESP / Eier durch Wände sehen
local espEnabled = false
createButton("Egg ESP (Highlight): OFF", function(btn)
	espEnabled = not espEnabled
	btn.Text = "Egg ESP: " .. (espEnabled and "ON" | "OFF")
	btn.BackgroundColor3 = espEnabled and Color3.fromRGB(50, 180, 80) or Color3.fromRGB(45, 45, 60)
	
	local eggsFolder = Workspace:FindFirstChild("Eggs")
	if eggsFolder then
		for _, egg in ipairs(eggsFolder:GetChildren()) do
			if espEnabled then
				if not egg:FindFirstChild("EspHighlight") then
					local hl = Instance.new("Highlight")
					hl.Name = "EspHighlight"
					hl.FillColor = Color3.fromRGB(255, 215, 0)
					hl.Parent = egg
				end
			else
				if egg:FindFirstChild("EspHighlight") then
					egg.EspHighlight:Destroy()
				end
			end
		end
	end
end)

print("Steal an Egg Hub erfolgreich geladen!")
