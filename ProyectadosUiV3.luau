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
	bg_color = Color3.fromRGB(18, 18, 22),
	text_color = Color3.fromRGB(220, 220, 230),
	min_size = Vector2.new(440, 310),
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
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local cloneref = type(cloneref) == "function" and cloneref or function(...) return ... end

local CoreGui
if not isSolara then pcall(function() CoreGui = game:GetService("CoreGui") end) end
if CoreGui then pcall(function() CoreGui = cloneref(CoreGui) end) end

-- Sistema de guardado persistente (Tamaño + Colores)
local CONFIG_FILE = "UniversalUI_Config.json"
_G.UniversalUISavedConfig = _G.UniversalUISavedConfig or {}

do
	if type(isfile) == "function" and type(readfile) == "function" then
		local ok, raw = pcall(function()
			if isfile(CONFIG_FILE) then
				return readfile(CONFIG_FILE)
			end
		end)
		if ok and type(raw) == "string" and #raw > 0 then
			local decOk, decoded = pcall(function()
				return HttpService:JSONDecode(raw)
			end)
			if decOk and type(decoded) == "table" then
				for k, v in pairs(decoded) do
					_G.UniversalUISavedConfig[k] = v
				end
			end
		end
	end
end

local function flushConfigFile()
	if type(writefile) == "function" then
		pcall(function()
			local encoded = HttpService:JSONEncode(_G.UniversalUISavedConfig)
			writefile(CONFIG_FILE, encoded)
		end)
	end
end

local function colorToTable(c)
	return {
		r = math.floor(c.R * 255 + 0.5),
		g = math.floor(c.G * 255 + 0.5),
		b = math.floor(c.B * 255 + 0.5)
	}
end

local function tableToColor(t)
	if type(t) == "table" and tonumber(t.r) and tonumber(t.g) and tonumber(t.b) then
		return Color3.fromRGB(
			math.clamp(tonumber(t.r), 0, 255),
			math.clamp(tonumber(t.g), 0, 255),
			math.clamp(tonumber(t.b), 0, 255)
		)
	end
	return nil
end

local function saveWindowSize(winKey, width, height)
	_G.UniversalUISavedConfig[winKey] = _G.UniversalUISavedConfig[winKey] or {}
	_G.UniversalUISavedConfig[winKey].w = math.floor(width)
	_G.UniversalUISavedConfig[winKey].h = math.floor(height)
	flushConfigFile()
end

local function getSavedWindowSize(winKey)
	local entry = _G.UniversalUISavedConfig[winKey]
	if type(entry) == "table" and tonumber(entry.w) and tonumber(entry.h) then
		return Vector2.new(tonumber(entry.w), tonumber(entry.h))
	end
	return nil
end

local function saveWindowColors(winKey, mainCol, bgCol, textCol)
	_G.UniversalUISavedConfig[winKey] = _G.UniversalUISavedConfig[winKey] or {}
	if typeof(mainCol) == "Color3" then
		_G.UniversalUISavedConfig[winKey].main_color = colorToTable(mainCol)
	end
	if typeof(bgCol) == "Color3" then
		_G.UniversalUISavedConfig[winKey].bg_color = colorToTable(bgCol)
	end
	if typeof(textCol) == "Color3" then
		_G.UniversalUISavedConfig[winKey].text_color = colorToTable(textCol)
	end
	flushConfigFile()
end

local function clearSavedWindowColors(winKey)
	local entry = _G.UniversalUISavedConfig[winKey]
	if type(entry) == "table" then
		entry.main_color = nil
		entry.bg_color = nil
		entry.text_color = nil
		flushConfigFile()
	end
end

local function getSavedWindowColors(winKey)
	local entry = _G.UniversalUISavedConfig[winKey]
	if type(entry) == "table" then
		return tableToColor(entry.main_color), tableToColor(entry.bg_color), tableToColor(entry.text_color)
	end
	return nil, nil, nil
end

-- Utilidades de ajuste de tonos derivados del fondo y acento
local function shiftColor(c, delta)
	return Color3.new(
		math.clamp(c.R + delta, 0, 1),
		math.clamp(c.G + delta, 0, 1),
		math.clamp(c.B + delta, 0, 1)
	)
end

-- Control de bloqueo de cámara al arrastrar la UI
local cameraLocks = 0
local savedCameraType = nil

local function setCameraLocked(locked)
	local cam = workspace.CurrentCamera
	if not cam then return end

	if locked then
		cameraLocks = cameraLocks + 1
		if cameraLocks == 1 then
			savedCameraType = cam.CameraType
			cam.CameraType = Enum.CameraType.Scriptable
		end
	else
		cameraLocks = math.max(0, cameraLocks - 1)
		if cameraLocks == 0 and savedCameraType ~= nil then
			if cam.CameraType == Enum.CameraType.Scriptable then
				cam.CameraType = savedCameraType
			end
			savedCameraType = nil
		end
	end
end

runtime:AddCleanup(function()
	cameraLocks = 0
	local cam = workspace.CurrentCamera
	if cam and savedCameraType ~= nil and cam.CameraType == Enum.CameraType.Scriptable then
		cam.CameraType = savedCameraType
	end
	savedCameraType = nil
end)

local function getViewportSize()
	local cam = workspace.CurrentCamera
	if cam and cam.ViewportSize.X > 0 and cam.ViewportSize.Y > 0 then
		return cam.ViewportSize
	end
	return Vector2.new(800, 600)
end

local function isCompactDevice()
	local vp = getViewportSize()
	return (UIS.TouchEnabled and not UIS.KeyboardEnabled) or vp.X < 650 or vp.Y < 450
end

