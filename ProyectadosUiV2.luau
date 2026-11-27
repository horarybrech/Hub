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
	local connection = signal:Connect(function(...)
		if self.Alive then
			callback(...)
		end
	end)
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

local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.new(0, 0, 0)
local DEFAULT_TWEEN = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Catálogo de temas predefinidos
local THEME_ORDER = {
	"Default Elirium",
	"Morado Neón",
	"Carmesí Imperial",
	"Ciber Cian",
	"Esmeralda Tóxica",
	"Oro Real",
	"Rosa Sakura",
	"Mecha Titanio",
}

local THEMES = {
	["Default Elirium"] = {
		main_color = Color3.fromRGB(138, 43, 226),
		bg_color = Color3.fromRGB(10, 10, 14),
		text_color = Color3.fromRGB(245, 245, 250),
		font_title = Enum.Font.GothamBold,
		font_body = Enum.Font.GothamBold,
		corner_window = 6,
		corner_card = 4,
		stroke_thickness = 1.6,
		top_tabs = true,
	},
	["Morado Neón"] = {
		main_color = Color3.fromRGB(162, 62, 255),
		bg_color = Color3.fromRGB(16, 15, 21),
		text_color = Color3.fromRGB(245, 245, 250),
		font_title = Enum.Font.GothamBold,
		font_body = Enum.Font.GothamMedium,
		corner_window = 14,
		corner_card = 10,
		stroke_thickness = 2.2,
		top_tabs = false,
	},
	["Carmesí Imperial"] = {
		main_color = Color3.fromRGB(230, 46, 77),
		bg_color = Color3.fromRGB(20, 12, 14),
		text_color = Color3.fromRGB(255, 244, 246),
		font_title = Enum.Font.FredokaOne,
		font_body = Enum.Font.GothamBold,
		corner_window = 9,
		corner_card = 7,
		stroke_thickness = 2.4,
		top_tabs = false,
	},
	["Ciber Cian"] = {
		main_color = Color3.fromRGB(0, 210, 255),
		bg_color = Color3.fromRGB(11, 18, 28),
		text_color = Color3.fromRGB(235, 249, 255),
		font_title = Enum.Font.RobotoMono,
		font_body = Enum.Font.RobotoMono,
		corner_window = 6,
		corner_card = 5,
		stroke_thickness = 2.0,
		top_tabs = false,
	},
	["Esmeralda Tóxica"] = {
		main_color = Color3.fromRGB(30, 215, 96),
		bg_color = Color3.fromRGB(12, 20, 16),
		text_color = Color3.fromRGB(240, 255, 245),
		font_title = Enum.Font.Ubuntu,
		font_body = Enum.Font.Ubuntu,
		corner_window = 16,
		corner_card = 12,
		stroke_thickness = 2.2,
		top_tabs = false,
	},
	["Oro Real"] = {
		main_color = Color3.fromRGB(245, 175, 25),
		bg_color = Color3.fromRGB(20, 17, 12),
		text_color = Color3.fromRGB(255, 251, 240),
		font_title = Enum.Font.TitilliumWeb,
		font_body = Enum.Font.TitilliumWeb,
		corner_window = 10,
		corner_card = 8,
		stroke_thickness = 2.3,
		top_tabs = false,
	},
	["Rosa Sakura"] = {
		main_color = Color3.fromRGB(245, 75, 175),
		bg_color = Color3.fromRGB(22, 13, 20),
		text_color = Color3.fromRGB(255, 242, 250),
		font_title = Enum.Font.Cartoon,
		font_body = Enum.Font.GothamBold,
		corner_window = 15,
		corner_card = 11,
		stroke_thickness = 2.2,
		top_tabs = false,
	},
	["Mecha Titanio"] = {
		main_color = Color3.fromRGB(190, 205, 225),
		bg_color = Color3.fromRGB(18, 20, 25),
		text_color = Color3.fromRGB(245, 248, 255),
		font_title = Enum.Font.Sarpanch,
		font_body = Enum.Font.Sarpanch,
		corner_window = 7,
		corner_card = 6,
		stroke_thickness = 2.1,
		top_tabs = false,
	},
}

local DEFAULT_THEME_NAME = "Default Elirium"

local ui_options = {
	theme = DEFAULT_THEME_NAME,
	min_size = Vector2.new(440, 310),
	toggle_key = Enum.KeyCode.RightShift,
	can_resize = true,
}

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local cloneref = type(cloneref) == "function" and cloneref or function(...) return ... end

local CoreGui
if not isSolara then pcall(function() CoreGui = cloneref(game:GetService("CoreGui")) end) end

-- Limpieza rápida directa
do
	local function destroyImguiIn(parent)
		if parent and parent.FindFirstChild then
			local existing = parent:FindFirstChild("imgui")
			if existing then pcall(function() existing:Destroy() end) end
			local toggleExist = parent:FindFirstChild("ToggleUI")
			if toggleExist then pcall(function() toggleExist:Destroy() end) end
		end
	end

	if CoreGui then pcall(function() destroyImguiIn(CoreGui) end) end
	if LocalPlayer then destroyImguiIn(LocalPlayer:FindFirstChild("PlayerGui")) end
	if not isSolara and type(gethui) == "function" then
		local ok, gh = pcall(gethui)
		if ok and gh then destroyImguiIn(gh) end
	end
end

-- Sistema de guardado persistente con escritura diferida (Debounce)
local CONFIG_FILE = "UniversalUI_Config.json"
_G.UniversalUISavedConfig = _G.UniversalUISavedConfig or {}

do
	if type(isfile) == "function" and type(readfile) == "function" then
		local ok, raw = pcall(function()
			return isfile(CONFIG_FILE) and readfile(CONFIG_FILE) or nil
		end)
		if ok and type(raw) == "string" and #raw > 0 then
			local decOk, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
			if decOk and type(decoded) == "table" then
				for k, v in pairs(decoded) do
					_G.UniversalUISavedConfig[k] = v
				end
			end
		end
	end
end

local pendingWrite = false
local function flushConfigFile()
	if pendingWrite or type(writefile) ~= "function" then return end
	pendingWrite = true
	nativeTask.delay(0.4, function()
		pendingWrite = false
		pcall(function()
			writefile(CONFIG_FILE, HttpService:JSONEncode(_G.UniversalUISavedConfig))
		end)
	end)
end

local function saveWindowSize(winKey, width, height)
	local entry = _G.UniversalUISavedConfig[winKey] or {}
	entry.w = math.floor(width)
	entry.h = math.floor(height)
	_G.UniversalUISavedConfig[winKey] = entry
	flushConfigFile()
end

local function getSavedWindowSize(winKey)
	local entry = _G.UniversalUISavedConfig[winKey]
	if type(entry) == "table" and tonumber(entry.w) and tonumber(entry.h) then
		return Vector2.new(tonumber(entry.w), tonumber(entry.h))
	end
	return nil
end

local function saveWindowTheme(winKey, themeName)
	local entry = _G.UniversalUISavedConfig[winKey] or {}
	entry.theme = themeName
	_G.UniversalUISavedConfig[winKey] = entry
	flushConfigFile()
end

