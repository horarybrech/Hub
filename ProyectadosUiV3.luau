local nativeTask = task
local runtime = {Alive = true, Threads = {}, Connections = {}, Cleanups = {}}

function runtime:Schedule(schedule, callback, ...)
	if not self.Alive then return end
	local arguments = table.pack(...)
	local thread
	thread = coroutine.create(function()
		if not self.Alive then self.Threads[thread] = nil return end
		local results = table.pack(pcall(callback, table.unpack(arguments, 1, arguments.n)))
		self.Threads[thread] = nil
		if not results[1] then error(results[2], 0) end
		return table.unpack(results, 2, results.n)
	end)
	self.Threads[thread] = true
	schedule(thread)
	return thread
end

function runtime:Spawn(callback, ...) return self:Schedule(nativeTask.spawn, callback, ...) end
function runtime:Defer(callback, ...) return self:Schedule(nativeTask.defer, callback, ...) end
function runtime:Connect(signal, callback)
	if not self.Alive then return end
	local connection = signal:Connect(function(...) self:Spawn(callback, ...) end)
	self.Connections[connection] = true
	return connection
end

function runtime:AddCleanup(callback)
	if self.Alive then table.insert(self.Cleanups, callback) else pcall(callback) end
	return callback
end

function runtime:Destroy()
	if not self.Alive then return end
	self.Alive = false
	for connection in pairs(self.Connections) do pcall(function() connection:Disconnect() end) end
	table.clear(self.Connections)
	local current = coroutine.running()
	for thread in pairs(self.Threads) do
		if thread ~= current and coroutine.status(thread) ~= "dead" then pcall(nativeTask.cancel, thread) end
	end
	table.clear(self.Threads)
	for index = #self.Cleanups, 1, -1 do pcall(self.Cleanups[index]) end
	table.clear(self.Cleanups)
	if _G.SilenceRuntime == self then _G.SilenceRuntime = nil end
end

if _G.SilenceRuntime then _G.SilenceRuntime:Destroy() end
_G.SilenceRuntime = runtime
runtime.Threads[coroutine.running()] = true

local isSolara = false
do
	local success, executorName = pcall(function()
		local identify = identifyexecutor
		if type(identify) ~= "function" then identify = getexecutorname end
		if type(identify) == "function" then return identify() end
	end)
	isSolara = success and type(executorName) == "string" and string.lower(executorName) == "solara"
end

local ui_options = {
	main_color = Color3.fromRGB(110, 50, 160),
	min_size = Vector2.new(420, 310),
	toggle_key = Enum.KeyCode.RightShift,
	can_resize = true,
}

do
	local function destroyImguiIn(parent)
		if parent and parent.FindFirstChild then
			local existing = parent:FindFirstChild("imgui")
			if existing then pcall(function() existing:Destroy() end) end
			local toggleExist = parent:FindFirstChild("ToggleUI")
			if toggleExist then pcall(function() toggleExist:Destroy() end) end
		end
	end

	if not isSolara then pcall(function() destroyImguiIn(game:GetService("CoreGui")) end) end
	local Players = game:GetService("Players")
	if Players and Players.LocalPlayer then destroyImguiIn(Players.LocalPlayer:FindFirstChild("PlayerGui")) end
	if not isSolara and type(gethui) == "function" then
		local ok, gh = pcall(gethui)
		if ok and gh then destroyImguiIn(gh) end
	end
	if not isSolara then
		for _, v in ipairs(game:GetDescendants()) do
			if (v.Name == "imgui" or v.Name == "ToggleUI") and v:IsA("ScreenGui") then
				pcall(function() v:Destroy() end)
			end
		end
	end
end

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local cloneref = type(cloneref) == "function" and cloneref or function(...) return ... end

local CoreGui
if not isSolara then pcall(function() CoreGui = game:GetService("CoreGui") end) end
if CoreGui then pcall(function() CoreGui = cloneref(CoreGui) end) end

local function mountGui(gui)
	if not isSolara and type(gethui) == "function" then
		pcall(function() gui.Parent = gethui() end)
	end
	if not gui.Parent and CoreGui then
		pcall(function() gui.Parent = CoreGui end)
	end
	if not gui.Parent then
		gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
end

local imgui = Instance.new("ScreenGui")
imgui.Name = "imgui"
imgui.ResetOnSpawn = false
imgui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mountGui(imgui)

runtime:AddCleanup(function() imgui:Destroy() end)
runtime:Connect(imgui.Destroying, function() runtime:Destroy() end)

local windowsFrame = Instance.new("Frame")
windowsFrame.Name = "Windows"
windowsFrame.Parent = imgui
windowsFrame.BackgroundTransparency = 1
windowsFrame.Size = UDim2.new(1, 0, 1, 0)