local function getResponsiveDimensions(requestedSize, isCustomSaved)
	local vp = getViewportSize()
	local compact = isCompactDevice()

	local maxAllowedW = math.max(260, vp.X - (compact and 24 or 40))
	local maxAllowedH = math.max(190, vp.Y - (compact and 76 or 90))

	local targetW = (compact and not isCustomSaved) and math.min(requestedSize.X, math.floor(vp.X * 0.88)) or requestedSize.X
	local targetH = (compact and not isCustomSaved) and math.min(requestedSize.Y, math.floor(vp.Y * 0.72)) or requestedSize.Y

	local finalW = math.clamp(targetW, 260, maxAllowedW)
	local finalH = math.clamp(targetH, 190, maxAllowedH)

	local hardMinW = math.min(compact and 270 or 340, maxAllowedW)
	local hardMinH = math.min(compact and 195 or 240, maxAllowedH)

	return Vector2.new(finalW, finalH), Vector2.new(hardMinW, hardMinH), vp
end

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

local btnSize = isCompactDevice() and 40 or 44
local floatingBtn = Instance.new("TextButton")
floatingBtn.Name = "OpenCloseBtn"
floatingBtn.Parent = toggleGui
floatingBtn.Active = true
floatingBtn.BackgroundColor3 = ui_options.main_color
floatingBtn.Position = UDim2.new(0.5, -math.floor(btnSize / 2), 0, 10)
floatingBtn.Size = UDim2.new(0, btnSize, 0, btnSize)
floatingBtn.Font = Enum.Font.GothamBold
floatingBtn.Text = "⚙️"
floatingBtn.TextSize = isCompactDevice() and 18 or 20
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
	local isDragging, dragInput, dragStart, startPos, hasMoved = false, nil, nil, nil, false

	runtime:Connect(floatingBtn.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if not isDragging then
				isDragging = true
				dragInput = input
				hasMoved = false
				dragStart = input.Position
				startPos = floatingBtn.Position
				setCameraLocked(true)
			end
		end
	end)

	runtime:Connect(UIS.InputChanged, function(input)
		if isDragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement) then
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
		if isDragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			isDragging = false
			dragInput = nil
			setCameraLocked(false)
			if not hasMoved and not checks.binding then
				imgui.Enabled = not imgui.Enabled
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

-- Permite arrastrar desde el borde grueso o cualquier área libre manteniendo quieta la cámara
local function makeDraggable(dragHandle, targetFrame)
	local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

	runtime:Connect(dragHandle.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if not dragging then
				dragging = true
				dragInput = input
				dragStart = input.Position
				startPos = targetFrame.Position
				setCameraLocked(true)
			end
		end
	end)

	runtime:Connect(UIS.InputChanged, function(input)
		if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement) then
			local delta = input.Position - dragStart
			targetFrame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	runtime:Connect(UIS.InputEnded, function(input)
		if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			dragInput = nil
			setCameraLocked(false)
		end
	end)
end

local windows = 0
local library = {Runtime = runtime}

function library:Destroy()
	runtime:Destroy()
end

function library:FormatWindows()
	local vp = getViewportSize()
	local xOffset = 15
	local yOffset = 60
	for _, win in ipairs(windowsFrame:GetChildren()) do
		if win:IsA("Frame") then
			if xOffset + win.AbsoluteSize.X > vp.X and xOffset > 15 then
				xOffset = 15
				yOffset = yOffset + 40
			end
			win.Position = UDim2.new(0, xOffset, 0, yOffset)
			xOffset = xOffset + win.AbsoluteSize.X + 12
		end
	end
end