local function getSavedWindowTheme(winKey)
	local entry = _G.UniversalUISavedConfig[winKey]
	if type(entry) == "table" and type(entry.theme) == "string" and THEMES[entry.theme] then
		return entry.theme
	end
	return nil
end

local function blendColor(base, target, alpha)
	return base:Lerp(target, math.clamp(alpha, 0, 1))
end

local function shiftColor(c, delta)
	if delta >= 0 then
		return c:Lerp(WHITE, math.clamp(delta, 0, 1))
	else
		return c:Lerp(BLACK, math.clamp(-delta, 0, 1))
	end
end

-- Bloqueo de cámara al arrastrar
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

-- Controlador único centralizado para arrastre y deslizadores
local activePointer = nil

local function beginPointerDrag(input, onMove, onEnd)
	if activePointer then return false end
	activePointer = {
		input = input,
		onMove = onMove,
		onEnd = onEnd,
	}
	setCameraLocked(true)
	return true
end

runtime:Connect(UIS.InputChanged, function(input)
	local ptr = activePointer
	if not ptr then return end
	if input == ptr.input or input.UserInputType == Enum.UserInputType.MouseMovement then
		if ptr.onMove then
			ptr.onMove(input.Position)
		end
	end
end)

runtime:Connect(UIS.InputEnded, function(input)
	local ptr = activePointer
	if not ptr then return end
	if input == ptr.input or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		activePointer = nil
		setCameraLocked(false)
		if ptr.onEnd then
			ptr.onEnd(input.Position)
		end
	end
end)

runtime:AddCleanup(function()
	activePointer = nil
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

runtime:Connect(UIS.InputBegan, function(input, gameProcessed)
	if gameProcessed then return end
	local toggleKey = (typeof(ui_options.toggle_key) == "EnumItem") and ui_options.toggle_key or Enum.KeyCode.RightShift
	if input.KeyCode == toggleKey and not checks.binding then
		imgui.Enabled = not imgui.Enabled
	end
end)

-- Botón flotante
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "ToggleUI"
toggleGui.ResetOnSpawn = false
toggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mountGui(toggleGui)
runtime:AddCleanup(function() toggleGui:Destroy() end)

local btnSize = isCompactDevice() and 42 or 46
local floatingBtn = Instance.new("TextButton")
floatingBtn.Name = "OpenCloseBtn"
floatingBtn.Parent = toggleGui
floatingBtn.Active = true
floatingBtn.BackgroundColor3 = Color3.fromRGB(20, 18, 26)
floatingBtn.Position = UDim2.new(0.5, -math.floor(btnSize / 2), 0, 10)
floatingBtn.Size = UDim2.new(0, btnSize, 0, btnSize)
floatingBtn.Font = Enum.Font.GothamBold
floatingBtn.Text = "⚙️"
floatingBtn.TextSize = isCompactDevice() and 18 or 20
floatingBtn.TextColor3 = WHITE
floatingBtn.AutoButtonColor = false
floatingBtn.ZIndex = 100

local floatingCorner = Instance.new("UICorner")
floatingCorner.CornerRadius = UDim.new(1, 0)
floatingCorner.Parent = floatingBtn

local floatingStroke = Instance.new("UIStroke")
floatingStroke.Color = THEMES[DEFAULT_THEME_NAME].main_color
floatingStroke.Thickness = 2.2
floatingStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
floatingStroke.Parent = floatingBtn

do
	local dragStart, startPos, hasMoved = nil, nil, false

	runtime:Connect(floatingBtn.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			hasMoved = false
			dragStart = input.Position
			startPos = floatingBtn.Position
			beginPointerDrag(input, function(pos)
				local delta = pos - dragStart
				if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then
					hasMoved = true
					floatingBtn.Position = UDim2.new(
						startPos.X.Scale, startPos.X.Offset + delta.X,
						startPos.Y.Scale, startPos.Y.Offset + delta.Y
					)
				end
			end, function()
				if not hasMoved and not checks.binding then
					imgui.Enabled = not imgui.Enabled
				end
			end)
		end
	end)
end

-- Utilidades ligeras
local function Tween(obj, props, info)
	local tw = TweenService:Create(obj, info or DEFAULT_TWEEN, props)
	tw:Play()
	return tw
end

local function addCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 10)
	c.Parent = parent
	return c
end

local function addStroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.fromRGB(46, 46, 54)
	s.Thickness = thickness or 1.6
	s.Transparency = transparency or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function bindWindowDrag(targetFrame, handles)
	for _, handle in ipairs(handles) do
		runtime:Connect(handle.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				local dragStart = input.Position
				local startPos = targetFrame.Position
				beginPointerDrag(input, function(pos)
					local delta = pos - dragStart
					targetFrame.Position = UDim2.new(
						startPos.X.Scale, startPos.X.Offset + delta.X,
						startPos.Y.Scale, startPos.Y.Offset + delta.Y
					)
				end)
			end
		end)
	end
end

