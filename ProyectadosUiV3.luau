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
local INK_OUTLINE = Color3.fromRGB(16, 15, 22)
local CLOSE_RED = Color3.fromRGB(214, 68, 64)
local DEFAULT_TWEEN = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Temas (sin Default Elirium, con emojis de Elirium en el tema morado)
local THEME_ORDER = {
	"Morado Neón",
	"Carmesí Imperial",
	"Ciber Cian",
	"Esmeralda Tóxica",
	"Oro Real",
	"Rosa Sakura",
	"Mecha Titanio",
}

local THEMES = {
	["Morado Neón"] = {
		main_color = Color3.fromRGB(162, 74, 224),
		bg_color = Color3.fromRGB(22, 18, 30),
		surface_color = Color3.fromRGB(32, 26, 44),
		bar_color = Color3.fromRGB(28, 22, 38),
		border_color = INK_OUTLINE,
		text_color = Color3.fromRGB(244, 240, 250),
		muted_text = Color3.fromRGB(168, 156, 186),
		font_title = Enum.Font.GothamBold,
		font_body = Enum.Font.GothamMedium,
		corner_window = 10,
		corner_card = 8,
		open_icon = "📽️",
		closed_icon = "❤️‍🔥",
		gui_icon = "⚙️",
		gui_hidden_icon = "⚙️",
	},
	["Carmesí Imperial"] = {
		main_color = Color3.fromRGB(214, 72, 82),
		bg_color = Color3.fromRGB(24, 18, 20),
		surface_color = Color3.fromRGB(36, 26, 28),
		bar_color = Color3.fromRGB(32, 22, 24),
		border_color = INK_OUTLINE,
		text_color = Color3.fromRGB(250, 242, 243),
		muted_text = Color3.fromRGB(178, 154, 158),
		font_title = Enum.Font.FredokaOne,
		font_body = Enum.Font.GothamMedium,
		corner_window = 10,
		corner_card = 8,
		open_icon = "👑",
		closed_icon = "🌹",
		gui_icon = "🗡️",
		gui_hidden_icon = "🗡️",
	},
	["Ciber Cian"] = {
		main_color = Color3.fromRGB(48, 168, 218),
		bg_color = Color3.fromRGB(18, 24, 32),
		surface_color = Color3.fromRGB(26, 35, 46),
		bar_color = Color3.fromRGB(22, 30, 40),
		border_color = INK_OUTLINE,
		text_color = Color3.fromRGB(238, 246, 252),
		muted_text = Color3.fromRGB(150, 174, 192),
		font_title = Enum.Font.RobotoMono,
		font_body = Enum.Font.RobotoMono,
		corner_window = 8,
		corner_card = 6,
		open_icon = "⚡",
		closed_icon = "💠",
		gui_icon = "🛰️",
		gui_hidden_icon = "🛰️",
	},
	["Esmeralda Tóxica"] = {
		main_color = Color3.fromRGB(68, 192, 98),
		bg_color = Color3.fromRGB(18, 25, 21),
		surface_color = Color3.fromRGB(26, 36, 30),
		bar_color = Color3.fromRGB(22, 31, 26),
		border_color = INK_OUTLINE,
		text_color = Color3.fromRGB(240, 250, 244),
		muted_text = Color3.fromRGB(152, 182, 162),
		font_title = Enum.Font.Ubuntu,
		font_body = Enum.Font.Ubuntu,
		corner_window = 10,
		corner_card = 8,
		open_icon = "🧪",
		closed_icon = "💚",
		gui_icon = "🌿",
		gui_hidden_icon = "🌿",
	},
	["Oro Real"] = {
		main_color = Color3.fromRGB(226, 174, 46),
		bg_color = Color3.fromRGB(25, 22, 17),
		surface_color = Color3.fromRGB(36, 31, 23),
		bar_color = Color3.fromRGB(31, 27, 20),
		border_color = INK_OUTLINE,
		text_color = Color3.fromRGB(250, 246, 236),
		muted_text = Color3.fromRGB(186, 170, 138),
		font_title = Enum.Font.GothamBold,
		font_body = Enum.Font.GothamMedium,
		corner_window = 10,
		corner_card = 8,
		open_icon = "🏆",
		closed_icon = "✨",
		gui_icon = "👑",
		gui_hidden_icon = "👑",
	},
	["Rosa Sakura"] = {
		main_color = Color3.fromRGB(224, 96, 156),
		bg_color = Color3.fromRGB(25, 18, 22),
		surface_color = Color3.fromRGB(36, 26, 32),
		bar_color = Color3.fromRGB(31, 22, 28),
		border_color = INK_OUTLINE,
		text_color = Color3.fromRGB(250, 242, 246),
		muted_text = Color3.fromRGB(186, 156, 170),
		font_title = Enum.Font.Cartoon,
		font_body = Enum.Font.GothamMedium,
		corner_window = 10,
		corner_card = 8,
		open_icon = "🌸",
		closed_icon = "🎀",
		gui_icon = "🌸",
		gui_hidden_icon = "🌸",
	},
	["Mecha Titanio"] = {
		main_color = Color3.fromRGB(146, 166, 192),
		bg_color = Color3.fromRGB(20, 23, 29),
		surface_color = Color3.fromRGB(30, 34, 42),
		bar_color = Color3.fromRGB(25, 29, 36),
		border_color = INK_OUTLINE,
		text_color = Color3.fromRGB(242, 246, 250),
		muted_text = Color3.fromRGB(158, 170, 186),
		font_title = Enum.Font.Sarpanch,
		font_body = Enum.Font.Sarpanch,
		corner_window = 9,
		corner_card = 7,
		open_icon = "🛡️",
		closed_icon = "⚙️",
		gui_icon = "🔩",
		gui_hidden_icon = "🔩",
	},
}

local DEFAULT_THEME_NAME = "Morado Neón"

local ui_options = {
	theme = DEFAULT_THEME_NAME,
	neon = false, -- apagado = sólido, encendido = neón
	min_size = Vector2.new(440, 310),
	toggle_key = Enum.KeyCode.RightShift,
	can_resize = true,
	hud_button_text = "HUB",
}

local function shiftColor(c, delta)
	if delta >= 0 then
		return c:Lerp(WHITE, math.clamp(delta, 0, 1))
	else
		return c:Lerp(BLACK, math.clamp(-delta, 0, 1))
	end
end

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
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

-- Guardado persistente con escritura diferida
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

local function saveWindowNeon(winKey, isNeon)
	local entry = _G.UniversalUISavedConfig[winKey] or {}
	entry.neon = (isNeon == true)
	_G.UniversalUISavedConfig[winKey] = entry
	flushConfigFile()
end

local function getSavedWindowNeon(winKey)
	local entry = _G.UniversalUISavedConfig[winKey]
	if type(entry) == "table" and type(entry.neon) == "boolean" then
		return entry.neon
	end
	return nil
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

-- Controlador único de arrastre y deslizadores
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
local syncFloatingGuiBtn = nil