local checks = { binding = false }

-- Tecla rápida en PC (RightShift)
runtime:Connect(UIS.InputBegan, function(input, gameProcessed)
	if gameProcessed then return end
	local toggleKey = (typeof(ui_options.toggle_key) == "EnumItem") and ui_options.toggle_key or Enum.KeyCode.RightShift
	if input.KeyCode == toggleKey and not checks.binding then
		imgui.Enabled = not imgui.Enabled
	end
end)

-- Botón flotante universal (PC y Android)
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "ToggleUI"
toggleGui.ResetOnSpawn = false
toggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mountGui(toggleGui)
runtime:AddCleanup(function() toggleGui:Destroy() end)

local floatingBtn = Instance.new("TextButton")
floatingBtn.Name = "OpenCloseBtn"
floatingBtn.Parent = toggleGui
floatingBtn.BackgroundColor3 = ui_options.main_color
floatingBtn.Position = UDim2.new(0.5, -22, 0, 12)
floatingBtn.Size = UDim2.new(0, 44, 0, 44)
floatingBtn.Font = Enum.Font.GothamBold
floatingBtn.Text = "⚙️"
floatingBtn.TextSize = 20
floatingBtn.TextColor3 = Color3.new(1, 1, 1)
floatingBtn.AutoButtonColor = false
floatingBtn.ZIndex = 100

local floatingCorner = Instance.new("UICorner")
floatingCorner.CornerRadius = UDim.new(1, 0)
floatingCorner.Parent = floatingBtn

local floatingStroke = Instance.new("UIStroke")
floatingStroke.Color = Color3.fromRGB(210, 170, 255)
floatingStroke.Thickness = 1.5
floatingStroke.Transparency = 0.25
floatingStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
floatingStroke.Parent = floatingBtn

local floatingGrad = Instance.new("UIGradient")
floatingGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(190, 190, 200))
})
floatingGrad.Rotation = 45
floatingGrad.Parent = floatingBtn

do
	local isDragging, dragStart, startPos, hasMoved = false, nil, nil, false

	runtime:Connect(floatingBtn.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
			hasMoved = false
			dragStart = input.Position
			startPos = floatingBtn.Position
		end
	end)

	runtime:Connect(UIS.InputChanged, function(input)
		if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			if dragStart then
				local delta = input.Position - dragStart
				if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then
					hasMoved = true
					floatingBtn.Position = UDim2.new(
						startPos.X.Scale, startPos.X.Offset + delta.X,
						startPos.Y.Scale, startPos.Y.Offset + delta.Y
					)
				end
			end
		end
	end)

	runtime:Connect(UIS.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if isDragging then
				isDragging = false
				if not hasMoved and not checks.binding then
					imgui.Enabled = not imgui.Enabled
				end
			end
		end
	end)
end

-- Utilidades ligeras
local function Tween(obj, props, duration)
	local info = TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tw = TweenService:Create(obj, info, props)
	tw:Play()
	return tw
end

local function addCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 6)
	c.Parent = parent
	return c
end

