local francis = game:GetService("ReplicatedStorage"):WaitForChild("francis")
local Blocks = francis:WaitForChild("Blocks")
local Remote = francis:WaitForChild("RemoteEvent")
local RenderStepped = game:GetService("RunService").RenderStepped

local WorldBlocks = Instance.new("Folder")
WorldBlocks.Name = "Blocks"
WorldBlocks.Parent = workspace

local World = {}
local WaitTimer = 0

local Player = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local Mouse = Player:GetMouse()
local Coords = Player:WaitForChild("PlayerGui"):WaitForChild("Coords")
local selectionBox = Coords:WaitForChild("SelectionBox")
local LastDestroy = 0

local itemStacks = {}
local inventorySlots = {}
local inventoryDecals = {}

local function fillStack(itemStack, qty)
	local stackQty = math.min(qty, 64)
	itemStack.Qty = stackQty
	return qty - stackQty
end

local function addToInventory(stackName, qty)
	local emptyStacks = {}
	for i = 1, 36 do
		local itemStack = itemStacks[i]
		local invSlot = inventorySlots[i]
		if itemStack.Name == stackName and qty > 0 then
			qty = fillStack(itemStack, qty) 
			invSlot.Text = itemStack.Qty
			invSlot.Visible = true
			invSlot.ImageLabel.Image = inventoryDecals[itemStack.Name]
		end
		if itemStack.Qty == 0 then
			emptyStacks[i] = itemStack
			invSlot.Visible = false
		end
	end
	
	for idx, itemStack in next, emptyStacks do
		if qty > 0 then
			itemStack.Name = stackName
			qty = fillStack(itemStack, qty)	
			local invSlot = inventorySlots[idx]
			invSlot.Text = itemStack.Qty
			invSlot.Visible = true
			invSlot.ImageLabel.Image = inventoryDecals[itemStack.Name]
		else
			break
		end
	end
end

for i = 1, 36 do
	itemStacks[i] = {
		Name = "null",
		Qty = 0
	}
	inventorySlots[i] = i < 10 and Coords.Hotbar[i] or Coords.Inventory[i - 9]
end

addToInventory("null", 0)

RenderStepped:Connect(function()
	local Target = Mouse.Target
	local Selection
	if Target and Target.Parent == WorldBlocks then
		Selection = Target	
		if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and (tick() - LastDestroy) > 0.025 then
			LastDestroy = tick()
			Remote:FireServer("Destroy", Target.Position)
			Target:Destroy()
		end
	end
	selectionBox.Adornee = Selection
	
	local Head = Player.Character and Player.Character:FindFirstChild("Head")
	if Head then
		Coords.Coords.Text = math.ceil(Head.Position.X/4) .. ", " .. math.floor(Head.Position.Y/4) .. ", " .. math.ceil(Head.Position.Z/4)
	else
		Coords.Coords.Text = "N/A"
	end
	
	Coords.Inventory.Visible = UIS:IsKeyDown(Enum.KeyCode.Tab)
end)

Remote.OnClientEvent:Connect(function(Action, ...)
	if Action == "updateWorld" then
		local myPos = workspace.CurrentCamera.CFrame.Position
		local updates = ...
		local sortedUpdates = {}
		for positionStr, blockName in next, updates do
			local X, Y, Z = positionStr:match("%((.-), (.-), (.-)%)")
			local position = Vector3.new(X, Y, Z)
			sortedUpdates[#sortedUpdates + 1] = {
				positionStr, position, blockName
			}
		end
		table.sort(sortedUpdates, function(mag1, mag2)
			return (myPos - mag1[2]).Magnitude < (myPos - mag2[2]).Magnitude
		end)
		for magnitude, update in next, sortedUpdates do
			local positionStr, position, blockName = unpack(update)
			WaitTimer += 1
			if WaitTimer == 250 then
				RenderStepped:Wait()
				WaitTimer = 0
			end
			local existingBlock = World[positionStr]
			if existingBlock then
				existingBlock:Destroy()
				World[positionStr] = nil
			end
			if (type(blockName) == "string") and (blockName ~= "null") then
				local block = Blocks[blockName]:Clone()
				World[positionStr] = block
				block.CFrame = CFrame.new(position)
				block.Parent = WorldBlocks
			end
		end
	elseif Action == "updateInventory" then
		addToInventory(...)
	end
	print(Action, "invoked:", ...)
end)

for idx, block in next, Blocks:GetChildren() do
	local Decal = block:FindFirstChildOfClass("Decal")
	inventoryDecals[block.Name] = Decal and Decal.Texture or ""
	print("Set texture id for", block.Name)
end