local function toggleGuiVisibility()
	if checks.binding then return end
	imgui.Enabled = not imgui.Enabled
	if syncFloatingGuiBtn then
		pcall(syncFloatingGuiBtn)
	end
end

runtime:Connect(UIS.InputBegan, function(input, gameProcessed)
	if gameProcessed then return end
	local toggleKey = (typeof(ui_options.toggle_key) == "EnumItem") and ui_options.toggle_key or Enum.KeyCode.RightShift
	if input.KeyCode == toggleKey and not checks.binding then
		toggleGuiVisibility()
	end
end)

-- Botón integrado discreto estilo HUD del juego
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "ToggleUI"
toggleGui.ResetOnSpawn = false
toggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mountGui(toggleGui)
runtime:AddCleanup(function() toggleGui:Destroy() end)

local defaultThemeInfo = THEMES[DEFAULT_THEME_NAME]
local compactHud = isCompactDevice()
local hudBtnW = compactHud and 92 or 104
local hudBtnH = compactHud and 28 or 32

local floatingBtn = Instance.new("TextButton")
floatingBtn.Name = "OpenCloseBtn"
floatingBtn.Parent = toggleGui
floatingBtn.Active = true
floatingBtn.BackgroundColor3 = defaultThemeInfo.surface_color
floatingBtn.Position = UDim2.new(0, 14, 0.5, 110)
floatingBtn.Size = UDim2.new(0, hudBtnW, 0, hudBtnH)
floatingBtn.Font = defaultThemeInfo.font_title
floatingBtn.Text = ""
floatingBtn.TextColor3 = defaultThemeInfo.text_color
floatingBtn.AutoButtonColor = false
floatingBtn.ZIndex = 100

local floatingCorner = Instance.new("UICorner")
floatingCorner.CornerRadius = UDim.new(0, 8)
floatingCorner.Parent = floatingBtn

local floatingStroke = Instance.new("UIStroke")
floatingStroke.Color = INK_OUTLINE
floatingStroke.Thickness = 2
floatingStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
floatingStroke.Parent = floatingBtn

local floatingIcon = Instance.new("TextLabel")
floatingIcon.Name = "Icon"
floatingIcon.Parent = floatingBtn
floatingIcon.BackgroundTransparency = 1
floatingIcon.Position = UDim2.new(0, 6, 0, 0)
floatingIcon.Size = UDim2.new(0, 22, 1, 0)
floatingIcon.Font = defaultThemeInfo.font_title
floatingIcon.Text = defaultThemeInfo.gui_icon or "⚙️"
floatingIcon.TextSize = compactHud and 14 or 16
floatingIcon.TextColor3 = defaultThemeInfo.text_color
floatingIcon.ZIndex = 101

local floatingLabel = Instance.new("TextLabel")
floatingLabel.Name = "Label"
floatingLabel.Parent = floatingBtn
floatingLabel.BackgroundTransparency = 1
floatingLabel.Position = UDim2.new(0, 30, 0, 0)
floatingLabel.Size = UDim2.new(1, -34, 1, 0)
floatingLabel.Font = defaultThemeInfo.font_title
floatingLabel.Text = ui_options.hud_button_text
floatingLabel.TextColor3 = defaultThemeInfo.text_color
floatingLabel.TextSize = compactHud and 12 or 13
floatingLabel.TextTruncate = Enum.TextTruncate.AtEnd
floatingLabel.TextXAlignment = Enum.TextXAlignment.Left
floatingLabel.ZIndex = 101

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
					toggleGuiVisibility()
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
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = parent
	return c
end