local windows = 0
local library = {
	Runtime = runtime,
	Themes = THEME_ORDER,
}

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

	local requestedTheme = (typeof(options) == "table" and type(options.theme) == "string" and THEMES[options.theme]) and options.theme or ui_options.theme
	local initialThemeName = getSavedWindowTheme(winKey) or requestedTheme

	local opts = {
		theme_name = initialThemeName,
		min_size = hardMinSize,
		can_resize = (typeof(options) == "table" and options.can_resize ~= nil) and options.can_resize or ui_options.can_resize,
		tween_time = 0.15,
	}

	-- Paleta y estilo cacheado del tema activo
	local palette = {}
	local function rebuildPalette()
		local t = THEMES[opts.theme_name] or THEMES[DEFAULT_THEME_NAME]
		local m, bg, txt = t.main_color, t.bg_color, t.text_color
		palette.name = opts.theme_name
		palette.main = m
		palette.bg = bg
		palette.text = txt
		palette.fontTitle = t.font_title
		palette.fontBody = t.font_body
		palette.cornerWindow = t.corner_window
		palette.cornerCard = t.corner_card
		palette.strokeThickness = t.stroke_thickness
		palette.topTabs = t.top_tabs == true

		palette.winBg = blendColor(bg, m, 0.28)
		palette.winStroke = shiftColor(m, 0.15)
		palette.innerRim = blendColor(bg, m, 0.45)
		palette.barBg = blendColor(bg, m, 0.58)
		palette.glowLine = shiftColor(m, 0.18)
		palette.sidebarBg = shiftColor(bg, 0.025)
		palette.cardBg = shiftColor(bg, 0.04)
		palette.cardStroke = shiftColor(bg, 0.13)
		palette.activeBg = blendColor(bg, m, 0.22)
		palette.activeTabBg = blendColor(bg, m, 0.24)
		palette.activeStroke = shiftColor(m, 0.2)
		palette.tabTextOff = shiftColor(txt, -0.15)
		palette.pillOff = shiftColor(bg, 0.12)
		palette.valText = shiftColor(m, 0.3)
		palette.placeholder = shiftColor(txt, -0.32)
		palette.itemBg = shiftColor(bg, 0.07)
		palette.btnHover = shiftColor(m, 0.08)
		palette.btnPress = shiftColor(m, 0.22)
		palette.btnStroke = shiftColor(m, 0.25)
		palette.folderHeader = blendColor(bg, m, 0.45)
		palette.floatingBg = shiftColor(bg, 0.03)
	end
	rebuildPalette()

	local themeCallbacks = {}
	local titleFontObjs = {}
	local bodyFontObjs = {}
	local cardCornerObjs = {}

	local function registerTitleFont(obj)
		obj.Font = palette.fontTitle
		table.insert(titleFontObjs, obj)
	end

	local function registerBodyFont(obj)
		obj.Font = palette.fontBody
		table.insert(bodyFontObjs, obj)
	end

	local function registerCardCorner(corner)
		corner.CornerRadius = UDim.new(0, palette.cornerCard)
		table.insert(cardCornerObjs, corner)
	end

	local function onThemeChange(fn)
		table.insert(themeCallbacks, fn)
		pcall(fn, palette)
	end

	local startX = math.max(12, math.floor((vp.X - initialSize.X) / 2) + ((windows - 1) * 18))
	local startY = math.clamp(60 + ((windows - 1) * 18), 54, math.max(54, vp.Y - initialSize.Y - 12))

	local BORDER_THICKNESS = 4
	local MINIMIZED_HEIGHT = 34 + (BORDER_THICKNESS * 2)

	-- Marco Exterior Oscuro con Contorno Neón
	local Window = Instance.new("Frame")
	Window.Name = "Window_" .. windows
	Window.Parent = windowsFrame
	Window.Active = true
	Window.BackgroundColor3 = palette.winBg
	Window.BorderSizePixel = 0
	Window.ClipsDescendants = true
	Window.Position = UDim2.new(0, startX, 0, startY)
	Window.Size = UDim2.new(0, initialSize.X, 0, initialSize.Y)
	local windowCorner = addCorner(Window, palette.cornerWindow)
	local windowNeonStroke = addStroke(Window, palette.winStroke, palette.strokeThickness, 0)

	-- Contenedor Interior Carbón Oscuro
	local InnerFrame = Instance.new("Frame")
	InnerFrame.Name = "Inner"
	InnerFrame.Parent = Window
	InnerFrame.BackgroundColor3 = palette.bg
	InnerFrame.BorderSizePixel = 0
	InnerFrame.ClipsDescendants = true
	InnerFrame.Position = UDim2.new(0, BORDER_THICKNESS, 0, BORDER_THICKNESS)
	InnerFrame.Size = UDim2.new(1, -(BORDER_THICKNESS * 2), 1, -(BORDER_THICKNESS * 2))
	local innerCorner = addCorner(InnerFrame, math.max(4, palette.cornerWindow - 3))
	local innerRimStroke = addStroke(InnerFrame, palette.innerRim, 1.3, 0.25)

	-- Barra Superior con línea de brillo neón
	local Bar = Instance.new("Frame")
	Bar.Name = "Bar"
	Bar.Parent = InnerFrame
	Bar.Active = true
	Bar.BackgroundColor3 = palette.barBg
	Bar.BorderSizePixel = 0
	Bar.Size = UDim2.new(1, 0, 0, 34)
	local barCorner = addCorner(Bar, math.max(4, palette.cornerWindow - 3))

	local BarCover = Instance.new("Frame")
	BarCover.Name = "BarCover"
	BarCover.Parent = Bar
	BarCover.BackgroundColor3 = palette.barBg
	BarCover.BorderSizePixel = 0
	BarCover.Position = UDim2.new(0, 0, 0.5, 0)
	BarCover.Size = UDim2.new(1, 0, 0.5, 0)

	local barGlowLine = Instance.new("Frame")
	barGlowLine.Name = "GlowLine"
	barGlowLine.Parent = Bar
	barGlowLine.BackgroundColor3 = palette.glowLine
	barGlowLine.BorderSizePixel = 0
	barGlowLine.Position = UDim2.new(0, 0, 1, -1)
	barGlowLine.Size = UDim2.new(1, 0, 0, 2)
	barGlowLine.ZIndex = 4

	bindWindowDrag(Window, {Window, Bar})

	-- Botón Circular Minimizar
	local ToggleBtn = Instance.new("TextButton")
	ToggleBtn.Name = "Toggle"
	ToggleBtn.Parent = Bar
	ToggleBtn.BackgroundColor3 = Color3.fromRGB(22, 20, 28)
	ToggleBtn.Position = UDim2.new(0, 7, 0.5, -12)
	ToggleBtn.Size = UDim2.new(0, 24, 0, 24)
	ToggleBtn.Font = Enum.Font.GothamBold
	ToggleBtn.Text = "📽️"
	ToggleBtn.TextColor3 = WHITE
	ToggleBtn.TextSize = 13
	ToggleBtn.ZIndex = 5
	addCorner(ToggleBtn, 12)
	local toggleStroke = addStroke(ToggleBtn, palette.winStroke, 1.5, 0.2)

	-- Título de la Ventana
	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Name = "Title"
	TitleLabel.Parent = Bar
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Position = UDim2.new(0, 38, 0, 0)
	TitleLabel.Size = UDim2.new(1, -48, 1, 0)
	TitleLabel.Text = tostring(title or "New Window")
	TitleLabel.TextColor3 = WHITE
	TitleLabel.TextSize = 14
	TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.ZIndex = 3
	registerTitleFont(TitleLabel)

	-- Panel Lateral Izquierdo de Pestañas (temas estándar)
	local sidebarW = isCompactDevice() and 96 or 114

	local TabSelection = Instance.new("ScrollingFrame")
	TabSelection.Name = "TabSelection"
	TabSelection.Parent = InnerFrame
	TabSelection.BackgroundColor3 = palette.sidebarBg
	TabSelection.BorderSizePixel = 0
	TabSelection.Position = UDim2.new(0, 8, 0, 42)
	TabSelection.Size = UDim2.new(0, sidebarW, 1, -50)
	TabSelection.CanvasSize = UDim2.new(0, 0, 0, 0)
	TabSelection.AutomaticCanvasSize = Enum.AutomaticSize.Y
	TabSelection.ScrollBarThickness = 3
	TabSelection.ScrollBarImageColor3 = palette.main
	TabSelection.Visible = false
	registerCardCorner(addCorner(TabSelection, palette.cornerCard))
	local sbStroke = addStroke(TabSelection, palette.cardStroke, 1.5, 0)

	local TabButtons = Instance.new("Frame")
	TabButtons.Name = "TabButtons"
	TabButtons.Parent = TabSelection
	TabButtons.BackgroundTransparency = 1
	TabButtons.Position = UDim2.new(0, 6, 0, 6)
	TabButtons.Size = UDim2.new(1, -12, 0, 0)
	TabButtons.AutomaticSize = Enum.AutomaticSize.Y

	local tabListLayout = Instance.new("UIListLayout")
	tabListLayout.Parent = TabButtons
	tabListLayout.FillDirection = Enum.FillDirection.Vertical
	tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabListLayout.Padding = UDim.new(0, 6)

	-- Fila Superior de Pestañas (exclusiva de Default Elirium)
	local TopTabBar = Instance.new("ScrollingFrame")
	TopTabBar.Name = "TopTabBar"
	TopTabBar.Parent = InnerFrame
	TopTabBar.BackgroundColor3 = palette.sidebarBg
	TopTabBar.BorderSizePixel = 0
	TopTabBar.Position = UDim2.new(0, 8, 0, 40)
	TopTabBar.Size = UDim2.new(1, -16, 0, 30)
	TopTabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
	TopTabBar.AutomaticCanvasSize = Enum.AutomaticSize.X
	TopTabBar.ScrollBarThickness = 2
	TopTabBar.ScrollBarImageColor3 = palette.main
	TopTabBar.ScrollingDirection = Enum.ScrollingDirection.X
	TopTabBar.Visible = false
	registerCardCorner(addCorner(TopTabBar, palette.cornerCard))
	local topBarStroke = addStroke(TopTabBar, palette.cardStroke, 1.3, 0)

	local TopTabButtons = Instance.new("Frame")
	TopTabButtons.Name = "TopTabButtons"
	TopTabButtons.Parent = TopTabBar
	TopTabButtons.BackgroundTransparency = 1
	TopTabButtons.Position = UDim2.new(0, 4, 0, 3)
	TopTabButtons.Size = UDim2.new(0, 0, 1, -6)
	TopTabButtons.AutomaticSize = Enum.AutomaticSize.X

	local topTabLayout = Instance.new("UIListLayout")
	topTabLayout.Parent = TopTabButtons
	topTabLayout.FillDirection = Enum.FillDirection.Horizontal
	topTabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	topTabLayout.Padding = UDim.new(0, 5)

	-- Contenedor Principal de Pestañas
	local TabsContainer = Instance.new("Frame")
	TabsContainer.Name = "Tabs"
	TabsContainer.Parent = InnerFrame
	TabsContainer.BackgroundTransparency = 1
	TabsContainer.Position = UDim2.new(0, 10, 0, 42)
	TabsContainer.Size = UDim2.new(1, -20, 1, -50)

	-- Redimensionador
	local Resizer = Instance.new("TextButton")
	Resizer.Name = "Resizer"
	Resizer.Parent = Window
	Resizer.BackgroundTransparency = 1
	Resizer.Position = UDim2.new(1, -26, 1, -26)
	Resizer.Size = UDim2.new(0, 26, 0, 26)
	Resizer.Text = "◢"
	Resizer.TextColor3 = Color3.fromRGB(220, 205, 245)
	Resizer.TextSize = 13
	Resizer.Visible = opts.can_resize
	Resizer.ZIndex = 10

	local isOpen = true
	local savedHeight = initialSize.Y
	local hasTabs = false
	local tabEntries = {}

	local function refreshTabLayoutPositions()
		sidebarW = isCompactDevice() and 96 or 114
		TabSelection.Size = UDim2.new(0, sidebarW, 1, -50)

		if not hasTabs then
			TabSelection.Visible = false
			TopTabBar.Visible = false
			TabsContainer.Position = UDim2.new(0, 10, 0, 42)
			TabsContainer.Size = UDim2.new(1, -20, 1, -50)
			return
		end

		if palette.topTabs then
			TabSelection.Visible = false
			TopTabBar.Visible = isOpen
			TabsContainer.Position = UDim2.new(0, 10, 0, 76)
			TabsContainer.Size = UDim2.new(1, -20, 1, -84)

			for _, entry in ipairs(tabEntries) do
				entry.btn.Parent = TopTabButtons
				local textW = TextService:GetTextSize(entry.name, 12, palette.fontBody, Vector2.new(300, 24)).X
				entry.btn.Size = UDim2.new(0, math.clamp(textW + 18, 56, 140), 1, 0)
				entry.btn.Text = entry.name
				entry.btn.TextXAlignment = Enum.TextXAlignment.Center
			end
		else
			TopTabBar.Visible = false
			TabSelection.Visible = isOpen
			TabsContainer.Position = UDim2.new(0, sidebarW + 14, 0, 42)
			TabsContainer.Size = UDim2.new(1, -(sidebarW + 22), 1, -50)

			for _, entry in ipairs(tabEntries) do
				entry.btn.Parent = TabButtons
				entry.btn.Size = UDim2.new(1, 0, 0, 30)
				entry.btn.Text = "  " .. entry.name
				entry.btn.TextXAlignment = Enum.TextXAlignment.Left
			end
		end
	end

	local function broadcastTheme()
		rebuildPalette()
		floatingStroke.Color = palette.main
		floatingBtn.BackgroundColor3 = palette.floatingBg

		local cardRadius = UDim.new(0, palette.cornerCard)
		for i = 1, #titleFontObjs do
			titleFontObjs[i].Font = palette.fontTitle
		end
		for i = 1, #bodyFontObjs do
			bodyFontObjs[i].Font = palette.fontBody
		end
		for i = 1, #cardCornerObjs do
			cardCornerObjs[i].CornerRadius = cardRadius
		end
		for i = 1, #themeCallbacks do
			pcall(themeCallbacks[i], palette)
		end
		refreshTabLayoutPositions()
	end

	onThemeChange(function(p)
		Window.BackgroundColor3 = p.winBg
		windowCorner.CornerRadius = UDim.new(0, p.cornerWindow)
		windowNeonStroke.Color = p.winStroke
		windowNeonStroke.Thickness = p.strokeThickness

		local innerR = UDim.new(0, math.max(4, p.cornerWindow - 3))
		innerCorner.CornerRadius = innerR
		barCorner.CornerRadius = innerR

		InnerFrame.BackgroundColor3 = p.bg
		innerRimStroke.Color = p.innerRim
		Bar.BackgroundColor3 = p.barBg
		BarCover.BackgroundColor3 = p.barBg
		barGlowLine.BackgroundColor3 = p.glowLine
		toggleStroke.Color = p.winStroke

		TabSelection.BackgroundColor3 = p.sidebarBg
		TabSelection.ScrollBarImageColor3 = p.main
		sbStroke.Color = p.cardStroke

		TopTabBar.BackgroundColor3 = p.sidebarBg
		TopTabBar.ScrollBarImageColor3 = p.main
		topBarStroke.Color = p.cardStroke
	end)

	floatingStroke.Color = palette.main
	floatingBtn.BackgroundColor3 = palette.floatingBg

	local function clampToViewport()
		if not Window or not Window.Parent then return end
		local currentReq = getSavedWindowSize(winKey) or defaultSize
		local _, newHardMin, currentVp = getResponsiveDimensions(currentReq, true)
		opts.min_size = newHardMin

		refreshTabLayoutPositions()

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
		runtime:Connect(Resizer.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				local resizeStart = input.Position
				local startSize = Window.AbsoluteSize
				beginPointerDrag(input, function(pos)
					local currentVp = getViewportSize()
					local delta = pos - resizeStart
					local newX = math.clamp(startSize.X + delta.X, opts.min_size.X, currentVp.X - 16)
					local newY = math.clamp(startSize.Y + delta.Y, opts.min_size.Y, currentVp.Y - 60)
					Window.Size = UDim2.new(0, newX, 0, newY)
				end, function()
					savedHeight = Window.Size.Y.Offset
					saveWindowSize(winKey, Window.Size.X.Offset, Window.Size.Y.Offset)
				end)
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
			TopTabBar.Visible = false
			Resizer.Visible = false
			BarCover.Visible = false
			barGlowLine.Visible = false
			Tween(Window, {Size = UDim2.new(0, Window.AbsoluteSize.X, 0, MINIMIZED_HEIGHT)})
			ToggleBtn.Text = "❤️‍🔥"
			isOpen = false
			nativeTask.delay(opts.tween_time, function() canToggle = true end)
		else
			Tween(Window, {Size = UDim2.new(0, Window.AbsoluteSize.X, 0, savedHeight)})
			nativeTask.delay(opts.tween_time * 0.6, function()
				if not runtime.Alive then return end
				BarCover.Visible = true
				barGlowLine.Visible = true
				if hasTabs then
					if palette.topTabs then
						TopTabBar.Visible = true
					else
						TabSelection.Visible = true
					end
				end
				TabsContainer.Visible = true
				Resizer.Visible = opts.can_resize
				ToggleBtn.Text = "📽️"
			end)
			isOpen = true
			nativeTask.delay(opts.tween_time, function() canToggle = true end)
		end
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

	function window_data:SetTheme(themeName)
		if type(themeName) == "string" and THEMES[themeName] then
			opts.theme_name = themeName
			broadcastTheme()
			saveWindowTheme(winKey, themeName)
		end
	end

	function window_data:GetTheme()
		return opts.theme_name
	end

	function window_data:GetThemes()
		return THEME_ORDER
	end

	function window_data:ResetTheme()
		window_data:SetTheme(DEFAULT_THEME_NAME)
	end
	window_data.ResetColors = window_data.ResetTheme

	local dropdown_open = false
	local activeTabBtn = nil
	local activeTabPage = nil
	local tabStrokes = {}

	local function styleTabBtn(btn, selected)
		local st = tabStrokes[btn]
		if selected then
			btn.BackgroundColor3 = palette.activeTabBg
			btn.TextColor3 = WHITE
			if st then
				st.Color = palette.activeStroke
				st.Thickness = 1.9
			end
		else
			btn.BackgroundColor3 = palette.cardBg
			btn.TextColor3 = palette.tabTextOff
			if st then
				st.Color = palette.cardStroke
				st.Thickness = 1.4
			end
		end
	end

	function window_data:AddTab(tab_name)
		local tab_data = {}
		tab_name = tostring(tab_name or "New Tab")

		local parentButtons = palette.topTabs and TopTabButtons or TabButtons
		local tabBtn = Instance.new("TextButton")
		tabBtn.Name = "TabBtn_" .. tab_name
		tabBtn.Parent = parentButtons
		tabBtn.BackgroundColor3 = palette.cardBg
		tabBtn.BorderSizePixel = 0
		tabBtn.Text = "  " .. tab_name
		tabBtn.TextColor3 = palette.tabTextOff
		tabBtn.TextSize = 12
		tabBtn.TextTruncate = Enum.TextTruncate.AtEnd
		tabBtn.TextXAlignment = Enum.TextXAlignment.Left
		tabBtn.AutoButtonColor = false
		tabBtn.Size = UDim2.new(1, 0, 0, 30)
		registerBodyFont(tabBtn)
		registerCardCorner(addCorner(tabBtn, palette.cornerCard))
		tabStrokes[tabBtn] = addStroke(tabBtn, palette.cardStroke, 1.5, 0)

		table.insert(tabEntries, {name = tab_name, btn = tabBtn})

		if not hasTabs then
			hasTabs = true
		end
		refreshTabLayoutPositions()

		local tabPage = Instance.new("ScrollingFrame")
		tabPage.Name = "Tab_" .. tab_name
		tabPage.Parent = TabsContainer
		tabPage.BackgroundTransparency = 1
		tabPage.BorderSizePixel = 0
		tabPage.Size = UDim2.new(1, 0, 1, 0)
		tabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
		tabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
		tabPage.ScrollBarThickness = 4
		tabPage.ScrollBarImageColor3 = palette.main
		tabPage.Visible = false

		onThemeChange(function(p)
			tabPage.ScrollBarImageColor3 = p.main
			styleTabBtn(tabBtn, activeTabBtn == tabBtn)
		end)

		local pagePadding = Instance.new("UIPadding")
		pagePadding.PaddingLeft = UDim.new(0, 2)
		pagePadding.PaddingRight = UDim.new(0, 8)
		pagePadding.PaddingTop = UDim.new(0, 2)
		pagePadding.PaddingBottom = UDim.new(0, 6)
		pagePadding.Parent = tabPage

		local pageLayout = Instance.new("UIListLayout")
		pageLayout.Parent = tabPage
		pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		pageLayout.Padding = UDim.new(0, 6)

		local function showTab()
			if activeTabBtn == tabBtn then return end
			if activeTabBtn then styleTabBtn(activeTabBtn, false) end
			if activeTabPage then activeTabPage.Visible = false end
			activeTabBtn = tabBtn
			activeTabPage = tabPage
			styleTabBtn(tabBtn, true)
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
			lbl.Size = UDim2.new(1, 0, 0, 22)
			lbl.AutomaticSize = Enum.AutomaticSize.Y
			lbl.Text = tostring(label_text or "Label")
			lbl.TextColor3 = palette.text
			lbl.TextSize = 13
			lbl.TextWrapped = true
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			registerTitleFont(lbl)

			onThemeChange(function(p)
				lbl.TextColor3 = p.text
			end)

			return lbl
		end

		-- ELEMENTO: BUTTON
		function tab_data:AddButton(button_text, callback)
			callback = typeof(callback) == "function" and callback or function() end

			local btn = Instance.new("TextButton")
			btn.Name = "Button"
			btn.Parent = tabPage
			btn.BackgroundColor3 = palette.main
			btn.BorderSizePixel = 0
			btn.Size = UDim2.new(1, 0, 0, 32)
			btn.Text = tostring(button_text or "Button")
			btn.TextColor3 = WHITE
			btn.TextSize = 13
			btn.AutoButtonColor = false
			registerTitleFont(btn)
			registerCardCorner(addCorner(btn, palette.cornerCard))
			local btnStroke = addStroke(btn, palette.btnStroke, 1.6, 0.15)

			onThemeChange(function(p)
				btn.BackgroundColor3 = p.main
				btnStroke.Color = p.btnStroke
			end)

			runtime:Connect(btn.MouseEnter, function()
				btn.BackgroundColor3 = palette.btnHover
			end)
			runtime:Connect(btn.MouseLeave, function()
				btn.BackgroundColor3 = palette.main
			end)
			runtime:Connect(btn.MouseButton1Click, function()
				btn.BackgroundColor3 = palette.btnPress
				nativeTask.delay(0.08, function()
					if btn and btn.Parent then
						btn.BackgroundColor3 = palette.main
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
			container.BackgroundColor3 = palette.cardBg
			container.BorderSizePixel = 0
			container.Size = UDim2.new(1, 0, 0, 34)
			container.Text = ""
			container.AutoButtonColor = false
			registerCardCorner(addCorner(container, palette.cornerCard))
			local swStroke = addStroke(container, palette.cardStroke, 1.6, 0)

			local titleLbl = Instance.new("TextLabel")
			titleLbl.Name = "Title"
			titleLbl.Parent = container
			titleLbl.BackgroundTransparency = 1
			titleLbl.Position = UDim2.new(0, 12, 0, 0)
			titleLbl.Size = UDim2.new(1, -64, 1, 0)
			titleLbl.Text = tostring(switch_text or "Switch")
			titleLbl.TextColor3 = palette.text
			titleLbl.TextSize = 13
			titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left
			registerBodyFont(titleLbl)

			local pill = Instance.new("Frame")
			pill.Name = "Pill"
			pill.Parent = container
			pill.BackgroundColor3 = palette.pillOff
			pill.BorderSizePixel = 0
			pill.Position = UDim2.new(1, -48, 0.5, -10)
			pill.Size = UDim2.new(0, 38, 0, 20)
			addCorner(pill, 10)
			addStroke(pill, Color3.fromRGB(14, 14, 20), 1.4, 0)

			local knob = Instance.new("Frame")
			knob.Name = "Knob"
			knob.Parent = pill
			knob.BackgroundColor3 = Color3.fromRGB(235, 235, 240)
			knob.BorderSizePixel = 0
			knob.Position = UDim2.new(0, 3, 0.5, -7)
			knob.Size = UDim2.new(0, 14, 0, 14)
			addCorner(knob, 7)

			local toggled = false

			local function syncSwitchTheme(p)
				titleLbl.TextColor3 = p.text
				if toggled then
					container.BackgroundColor3 = p.activeBg
					swStroke.Color = p.activeStroke
					pill.BackgroundColor3 = p.main
				else
					container.BackgroundColor3 = p.cardBg
					swStroke.Color = p.cardStroke
					pill.BackgroundColor3 = p.pillOff
				end
			end

			onThemeChange(syncSwitchTheme)

			local function updateVisual(state)
				syncSwitchTheme(palette)
				if state then
					Tween(knob, {Position = UDim2.new(1, -17, 0.5, -7), BackgroundColor3 = WHITE})
				else
					Tween(knob, {Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Color3.fromRGB(235, 235, 240)})
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
			container.BackgroundColor3 = palette.cardBg
			container.BorderSizePixel = 0
			container.Size = UDim2.new(1, 0, 0, 44)
			registerCardCorner(addCorner(container, palette.cornerCard))
			local slStroke = addStroke(container, palette.cardStroke, 1.6, 0)

			local titleLbl = Instance.new("TextLabel")
			titleLbl.Name = "Title"
			titleLbl.Parent = container
			titleLbl.BackgroundTransparency = 1
			titleLbl.Position = UDim2.new(0, 12, 0, 4)
			titleLbl.Size = UDim2.new(1, -74, 0, 18)
			titleLbl.Text = tostring(slider_text or "Slider")
			titleLbl.TextColor3 = palette.text
			titleLbl.TextSize = 13
			titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left
			registerBodyFont(titleLbl)

			local valLbl = Instance.new("TextLabel")
			valLbl.Name = "Value"
			valLbl.Parent = container
			valLbl.BackgroundTransparency = 1
			valLbl.Position = UDim2.new(1, -62, 0, 4)
			valLbl.Size = UDim2.new(0, 50, 0, 18)
			valLbl.Text = tostring(minVal)
			valLbl.TextColor3 = palette.valText
			valLbl.TextSize = 13
			valLbl.TextXAlignment = Enum.TextXAlignment.Right
			registerTitleFont(valLbl)

			local track = Instance.new("Frame")
			track.Name = "Track"
			track.Parent = container
			track.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
			track.BorderSizePixel = 0
			track.Position = UDim2.new(0, 12, 0, 27)
			track.Size = UDim2.new(1, -24, 0, 8)
			addCorner(track, 4)
			addStroke(track, Color3.fromRGB(48, 48, 58), 1.2, 0)

			local fill = Instance.new("Frame")
			fill.Name = "Indicator"
			fill.Parent = track
			fill.BackgroundColor3 = palette.main
			fill.BorderSizePixel = 0
			fill.Size = UDim2.new(0, 0, 1, 0)
			addCorner(fill, 4)

			local thumb = Instance.new("Frame")
			thumb.Name = "Thumb"
			thumb.Parent = fill
			thumb.BackgroundColor3 = WHITE
			thumb.BorderSizePixel = 0
			thumb.Position = UDim2.new(1, -4, 0.5, -8)
			thumb.Size = UDim2.new(0, 8, 0, 16)
			addCorner(thumb, 4)
			addStroke(thumb, Color3.fromRGB(12, 12, 16), 1.4, 0)

			onThemeChange(function(p)
				container.BackgroundColor3 = p.cardBg
				slStroke.Color = p.cardStroke
				titleLbl.TextColor3 = p.text
				valLbl.TextColor3 = p.valText
				fill.BackgroundColor3 = p.main
			end)

			local hitArea = Instance.new("TextButton")
			hitArea.Name = "HitArea"
			hitArea.Parent = container
			hitArea.BackgroundTransparency = 1
			hitArea.Position = UDim2.new(0, 6, 0, 18)
			hitArea.Size = UDim2.new(1, -12, 0, 24)
			hitArea.Text = ""

			local lastComputed = nil

			local function applyRatio(ratio)
				ratio = math.clamp(ratio, 0, 1)
				fill.Size = UDim2.new(ratio, 0, 1, 0)
				local computed = math.floor(((maxVal - minVal) * ratio) + minVal + 0.5)
				if computed ~= lastComputed then
					lastComputed = computed
					valLbl.Text = tostring(computed)
					pcall(callback, computed)
				end
			end

			local function updateFromInput(inputPos)
				local relX = (inputPos.X - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X)
				applyRatio(relX)
			end

			runtime:Connect(hitArea.InputBegan, function(input)
				if readonly or dropdown_open then return end
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					if beginPointerDrag(input, updateFromInput, function()
						slStroke.Color = palette.cardStroke
					end) then
						slStroke.Color = palette.activeStroke
						updateFromInput(input.Position)
					end
				end
			end)

			function slider_data:Set(new_value)
				new_value = tonumber(new_value) or minVal
				local ratio = (maxVal > minVal) and ((new_value - minVal) / (maxVal - minVal)) or 0
				lastComputed = nil
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
			box.BackgroundColor3 = palette.cardBg
			box.BorderSizePixel = 0
			box.Size = UDim2.new(1, 0, 0, 32)
			box.PlaceholderText = tostring(textbox_text or "Input Text")
			box.PlaceholderColor3 = palette.placeholder
			box.Text = ""
			box.TextColor3 = palette.text
			box.TextSize = 13
			box.ClearTextOnFocus = false
			registerBodyFont(box)
			registerCardCorner(addCorner(box, palette.cornerCard))
			local boxStroke = addStroke(box, palette.cardStroke, 1.6, 0)

			onThemeChange(function(p)
				box.BackgroundColor3 = p.cardBg
				box.PlaceholderColor3 = p.placeholder
				box.TextColor3 = p.text
				boxStroke.Color = box:IsFocused() and p.activeStroke or p.cardStroke
			end)

			runtime:Connect(box.Focused, function()
				boxStroke.Color = palette.activeStroke
			end)

			runtime:Connect(box.FocusLost, function(enterPressed)
				boxStroke.Color = palette.cardStroke
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
			wrapper.BackgroundColor3 = palette.cardBg
			wrapper.BorderSizePixel = 0
			wrapper.ClipsDescendants = true
			wrapper.Size = UDim2.new(1, 0, 0, 32)
			registerCardCorner(addCorner(wrapper, palette.cornerCard))
			local ddStroke = addStroke(wrapper, palette.cardStroke, 1.6, 0)

			local headerBtn = Instance.new("TextButton")
			headerBtn.Name = "Header"
			headerBtn.Parent = wrapper
			headerBtn.BackgroundTransparency = 1
			headerBtn.Size = UDim2.new(1, 0, 0, 32)
			headerBtn.Text = "   " .. dropdown_name
			headerBtn.TextColor3 = palette.text
			headerBtn.TextSize = 13
			headerBtn.TextTruncate = Enum.TextTruncate.AtEnd
			headerBtn.TextXAlignment = Enum.TextXAlignment.Left
			registerBodyFont(headerBtn)

			local arrow = Instance.new("TextLabel")
			arrow.Name = "Arrow"
			arrow.Parent = headerBtn
			arrow.BackgroundTransparency = 1
			arrow.Position = UDim2.new(1, -28, 0, 0)
			arrow.Size = UDim2.new(0, 20, 1, 0)
			arrow.Font = Enum.Font.GothamBold
			arrow.Text = "▼"
			arrow.TextColor3 = palette.valText
			arrow.TextSize = 11

			local listFrame = Instance.new("ScrollingFrame")
			listFrame.Name = "Objects"
			listFrame.Parent = wrapper
			listFrame.BackgroundTransparency = 1
			listFrame.BorderSizePixel = 0
			listFrame.Position = UDim2.new(0, 6, 0, 34)
			listFrame.Size = UDim2.new(1, -12, 0, 0)
			listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
			listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			listFrame.ScrollBarThickness = 2
			listFrame.ScrollBarImageColor3 = palette.main

			local isExpanded = false

			onThemeChange(function(p)
				wrapper.BackgroundColor3 = p.cardBg
				ddStroke.Color = isExpanded and p.activeStroke or p.cardStroke
				headerBtn.TextColor3 = p.text
				arrow.TextColor3 = p.valText
				listFrame.ScrollBarImageColor3 = p.main
				for _, itemBtn in pairs(itemsMap) do
					if itemBtn and itemBtn.Parent then
						itemBtn.BackgroundColor3 = p.itemBg
						itemBtn.TextColor3 = p.text
					end
				end
			end)

			local listLayout = Instance.new("UIListLayout")
			listLayout.Parent = listFrame
			listLayout.SortOrder = Enum.SortOrder.LayoutOrder
			listLayout.Padding = UDim.new(0, 4)

			local function refreshHeight()
				local count = 0
				for _ in pairs(itemsMap) do count = count + 1 end
				local targetListH = math.min(count * 28, 130)
				listFrame.Size = UDim2.new(1, -12, 0, targetListH)
				ddStroke.Color = isExpanded and palette.activeStroke or palette.cardStroke
				Tween(wrapper, {Size = UDim2.new(1, 0, 0, isExpanded and (38 + targetListH) or 32)})
			end

			runtime:Connect(headerBtn.MouseButton1Click, function()
				isExpanded = not isExpanded
				dropdown_open = isExpanded
				Tween(arrow, {Rotation = isExpanded and 180 or 0})
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
				itemBtn.BackgroundColor3 = palette.itemBg
				itemBtn.BorderSizePixel = 0
				itemBtn.Size = UDim2.new(1, 0, 0, 24)
				itemBtn.Text = "  " .. itemName
				itemBtn.TextColor3 = palette.text
				itemBtn.TextSize = 12
				itemBtn.TextXAlignment = Enum.TextXAlignment.Left
				itemBtn.AutoButtonColor = false
				registerBodyFont(itemBtn)
				addCorner(itemBtn, 6)

				itemsMap[itemName] = itemBtn

				runtime:Connect(itemBtn.MouseEnter, function()
					itemBtn.BackgroundColor3 = palette.main
				end)
				runtime:Connect(itemBtn.MouseLeave, function()
					itemBtn.BackgroundColor3 = palette.itemBg
				end)
				runtime:Connect(itemBtn.MouseButton1Click, function()
					headerBtn.Text = "   [ " .. itemName .. " ]"
					isExpanded = false
					dropdown_open = false
					Tween(arrow, {Rotation = 0})
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

		-- ELEMENTO: SELECTOR DESPLEGABLE DE TEMAS (Colores + Tipografía + Geometría)
		function tab_data:AddThemeSelector(selector_text, callback)
			local selector_data = {}
			selector_text = tostring(selector_text or "Tema de Interfaz")
			callback = typeof(callback) == "function" and callback or function() end

			local wrapper = Instance.new("Frame")
			wrapper.Name = "ThemeSelector"
			wrapper.Parent = tabPage
			wrapper.BackgroundColor3 = palette.cardBg
			wrapper.BorderSizePixel = 0
			wrapper.ClipsDescendants = true
			wrapper.Size = UDim2.new(1, 0, 0, 34)
			registerCardCorner(addCorner(wrapper, palette.cornerCard))
			local tsStroke = addStroke(wrapper, palette.cardStroke, 1.6, 0)

			local headerBtn = Instance.new("TextButton")
			headerBtn.Name = "Header"
			headerBtn.Parent = wrapper
			headerBtn.BackgroundTransparency = 1
			headerBtn.Size = UDim2.new(1, 0, 0, 34)
			headerBtn.Text = ""

			local titleLbl = Instance.new("TextLabel")
			titleLbl.Name = "Title"
			titleLbl.Parent = headerBtn
			titleLbl.BackgroundTransparency = 1
			titleLbl.Position = UDim2.new(0, 12, 0, 0)
			titleLbl.Size = UDim2.new(1, -78, 1, 0)
			titleLbl.Text = selector_text .. ": " .. opts.theme_name
			titleLbl.TextColor3 = palette.text
			titleLbl.TextSize = 13
			titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left
			registerBodyFont(titleLbl)

			local activeDot = Instance.new("Frame")
			activeDot.Name = "ActiveDot"
			activeDot.Parent = headerBtn
			activeDot.BackgroundColor3 = palette.main
			activeDot.BorderSizePixel = 0
			activeDot.Position = UDim2.new(1, -56, 0.5, -8)
			activeDot.Size = UDim2.new(0, 24, 0, 16)
			addCorner(activeDot, 8)
			addStroke(activeDot, Color3.fromRGB(14, 14, 20), 1.4, 0)

			local arrow = Instance.new("TextLabel")
			arrow.Name = "Arrow"
			arrow.Parent = headerBtn
			arrow.BackgroundTransparency = 1
			arrow.Position = UDim2.new(1, -28, 0, 0)
			arrow.Size = UDim2.new(0, 20, 1, 0)
			arrow.Font = Enum.Font.GothamBold
			arrow.Text = "▼"
			arrow.TextColor3 = palette.valText
			arrow.TextSize = 11

			local listFrame = Instance.new("ScrollingFrame")
			listFrame.Name = "ThemeList"
			listFrame.Parent = wrapper
			listFrame.BackgroundTransparency = 1
			listFrame.BorderSizePixel = 0
			listFrame.Position = UDim2.new(0, 8, 0, 38)
			listFrame.Size = UDim2.new(1, -16, 0, 146)
			listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
			listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			listFrame.ScrollBarThickness = 2
			listFrame.ScrollBarImageColor3 = palette.main

			local listLayout = Instance.new("UIListLayout")
			listLayout.Parent = listFrame
			listLayout.SortOrder = Enum.SortOrder.LayoutOrder
			listLayout.Padding = UDim.new(0, 5)

			local isExpanded = false
			local themeOptionRows = {}

			local function refreshOptionHighlights()
				titleLbl.Text = selector_text .. ": " .. opts.theme_name
				activeDot.BackgroundColor3 = palette.main
				for name, rowData in pairs(themeOptionRows) do
					local isCurrent = (name == opts.theme_name)
					rowData.btn.BackgroundColor3 = isCurrent and palette.activeBg or rowData.baseBg
					rowData.stroke.Color = isCurrent and rowData.accent or Color3.fromRGB(48, 48, 58)
					rowData.stroke.Thickness = isCurrent and 1.8 or 1.2
				end
			end

			for _, tName in ipairs(THEME_ORDER) do
				local tInfo = THEMES[tName]
				local baseBg = shiftColor(tInfo.bg_color, 0.06)

				local optBtn = Instance.new("TextButton")
				optBtn.Name = "Theme_" .. tName
				optBtn.Parent = listFrame
				optBtn.BackgroundColor3 = baseBg
				optBtn.BorderSizePixel = 0
				optBtn.Size = UDim2.new(1, 0, 0, 28)
				optBtn.Text = ""
				optBtn.AutoButtonColor = false
				addCorner(optBtn, tInfo.corner_card)
				local optStroke = addStroke(optBtn, Color3.fromRGB(48, 48, 58), 1.2, 0)

				local dot = Instance.new("Frame")
				dot.Parent = optBtn
				dot.BackgroundColor3 = tInfo.main_color
				dot.BorderSizePixel = 0
				dot.Position = UDim2.new(0, 10, 0.5, -7)
				dot.Size = UDim2.new(0, 14, 0, 14)
				addCorner(dot, 7)

				local nameLbl = Instance.new("TextLabel")
				nameLbl.Parent = optBtn
				nameLbl.BackgroundTransparency = 1
				nameLbl.Position = UDim2.new(0, 32, 0, 0)
				nameLbl.Size = UDim2.new(1, -42, 1, 0)
				nameLbl.Font = tInfo.font_title
				nameLbl.Text = tName
				nameLbl.TextColor3 = tInfo.text_color
				nameLbl.TextSize = 13
				nameLbl.TextXAlignment = Enum.TextXAlignment.Left

				themeOptionRows[tName] = {
					btn = optBtn,
					stroke = optStroke,
					baseBg = baseBg,
					accent = tInfo.main_color,
				}

				runtime:Connect(optBtn.MouseButton1Click, function()
					window_data:SetTheme(tName)
					isExpanded = false
					dropdown_open = false
					Tween(arrow, {Rotation = 0})
					tsStroke.Color = palette.cardStroke
					Tween(wrapper, {Size = UDim2.new(1, 0, 0, 34)})
					pcall(callback, tName)
				end)
			end

			onThemeChange(function(p)
				wrapper.BackgroundColor3 = p.cardBg
				tsStroke.Color = isExpanded and p.activeStroke or p.cardStroke
				titleLbl.TextColor3 = p.text
				arrow.TextColor3 = p.valText
				listFrame.ScrollBarImageColor3 = p.main
				refreshOptionHighlights()
			end)

			runtime:Connect(headerBtn.MouseButton1Click, function()
				isExpanded = not isExpanded
				dropdown_open = isExpanded
				Tween(arrow, {Rotation = isExpanded and 180 or 0})
				tsStroke.Color = isExpanded and palette.activeStroke or palette.cardStroke
				local listH = math.min(#THEME_ORDER * 33, 150)
				listFrame.Size = UDim2.new(1, -16, 0, listH)
				Tween(wrapper, {Size = UDim2.new(1, 0, 0, isExpanded and (44 + listH) or 34)})
			end)

			function selector_data:Set(themeName)
				if type(themeName) == "string" and THEMES[themeName] then
					window_data:SetTheme(themeName)
					pcall(callback, themeName)
				end
			end

			return selector_data, wrapper
		end

		-- Alias por compatibilidad
		tab_data.AddThemeDropdown = tab_data.AddThemeSelector

		-- ELEMENTO: FOLDER
		function tab_data:AddFolder(folder_name)
			local folder_data = {}
			folder_name = tostring(folder_name or "Folder")

			local folderBox = Instance.new("Frame")
			folderBox.Name = "Folder"
			folderBox.Parent = tabPage
			folderBox.BackgroundColor3 = palette.sidebarBg
			folderBox.BorderSizePixel = 0
			folderBox.ClipsDescendants = true
			folderBox.Size = UDim2.new(1, 0, 0, 32)
			registerCardCorner(addCorner(folderBox, palette.cornerCard))
			local fldStroke = addStroke(folderBox, palette.activeStroke, 1.5, 0.25)

			local folderBtn = Instance.new("TextButton")
			folderBtn.Name = "Header"
			folderBtn.Parent = folderBox
			folderBtn.BackgroundColor3 = palette.folderHeader
			folderBtn.BorderSizePixel = 0
			folderBtn.Size = UDim2.new(1, 0, 0, 32)
			folderBtn.Text = "  ▸  " .. folder_name
			folderBtn.TextColor3 = WHITE
			folderBtn.TextSize = 13
			folderBtn.TextXAlignment = Enum.TextXAlignment.Left
			registerTitleFont(folderBtn)
			registerCardCorner(addCorner(folderBtn, palette.cornerCard))

			onThemeChange(function(p)
				folderBox.BackgroundColor3 = p.sidebarBg
				fldStroke.Color = p.activeStroke
				folderBtn.BackgroundColor3 = p.folderHeader
			end)

			local content = Instance.new("Frame")
			content.Name = "Objects"
			content.Parent = folderBox
			content.BackgroundTransparency = 1
			content.Position = UDim2.new(0, 7, 0, 37)
			content.Size = UDim2.new(1, -14, 0, 0)
			content.AutomaticSize = Enum.AutomaticSize.Y

			local contentLayout = Instance.new("UIListLayout")
			contentLayout.Parent = content
			contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
			contentLayout.Padding = UDim.new(0, 6)

			local folderOpen = false

			local function syncFolderSize()
				if folderOpen then
					folderBox.Size = UDim2.new(1, 0, 0, 44 + contentLayout.AbsoluteContentSize.Y)
				else
					folderBox.Size = UDim2.new(1, 0, 0, 32)
				end
			end

			runtime:Connect(contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				if folderOpen then
					syncFolderSize()
				end
			end)

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
