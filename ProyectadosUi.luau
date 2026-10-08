local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local ModernLib = {}

function ModernLib:AddWindow(titleText, options)
    local window_data = {}
    options = options or {}
    local mainColor = options.main_color or Color3.fromRGB(138, 43, 226)
    local toggleKey = options.toggle_key or Enum.KeyCode.RightShift

    -- Limpiar ejecuciones anteriores
    local oldGui = CoreGui:FindFirstChild("ProyectadosModernUI")
    if oldGui then oldGui:Destroy() end

    -- GUI Principal
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ProyectadosModernUI"
    screenGui.Parent = (CoreGui:FindFirstChild("RobloxGui") and CoreGui) or Players.LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false

    -- Botón Flotante para Ocultar/Mostrar
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 45, 0, 45)
    toggleBtn.Position = UDim2.new(0, 20, 0.5, -22)
    toggleBtn.BackgroundColor3 = mainColor
    toggleBtn.Text = "👁"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 24
    toggleBtn.Parent = screenGui
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBtn

    -- Marco de la Ventana
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, options.min_size and options.min_size.X or 550, 0, options.min_size and options.min_size.Y or 400)
    mainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = mainFrame

    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = tostring(titleText)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = mainFrame

    function window_data:SetTitle(newTitle)
        title.Text = tostring(newTitle)
    end

    -- Contenedor de Pestañas (Botones)
    local tabButtonsContainer = Instance.new("ScrollingFrame")
    tabButtonsContainer.Size = UDim2.new(1, -20, 0, 35)
    tabButtonsContainer.Position = UDim2.new(0, 10, 0, 40)
    tabButtonsContainer.BackgroundTransparency = 1
    tabButtonsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabButtonsContainer.ScrollBarThickness = 0
    tabButtonsContainer.Parent = mainFrame

    local tabButtonsLayout = Instance.new("UIListLayout")
    tabButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
    tabButtonsLayout.Padding = UDim.new(0, 5)
    tabButtonsLayout.Parent = tabButtonsContainer

    -- Contenedor de las Páginas
    local pagesContainer = Instance.new("Frame")
    pagesContainer.Size = UDim2.new(1, -20, 1, -85)
    pagesContainer.Position = UDim2.new(0, 10, 0, 80)
    pagesContainer.BackgroundTransparency = 1
    pagesContainer.Parent = mainFrame

    -- Lógica de Ocultar/Mostrar
    local isGuiVisible = true
    local function ToggleVisibility()
        isGuiVisible = not isGuiVisible
        mainFrame.Visible = isGuiVisible
        toggleBtn.Text = isGuiVisible and "👁" or "✖"
        toggleBtn.BackgroundColor3 = isGuiVisible and mainColor or Color3.fromRGB(180, 50, 50)
    end

    toggleBtn.MouseButton1Click:Connect(ToggleVisibility)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == toggleKey then
            ToggleVisibility()
        end
    end)

    -- Constructor de Pestañas
    local firstTab = true

    function window_data:AddTab(tab_name)
        local tab_data = {}

        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(0, 100, 1, 0)
        tabBtn.BackgroundColor3 = firstTab and mainColor or Color3.fromRGB(40, 40, 48)
        tabBtn.Text = tostring(tab_name)
        tabBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
        tabBtn.Font = Enum.Font.GothamSemibold
        tabBtn.TextSize = 13
        tabBtn.Parent = tabButtonsContainer
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 4)
        tabCorner.Parent = tabBtn

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 4
        page.Visible = firstTab
        page.Parent = pagesContainer
        
        local pageLayout = Instance.new("UIListLayout")
        pageLayout.Padding = UDim.new(0, 8)
        pageLayout.Parent = page

        local function ShowTab()
            for _, child in pairs(pagesContainer:GetChildren()) do
                if child:IsA("ScrollingFrame") then child.Visible = false end
            end
            for _, btn in pairs(tabButtonsContainer:GetChildren()) do
                if btn:IsA("TextButton") then btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48) end
            end
            page.Visible = true
            tabBtn.BackgroundColor3 = mainColor
        end

        tabBtn.MouseButton1Click:Connect(ShowTab)
        function tab_data:Show() ShowTab() end
        firstTab = false

        -- Etiquetas (Labels)
        function tab_data:AddLabel(labelText)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -10, 0, 25)
            label.BackgroundTransparency = 1
            label.Text = tostring(labelText)
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = page
            return label
        end

        -- Botones (Buttons)
        function tab_data:AddButton(btnText, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 32)
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            btn.Text = "  " .. tostring(btnText)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.GothamSemibold
            btn.TextSize = 14
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = page
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btn

            btn.MouseButton1Click:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = mainColor}):Play()
                task.delay(0.15, function() 
                    TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}):Play() 
                end)
                if callback then pcall(callback) end
            end)
            return btn
        end

        -- Interruptores (Switches)
        function tab_data:AddSwitch(switchText, callback)
            local switchObj = {}
            local state = false

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 32)
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            btn.Text = "  " .. tostring(switchText) .. " : [ OFF ]"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.GothamSemibold
            btn.TextSize = 14
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = page
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btn

            function switchObj:Set(newState)
                state = newState
                btn.Text = "  " .. tostring(switchText) .. (state and " : [ ON ]" or " : [ OFF ]")
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and mainColor or Color3.fromRGB(45, 45, 55)}):Play()
                if callback then pcall(callback, state) end
            end

            btn.MouseButton1Click:Connect(function() switchObj:Set(not state) end)
            return switchObj
        end

        -- Cajas de Texto (TextBoxes)
        function tab_data:AddTextBox(placeholder, callback, textOptions)
            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1, -10, 0, 32)
            box.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            box.PlaceholderText = "  " .. tostring(placeholder)
            box.Text = ""
            box.TextColor3 = Color3.fromRGB(255, 255, 255)
            box.Font = Enum.Font.Gotham
            box.TextSize = 14
            box.TextXAlignment = Enum.TextXAlignment.Left
            box.Parent = page
            local boxCorner = Instance.new("UICorner")
            boxCorner.CornerRadius = UDim.new(0, 6)
            boxCorner.Parent = box

            local shouldClear = true
            if textOptions and type(textOptions) == "table" and textOptions.clear == false then
                shouldClear = false
            end

            box.FocusLost:Connect(function(enterPressed)
                if enterPressed and callback then
                    pcall(callback, box.Text)
                    if shouldClear then box.Text = "" end
                end
            end)
            return box
        end

        -- Menús Desplegables (Dropdowns)
        function tab_data:AddDropdown(titleText, callback)
            local dropObj = {}
            local dropBtn = tab_data:AddButton(titleText .. " ▼", nil)
            local isOpen = false

            local listFrame = Instance.new("Frame")
            listFrame.Size = UDim2.new(1, -10, 0, 0)
            listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            listFrame.ClipsDescendants = true
            listFrame.Parent = page
            local listCorner = Instance.new("UICorner")
            listCorner.CornerRadius = UDim.new(0, 6)
            listCorner.Parent = listFrame
            
            local listLayout = Instance.new("UIListLayout")
            listLayout.Parent = listFrame

            dropBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                local targetHeight = isOpen and (listLayout.AbsoluteContentSize.Y) or 0
                TweenService:Create(listFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, targetHeight)}):Play()
            end)

            function dropObj:Add(itemName)
                local itemBtn = Instance.new("TextButton")
                itemBtn.Size = UDim2.new(1, 0, 0, 25)
                itemBtn.BackgroundTransparency = 1
                itemBtn.Text = "  " .. tostring(itemName)
                itemBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                itemBtn.Font = Enum.Font.Gotham
                itemBtn.TextSize = 13
                itemBtn.TextXAlignment = Enum.TextXAlignment.Left
                itemBtn.Parent = listFrame

                itemBtn.MouseButton1Click:Connect(function()
                    dropBtn.Text = "  " .. titleText .. ": " .. tostring(itemName)
                    isOpen = false
                    TweenService:Create(listFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, 0)}):Play()
                    if callback then pcall(callback, itemName) end
                end)
            end
            return dropObj
        end

        return tab_data
    end

    -- Método vacío de compatibilidad por si se llama a FormatWindows
    function window_data:FormatWindows() end
    function ModernLib:FormatWindows() end

    return window_data
end

return ModernLib