local function addStroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness or 1.8
	s.Transparency = transparency or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function setGradientState(parent, enabled, colorA, colorB, angle)
	local grad = parent:FindFirstChildOfClass("UIGradient")
	if enabled then
		if not grad then
			grad = Instance.new("UIGradient")
			grad.Parent = parent
		end
		grad.Color = ColorSequence.new(colorA, colorB)
		grad.Rotation = angle or 90
		grad.Enabled = true
	elseif grad then
		grad.Enabled = false
	end
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

	local savedNeon = getSavedWindowNeon(winKey)
	local initialNeon = (savedNeon ~= nil) and savedNeon or ((typeof(options) == "table" and type(options.neon) == "boolean") and options.neon or ui_options.neon)

	local opts = {
		theme_name = initialThemeName,
		neon = initialNeon,
		min_size = hardMinSize,
		can_resize = (typeof(options) == "table" and options.can_resize ~= nil) and options.can_resize or ui_options.can_resize,
		tween_time = 0.12,
	}

	-- Paleta limpia: Sólido (apagado) o Neón (encendido)
	local palette = {}
	local function rebuildPalette()
		local t = THEMES[opts.theme_name] or THEMES[DEFAULT_THEME_NAME]
		local neonOn = opts.neon == true
		local neonAccent = shiftColor(t.main_color, 0.30)
		local neonDeep = shiftColor(t.main_color, -0.26)

		palette.name = opts.theme_name
		palette.isNeon = neonOn
		palette.main = neonOn and shiftColor(t.main_color, 0.10) or t.main_color
		palette.neonBright = neonAccent
		palette.neonDeep = neonDeep
		palette.bg = neonOn and shiftColor(t.bg_color, -0.14) or t.bg_color
		palette.surface = neonOn and shiftColor(t.surface_color, -0.04) or t.surface_color
		palette.bar = neonOn and shiftColor(t.bar_color, -0.04) or t.bar_color
		palette.border = neonOn and neonAccent or INK_OUTLINE
		palette.cardBorder = neonOn and t.main_color or INK_OUTLINE
		palette.text = neonOn and shiftColor(t.text_color, 0.04) or t.text_color
		palette.muted = neonOn and shiftColor(t.muted_text, 0.12) or t.muted_text
		palette.fontTitle = t.font_title
		palette.fontBody = t.font_body
		palette.cornerWindow = t.corner_window
		palette.cornerCard = t.corner_card
		palette.strokeThickness = neonOn and 2.2 or 1.8
		palette.openIcon = t.open_icon or "📽️"
		palette.closedIcon = t.closed_icon or "❤️‍🔥"
		palette.guiIcon = t.gui_icon or "⚙️"
		palette.guiHiddenIcon = t.gui_hidden_icon or palette.guiIcon
	end
	rebuildPalette()

	local themeCallbacks = {}
	local titleFontObjs = {}
	local bodyFontObjs = {}
	local cardCornerObjs = {}
	local syncLayoutAfterTheme = nil
	local neonSwitchController = nil

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

	local function applyFloatingTheme()
		floatingStroke.Color = palette.isNeon and palette.neonBright or INK_OUTLINE
		floatingStroke.Thickness = palette.strokeThickness
		floatingBtn.BackgroundColor3 = imgui.Enabled and palette.surface or palette.bg
		floatingIcon.Text = imgui.Enabled and palette.guiIcon or palette.guiHiddenIcon
		floatingIcon.Font = palette.fontTitle
		floatingIcon.TextColor3 = palette.isNeon and palette.neonBright or palette.text
		floatingLabel.Font = palette.fontTitle
		floatingLabel.Text = imgui.Enabled and ui_options.hud_button_text or "OPEN"
		floatingLabel.TextColor3 = imgui.Enabled and palette.text or palette.muted
		setGradientState(floatingBtn, false)
	end

	syncFloatingGuiBtn = applyFloatingTheme

	local function broadcastTheme()
		rebuildPalette()
		applyFloatingTheme()

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
		if neonSwitchController then
			pcall(neonSwitchController.SyncVisual, opts.neon)
		end
		if syncLayoutAfterTheme then
			pcall(syncLayoutAfterTheme)
		end
	end

	applyFloatingTheme()

	local startX = math.max(12, math.floor((vp.X - initialSize.X) / 2) + ((windows - 1) * 18))
	local startY = math.clamp(60 + ((windows - 1) * 18), 54, math.max(54, vp.Y - initialSize.Y - 12))

	local BORDER_THICKNESS = 1.5
	local MINIMIZED_HEIGHT = 38 + (BORDER_THICKNESS * 2)

	-- Ventana simple y limpia
	local Window = Instance.new("Frame")
	Window.Name = "Window_" .. windows
	Window.Parent = windowsFrame
	Window.Active = true
	Window.BackgroundColor3 = palette.bg
	Window.BorderSizePixel = 0
	Window.ClipsDescendants = true
	Window.Position = UDim2.new(0, startX, 0, startY)
	Window.Size = UDim2.new(0, initialSize.X, 0, initialSize.Y)
	local windowCorner = addCorner(Window, palette.cornerWindow)
	local windowStroke = addStroke(Window, palette.border, palette.strokeThickness, 0)

	local InnerFrame = Instance.new("Frame")
	InnerFrame.Name = "Inner"
	InnerFrame.Parent = Window
	InnerFrame.BackgroundColor3 = palette.bg
	InnerFrame.BorderSizePixel = 0
	InnerFrame.ClipsDescendants = true
	InnerFrame.Position = UDim2.new(0, BORDER_THICKNESS, 0, BORDER_THICKNESS)
	InnerFrame.Size = UDim2.new(1, -(BORDER_THICKNESS * 2), 1, -(BORDER_THICKNESS * 2))
	local innerCorner = addCorner(InnerFrame, math.max(5, palette.cornerWindow - 2))

	local Bar = Instance.new("Frame")
	Bar.Name = "Bar"
	Bar.Parent = InnerFrame
	Bar.Active = true
	Bar.BackgroundColor3 = palette.bar
	Bar.BorderSizePixel = 0
	Bar.Size = UDim2.new(1, 0, 0, 36)
	local barCorner = addCorner(Bar, math.max(5, palette.cornerWindow - 2))

	local BarCover = Instance.new("Frame")
	BarCover.Name = "BarCover"
	BarCover.Parent = Bar
	BarCover.BackgroundColor3 = palette.bar
	BarCover.BorderSizePixel = 0
	BarCover.Position = UDim2.new(0, 0, 0.5, 0)
	BarCover.Size = UDim2.new(1, 0, 0.5, 0)

	local BarDivider = Instance.new("Frame")
	BarDivider.Name = "BarDivider"
	BarDivider.Parent = Bar
	BarDivider.BackgroundColor3 = INK_OUTLINE
	BarDivider.BorderSizePixel = 0
	BarDivider.Position = UDim2.new(0, 0, 1, -1)
	BarDivider.Size = UDim2.new(1, 0, 0, 1)
	BarDivider.ZIndex = 4

	bindWindowDrag(Window, {Window, Bar})

	onThemeChange(function(p)
		Window.BackgroundColor3 = p.bg
		windowCorner.CornerRadius = UDim.new(0, p.cornerWindow)
		windowStroke.Color = p.border
		windowStroke.Thickness = p.strokeThickness

		local innerR = UDim.new(0, math.max(5, p.cornerWindow - 2))
		innerCorner.CornerRadius = innerR
		barCorner.CornerRadius = innerR

		InnerFrame.BackgroundColor3 = p.bg
		Bar.BackgroundColor3 = p.bar
		BarCover.BackgroundColor3 = p.bar
		BarDivider.BackgroundColor3 = p.isNeon and p.neonBright or INK_OUTLINE
		setGradientState(Bar, false)
		setGradientState(BarCover, false)
		setGradientState(InnerFrame, false)
	end)

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Name = "Title"
	TitleLabel.Parent = Bar
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Position = UDim2.new(0, 12, 0, 0)
	TitleLabel.Size = UDim2.new(1, -48, 1, 0)
	TitleLabel.Text = tostring(title or "New Window")
	TitleLabel.TextColor3 = palette.text
	TitleLabel.TextSize = 14
	TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.ZIndex = 4
	registerTitleFont(TitleLabel)

	onThemeChange(function(p)
		TitleLabel.TextColor3 = p.isNeon and p.neonBright or p.text
	end)

	local isOpen = true

	local ToggleBtn = Instance.new("TextButton")
	ToggleBtn.Name = "Toggle"
	ToggleBtn.Parent = Bar
	ToggleBtn.BackgroundColor3 = CLOSE_RED
	ToggleBtn.Position = UDim2.new(1, -31, 0.5, -12)
	ToggleBtn.Size = UDim2.new(0, 24, 0, 24)
	ToggleBtn.Font = Enum.Font.GothamBold
	ToggleBtn.Text = palette.openIcon
	ToggleBtn.TextColor3 = WHITE
	ToggleBtn.TextSize = 13
	ToggleBtn.AutoButtonColor = false
	ToggleBtn.ZIndex = 5
	addCorner(ToggleBtn, 6)
	local toggleStroke = addStroke(ToggleBtn, INK_OUTLINE, 1.6, 0)

	onThemeChange(function(p)
		ToggleBtn.BackgroundColor3 = isOpen and CLOSE_RED or p.surface
		ToggleBtn.TextColor3 = WHITE
		toggleStroke.Color = p.isNeon and p.neonBright or INK_OUTLINE
		toggleStroke.Thickness = p.strokeThickness
		ToggleBtn.Text = isOpen and p.openIcon or p.closedIcon
	end)

	local sidebarW = isCompactDevice() and 96 or 112

	local TabSelection = Instance.new("ScrollingFrame")
	TabSelection.Name = "TabSelection"
	TabSelection.Parent = InnerFrame
	TabSelection.Active = true
	TabSelection.BackgroundColor3 = palette.surface
	TabSelection.BorderSizePixel = 0
	TabSelection.Position = UDim2.new(0, 8, 0, 44)
	TabSelection.Size = UDim2.new(0, sidebarW, 1, -52)
	TabSelection.CanvasSize = UDim2.new(0, 0, 0, 0)
	TabSelection.AutomaticCanvasSize = Enum.AutomaticSize.Y
	TabSelection.ScrollBarThickness = 2
	TabSelection.ScrollBarImageColor3 = palette.main
	TabSelection.ZIndex = 3
	TabSelection.Visible = false
	registerCardCorner(addCorner(TabSelection, palette.cornerCard))
	local sbStroke = addStroke(TabSelection, palette.cardBorder, palette.strokeThickness, 0)

	onThemeChange(function(p)
		TabSelection.BackgroundColor3 = p.surface
		TabSelection.ScrollBarImageColor3 = p.isNeon and p.neonBright or p.main
		sbStroke.Color = p.cardBorder
		sbStroke.Thickness = p.strokeThickness
	end)

	local TabButtons = Instance.new("Frame")
	TabButtons.Name = "TabButtons"
	TabButtons.Parent = TabSelection
	TabButtons.BackgroundTransparency = 1
	TabButtons.Position = UDim2.new(0, 6, 0, 6)
	TabButtons.Size = UDim2.new(1, -12, 0, 0)
	TabButtons.AutomaticSize = Enum.AutomaticSize.Y
	TabButtons.ZIndex = 4

	local tabListLayout = Instance.new("UIListLayout")
	tabListLayout.Parent = TabButtons
	tabListLayout.FillDirection = Enum.FillDirection.Vertical
	tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabListLayout.Padding = UDim.new(0, 6)

	local TabsContainer = Instance.new("Frame")
	TabsContainer.Name = "Tabs"
	TabsContainer.Parent = InnerFrame
	TabsContainer.BackgroundTransparency = 1
	TabsContainer.Position = UDim2.new(0, 10, 0, 44)
	TabsContainer.Size = UDim2.new(1, -20, 1, -52)
	TabsContainer.ZIndex = 3

	local Resizer = Instance.new("TextButton")
	Resizer.Name = "Resizer"
	Resizer.Parent = Window
	Resizer.BackgroundTransparency = 1
	Resizer.Position = UDim2.new(1, -24, 1, -24)
	Resizer.Size = UDim2.new(0, 24, 0, 24)
	Resizer.Text = "◢"
	Resizer.TextColor3 = palette.muted
	Resizer.TextSize = 12
	Resizer.Visible = opts.can_resize
	Resizer.ZIndex = 10

	onThemeChange(function(p)
		Resizer.TextColor3 = p.isNeon and p.neonBright or p.muted
	end)

	local savedHeight = initialSize.Y
	local hasTabs = false
	local activeTabBtn = nil
	local activeTabPage = nil
	local tabStrokes = {}
	local dropdown_open = false

	local function applyTabLayoutGeometry()
		local nextSidebarW = isCompactDevice() and 96 or 112
		if nextSidebarW ~= sidebarW then
			sidebarW = nextSidebarW
		end
		TabSelection.Size = UDim2.new(0, sidebarW, 1, -52)
		TabSelection.Position = UDim2.new(0, 8, 0, 44)
		if hasTabs then
			TabsContainer.Position = UDim2.new(0, sidebarW + 14, 0, 44)
			TabsContainer.Size = UDim2.new(1, -(sidebarW + 22), 1, -52)
		else
			TabsContainer.Position = UDim2.new(0, 10, 0, 44)
			TabsContainer.Size = UDim2.new(1, -20, 1, -52)
		end
		if isOpen then
			InnerFrame.Visible = true
			TabsContainer.Visible = true
			if hasTabs then
				TabSelection.Visible = true
			end
			if activeTabPage then
				activeTabPage.Visible = true
				activeTabPage.CanvasPosition = Vector2.new(0, activeTabPage.CanvasPosition.Y)
			end
		end
	end

	local function clampToViewport()
		if not Window or not Window.Parent then return end
		local currentReq = getSavedWindowSize(winKey) or defaultSize
		local _, newHardMin, currentVp = getResponsiveDimensions(currentReq, true)
		opts.min_size = newHardMin

		applyTabLayoutGeometry()

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

	syncLayoutAfterTheme = function()
		dropdown_open = false
		clampToViewport()
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
					applyTabLayoutGeometry()
				end, function()
					savedHeight = Window.Size.Y.Offset
					saveWindowSize(winKey, Window.Size.X.Offset, Window.Size.Y.Offset)
					clampToViewport()
				end)
			end
		end)
	end

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
			BarDivider.Visible = false
			Tween(Window, {Size = UDim2.new(0, Window.AbsoluteSize.X, 0, MINIMIZED_HEIGHT)})
			ToggleBtn.BackgroundColor3 = palette.surface
			ToggleBtn.Text = palette.closedIcon
			isOpen = false
			nativeTask.delay(opts.tween_time, function() canToggle = true end)
		else
			Tween(Window, {Size = UDim2.new(0, Window.AbsoluteSize.X, 0, savedHeight)})
			nativeTask.delay(opts.tween_time * 0.6, function()
				if not runtime.Alive then return end
				BarCover.Visible = true
				BarDivider.Visible = true
				if hasTabs then TabSelection.Visible = true end
				TabsContainer.Visible = true
				Resizer.Visible = opts.can_resize
				ToggleBtn.BackgroundColor3 = CLOSE_RED
				ToggleBtn.Text = palette.openIcon
				applyTabLayoutGeometry()
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

	function window_data:SetNeon(enabled)
		opts.neon = (enabled == true)
		broadcastTheme()
		saveWindowNeon(winKey, opts.neon)
	end

	function window_data:IsNeon()
		return opts.neon == true
	end

	local function styleTabBtn(btn, selected)
		local st = tabStrokes[btn]
		if selected then
			btn.BackgroundColor3 = palette.main
			btn.TextColor3 = WHITE
			if st then
				st.Color = palette.isNeon and palette.neonBright or INK_OUTLINE
				st.Thickness = palette.strokeThickness
			end
			setGradientState(btn, palette.isNeon, palette.main, palette.neonBright, 0)
		else
			btn.BackgroundColor3 = palette.bg
			btn.TextColor3 = palette.muted
			if st then
				st.Color = palette.cardBorder
				st.Thickness = math.max(1.5, palette.strokeThickness - 0.3)
			end
			setGradientState(btn, false)
		end
	end

	function window_data:AddTab(tab_name)
		local tab_data = {}
		tab_name = tostring(tab_name or "New Tab")

		if not hasTabs then
			hasTabs = true
			applyTabLayoutGeometry()
		end
		if isOpen then TabSelection.Visible = true end

		local tabBtn = Instance.new("TextButton")
		tabBtn.Name = "TabBtn_" .. tab_name
		tabBtn.Parent = TabButtons
		tabBtn.Active = true
		tabBtn.BackgroundColor3 = palette.bg
		tabBtn.BorderSizePixel = 0
		tabBtn.Text = "  " .. tab_name
		tabBtn.TextColor3 = palette.muted
		tabBtn.TextSize = 12
		tabBtn.TextTruncate = Enum.TextTruncate.AtEnd
		tabBtn.TextXAlignment = Enum.TextXAlignment.Left
		tabBtn.AutoButtonColor = false
		tabBtn.ZIndex = 5
		tabBtn.Size = UDim2.new(1, 0, 0, 31)
		registerBodyFont(tabBtn)
		registerCardCorner(addCorner(tabBtn, palette.cornerCard))
		tabStrokes[tabBtn] = addStroke(tabBtn, palette.cardBorder, 1.6, 0)

		local tabPage = Instance.new("ScrollingFrame")
		tabPage.Name = "Tab_" .. tab_name
		tabPage.Parent = TabsContainer
		tabPage.Active = true
		tabPage.BackgroundTransparency = 1
		tabPage.BorderSizePixel = 0
		tabPage.Size = UDim2.new(1, 0, 1, 0)
		tabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
		tabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
		tabPage.ScrollBarThickness = 3
		tabPage.ScrollBarImageColor3 = palette.main
		tabPage.ZIndex = 4
		tabPage.Visible = false

		onThemeChange(function(p)
			tabPage.ScrollBarImageColor3 = p.isNeon and p.neonBright or p.main
			styleTabBtn(tabBtn, activeTabBtn == tabBtn)
		end)

		local pagePadding = Instance.new("UIPadding")
		pagePadding.PaddingLeft = UDim.new(0, 2)
		pagePadding.PaddingRight = UDim.new(0, 8)
		pagePadding.PaddingTop = UDim.new(0, 2)
		pagePadding.PaddingBottom = UDim.new(0, 8)
		pagePadding.Parent = tabPage

		local pageLayout = Instance.new("UIListLayout")
		pageLayout.Parent = tabPage
		pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		pageLayout.Padding = UDim.new(0, 8)

		local function showTab()
			if activeTabPage then activeTabPage.Visible = false end
			if activeTabBtn then styleTabBtn(activeTabBtn, false) end
			activeTabBtn = tabBtn
			activeTabPage = tabPage
			styleTabBtn(tabBtn, true)
			tabPage.Visible = true
			applyTabLayoutGeometry()
		end

		runtime:Connect(tabBtn.MouseButton1Click, showTab)
		function tab_data:Show() showTab() end

		-- LABEL
		function tab_data:AddLabel(label_text)
			local lbl = Instance.new("TextLabel")
			lbl.Name = "Label"
			lbl.Parent = tabPage
			lbl.BackgroundTransparency = 1
			lbl.Size = UDim2.new(1, 0, 0, 20)
			lbl.AutomaticSize = Enum.AutomaticSize.Y
			lbl.Text = tostring(label_text or "Label")
			lbl.TextColor3 = palette.text
			lbl.TextSize = 13
			lbl.TextWrapped = true
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.ZIndex = 5
			registerTitleFont(lbl)

			onThemeChange(function(p)
				lbl.TextColor3 = p.isNeon and p.neonBright or p.text
			end)

			return lbl
		end

		-- BUTTON
		function tab_data:AddButton(button_text, callback)
			callback = typeof(callback) == "function" and callback or function() end

			local btn = Instance.new("TextButton")
			btn.Name = "Button"
			btn.Parent = tabPage
			btn.Active = true
			btn.BackgroundColor3 = palette.main
			btn.BorderSizePixel = 0
			btn.Size = UDim2.new(1, 0, 0, 34)
			btn.Text = tostring(button_text or "Button")
			btn.TextColor3 = WHITE
			btn.TextSize = 13
			btn.AutoButtonColor = false
			btn.ZIndex = 6
			registerTitleFont(btn)
			registerCardCorner(addCorner(btn, palette.cornerCard))
			local btnStroke = addStroke(btn, INK_OUTLINE, palette.strokeThickness, 0)

			onThemeChange(function(p)
				btn.BackgroundColor3 = p.main
				btnStroke.Color = p.isNeon and p.neonBright or INK_OUTLINE
				btnStroke.Thickness = p.strokeThickness
				setGradientState(btn, p.isNeon, p.main, p.neonBright, 0)
			end)

			runtime:Connect(btn.MouseButton1Click, function()
				pcall(callback)
			end)

			return btn
		end

		-- SWITCH
		function tab_data:AddSwitch(switch_text, callback, initial_state)
			local switch_data = {}
			callback = typeof(callback) == "function" and callback or function() end

			local container = Instance.new("TextButton")
			container.Name = "Switch"
			container.Parent = tabPage
			container.Active = true
			container.BackgroundColor3 = palette.surface
			container.BorderSizePixel = 0
			container.Size = UDim2.new(1, 0, 0, 36)
			container.Text = ""
			container.AutoButtonColor = false
			container.ZIndex = 6
			registerCardCorner(addCorner(container, palette.cornerCard))
			local swStroke = addStroke(container, palette.cardBorder, palette.strokeThickness, 0)

			local titleLbl = Instance.new("TextLabel")
			titleLbl.Name = "Title"
			titleLbl.Parent = container
			titleLbl.BackgroundTransparency = 1
			titleLbl.Position = UDim2.new(0, 12, 0, 0)
			titleLbl.Size = UDim2.new(1, -66, 1, 0)
			titleLbl.Text = tostring(switch_text or "Switch")
			titleLbl.TextColor3 = palette.text
			titleLbl.TextSize = 13
			titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left
			titleLbl.ZIndex = 7
			registerBodyFont(titleLbl)

			local pill = Instance.new("Frame")
			pill.Name = "Pill"
			pill.Parent = container
			pill.BackgroundColor3 = palette.bg
			pill.BorderSizePixel = 0
			pill.Position = UDim2.new(1, -50, 0.5, -10)
			pill.Size = UDim2.new(0, 40, 0, 20)
			pill.ZIndex = 7
			addCorner(pill, 10)
			local pillStroke = addStroke(pill, INK_OUTLINE, 1.5, 0)

			local knob = Instance.new("Frame")
			knob.Name = "Knob"
			knob.Parent = pill
			knob.BackgroundColor3 = palette.muted
			knob.BorderSizePixel = 0
			knob.Position = UDim2.new(0, 3, 0.5, -7)
			knob.Size = UDim2.new(0, 14, 0, 14)
			knob.ZIndex = 8
			addCorner(knob, 7)

			local toggled = (initial_state == true)

			local function syncSwitchTheme(p)
				container.BackgroundColor3 = p.surface
				swStroke.Color = (toggled and p.isNeon) and p.neonBright or p.cardBorder
				swStroke.Thickness = p.strokeThickness
				titleLbl.TextColor3 = (toggled and p.isNeon) and p.neonBright or p.text
				pillStroke.Color = (toggled and p.isNeon) and p.neonBright or INK_OUTLINE
				if toggled then
					pill.BackgroundColor3 = p.main
					knob.BackgroundColor3 = WHITE
					knob.Position = UDim2.new(1, -17, 0.5, -7)
					setGradientState(pill, p.isNeon, p.main, p.neonBright, 0)
				else
					pill.BackgroundColor3 = p.bg
					knob.BackgroundColor3 = p.muted
					knob.Position = UDim2.new(0, 3, 0.5, -7)
					setGradientState(pill, false)
				end
			end

			onThemeChange(syncSwitchTheme)

			local function updateVisual(state, animate)
				syncSwitchTheme(palette)
				if animate then
					Tween(knob, {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)})
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
				updateVisual(toggled, true)
				pcall(callback, toggled)
			end)

			function switch_data:Set(bool)
				if not runtime.Alive then return end
				toggled = (typeof(bool) == "boolean") and bool or false
				updateVisual(toggled, true)
				pcall(callback, toggled)
			end

			function switch_data:SyncState(bool)
				if not runtime.Alive then return end
				toggled = (typeof(bool) == "boolean") and bool or false
				updateVisual(toggled, false)
			end

			function switch_data:Get()
				return toggled
			end

			return switch_data, container
		end

		-- SWITCH DEDICADO: MODO NEÓN (Apagado = Sólido / Encendido = Neón)
		function tab_data:AddNeonSwitch(label_text, callback)
			local text = tostring(label_text or "Modo Neón")
			local swCtrl, swFrame = tab_data:AddSwitch(text, function(isNeonEnabled)
				window_data:SetNeon(isNeonEnabled)
				if typeof(callback) == "function" then
					pcall(callback, isNeonEnabled)
				end
			end, opts.neon)

			swCtrl:SyncState(opts.neon)
			neonSwitchController = {
				SyncVisual = function(state)
					swCtrl:SyncState(state)
				end,
			}

			return swCtrl, swFrame
		end

		tab_data.AddModeSwitch = tab_data.AddNeonSwitch

		-- SLIDER
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
			container.BackgroundColor3 = palette.surface
			container.BorderSizePixel = 0
			container.Size = UDim2.new(1, 0, 0, 44)
			container.ZIndex = 6
			registerCardCorner(addCorner(container, palette.cornerCard))
			local slStroke = addStroke(container, palette.cardBorder, palette.strokeThickness, 0)

			local titleLbl = Instance.new("TextLabel")
			titleLbl.Name = "Title"
			titleLbl.Parent = container
			titleLbl.BackgroundTransparency = 1
			titleLbl.Position = UDim2.new(0, 12, 0, 4)
			titleLbl.Size = UDim2.new(1, -72, 0, 18)
			titleLbl.Text = tostring(slider_text or "Slider")
			titleLbl.TextColor3 = palette.text
			titleLbl.TextSize = 13
			titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left
			titleLbl.ZIndex = 7
			registerBodyFont(titleLbl)

			local valLbl = Instance.new("TextLabel")
			valLbl.Name = "Value"
			valLbl.Parent = container
			valLbl.BackgroundTransparency = 1
			valLbl.Position = UDim2.new(1, -60, 0, 4)
			valLbl.Size = UDim2.new(0, 48, 0, 18)
			valLbl.Text = tostring(minVal)
			valLbl.TextColor3 = palette.muted
			valLbl.TextSize = 13
			valLbl.TextXAlignment = Enum.TextXAlignment.Right
			valLbl.ZIndex = 7
			registerTitleFont(valLbl)

			local track = Instance.new("Frame")
			track.Name = "Track"
			track.Parent = container
			track.BackgroundColor3 = palette.bg
			track.BorderSizePixel = 0
			track.Position = UDim2.new(0, 12, 0, 27)
			track.Size = UDim2.new(1, -24, 0, 8)
			track.ZIndex = 7
			addCorner(track, 4)

			local fill = Instance.new("Frame")
			fill.Name = "Indicator"
			fill.Parent = track
			fill.BackgroundColor3 = palette.main
			fill.BorderSizePixel = 0
			fill.Size = UDim2.new(0, 0, 1, 0)
			fill.ZIndex = 8
			addCorner(fill, 4)

			local thumb = Instance.new("Frame")
			thumb.Name = "Thumb"
			thumb.Parent = fill
			thumb.BackgroundColor3 = WHITE
			thumb.BorderSizePixel = 0
			thumb.Position = UDim2.new(1, -4, 0.5, -7)
			thumb.Size = UDim2.new(0, 8, 0, 14)
			thumb.ZIndex = 9
			addCorner(thumb, 4)

			onThemeChange(function(p)
				container.BackgroundColor3 = p.surface
				slStroke.Color = p.cardBorder
				slStroke.Thickness = p.strokeThickness
				titleLbl.TextColor3 = p.text
				valLbl.TextColor3 = p.isNeon and p.neonBright or p.muted
				track.BackgroundColor3 = p.bg
				fill.BackgroundColor3 = p.main
				setGradientState(fill, p.isNeon, p.main, p.neonBright, 0)
			end)

			local hitArea = Instance.new("TextButton")
			hitArea.Name = "HitArea"
			hitArea.Parent = container
			hitArea.Active = true
			hitArea.BackgroundTransparency = 1
			hitArea.Position = UDim2.new(0, 6, 0, 18)
			hitArea.Size = UDim2.new(1, -12, 0, 24)
			hitArea.Text = ""
			hitArea.ZIndex = 10

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
						slStroke.Color = palette.cardBorder
					end) then
						slStroke.Color = palette.isNeon and palette.neonBright or palette.main
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

		-- TEXTBOX
		function tab_data:AddTextBox(textbox_text, callback, textbox_options)
			callback = typeof(callback) == "function" and callback or function() end
			local clearOnEnter = (typeof(textbox_options) == "table" and textbox_options.clear ~= nil) and textbox_options.clear or true

			local box = Instance.new("TextBox")
			box.Name = "TextBox"
			box.Parent = tabPage
			box.Active = true
			box.BackgroundColor3 = palette.surface
			box.BorderSizePixel = 0
			box.Size = UDim2.new(1, 0, 0, 34)
			box.PlaceholderText = tostring(textbox_text or "Input Text")
			box.PlaceholderColor3 = palette.muted
			box.Text = ""
			box.TextColor3 = palette.text
			box.TextSize = 13
			box.ClearTextOnFocus = false
			box.ZIndex = 6
			registerBodyFont(box)
			registerCardCorner(addCorner(box, palette.cornerCard))
			local boxStroke = addStroke(box, palette.cardBorder, palette.strokeThickness, 0)

			onThemeChange(function(p)
				box.BackgroundColor3 = p.surface
				box.PlaceholderColor3 = p.muted
				box.TextColor3 = p.text
				boxStroke.Thickness = p.strokeThickness
				boxStroke.Color = box:IsFocused() and (p.isNeon and p.neonBright or p.main) or p.cardBorder
			end)

			runtime:Connect(box.Focused, function()
				boxStroke.Color = palette.isNeon and palette.neonBright or palette.main
			end)

			runtime:Connect(box.FocusLost, function(enterPressed)
				boxStroke.Color = palette.cardBorder
				if enterPressed and #box.Text > 0 then
					pcall(callback, box.Text)
					if clearOnEnter then box.Text = "" end
				end
			end)

			return box
		end

		-- DROPDOWN
		function tab_data:AddDropdown(dropdown_name, callback)
			local dropdown_data = {}
			local itemsMap = {}
			dropdown_name = tostring(dropdown_name or "Dropdown")
			callback = typeof(callback) == "function" and callback or function() end

			local wrapper = Instance.new("Frame")
			wrapper.Name = "Dropdown"
			wrapper.Parent = tabPage
			wrapper.BackgroundColor3 = palette.surface
			wrapper.BorderSizePixel = 0
			wrapper.ClipsDescendants = true
			wrapper.Size = UDim2.new(1, 0, 0, 34)
			wrapper.ZIndex = 6
			registerCardCorner(addCorner(wrapper, palette.cornerCard))
			local ddStroke = addStroke(wrapper, palette.cardBorder, palette.strokeThickness, 0)

			local headerBtn = Instance.new("TextButton")
			headerBtn.Name = "Header"
			headerBtn.Parent = wrapper
			headerBtn.Active = true
			headerBtn.BackgroundTransparency = 1
			headerBtn.Size = UDim2.new(1, 0, 0, 34)
			headerBtn.Text = "   " .. dropdown_name
			headerBtn.TextColor3 = palette.text
			headerBtn.TextSize = 13
			headerBtn.TextTruncate = Enum.TextTruncate.AtEnd
			headerBtn.TextXAlignment = Enum.TextXAlignment.Left
			headerBtn.ZIndex = 7
			registerBodyFont(headerBtn)

			local arrow = Instance.new("TextLabel")
			arrow.Name = "Arrow"
			arrow.Parent = headerBtn
			arrow.BackgroundTransparency = 1
			arrow.Position = UDim2.new(1, -28, 0, 0)
			arrow.Size = UDim2.new(0, 20, 1, 0)
			arrow.Font = Enum.Font.GothamBold
			arrow.Text = "▼"
			arrow.TextColor3 = palette.muted
			arrow.TextSize = 10
			arrow.ZIndex = 8

			local listFrame = Instance.new("ScrollingFrame")
			listFrame.Name = "Objects"
			listFrame.Parent = wrapper
			listFrame.Active = true
			listFrame.BackgroundTransparency = 1
			listFrame.BorderSizePixel = 0
			listFrame.Position = UDim2.new(0, 6, 0, 36)
			listFrame.Size = UDim2.new(1, -12, 0, 0)
			listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
			listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			listFrame.ScrollBarThickness = 2
			listFrame.ScrollBarImageColor3 = palette.main
			listFrame.ZIndex = 7

			local isExpanded = false

			onThemeChange(function(p)
				wrapper.BackgroundColor3 = p.surface
				ddStroke.Color = isExpanded and (p.isNeon and p.neonBright or p.main) or p.cardBorder
				ddStroke.Thickness = p.strokeThickness
				headerBtn.TextColor3 = p.text
				arrow.TextColor3 = p.muted
				listFrame.ScrollBarImageColor3 = p.isNeon and p.neonBright or p.main
				for _, itemBtn in pairs(itemsMap) do
					if itemBtn and itemBtn.Parent then
						itemBtn.BackgroundColor3 = p.bg
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
				ddStroke.Color = isExpanded and (palette.isNeon and palette.neonBright or palette.main) or palette.cardBorder
				Tween(wrapper, {Size = UDim2.new(1, 0, 0, isExpanded and (40 + targetListH) or 34)})
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
				itemBtn.Active = true
				itemBtn.BackgroundColor3 = palette.bg
				itemBtn.BorderSizePixel = 0
				itemBtn.Size = UDim2.new(1, 0, 0, 24)
				itemBtn.Text = "  " .. itemName
				itemBtn.TextColor3 = palette.text
				itemBtn.TextSize = 12
				itemBtn.TextXAlignment = Enum.TextXAlignment.Left
				itemBtn.AutoButtonColor = false
				itemBtn.ZIndex = 8
				registerBodyFont(itemBtn)
				addCorner(itemBtn, 6)

				itemsMap[itemName] = itemBtn

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

		-- SELECTOR DESPLEGABLE DE TEMAS (nombre limpio sin emojis)
		function tab_data:AddThemeSelector(selector_text, callback)
			local selector_data = {}
			selector_text = tostring(selector_text or "Tema de Interfaz")
			callback = typeof(callback) == "function" and callback or function() end

			local wrapper = Instance.new("Frame")
			wrapper.Name = "ThemeSelector"
			wrapper.Parent = tabPage
			wrapper.BackgroundColor3 = palette.surface
			wrapper.BorderSizePixel = 0
			wrapper.ClipsDescendants = true
			wrapper.Size = UDim2.new(1, 0, 0, 36)
			wrapper.ZIndex = 6
			registerCardCorner(addCorner(wrapper, palette.cornerCard))
			local tsStroke = addStroke(wrapper, palette.cardBorder, palette.strokeThickness, 0)

			local headerBtn = Instance.new("TextButton")
			headerBtn.Name = "Header"
			headerBtn.Parent = wrapper
			headerBtn.Active = true
			headerBtn.BackgroundTransparency = 1
			headerBtn.Size = UDim2.new(1, 0, 0, 36)
			headerBtn.Text = ""
			headerBtn.ZIndex = 7

			local titleLbl = Instance.new("TextLabel")
			titleLbl.Name = "Title"
			titleLbl.Parent = headerBtn
			titleLbl.BackgroundTransparency = 1
			titleLbl.Position = UDim2.new(0, 12, 0, 0)
			titleLbl.Size = UDim2.new(1, -76, 1, 0)
			titleLbl.Text = selector_text .. ": " .. opts.theme_name
			titleLbl.TextColor3 = palette.text
			titleLbl.TextSize = 13
			titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left
			titleLbl.ZIndex = 8
			registerBodyFont(titleLbl)

			local activeDot = Instance.new("Frame")
			activeDot.Name = "ActiveDot"
			activeDot.Parent = headerBtn
			activeDot.BackgroundColor3 = palette.main
			activeDot.BorderSizePixel = 0
			activeDot.Position = UDim2.new(1, -54, 0.5, -7)
			activeDot.Size = UDim2.new(0, 22, 0, 14)
			activeDot.ZIndex = 8
			addCorner(activeDot, 7)

			local arrow = Instance.new("TextLabel")
			arrow.Name = "Arrow"
			arrow.Parent = headerBtn
			arrow.BackgroundTransparency = 1
			arrow.Position = UDim2.new(1, -28, 0, 0)
			arrow.Size = UDim2.new(0, 20, 1, 0)
			arrow.Font = Enum.Font.GothamBold
			arrow.Text = "▼"
			arrow.TextColor3 = palette.muted
			arrow.TextSize = 10
			arrow.ZIndex = 8

			local listFrame = Instance.new("ScrollingFrame")
			listFrame.Name = "ThemeList"
			listFrame.Parent = wrapper
			listFrame.Active = true
			listFrame.BackgroundTransparency = 1
			listFrame.BorderSizePixel = 0
			listFrame.Position = UDim2.new(0, 8, 0, 40)
			listFrame.Size = UDim2.new(1, -16, 0, 146)
			listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
			listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			listFrame.ScrollBarThickness = 2
			listFrame.ScrollBarImageColor3 = palette.main
			listFrame.ZIndex = 7

			local listLayout = Instance.new("UIListLayout")
			listLayout.Parent = listFrame
			listLayout.SortOrder = Enum.SortOrder.LayoutOrder
			listLayout.Padding = UDim.new(0, 5)

			local isExpanded = false
			local themeOptionRows = {}

			local function refreshOptionHighlights()
				titleLbl.Text = selector_text .. ": " .. opts.theme_name
				activeDot.BackgroundColor3 = palette.isNeon and palette.neonBright or palette.main
				for name, rowData in pairs(themeOptionRows) do
					local isCurrent = (name == opts.theme_name)
					rowData.btn.BackgroundColor3 = isCurrent and palette.main or rowData.baseBg
					rowData.nameLbl.TextColor3 = isCurrent and WHITE or rowData.baseText
					rowData.stroke.Color = isCurrent and (palette.isNeon and shiftColor(rowData.accent, 0.30) or INK_OUTLINE) or INK_OUTLINE
					rowData.stroke.Thickness = isCurrent and palette.strokeThickness or 1.4
				end
			end

			for _, tName in ipairs(THEME_ORDER) do
				local tInfo = THEMES[tName]

				local optBtn = Instance.new("TextButton")
				optBtn.Name = "Theme_" .. tName
				optBtn.Parent = listFrame
				optBtn.Active = true
				optBtn.BackgroundColor3 = tInfo.bg_color
				optBtn.BorderSizePixel = 0
				optBtn.Size = UDim2.new(1, 0, 0, 28)
				optBtn.Text = ""
				optBtn.AutoButtonColor = false
				optBtn.ZIndex = 8
				addCorner(optBtn, tInfo.corner_card)
				local optStroke = addStroke(optBtn, INK_OUTLINE, 1.4, 0)

				local dot = Instance.new("Frame")
				dot.Parent = optBtn
				dot.BackgroundColor3 = tInfo.main_color
				dot.BorderSizePixel = 0
				dot.Position = UDim2.new(0, 10, 0.5, -6)
				dot.Size = UDim2.new(0, 12, 0, 12)
				dot.ZIndex = 9
				addCorner(dot, 6)

				local nameLbl = Instance.new("TextLabel")
				nameLbl.Parent = optBtn
				nameLbl.BackgroundTransparency = 1
				nameLbl.Position = UDim2.new(0, 30, 0, 0)
				nameLbl.Size = UDim2.new(1, -40, 1, 0)
				nameLbl.Font = tInfo.font_title
				nameLbl.Text = tName
				nameLbl.TextColor3 = tInfo.text_color
				nameLbl.TextSize = 13
				nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
				nameLbl.TextXAlignment = Enum.TextXAlignment.Left
				nameLbl.ZIndex = 9

				themeOptionRows[tName] = {
					btn = optBtn,
					stroke = optStroke,
					nameLbl = nameLbl,
					baseBg = tInfo.bg_color,
					baseText = tInfo.text_color,
					accent = tInfo.main_color,
				}

				runtime:Connect(optBtn.MouseButton1Click, function()
					isExpanded = false
					dropdown_open = false
					Tween(arrow, {Rotation = 0})
					tsStroke.Color = palette.cardBorder
					Tween(wrapper, {Size = UDim2.new(1, 0, 0, 36)})
					window_data:SetTheme(tName)
					pcall(callback, tName)
				end)
			end

			onThemeChange(function(p)
				wrapper.BackgroundColor3 = p.surface
				tsStroke.Color = isExpanded and (p.isNeon and p.neonBright or p.main) or p.cardBorder
				tsStroke.Thickness = p.strokeThickness
				titleLbl.TextColor3 = p.text
				arrow.TextColor3 = p.muted
				listFrame.ScrollBarImageColor3 = p.isNeon and p.neonBright or p.main
				refreshOptionHighlights()
			end)

			runtime:Connect(headerBtn.MouseButton1Click, function()
				isExpanded = not isExpanded
				dropdown_open = isExpanded
				Tween(arrow, {Rotation = isExpanded and 180 or 0})
				tsStroke.Color = isExpanded and (palette.isNeon and palette.neonBright or palette.main) or p.cardBorder
				local listH = math.min(#THEME_ORDER * 33, 150)
				listFrame.Size = UDim2.new(1, -16, 0, listH)
				Tween(wrapper, {Size = UDim2.new(1, 0, 0, isExpanded and (46 + listH) or 36)})
			end)

			function selector_data:Set(themeName)
				if type(themeName) == "string" and THEMES[themeName] then
					window_data:SetTheme(themeName)
					pcall(callback, themeName)
				end
			end

			return selector_data, wrapper
		end

		tab_data.AddThemeDropdown = tab_data.AddThemeSelector

		-- FOLDER
		function tab_data:AddFolder(folder_name)
			local folder_data = {}
			folder_name = tostring(folder_name or "Folder")

			local folderBox = Instance.new("Frame")
			folderBox.Name = "Folder"
			folderBox.Parent = tabPage
			folderBox.BackgroundColor3 = palette.surface
			folderBox.BorderSizePixel = 0
			folderBox.ClipsDescendants = true
			folderBox.Size = UDim2.new(1, 0, 0, 34)
			folderBox.ZIndex = 6
			registerCardCorner(addCorner(folderBox, palette.cornerCard))
			local fldStroke = addStroke(folderBox, palette.cardBorder, palette.strokeThickness, 0)

			local folderBtn = Instance.new("TextButton")
			folderBtn.Name = "Header"
			folderBtn.Parent = folderBox
			folderBtn.Active = true
			folderBtn.BackgroundColor3 = palette.bar
			folderBtn.BorderSizePixel = 0
			folderBtn.Size = UDim2.new(1, 0, 0, 34)
			folderBtn.Text = "  ▸  " .. folder_name
			folderBtn.TextColor3 = palette.text
			folderBtn.TextSize = 13
			folderBtn.TextXAlignment = Enum.TextXAlignment.Left
			folderBtn.ZIndex = 7
			registerTitleFont(folderBtn)
			registerCardCorner(addCorner(folderBtn, palette.cornerCard))

			onThemeChange(function(p)
				folderBox.BackgroundColor3 = p.surface
				fldStroke.Color = p.isNeon and p.neonBright or p.cardBorder
				fldStroke.Thickness = p.strokeThickness
				folderBtn.BackgroundColor3 = p.bar
				folderBtn.TextColor3 = p.isNeon and p.neonBright or p.text
				setGradientState(folderBtn, false)
			end)

			local content = Instance.new("Frame")
			content.Name = "Objects"
			content.Parent = folderBox
			content.BackgroundTransparency = 1
			content.Position = UDim2.new(0, 8, 0, 40)
			content.Size = UDim2.new(1, -16, 0, 0)
			content.AutomaticSize = Enum.AutomaticSize.Y
			content.ZIndex = 7

			local contentLayout = Instance.new("UIListLayout")
			contentLayout.Parent = content
			contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
			contentLayout.Padding = UDim.new(0, 7)

			local folderOpen = false

			local function syncFolderSize()
				if folderOpen then
					folderBox.Size = UDim2.new(1, 0, 0, 48 + contentLayout.AbsoluteContentSize.Y)
				else
					folderBox.Size = UDim2.new(1, 0, 0, 34)
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