function library:AddWindow(title, options)
	if not runtime.Alive then return end
	windows = windows + 1

	local winKey = tostring(title or ("Window_" .. windows))
	local defaultSize = (typeof(options) == "table" and options.min_size) or ui_options.min_size
	local savedSize = getSavedWindowSize(winKey)
	local requestedSize = savedSize or defaultSize
	local initialSize, hardMinSize, vp = getResponsiveDimensions(requestedSize, savedSize ~= nil)

	local defaultMainColor = (typeof(options) == "table" and typeof(options.main_color) == "Color3") and options.main_color or ui_options.main_color
	local defaultBgColor = (typeof(options) == "table" and typeof(options.bg_color) == "Color3") and options.bg_color or ui_options.bg_color
	local defaultTextColor = (typeof(options) == "table" and typeof(options.text_color) == "Color3") and options.text_color or ui_options.text_color

	local savedMain, savedBg, savedText = getSavedWindowColors(winKey)

	local opts = {
		main_color = savedMain or defaultMainColor,
		bg_color = savedBg or defaultBgColor,
		text_color = savedText or defaultTextColor,
		min_size = hardMinSize,
		can_resize = (typeof(options) == "table" and options.can_resize ~= nil) and options.can_resize or ui_options.can_resize,
		tween_time = 0.16,
	}

	-- Suscriptores de tema para actualizar colores en tiempo real sin bucles Heartbeat
	local themeCallbacks = {}
	local function onThemeChange(fn)
		table.insert(themeCallbacks, fn)
		pcall(fn, opts)
	end
	local function broadcastTheme()
		floatingBtn.BackgroundColor3 = opts.main_color
		floatingStroke.Color = shiftColor(opts.main_color, 0.35)
		for _, fn in ipairs(themeCallbacks) do
			pcall(fn, opts)
		end
	end

	floatingBtn.BackgroundColor3 = opts.main_color
	floatingStroke.Color = shiftColor(opts.main_color, 0.35)

	local startX = math.max(12, math.floor((vp.X - initialSize.X) / 2) + ((windows - 1) * 18))
	local startY = math.clamp(60 + ((windows - 1) * 18), 54, math.max(54, vp.Y - initialSize.Y - 12))

	local BORDER_THICKNESS = 5
	local MINIMIZED_HEIGHT = 30 + (BORDER_THICKNESS * 2)

	-- Marco Exterior (Borde grueso e interactivo para arrastrar toda la UI)
	local Window = Instance.new("Frame")
	Window.Name = "Window_" .. windows
	Window.Parent = windowsFrame
	Window.Active = true
	Window.BackgroundColor3 = opts.main_color
	Window.BorderSizePixel = 0
	Window.ClipsDescendants = true
	Window.Position = UDim2.new(0, startX, 0, startY)
	Window.Size = UDim2.new(0, initialSize.X, 0, initialSize.Y)
	addCorner(Window, 10)
	local windowGlowStroke = addStroke(Window, shiftColor(opts.main_color, 0.35), 1.5, 0.35)

	local borderGrad = Instance.new("UIGradient")
	borderGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(195, 195, 210))
	})
	borderGrad.Rotation = 45
	borderGrad.Parent = Window

	makeDraggable(Window, Window)

	-- Contenedor Interior
	local InnerFrame = Instance.new("Frame")
	InnerFrame.Name = "Inner"
	InnerFrame.Parent = Window
	InnerFrame.Active = true
	InnerFrame.BackgroundColor3 = opts.bg_color
	InnerFrame.BorderSizePixel = 0
	InnerFrame.ClipsDescendants = true
	InnerFrame.Position = UDim2.new(0, BORDER_THICKNESS, 0, BORDER_THICKNESS)
	InnerFrame.Size = UDim2.new(1, -(BORDER_THICKNESS * 2), 1, -(BORDER_THICKNESS * 2))
	addCorner(InnerFrame, 7)

	-- Barra Superior
	local Bar = Instance.new("Frame")
	Bar.Name = "Bar"
	Bar.Parent = InnerFrame
	Bar.BackgroundColor3 = opts.main_color
	Bar.BorderSizePixel = 0
	Bar.Size = UDim2.new(1, 0, 0, 30)
	addCorner(Bar, 7)

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

	onThemeChange(function(c)
		Window.BackgroundColor3 = c.main_color
		windowGlowStroke.Color = shiftColor(c.main_color, 0.35)
		InnerFrame.BackgroundColor3 = c.bg_color
		Bar.BackgroundColor3 = c.main_color
		BarCover.BackgroundColor3 = c.main_color
	end)

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
	TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.ZIndex = 3

	-- Panel Lateral Izquierdo de Pestañas
	local sidebarW = isCompactDevice() and 96 or 115

	local TabSelection = Instance.new("ScrollingFrame")
	TabSelection.Name = "TabSelection"
	TabSelection.Parent = InnerFrame
	TabSelection.BackgroundColor3 = shiftColor(opts.bg_color, 0.025)
	TabSelection.BorderSizePixel = 0
	TabSelection.Position = UDim2.new(0, 8, 0, 36)
	TabSelection.Size = UDim2.new(0, sidebarW, 1, -44)
	TabSelection.CanvasSize = UDim2.new(0, 0, 0, 0)
	TabSelection.AutomaticCanvasSize = Enum.AutomaticSize.Y
	TabSelection.ScrollBarThickness = 2
	TabSelection.ScrollBarImageColor3 = opts.main_color
	TabSelection.Visible = false
	addCorner(TabSelection, 6)
	local sidebarStroke = addStroke(TabSelection, shiftColor(opts.bg_color, 0.11), 1, 0.3)

	onThemeChange(function(c)
		TabSelection.BackgroundColor3 = shiftColor(c.bg_color, 0.025)
		TabSelection.ScrollBarImageColor3 = c.main_color
		sidebarStroke.Color = shiftColor(c.bg_color, 0.11)
	end)

	local TabButtons = Instance.new("Frame")
	TabButtons.Name = "TabButtons"
	TabButtons.Parent = TabSelection
	TabButtons.BackgroundTransparency = 1
	TabButtons.Position = UDim2.new(0, 4, 0, 4)
	TabButtons.Size = UDim2.new(1, -8, 0, 0)
	TabButtons.AutomaticSize = Enum.AutomaticSize.Y

	local tabListLayout = Instance.new("UIListLayout")
	tabListLayout.Parent = TabButtons
	tabListLayout.FillDirection = Enum.FillDirection.Vertical
	tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabListLayout.Padding = UDim.new(0, 4)

	-- Contenedor Principal de Pestañas
	local TabsContainer = Instance.new("Frame")
	TabsContainer.Name = "Tabs"
	TabsContainer.Parent = InnerFrame
	TabsContainer.BackgroundTransparency = 1
	TabsContainer.Position = UDim2.new(0, 10, 0, 36)
	TabsContainer.Size = UDim2.new(1, -20, 1, -44)

	-- Redimensionador
	local Resizer = Instance.new("TextButton")
	Resizer.Name = "Resizer"
	Resizer.Parent = Window
	Resizer.BackgroundTransparency = 1
	Resizer.Position = UDim2.new(1, -24, 1, -24)
	Resizer.Size = UDim2.new(0, 24, 0, 24)
	Resizer.Text = "◢"
	Resizer.TextColor3 = Color3.fromRGB(230, 215, 255)
	Resizer.TextSize = 12
	Resizer.Visible = opts.can_resize
	Resizer.ZIndex = 10

	local isOpen = true
	local savedHeight = initialSize.Y
	local hasTabs = false

	local function clampToViewport()
		if not Window or not Window.Parent then return end
		local currentReq = getSavedWindowSize(winKey) or defaultSize
		local _, newHardMin, currentVp = getResponsiveDimensions(currentReq, true)
		opts.min_size = newHardMin

		sidebarW = isCompactDevice() and 96 or 115
		TabSelection.Size = UDim2.new(0, sidebarW, 1, -44)
		if hasTabs then
			TabsContainer.Position = UDim2.new(0, sidebarW + 14, 0, 36)
			TabsContainer.Size = UDim2.new(1, -(sidebarW + 22), 1, -44)
		end

		local maxW = math.max(260, currentVp.X - 20)
		local maxH = math.max(190, currentVp.Y - 70)

		local curW = math.min(Window.Size.X.Offset, maxW)
		if isOpen then
			local curH = math.min(Window.Size.Y.Offset, maxH)
			savedHeight = curH
			Window.Size = UDim2.new(0, curW, 0, curH)
		else
			savedHeight = math.min(savedHeight, maxH)
			Window.Size = UDim2.new(0, curW, 0, MINIMIZED_HEIGHT)
		end

		local clampedX = math.clamp(Window.Position.X.Offset, 6, math.max(6, currentVp.X - curW - 6))
		local clampedY = math.clamp(Window.Position.Y.Offset, 6, math.max(6, currentVp.Y - Window.Size.Y.Offset - 6))
		Window.Position = UDim2.new(0, clampedX, 0, clampedY)
	end

	do
		local camConn
		local function bindCamera(cam)
			if camConn then camConn:Disconnect() end
			if cam then
				camConn = runtime:Connect(cam:GetPropertyChangedSignal("ViewportSize"), clampToViewport)
			end
		end
		bindCamera(workspace.CurrentCamera)
		runtime:Connect(workspace:GetPropertyChangedSignal("CurrentCamera"), function()
			bindCamera(workspace.CurrentCamera)
			clampToViewport()
		end)
	end

	if opts.can_resize then
		local resizing, resizeInput, resizeStart, startSize = false, nil, nil, nil
		runtime:Connect(Resizer.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				if not resizing then
					resizing = true
					resizeInput = input
					resizeStart = input.Position
					startSize = Window.AbsoluteSize
					setCameraLocked(true)
				end
			end
		end)
		runtime:Connect(UIS.InputChanged, function(input)
			if resizing and (input == resizeInput or input.UserInputType == Enum.UserInputType.MouseMovement) then
				local currentVp = getViewportSize()
				local delta = input.Position - resizeStart
				local newX = math.clamp(startSize.X + delta.X, opts.min_size.X, currentVp.X - 16)
				local newY = math.clamp(startSize.Y + delta.Y, opts.min_size.Y, currentVp.Y - 60)
				Window.Size = UDim2.new(0, newX, 0, newY)
			end
		end)
		runtime:Connect(UIS.InputEnded, function(input)
			if resizing and (input == resizeInput or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
				resizing = false
				resizeInput = nil
				setCameraLocked(false)
				savedHeight = Window.Size.Y.Offset
				saveWindowSize(winKey, Window.Size.X.Offset, Window.Size.Y.Offset)
			end
		end)
	end

	-- Lógica de Minimizar
	local canToggle = true

	runtime:Connect(ToggleBtn.MouseButton1Click, function()
		if not canToggle then return end
		canToggle = false

		if isOpen then
			savedHeight = Window.AbsoluteSize.Y
			TabsContainer.Visible = false
			TabSelection.Visible = false
			Resizer.Visible = false
			BarCover.Visible = false
			Tween(Window, {Size = UDim2.new(0, Window.AbsoluteSize.X, 0, MINIMIZED_HEIGHT)}, opts.tween_time)
			ToggleBtn.Text = "❤️‍🔥"
		else
			Tween(Window, {Size = UDim2.new(0, Window.AbsoluteSize.X, 0, savedHeight)}, opts.tween_time)
			nativeTask.wait(opts.tween_time * 0.6)
			BarCover.Visible = true
			if hasTabs then
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

	-- Métodos para cambiar y guardar colores en tiempo real
	function window_data:SetMainColor(new_color)
		if typeof(new_color) == "Color3" then
			opts.main_color = new_color
			broadcastTheme()
			saveWindowColors(winKey, opts.main_color, nil, nil)
		end
	end

	function window_data:SetBackgroundColor(new_color)
		if typeof(new_color) == "Color3" then
			opts.bg_color = new_color
			broadcastTheme()
			saveWindowColors(winKey, nil, opts.bg_color, nil)
		end
	end

	function window_data:SetTextColor(new_color)
		if typeof(new_color) == "Color3" then
			opts.text_color = new_color
			broadcastTheme()
			saveWindowColors(winKey, nil, nil, opts.text_color)
		end
	end

	function window_data:SetColors(color_table)
		if typeof(color_table) ~= "table" then return end
		if typeof(color_table.main_color) == "Color3" then opts.main_color = color_table.main_color end
		if typeof(color_table.bg_color) == "Color3" then opts.bg_color = color_table.bg_color end
		if typeof(color_table.text_color) == "Color3" then opts.text_color = color_table.text_color end
		broadcastTheme()
		saveWindowColors(winKey, opts.main_color, opts.bg_color, opts.text_color)
	end

	function window_data:ResetColors()
		opts.main_color = defaultMainColor
		opts.bg_color = defaultBgColor
		opts.text_color = defaultTextColor
		broadcastTheme()
		clearSavedWindowColors(winKey)
	end

	local dropdown_open = false
	local activeTabBtn = nil

	function window_data:AddTab(tab_name)
		local tab_data = {}
		tab_name = tostring(tab_name or "New Tab")

		if not hasTabs then
			hasTabs = true
			TabsContainer.Position = UDim2.new(0, sidebarW + 14, 0, 36)
			TabsContainer.Size = UDim2.new(1, -(sidebarW + 22), 1, -44)
		end
		if isOpen then TabSelection.Visible = true end

		local tabBtn = Instance.new("TextButton")
		tabBtn.Name = "TabBtn_" .. tab_name
		tabBtn.Parent = TabButtons
		tabBtn.BackgroundColor3 = shiftColor(opts.bg_color, 0.06)
		tabBtn.BorderSizePixel = 0
		tabBtn.Font = Enum.Font.GothamSemibold
		tabBtn.Text = tab_name
		tabBtn.TextColor3 = shiftColor(opts.text_color, -0.14)
		tabBtn.TextSize = 12
		tabBtn.TextTruncate = Enum.TextTruncate.AtEnd
		tabBtn.TextXAlignment = Enum.TextXAlignment.Left
		tabBtn.AutoButtonColor = false
		tabBtn.Size = UDim2.new(1, 0, 0, 28)
		addCorner(tabBtn, 5)

		local tabBtnPad = Instance.new("UIPadding")
		tabBtnPad.PaddingLeft = UDim.new(0, 8)
		tabBtnPad.PaddingRight = UDim.new(0, 6)
		tabBtnPad.Parent = tabBtn

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

		onThemeChange(function(c)
			tabPage.ScrollBarImageColor3 = c.main_color
			if activeTabBtn == tabBtn then
				tabBtn.BackgroundColor3 = c.main_color
				tabBtn.TextColor3 = Color3.new(1, 1, 1)
			else
				tabBtn.BackgroundColor3 = shiftColor(c.bg_color, 0.06)
				tabBtn.TextColor3 = shiftColor(c.text_color, -0.14)
			end
		end)

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
			activeTabBtn = tabBtn
			for _, child in ipairs(TabButtons:GetChildren()) do
				if child:IsA("TextButton") then
					Tween(child, {
						BackgroundColor3 = shiftColor(opts.bg_color, 0.06),
						TextColor3 = shiftColor(opts.text_color, -0.14)
					}, 0.12)
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
			lbl.TextColor3 = opts.text_color
			lbl.TextSize = 13
			lbl.TextWrapped = true
			lbl.TextXAlignment = Enum.TextXAlignment.Left

			onThemeChange(function(c)
				lbl.TextColor3 = c.text_color
			end)

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

			onThemeChange(function(c)
				btn.BackgroundColor3 = c.main_color
			end)

			runtime:Connect(btn.MouseEnter, function()
				Tween(btn, {BackgroundColor3 = shiftColor(opts.main_color, 0.08)}, 0.1)
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

		-- ELEMENTO: SWITCH
		function tab_data:AddSwitch(switch_text, callback)
			local switch_data = {}
			callback = typeof(callback) == "function" and callback or function() end

			local container = Instance.new("TextButton")
			container.Name = "Switch"
			container.Parent = tabPage
			container.BackgroundColor3 = shiftColor(opts.bg_color, 0.032)
			container.BorderSizePixel = 0
			container.Size = UDim2.new(1, 0, 0, 30)
			container.Text = ""
			container.AutoButtonColor = false
			addCorner(container, 6)
			local swStroke = addStroke(container, shiftColor(opts.bg_color, 0.11), 1, 0.4)

			local titleLbl = Instance.new("TextLabel")
			titleLbl.Name = "Title"
			titleLbl.Parent = container
			titleLbl.BackgroundTransparency = 1
			titleLbl.Position = UDim2.new(0, 10, 0, 0)
			titleLbl.Size = UDim2.new(1, -60, 1, 0)
			titleLbl.Font = Enum.Font.GothamSemibold
			titleLbl.Text = tostring(switch_text or "Switch")
			titleLbl.TextColor3 = opts.text_color
			titleLbl.TextSize = 13
			titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left

			local pill = Instance.new("Frame")
			pill.Name = "Pill"
			pill.Parent = container
			pill.BackgroundColor3 = shiftColor(opts.bg_color, 0.13)
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

			onThemeChange(function(c)
				container.BackgroundColor3 = shiftColor(c.bg_color, 0.032)
				swStroke.Color = shiftColor(c.bg_color, 0.11)
				titleLbl.TextColor3 = c.text_color
				pill.BackgroundColor3 = toggled and c.main_color or shiftColor(c.bg_color, 0.13)
			end)

			local function updateVisual(state)
				if state then
					Tween(pill, {BackgroundColor3 = opts.main_color}, 0.15)
					Tween(knob, {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = Color3.new(1, 1, 1)}, 0.15)
				else
					Tween(pill, {BackgroundColor3 = shiftColor(opts.bg_color, 0.13)}, 0.15)
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

		-- ELEMENTO: SLIDER
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
			container.BackgroundColor3 = shiftColor(opts.bg_color, 0.032)
			container.BorderSizePixel = 0
			container.Size = UDim2.new(1, 0, 0, 42)
			addCorner(container, 6)
			local slStroke = addStroke(container, shiftColor(opts.bg_color, 0.11), 1, 0.4)

			local titleLbl = Instance.new("TextLabel")
			titleLbl.Name = "Title"
			titleLbl.Parent = container
			titleLbl.BackgroundTransparency = 1
			titleLbl.Position = UDim2.new(0, 10, 0, 4)
			titleLbl.Size = UDim2.new(1, -70, 0, 18)
			titleLbl.Font = Enum.Font.GothamSemibold
			titleLbl.Text = tostring(slider_text or "Slider")
			titleLbl.TextColor3 = opts.text_color
			titleLbl.TextSize = 13
			titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left

			local valLbl = Instance.new("TextLabel")
			valLbl.Name = "Value"
			valLbl.Parent = container
			valLbl.BackgroundTransparency = 1
			valLbl.Position = UDim2.new(1, -60, 0, 4)
			valLbl.Size = UDim2.new(0, 50, 0, 18)
			valLbl.Font = Enum.Font.GothamBold
			valLbl.Text = tostring(minVal)
			valLbl.TextColor3 = shiftColor(opts.main_color, 0.35)
			valLbl.TextSize = 13
			valLbl.TextXAlignment = Enum.TextXAlignment.Right

			local track = Instance.new("Frame")
			track.Name = "Track"
			track.Parent = container
			track.BackgroundColor3 = shiftColor(opts.bg_color, 0.11)
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

			onThemeChange(function(c)
				container.BackgroundColor3 = shiftColor(c.bg_color, 0.032)
				slStroke.Color = shiftColor(c.bg_color, 0.11)
				titleLbl.TextColor3 = c.text_color
				valLbl.TextColor3 = shiftColor(c.main_color, 0.35)
				track.BackgroundColor3 = shiftColor(c.bg_color, 0.11)
				fill.BackgroundColor3 = c.main_color
			end)

			local hitArea = Instance.new("TextButton")
			hitArea.Name = "HitArea"
			hitArea.Parent = container
			hitArea.BackgroundTransparency = 1
			hitArea.Position = UDim2.new(0, 6, 0, 20)
			hitArea.Size = UDim2.new(1, -12, 0, 20)
			hitArea.Text = ""

			local sliding, slideInput = false, nil

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
					if not sliding then
						sliding = true
						slideInput = input
						setCameraLocked(true)
						updateFromInput(input.Position)
					end
				end
			end)

			runtime:Connect(UIS.InputChanged, function(input)
				if sliding and (input == slideInput or input.UserInputType == Enum.UserInputType.MouseMovement) then
					updateFromInput(input.Position)
				end
			end)

			runtime:Connect(UIS.InputEnded, function(input)
				if sliding and (input == slideInput or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
					sliding = false
					slideInput = nil
					setCameraLocked(false)
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
			box.BackgroundColor3 = shiftColor(opts.bg_color, 0.032)
			box.BorderSizePixel = 0
			box.Size = UDim2.new(1, 0, 0, 28)
			box.Font = Enum.Font.GothamSemibold
			box.PlaceholderText = tostring(textbox_text or "Input Text")
			box.PlaceholderColor3 = shiftColor(opts.text_color, -0.3)
			box.Text = ""
			box.TextColor3 = opts.text_color
			box.TextSize = 13
			box.ClearTextOnFocus = false
			addCorner(box, 6)
			local boxStroke = addStroke(box, shiftColor(opts.bg_color, 0.11), 1, 0.4)

			onThemeChange(function(c)
				box.BackgroundColor3 = shiftColor(c.bg_color, 0.032)
				box.PlaceholderColor3 = shiftColor(c.text_color, -0.3)
				box.TextColor3 = c.text_color
				if not box:IsFocused() then
					boxStroke.Color = shiftColor(c.bg_color, 0.11)
				else
					boxStroke.Color = c.main_color
				end
			end)

			runtime:Connect(box.Focused, function()
				Tween(boxStroke, {Color = opts.main_color, Transparency = 0}, 0.12)
			end)

			runtime:Connect(box.FocusLost, function(enterPressed)
				Tween(boxStroke, {Color = shiftColor(opts.bg_color, 0.11), Transparency = 0.4}, 0.12)
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
			wrapper.BackgroundColor3 = shiftColor(opts.bg_color, 0.032)
			wrapper.BorderSizePixel = 0
			wrapper.ClipsDescendants = true
			wrapper.Size = UDim2.new(1, 0, 0, 28)
			addCorner(wrapper, 6)
			local ddStroke = addStroke(wrapper, shiftColor(opts.bg_color, 0.11), 1, 0.4)

			local headerBtn = Instance.new("TextButton")
			headerBtn.Name = "Header"
			headerBtn.Parent = wrapper
			headerBtn.BackgroundTransparency = 1
			headerBtn.Size = UDim2.new(1, 0, 0, 28)
			headerBtn.Font = Enum.Font.GothamSemibold
			headerBtn.Text = "   " .. dropdown_name
			headerBtn.TextColor3 = opts.text_color
			headerBtn.TextSize = 13
			headerBtn.TextTruncate = Enum.TextTruncate.AtEnd
			headerBtn.TextXAlignment = Enum.TextXAlignment.Left

			local arrow = Instance.new("TextLabel")
			arrow.Name = "Arrow"
			arrow.Parent = headerBtn
			arrow.BackgroundTransparency = 1
			arrow.Position = UDim2.new(1, -26, 0, 0)
			arrow.Size = UDim2.new(0, 20, 1, 0)
			arrow.Font = Enum.Font.GothamBold
			arrow.Text = "▼"
			arrow.TextColor3 = shiftColor(opts.text_color, -0.15)
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

			onThemeChange(function(c)
				wrapper.BackgroundColor3 = shiftColor(c.bg_color, 0.032)
				ddStroke.Color = shiftColor(c.bg_color, 0.11)
				headerBtn.TextColor3 = c.text_color
				arrow.TextColor3 = shiftColor(c.text_color, -0.15)
				listFrame.ScrollBarImageColor3 = c.main_color
				for _, itemBtn in pairs(itemsMap) do
					if itemBtn and itemBtn.Parent then
						itemBtn.BackgroundColor3 = shiftColor(c.bg_color, 0.06)
						itemBtn.TextColor3 = c.text_color
					end
				end
			end)

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
				itemBtn.BackgroundColor3 = shiftColor(opts.bg_color, 0.06)
				itemBtn.BorderSizePixel = 0
				itemBtn.Size = UDim2.new(1, 0, 0, 22)
				itemBtn.Font = Enum.Font.GothamSemibold
				itemBtn.Text = "  " .. itemName
				itemBtn.TextColor3 = opts.text_color
				itemBtn.TextSize = 12
				itemBtn.TextXAlignment = Enum.TextXAlignment.Left
				itemBtn.AutoButtonColor = false
				addCorner(itemBtn, 4)

				itemsMap[itemName] = itemBtn

				runtime:Connect(itemBtn.MouseEnter, function()
					itemBtn.BackgroundColor3 = opts.main_color
				end)
				runtime:Connect(itemBtn.MouseLeave, function()
					itemBtn.BackgroundColor3 = shiftColor(opts.bg_color, 0.06)
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

		-- ELEMENTO: COLOR PICKER (Paleta rápida + Sliders RGB con autoguardado)
		function tab_data:AddColorPicker(picker_text, callback, default_col)
			local picker_data = {}
			picker_text = tostring(picker_text or "Color Principal")
			callback = typeof(callback) == "function" and callback or function() end
			local currentColor = (typeof(default_col) == "Color3") and default_col or opts.main_color

			local wrapper = Instance.new("Frame")
			wrapper.Name = "ColorPicker"
			wrapper.Parent = tabPage
			wrapper.BackgroundColor3 = shiftColor(opts.bg_color, 0.032)
			wrapper.BorderSizePixel = 0
			wrapper.ClipsDescendants = true
			wrapper.Size = UDim2.new(1, 0, 0, 30)
			addCorner(wrapper, 6)
			local cpStroke = addStroke(wrapper, shiftColor(opts.bg_color, 0.11), 1, 0.4)

			local headerBtn = Instance.new("TextButton")
			headerBtn.Name = "Header"
			headerBtn.Parent = wrapper
			headerBtn.BackgroundTransparency = 1
			headerBtn.Size = UDim2.new(1, 0, 0, 30)
			headerBtn.Text = ""

			local titleLbl = Instance.new("TextLabel")
			titleLbl.Name = "Title"
			titleLbl.Parent = headerBtn
			titleLbl.BackgroundTransparency = 1
			titleLbl.Position = UDim2.new(0, 10, 0, 0)
			titleLbl.Size = UDim2.new(1, -56, 1, 0)
			titleLbl.Font = Enum.Font.GothamSemibold
			titleLbl.Text = picker_text
			titleLbl.TextColor3 = opts.text_color
			titleLbl.TextSize = 13
			titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left

			local previewBox = Instance.new("Frame")
			previewBox.Name = "Preview"
			previewBox.Parent = headerBtn
			previewBox.BackgroundColor3 = currentColor
			previewBox.BorderSizePixel = 0
			previewBox.Position = UDim2.new(1, -42, 0.5, -9)
			previewBox.Size = UDim2.new(0, 32, 0, 18)
			addCorner(previewBox, 5)
			addStroke(previewBox, Color3.new(1, 1, 1), 1, 0.5)

			onThemeChange(function(c)
				wrapper.BackgroundColor3 = shiftColor(c.bg_color, 0.032)
				cpStroke.Color = shiftColor(c.bg_color, 0.11)
				titleLbl.TextColor3 = c.text_color
			end)

			local panel = Instance.new("Frame")
			panel.Name = "Panel"
			panel.Parent = wrapper
			panel.BackgroundTransparency = 1
			panel.Position = UDim2.new(0, 8, 0, 34)
			panel.Size = UDim2.new(1, -16, 0, 104)

			-- Paleta de colores predefinidos
			local presetsRow = Instance.new("Frame")
			presetsRow.Name = "Presets"
			presetsRow.Parent = panel
			presetsRow.BackgroundTransparency = 1
			presetsRow.Size = UDim2.new(1, 0, 0, 20)

			local presetLayout = Instance.new("UIListLayout")
			presetLayout.Parent = presetsRow
			presetLayout.FillDirection = Enum.FillDirection.Horizontal
			presetLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			presetLayout.Padding = UDim.new(0, 6)

			local presetColors = {
				Color3.fromRGB(110, 50, 160), -- Morado
				Color3.fromRGB(0, 145, 220),  -- Azul Cian
				Color3.fromRGB(200, 45, 70),  -- Rojo Carmesí
				Color3.fromRGB(35, 165, 95),  -- Verde Esmeralda
				Color3.fromRGB(225, 130, 30), -- Naranja
				Color3.fromRGB(215, 65, 155), -- Rosa Neón
				Color3.fromRGB(18, 18, 22),   -- Oscuro
			}

			local rgbUpdaters = {}

			local function applyColor(col, triggerCallback)
				currentColor = col
				previewBox.BackgroundColor3 = col
				for _, upd in ipairs(rgbUpdaters) do
					upd(col)
				end
				if triggerCallback then
					pcall(callback, col)
				end
			end

			for _, pCol in ipairs(presetColors) do
				local swatch = Instance.new("TextButton")
				swatch.Parent = presetsRow
				swatch.BackgroundColor3 = pCol
				swatch.BorderSizePixel = 0
				swatch.Size = UDim2.new(0, 20, 0, 20)
				swatch.Text = ""
				swatch.AutoButtonColor = false
				addCorner(swatch, 10)
				addStroke(swatch, Color3.new(1, 1, 1), 1, 0.65)

				runtime:Connect(swatch.MouseButton1Click, function()
					applyColor(pCol, true)
				end)
			end

			-- Barras R, G, B
			local channels = {
				{name = "R", col = Color3.fromRGB(220, 65, 65), y = 28},
				{name = "G", col = Color3.fromRGB(65, 200, 95), y = 54},
				{name = "B", col = Color3.fromRGB(65, 145, 235), y = 80},
			}

			local rVal = math.floor(currentColor.R * 255 + 0.5)
			local gVal = math.floor(currentColor.G * 255 + 0.5)
			local bVal = math.floor(currentColor.B * 255 + 0.5)

			for idx, ch in ipairs(channels) do
				local row = Instance.new("Frame")
				row.Parent = panel
				row.BackgroundTransparency = 1
				row.Position = UDim2.new(0, 0, 0, ch.y)
				row.Size = UDim2.new(1, 0, 0, 20)

				local tag = Instance.new("TextLabel")
				tag.Parent = row
				tag.BackgroundTransparency = 1
				tag.Size = UDim2.new(0, 16, 1, 0)
				tag.Font = Enum.Font.GothamBold
				tag.Text = ch.name
				tag.TextColor3 = ch.col
				tag.TextSize = 12

				local numLbl = Instance.new("TextLabel")
				numLbl.Parent = row
				numLbl.BackgroundTransparency = 1
				numLbl.Position = UDim2.new(1, -28, 0, 0)
				numLbl.Size = UDim2.new(0, 28, 1, 0)
				numLbl.Font = Enum.Font.GothamSemibold
				numLbl.Text = "0"
				numLbl.TextColor3 = opts.text_color
				numLbl.TextSize = 11
				numLbl.TextXAlignment = Enum.TextXAlignment.Right

				onThemeChange(function(c)
					numLbl.TextColor3 = c.text_color
				end)

				local barTrack = Instance.new("Frame")
				barTrack.Parent = row
				barTrack.BackgroundColor3 = shiftColor(opts.bg_color, 0.12)
				barTrack.BorderSizePixel = 0
				barTrack.Position = UDim2.new(0, 20, 0.5, -3)
				barTrack.Size = UDim2.new(1, -52, 0, 6)
				addCorner(barTrack, 3)

				local barFill = Instance.new("Frame")
				barFill.Parent = barTrack
				barFill.BackgroundColor3 = ch.col
				barFill.BorderSizePixel = 0
				barFill.Size = UDim2.new(0, 0, 1, 0)
				addCorner(barFill, 3)

				local hit = Instance.new("TextButton")
				hit.Parent = row
				hit.BackgroundTransparency = 1
				hit.Position = UDim2.new(0, 16, 0, 0)
				hit.Size = UDim2.new(1, -44, 1, 0)
				hit.Text = ""

				local function syncChannelVisual(col)
					local v = (idx == 1 and col.R) or (idx == 2 and col.G) or col.B
					local intV = math.floor(v * 255 + 0.5)
					if idx == 1 then rVal = intV elseif idx == 2 then gVal = intV else bVal = intV end
					barFill.Size = UDim2.new(math.clamp(v, 0, 1), 0, 1, 0)
					numLbl.Text = tostring(intV)
				end

				table.insert(rgbUpdaters, syncChannelVisual)
				syncChannelVisual(currentColor)

				local draggingCh, dragChInput = false, nil
				local function updateCh(pos)
					local ratio = math.clamp((pos.X - barTrack.AbsolutePosition.X) / math.max(1, barTrack.AbsoluteSize.X), 0, 1)
					local intV = math.floor(ratio * 255 + 0.5)
					if idx == 1 then rVal = intV elseif idx == 2 then gVal = intV else bVal = intV end
					applyColor(Color3.fromRGB(rVal, gVal, bVal), true)
				end

				runtime:Connect(hit.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						if not draggingCh then
							draggingCh = true
							dragChInput = input
							setCameraLocked(true)
							updateCh(input.Position)
						end
					end
				end)
				runtime:Connect(UIS.InputChanged, function(input)
					if draggingCh and (input == dragChInput or input.UserInputType == Enum.UserInputType.MouseMovement) then
						updateCh(input.Position)
					end
				end)
				runtime:Connect(UIS.InputEnded, function(input)
					if draggingCh and (input == dragChInput or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
						draggingCh = false
						dragChInput = nil
						setCameraLocked(false)
					end
				end)
			end

			local expanded = false
			runtime:Connect(headerBtn.MouseButton1Click, function()
				expanded = not expanded
				Tween(wrapper, {Size = UDim2.new(1, 0, 0, expanded and 144 or 30)}, 0.14)
			end)

			function picker_data:Set(col)
				if typeof(col) == "Color3" then
					applyColor(col, true)
				end
			end

			return picker_data, wrapper
		end

		-- ELEMENTO: FOLDER
		function tab_data:AddFolder(folder_name)
			local folder_data = {}
			folder_name = tostring(folder_name or "Folder")

			local folderBox = Instance.new("Frame")
			folderBox.Name = "Folder"
			folderBox.Parent = tabPage
			folderBox.BackgroundColor3 = shiftColor(opts.bg_color, 0.02)
			folderBox.BorderSizePixel = 0
			folderBox.ClipsDescendants = true
			folderBox.Size = UDim2.new(1, 0, 0, 28)
			addCorner(folderBox, 6)
			local fldStroke = addStroke(folderBox, opts.main_color, 1, 0.5)

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

			onThemeChange(function(c)
				folderBox.BackgroundColor3 = shiftColor(c.bg_color, 0.02)
				fldStroke.Color = c.main_color
				folderBtn.BackgroundColor3 = c.main_color
			end)

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