local function addStroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.fromRGB(55, 55, 65)
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function makeDraggable(dragHandle, targetFrame)
	local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

	runtime:Connect(dragHandle.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = targetFrame.Position
		end
	end)

	runtime:Connect(dragHandle.InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	runtime:Connect(UIS.InputChanged, function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			targetFrame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	runtime:Connect(UIS.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

local windows = 0
local library = {Runtime = runtime}

function library:Destroy()
	runtime:Destroy()
end

function library:FormatWindows()
	local xOffset = 25
	for _, win in ipairs(windowsFrame:GetChildren()) do
		if win:IsA("Frame") then
			win.Position = UDim2.new(0, xOffset, 0, 65)
			xOffset = xOffset + win.AbsoluteSize.X + 15
		end
	end
end

function library:AddWindow(title, options)
	if not runtime.Alive then return end
	windows = windows + 1

	local opts = {
		main_color = (typeof(options) == "table" and options.main_color) or ui_options.main_color,
		min_size = (typeof(options) == "table" and options.min_size) or ui_options.min_size,
		can_resize = (typeof(options) == "table" and options.can_resize ~= nil) and options.can_resize or ui_options.can_resize,
		tween_time = 0.16,
	}

	floatingBtn.BackgroundColor3 = opts.main_color

	-- Ventana Principal
	local Window = Instance.new("Frame")
	Window.Name = "Window_" .. windows
	Window.Parent = windowsFrame
	Window.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	Window.BorderSizePixel = 0
	Window.ClipsDescendants = true
	Window.Position = UDim2.new(0, 25 + ((windows - 1) * 30), 0, 65)
	Window.Size = UDim2.new(0, opts.min_size.X, 0, opts.min_size.Y)
	addCorner(Window, 8)
	local windowStroke = addStroke(Window, opts.main_color, 1.3, 0.2)

	-- Barra Superior
	local Bar = Instance.new("Frame")
	Bar.Name = "Bar"
	Bar.Parent = Window
	Bar.BackgroundColor3 = opts.main_color
	Bar.BorderSizePixel = 0
	Bar.Size = UDim2.new(1, 0, 0, 30)
	addCorner(Bar, 8)

	local BarCover = Instance.new("Frame")
	BarCover.Name = "BarCover"
	BarCover.Parent = Bar
	BarCover.BackgroundColor3 = opts.main_color
	BarCover.BorderSizePixel = 0
	BarCover.Position = UDim2.new(0, 0, 0.5, 0)
	BarCover.Size = UDim2.new(1, 0, 0.5, 0)

	local barGrad = Instance.new("UIGradient")
	barGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(205, 205, 215))
	})
	barGrad.Parent = Bar

	makeDraggable(Bar, Window)

	-- Botón Minimizar (📽️ / ❤️‍🔥)
	local ToggleBtn = Instance.new("TextButton")
	ToggleBtn.Name = "Toggle"
	ToggleBtn.Parent = Bar
	ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	ToggleBtn.BackgroundTransparency = 0.75
	ToggleBtn.Position = UDim2.new(0, 6, 0.5, -10)
	ToggleBtn.Size = UDim2.new(0, 22, 0, 20)
	ToggleBtn.Font = Enum.Font.GothamBold
	ToggleBtn.Text = "📽️"
	ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
	ToggleBtn.TextSize = 13
	ToggleBtn.ZIndex = 3
	addCorner(ToggleBtn, 5)

	-- Título de la Ventana
	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Name = "Title"
	TitleLabel.Parent = Bar
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Position = UDim2.new(0, 34, 0, 0)
	TitleLabel.Size = UDim2.new(1, -44, 1, 0)
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.Text = tostring(title or "New Window")
	TitleLabel.TextColor3 = Color3.new(1, 1, 1)
	TitleLabel.TextSize = 14
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.ZIndex = 3

	-- Barra de Pestañas (Tabs)
	local TabSelection = Instance.new("ScrollingFrame")
	TabSelection.Name = "TabSelection"
	TabSelection.Parent = Window
	TabSelection.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
	TabSelection.BorderSizePixel = 0
	TabSelection.Position = UDim2.new(0, 10, 0, 36)
	TabSelection.Size = UDim2.new(1, -20, 0, 28)
	TabSelection.CanvasSize = UDim2.new(0, 0, 0, 0)
	TabSelection.AutomaticCanvasSize = Enum.AutomaticSize.X
	TabSelection.ScrollBarThickness = 0
	TabSelection.Visible = false
	addCorner(TabSelection, 6)
	addStroke(TabSelection, Color3.fromRGB(45, 45, 55), 1, 0.3)

	local TabButtons = Instance.new("Frame")
	TabButtons.Name = "TabButtons"
	TabButtons.Parent = TabSelection
	TabButtons.BackgroundTransparency = 1
	TabButtons.Position = UDim2.new(0, 4, 0, 3)
	TabButtons.Size = UDim2.new(1, -8, 1, -6)

	local tabListLayout = Instance.new("UIListLayout")
	tabListLayout.Parent = TabButtons
	tabListLayout.FillDirection = Enum.FillDirection.Horizontal
	tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabListLayout.Padding = UDim.new(0, 5)

	-- Contenedor de Pestañas
	local TabsContainer = Instance.new("Frame")
	TabsContainer.Name = "Tabs"
	TabsContainer.Parent = Window
	TabsContainer.BackgroundTransparency = 1
	TabsContainer.Position = UDim2.new(0, 10, 0, 70)
	TabsContainer.Size = UDim2.new(1, -20, 1, -80)

	-- Redimensionador (Esquina inferior derecha)
	local Resizer = Instance.new("TextButton")
	Resizer.Name = "Resizer"
	Resizer.Parent = Window
	Resizer.BackgroundTransparency = 1
	Resizer.Position = UDim2.new(1, -18, 1, -18)
	Resizer.Size = UDim2.new(0, 18, 0, 18)
	Resizer.Text = "◢"
	Resizer.TextColor3 = Color3.fromRGB(130, 130, 145)
	Resizer.TextSize = 11
	Resizer.Visible = opts.can_resize
	Resizer.ZIndex = 5

	if opts.can_resize then
		local resizing, resizeStart, startSize = false, nil, nil
		runtime:Connect(Resizer.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				resizing = true
				resizeStart = input.Position
				startSize = Window.AbsoluteSize
			end
		end)
		runtime:Connect(UIS.InputChanged, function(input)
			if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - resizeStart
				local newX = math.max(opts.min_size.X, startSize.X + delta.X)
				local newY = math.max(opts.min_size.Y, startSize.Y + delta.Y)
				Window.Size = UDim2.new(0, newX, 0, newY)
			end
		end)
		runtime:Connect(UIS.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				resizing = false
			end
		end)
	end

	-- Lógica de Minimizar
	local isOpen = true
	local canToggle = true
	local savedHeight = opts.min_size.Y

	runtime:Connect(ToggleBtn.MouseButton1Click, function()
		if not canToggle then return end
		canToggle = false

		if isOpen then
			savedHeight = Window.AbsoluteSize.Y
			TabsContainer.Visible = false
			TabSelection.Visible = false
			Resizer.Visible = false
			BarCover.Visible = false
			Tween(Window, {Size = UDim2.new(0, Window.AbsoluteSize.X, 0, 30)}, opts.tween_time)
			ToggleBtn.Text = "❤️‍🔥"
		else
			Tween(Window, {Size = UDim2.new(0, Window.AbsoluteSize.X, 0, savedHeight)}, opts.tween_time)
			nativeTask.wait(opts.tween_time * 0.6)
			BarCover.Visible = true
			if #TabButtons:GetChildren() > 1 then
				TabSelection.Visible = true
			end
			TabsContainer.Visible = true
			Resizer.Visible = opts.can_resize
			ToggleBtn.Text = "📽️"
		end

		isOpen = not isOpen
		nativeTask.wait(opts.tween_time)
		canToggle = true
	end)

	local window_data = {}
	function window_data:Destroy()
		library:Destroy()
	end
	function window_data:SetTitle(new_title)
		if runtime.Alive then
			TitleLabel.Text = tostring(new_title or "New Window")
		end
	end

	local dropdown_open = false

	function window_data:AddTab(tab_name)
		local tab_data = {}
		tab_name = tostring(tab_name or "New Tab")
		if isOpen then TabSelection.Visible = true end

		local tabBtn = Instance.new("TextButton")
		tabBtn.Name = "TabBtn_" .. tab_name
		tabBtn.Parent = TabButtons
		tabBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 42)
		tabBtn.BorderSizePixel = 0
		tabBtn.Font = Enum.Font.GothamSemibold
		tabBtn.Text = tab_name
		tabBtn.TextColor3 = Color3.fromRGB(185, 185, 195)
		tabBtn.TextSize = 13
		tabBtn.AutoButtonColor = false
		tabBtn.Size = UDim2.new(0, math.max(68, tabBtn.TextBounds.X + 20), 1, 0)
		addCorner(tabBtn, 5)

		local tabPage = Instance.new("ScrollingFrame")
		tabPage.Name = "Tab_" .. tab_name
		tabPage.Parent = TabsContainer
		tabPage.BackgroundTransparency = 1
		tabPage.BorderSizePixel = 0
		tabPage.Size = UDim2.new(1, 0, 1, 0)
		tabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
		tabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
		tabPage.ScrollBarThickness = 3
		tabPage.ScrollBarImageColor3 = opts.main_color
		tabPage.Visible = false

		local pagePadding = Instance.new("UIPadding")
		pagePadding.PaddingRight = UDim.new(0, 6)
		pagePadding.PaddingTop = UDim.new(0, 2)
		pagePadding.PaddingBottom = UDim.new(0, 4)
		pagePadding.Parent = tabPage

		local pageLayout = Instance.new("UIListLayout")
		pageLayout.Parent = tabPage
		pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		pageLayout.Padding = UDim.new(0, 6)

		local function showTab()
			if dropdown_open then return end
			for _, child in ipairs(TabButtons:GetChildren()) do
				if child:IsA("TextButton") then
					Tween(child, {BackgroundColor3 = Color3.fromRGB(34, 34, 42), TextColor3 = Color3.fromRGB(185, 185, 195)}, 0.12)
				end
			end
			for _, page in ipairs(TabsContainer:GetChildren()) do
				if page:IsA("ScrollingFrame") then
					page.Visible = false
				end
			end
			Tween(tabBtn, {BackgroundColor3 = opts.main_color, TextColor3 = Color3.new(1, 1, 1)}, 0.12)
			tabPage.Visible = true
		end

		runtime:Connect(tabBtn.MouseButton1Click, showTab)
		function tab_data:Show() showTab() end

		-- ELEMENTO: LABEL
		function tab_data:AddLabel(label_text)
			local lbl = Instance.new("TextLabel")
			lbl.Name = "Label"
			lbl.Parent = tabPage
			lbl.BackgroundTransparency = 1
			lbl.Size = UDim2.new(1, 0, 0, 20)
			lbl.AutomaticSize = Enum.AutomaticSize.Y
			lbl.Font = Enum.Font.GothamSemibold
			lbl.Text = tostring(label_text or "Label")
			lbl.TextColor3 = Color3.fromRGB(220, 220, 230)
			lbl.TextSize = 13
			lbl.TextWrapped = true
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			return lbl
		end

		-- ELEMENTO: BUTTON
		function tab_data:AddButton(button_text, callback)
			callback = typeof(callback) == "function" and callback or function() end

			local btn = Instance.new("TextButton")
			btn.Name = "Button"
			btn.Parent = tabPage
			btn.BackgroundColor3 = opts.main_color
			btn.BorderSizePixel = 0
			btn.Size = UDim2.new(1, 0, 0, 28)
			btn.Font = Enum.Font.GothamSemibold
			btn.Text = tostring(button_text or "Button")
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.TextSize = 13
			btn.AutoButtonColor = false
			addCorner(btn, 6)

			local hoverColor = Color3.new(
				math.min(1, opts.main_color.R + 0.08),
				math.min(1, opts.main_color.G + 0.08),
				math.min(1, opts.main_color.B + 0.08)
			)

			runtime:Connect(btn.MouseEnter, function()
				Tween(btn, {BackgroundColor3 = hoverColor}, 0.1)
			end)
			runtime:Connect(btn.MouseLeave, function()
				Tween(btn, {BackgroundColor3 = opts.main_color}, 0.1)
			end)
			runtime:Connect(btn.MouseButton1Click, function()
				Tween(btn, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.06)
				nativeTask.delay(0.06, function()
					if btn and btn.Parent then
						Tween(btn, {BackgroundColor3 = opts.main_color}, 0.12)
					end
				end)
				pcall(callback)
			end)

			return btn
		end

		-- ELEMENTO: SWITCH (Estilo píldora animado)
		function tab_data:AddSwitch(switch_text, callback)
			local switch_data = {}
			callback = typeof(callback) == "function" and callback or function() end

			local container = Instance.new("TextButton")
			container.Name = "Switch"
			container.Parent = tabPage
			container.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
			container.BorderSizePixel = 0
			container.Size = UDim2.new(1, 0, 0, 30)
			container.Text = ""
			container.AutoButtonColor = false
			addCorner(container, 6)
			addStroke(container, Color3.fromRGB(45, 45, 55), 1, 0.4)

			local titleLbl = Instance.new("TextLabel")
			titleLbl.Name = "Title"
			titleLbl.Parent = container
			titleLbl.BackgroundTransparency = 1
			titleLbl.Position = UDim2.new(0, 10, 0, 0)
			titleLbl.Size = UDim2.new(1, -60, 1, 0)
			titleLbl.Font = Enum.Font.GothamSemibold
			titleLbl.Text = tostring(switch_text or "Switch")
			titleLbl.TextColor3 = Color3.fromRGB(220, 220, 230)
			titleLbl.TextSize = 13
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left

			local pill = Instance.new("Frame")
			pill.Name = "Pill"
			pill.Parent = container
			pill.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
			pill.BorderSizePixel = 0
			pill.Position = UDim2.new(1, -46, 0.5, -9)
			pill.Size = UDim2.new(0, 36, 0, 18)
			addCorner(pill, 9)

			local knob = Instance.new("Frame")
			knob.Name = "Knob"
			knob.Parent = pill
			knob.BackgroundColor3 = Color3.fromRGB(235, 235, 240)
			knob.BorderSizePixel = 0
			knob.Position = UDim2.new(0, 2, 0.5, -7)
			knob.Size = UDim2.new(0, 14, 0, 14)
			addCorner(knob, 7)

			local toggled = false

			local function updateVisual(state)
				if state then
					Tween(pill, {BackgroundColor3 = opts.main_color}, 0.15)
					Tween(knob, {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = Color3.new(1, 1, 1)}, 0.15)
				else
					Tween(pill, {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}, 0.15)
					Tween(knob, {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(235, 235, 240)}, 0.15)
				end
			end

			runtime:AddCleanup(function()
				if toggled then
					toggled = false
					pcall(callback, false)
				end
			end)

			runtime:Connect(container.MouseButton1Click, function()
				toggled = not toggled
				updateVisual(toggled)
				pcall(callback, toggled)
			end)

			function switch_data:Set(bool)
				if not runtime.Alive then return end
				toggled = (typeof(bool) == "boolean") and bool or false
				updateVisual(toggled)
				pcall(callback, toggled)
			end

			return switch_data, container
		end

		-- ELEMENTO: SLIDER (Soporte Mouse + Touch fluido)
		function tab_data:AddSlider(slider_text, callback, slider_options)
			local slider_data = {}
			callback = typeof(callback) == "function" and callback or function() end
			slider_options = typeof(slider_options) == "table" and slider_options or {}
			local minVal = slider_options.min or 0
			local maxVal = slider_options.max or 100
			local readonly = slider_options.readonly or false

			local container = Instance.new("Frame")
			container.Name = "Slider"
			container.Parent = tabPage
			container.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
			container.BorderSizePixel = 0
			container.Size = UDim2.new(1, 0, 0, 42)
			addCorner(container, 6)
			addStroke(container, Color3.fromRGB(45, 45, 55), 1, 0.4)

			local titleLbl = Instance.new("TextLabel")
			titleLbl.Name = "Title"
			titleLbl.Parent = container
			titleLbl.BackgroundTransparency = 1
			titleLbl.Position = UDim2.new(0, 10, 0, 4)
			titleLbl.Size = UDim2.new(1, -70, 0, 18)
			titleLbl.Font = Enum.Font.GothamSemibold
			titleLbl.Text = tostring(slider_text or "Slider")
			titleLbl.TextColor3 = Color3.fromRGB(220, 220, 230)
			titleLbl.TextSize = 13
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left

			local valLbl = Instance.new("TextLabel")
			valLbl.Name = "Value"
			valLbl.Parent = container
			valLbl.BackgroundTransparency = 1
			valLbl.Position = UDim2.new(1, -60, 0, 4)
			valLbl.Size = UDim2.new(0, 50, 0, 18)
			valLbl.Font = Enum.Font.GothamBold
			valLbl.Text = tostring(minVal)
			valLbl.TextColor3 = Color3.fromRGB(200, 160, 255)
			valLbl.TextSize = 13
			valLbl.TextXAlignment = Enum.TextXAlignment.Right

			local track = Instance.new("Frame")
			track.Name = "Track"
			track.Parent = container
			track.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
			track.BorderSizePixel = 0
			track.Position = UDim2.new(0, 10, 0, 28)
			track.Size = UDim2.new(1, -20, 0, 6)
			addCorner(track, 3)

			local fill = Instance.new("Frame")
			fill.Name = "Indicator"
			fill.Parent = track
			fill.BackgroundColor3 = opts.main_color
			fill.BorderSizePixel = 0
			fill.Size = UDim2.new(0, 0, 1, 0)
			addCorner(fill, 3)

			local thumb = Instance.new("Frame")
			thumb.Name = "Thumb"
			thumb.Parent = fill
			thumb.BackgroundColor3 = Color3.new(1, 1, 1)
			thumb.BorderSizePixel = 0
			thumb.Position = UDim2.new(1, -6, 0.5, -6)
			thumb.Size = UDim2.new(0, 12, 0, 12)
			addCorner(thumb, 6)

			local hitArea = Instance.new("TextButton")
			hitArea.Name = "HitArea"
			hitArea.Parent = container
			hitArea.BackgroundTransparency = 1
			hitArea.Position = UDim2.new(0, 6, 0, 20)
			hitArea.Size = UDim2.new(1, -12, 0, 20)
			hitArea.Text = ""

			local sliding = false

			local function applyRatio(ratio)
				ratio = math.clamp(ratio, 0, 1)
				fill.Size = UDim2.new(ratio, 0, 1, 0)
				local computed = math.floor(((maxVal - minVal) * ratio) + minVal + 0.5)
				valLbl.Text = tostring(computed)
				pcall(callback, computed)
			end

			local function updateFromInput(inputPos)
				local relX = (inputPos.X - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X)
				applyRatio(relX)
			end

			runtime:Connect(hitArea.InputBegan, function(input)
				if readonly or dropdown_open then return end
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					sliding = true
					updateFromInput(input.Position)
				end
			end)

			runtime:Connect(UIS.InputChanged, function(input)
				if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					updateFromInput(input.Position)
				end
			end)

			runtime:Connect(UIS.InputEnded, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					sliding = false
				end
			end)

			function slider_data:Set(new_value)
				new_value = tonumber(new_value) or minVal
				local ratio = (maxVal > minVal) and ((new_value - minVal) / (maxVal - minVal)) or 0
				applyRatio(ratio)
			end

			slider_data:Set(minVal)
			return slider_data, container
		end

		-- ELEMENTO: TEXTBOX
		function tab_data:AddTextBox(textbox_text, callback, textbox_options)
			callback = typeof(callback) == "function" and callback or function() end
			local clearOnEnter = (typeof(textbox_options) == "table" and textbox_options.clear ~= nil) and textbox_options.clear or true

			local box = Instance.new("TextBox")
			box.Name = "TextBox"
			box.Parent = tabPage
			box.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
			box.BorderSizePixel = 0
			box.Size = UDim2.new(1, 0, 0, 28)
			box.Font = Enum.Font.GothamSemibold
			box.PlaceholderText = tostring(textbox_text or "Input Text")
			box.PlaceholderColor3 = Color3.fromRGB(135, 135, 150)
			box.Text = ""
			box.TextColor3 = Color3.fromRGB(235, 235, 245)
			box.TextSize = 13
			box.ClearTextOnFocus = false
			addCorner(box, 6)
			local boxStroke = addStroke(box, Color3.fromRGB(45, 45, 55), 1, 0.4)

			runtime:Connect(box.Focused, function()
				Tween(boxStroke, {Color = opts.main_color, Transparency = 0}, 0.12)
			end)

			runtime:Connect(box.FocusLost, function(enterPressed)
				Tween(boxStroke, {Color = Color3.fromRGB(45, 45, 55), Transparency = 0.4}, 0.12)
				if enterPressed and #box.Text > 0 then
					pcall(callback, box.Text)
					if clearOnEnter then box.Text = "" end
				end
			end)

			return box
		end

		-- ELEMENTO: DROPDOWN
		function tab_data:AddDropdown(dropdown_name, callback)
			local dropdown_data = {}
			local itemsMap = {}
			dropdown_name = tostring(dropdown_name or "Dropdown")
			callback = typeof(callback) == "function" and callback or function() end

			local wrapper = Instance.new("Frame")
			wrapper.Name = "Dropdown"
			wrapper.Parent = tabPage
			wrapper.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
			wrapper.BorderSizePixel = 0
			wrapper.ClipsDescendants = true
			wrapper.Size = UDim2.new(1, 0, 0, 28)
			addCorner(wrapper, 6)
			addStroke(wrapper, Color3.fromRGB(45, 45, 55), 1, 0.4)

			local headerBtn = Instance.new("TextButton")
			headerBtn.Name = "Header"
			headerBtn.Parent = wrapper
			headerBtn.BackgroundTransparency = 1
			headerBtn.Size = UDim2.new(1, 0, 0, 28)
			headerBtn.Font = Enum.Font.GothamSemibold
			headerBtn.Text = "   " .. dropdown_name
			headerBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
			headerBtn.TextSize = 13
			headerBtn.TextXAlignment = Enum.TextXAlignment.Left

			local arrow = Instance.new("TextLabel")
			arrow.Name = "Arrow"
			arrow.Parent = headerBtn
			arrow.BackgroundTransparency = 1
			arrow.Position = UDim2.new(1, -26, 0, 0)
			arrow.Size = UDim2.new(0, 20, 1, 0)
			arrow.Font = Enum.Font.GothamBold
			arrow.Text = "▼"
			arrow.TextColor3 = Color3.fromRGB(180, 180, 195)
			arrow.TextSize = 11

			local listFrame = Instance.new("ScrollingFrame")
			listFrame.Name = "Objects"
			listFrame.Parent = wrapper
			listFrame.BackgroundTransparency = 1
			listFrame.BorderSizePixel = 0
			listFrame.Position = UDim2.new(0, 4, 0, 30)
			listFrame.Size = UDim2.new(1, -8, 0, 0)
			listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
			listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			listFrame.ScrollBarThickness = 2
			listFrame.ScrollBarImageColor3 = opts.main_color

			local listLayout = Instance.new("UIListLayout")
			listLayout.Parent = listFrame
			listLayout.SortOrder = Enum.SortOrder.LayoutOrder
			listLayout.Padding = UDim.new(0, 2)

			local isExpanded = false

			local function refreshHeight()
				local count = 0
				for _, child in ipairs(listFrame:GetChildren()) do
					if child:IsA("TextButton") then count = count + 1 end
				end
				local targetListH = math.min(count * 24, 120)
				listFrame.Size = UDim2.new(1, -8, 0, targetListH)
				Tween(wrapper, {Size = UDim2.new(1, 0, 0, isExpanded and (32 + targetListH) or 28)}, 0.14)
			end

			runtime:Connect(headerBtn.MouseButton1Click, function()
				isExpanded = not isExpanded
				dropdown_open = isExpanded
				Tween(arrow, {Rotation = isExpanded and 180 or 0}, 0.14)
				refreshHeight()
			end)

			function dropdown_data:Add(itemName)
				itemName = tostring(itemName or "Item")
				if itemsMap[itemName] and itemsMap[itemName].Parent then
					return itemsMap[itemName]
				end

				local itemBtn = Instance.new("TextButton")
				itemBtn.Name = itemName
				itemBtn.Parent = listFrame
				itemBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 42)
				itemBtn.BorderSizePixel = 0
				itemBtn.Size = UDim2.new(1, 0, 0, 22)
				itemBtn.Font = Enum.Font.GothamSemibold
				itemBtn.Text = "  " .. itemName
				itemBtn.TextColor3 = Color3.fromRGB(210, 210, 220)
				itemBtn.TextSize = 12
				itemBtn.TextXAlignment = Enum.TextXAlignment.Left
				itemBtn.AutoButtonColor = false
				addCorner(itemBtn, 4)

				itemsMap[itemName] = itemBtn

				runtime:Connect(itemBtn.MouseEnter, function()
					itemBtn.BackgroundColor3 = opts.main_color
				end)
				runtime:Connect(itemBtn.MouseLeave, function()
					itemBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 42)
				end)
				runtime:Connect(itemBtn.MouseButton1Click, function()
					headerBtn.Text = "   [ " .. itemName .. " ]"
					isExpanded = false
					dropdown_open = false
					Tween(arrow, {Rotation = 0}, 0.14)
					refreshHeight()
					pcall(callback, itemName)
				end)

				if isExpanded then refreshHeight() end
				return itemBtn
			end

			function dropdown_data:Remove(itemName)
				itemName = tostring(itemName or "")
				if itemsMap[itemName] then
					itemsMap[itemName]:Destroy()
					itemsMap[itemName] = nil
					if isExpanded then refreshHeight() end
				end
			end

			function dropdown_data:Clear()
				for k, v in pairs(itemsMap) do
					if v and v.Parent then v:Destroy() end
					itemsMap[k] = nil
				end
				headerBtn.Text = "   " .. dropdown_name
				if isExpanded then refreshHeight() end
			end

			function dropdown_data:Refresh(items)
				dropdown_data:Clear()
				for _, item in ipairs(items or {}) do
					dropdown_data:Add(item)
				end
			end

			return dropdown_data, wrapper
		end

		-- ELEMENTO: FOLDER
		function tab_data:AddFolder(folder_name)
			local folder_data = {}
			folder_name = tostring(folder_name or "Folder")

			local folderBox = Instance.new("Frame")
			folderBox.Name = "Folder"
			folderBox.Parent = tabPage
			folderBox.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
			folderBox.BorderSizePixel = 0
			folderBox.ClipsDescendants = true
			folderBox.Size = UDim2.new(1, 0, 0, 28)
			addCorner(folderBox, 6)
			addStroke(folderBox, opts.main_color, 1, 0.5)

			local folderBtn = Instance.new("TextButton")
			folderBtn.Name = "Header"
			folderBtn.Parent = folderBox
			folderBtn.BackgroundColor3 = opts.main_color
			folderBtn.BorderSizePixel = 0
			folderBtn.Size = UDim2.new(1, 0, 0, 28)
			folderBtn.Font = Enum.Font.GothamBold
			folderBtn.Text = "  ▸  " .. folder_name
			folderBtn.TextColor3 = Color3.new(1, 1, 1)
			folderBtn.TextSize = 13
			folderBtn.TextXAlignment = Enum.TextXAlignment.Left
			addCorner(folderBtn, 6)

			local content = Instance.new("Frame")
			content.Name = "Objects"
			content.Parent = folderBox
			content.BackgroundTransparency = 1
			content.Position = UDim2.new(0, 6, 0, 32)
			content.Size = UDim2.new(1, -12, 0, 0)
			content.AutomaticSize = Enum.AutomaticSize.Y

			local contentLayout = Instance.new("UIListLayout")
			contentLayout.Parent = content
			contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
			contentLayout.Padding = UDim.new(0, 5)

			local folderOpen = false

			local function syncFolderSize()
				if folderOpen then
					folderBox.Size = UDim2.new(1, 0, 0, 38 + contentLayout.AbsoluteContentSize.Y)
				else
					folderBox.Size = UDim2.new(1, 0, 0, 28)
				end
			end

			runtime:Connect(contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"), syncFolderSize)

			runtime:Connect(folderBtn.MouseButton1Click, function()
				folderOpen = not folderOpen
				folderBtn.Text = (folderOpen and "  ▾  " or "  ▸  ") .. folder_name
				syncFolderSize()
			end)

			for methodName, methodFn in pairs(tab_data) do
				if methodName ~= "Show" and methodName ~= "AddFolder" then
					folder_data[methodName] = function(...)
						local ret = {methodFn(...)}
						local obj = (typeof(ret[1]) == "table") and ret[2] or ret[1]
						if obj and typeof(obj) == "Instance" then
							obj.Parent = content
						end
						syncFolderSize()
						return table.unpack(ret)
					end
				end
			end

			return folder_data, folderBox
		end

		return tab_data, tabPage
	end

	return window_data, Window
end

return library
