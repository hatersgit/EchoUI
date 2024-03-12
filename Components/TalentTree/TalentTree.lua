TalentTree = {
    FORGE_TABS = {},
    FORGE_ACTIVE_SPEC = {},
    FORGE_SPECS_TAB = {},
    FORGE_SPEC_SLOTS = {},
    FORGE_SELECTED_TAB = nil,
    FORGE_SPELLS_PAGES = {},
    FORGE_CURRENT_PAGE = 0,
    FORGE_MAX_PAGE = nil,
    FORGE_TALENTS = nil,
    INITIALIZED = false,
    SELECTED_SPEC = nil,
    MaxPoints = {},
    ClassTree = nil,
    CLASS_TAB = nil,
    TalentLoadoutCache = {},
    currentLoadout = nil,
    prevLoadout = nil,
    activeString = nil
}

TT_SETTINGS = {
    headerheight = (GetScreenHeight() / 1.8) / 25
}

TreeCache = {
    Spells = {},
    PointsSpent = {},
    Investments = {},
    TotalInvests = {},
    PrereqUnlocks = {},
    PrereqRev = {},
    Points = {},
    PreviousString = {},
    IndexToFrame = {}
}

-- local Backdrop = {
--     bgFile = "Interface/Tooltips/UI-Tooltip-Background", -- Arquivo de textura do fundo
--     edgeFile = "Interface/Tooltips/UI-Tooltip-Border", -- Arquivo de textura da borda
--     tile = true,
--     tileSize = 16,
--     edgeSize = 16,
--     insets = {left = 4, right = 4, top = 4, bottom = 4}
-- }

TalentTreeWindow = CreateFrame("Frame", "TalentFrame", nil)
TalentTreeWindow:SetSize(550, 400)
TalentTreeWindow:SetFrameLevel(1)
TalentTreeWindow:SetMovable(true)
TalentTreeWindow:SetFrameStrata("MEDIUM")
TalentTreeWindow:SetPoint("CENTER", 0, 0)
TalentTreeWindow:SetBackdrop(
    {
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        insets = {top = 1, left = 1, bottom = 1, right = 1},
        edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
        tileEdge = false,
        edgeSize = 1
    }
)
TalentTreeWindow:SetBackdropColor(0, 0, 0, .75)
TalentTreeWindow:SetBackdropBorderColor(188 / 255, 150 / 255, 28 / 255, .6)
TalentTreeWindow:SetScript(
    "OnHide",
    function(_)
        ForgedWoWMicrobarButton:SetButtonState("NORMAL")
    end
)
TalentTreeWindow:SetScript(
    "OnUpdate",
    function(_)
        if TalentTreeWindow:IsVisible() then
            ForgedWoWMicrobarButton:SetButtonState("PUSHED", 1)
        else
            ForgedWoWMicrobarButton:SetButtonState("NORMAL")
        end
    end
)

TalentTreeWindow.header = CreateFrame("BUTTON", nil, TalentTreeWindow)
TalentTreeWindow.header:SetSize(TalentTreeWindow:GetWidth(), TT_SETTINGS.headerheight)
TalentTreeWindow.header:SetPoint("TOP", 0, 0)
TalentTreeWindow.header:SetFrameLevel(4)
TalentTreeWindow.header:EnableMouse(true)
TalentTreeWindow.header:RegisterForClicks("AnyUp", "AnyDown")
TalentTreeWindow.header:SetScript(
    "OnMouseDown",
    function()
        TalentTreeWindow:StartMoving()
    end
)
TalentTreeWindow.header:SetScript(
    "OnMouseUp",
    function()
        TalentTreeWindow:StopMovingOrSizing()
    end
)

TalentTreeWindow.header.close = CreateFrame("BUTTON", "InstallCloseButton", TalentTreeWindow.header, "UIPanelCloseButton")
TalentTreeWindow.header.close:SetSize(TT_SETTINGS.headerheight, TT_SETTINGS.headerheight)
TalentTreeWindow.header.close:SetPoint("TOPRIGHT", TalentTreeWindow.header, "TOPRIGHT")
TalentTreeWindow.header.close:SetScript(
    "OnClick",
    function()
        TalentTreeWindow:Hide()
    end
)
TalentTreeWindow.header.close:SetFrameLevel(TalentTreeWindow.header:GetFrameLevel() + 1)

TalentTreeWindow.header.title = TalentTreeWindow.header:CreateFontString("OVERLAY")
TalentTreeWindow.header.title:SetPoint("CENTER", TalentTreeWindow.header, "CENTER")
TalentTreeWindow.header.title:SetFont("Fonts\\FRIZQT__.TTF", 9)
TalentTreeWindow.header.title:SetText("Advancement")
TalentTreeWindow.header.title:SetTextColor(188 / 255, 150 / 255, 28 / 255, 1)

TalentTreeWindow.body = CreateFrame("Frame", TalentTreeWindow.body, TalentTreeWindow)
TalentTreeWindow.body:SetPoint("TOP", 0, -TT_SETTINGS.headerheight)
TalentTreeWindow.body:SetSize(TalentTreeWindow:GetWidth()-2, TalentTreeWindow:GetHeight()-TT_SETTINGS.headerheight-2)

TalentTreeWindow.body.talents = CreateFrame("Frame", TalentTreeWindow.body.talents, TalentTreeWindow.body)
TalentTreeWindow.body.talents:SetPoint("TOPRIGHT", 0, 0)
TalentTreeWindow.body.talents:SetSize(9*TalentTreeWindow.body:GetWidth()/10, TalentTreeWindow.body:GetHeight())

TalentTreeWindow.body.talents.box = CreateFrame("Frame", TalentTreeWindow.body.talents.box , TalentTreeWindow.body.talents)
TalentTreeWindow.body.talents.box:SetPoint("CENTER", -TT_SETTINGS.headerheight/2, 0)
TalentTreeWindow.body.talents.box:SetSize(TalentTreeWindow.body.talents:GetWidth()-2*TT_SETTINGS.headerheight, TalentTreeWindow.body.talents:GetHeight()-4*TT_SETTINGS.headerheight)
TalentTreeWindow.body.talents.box:SetBackdrop(
    {
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        insets = {top = 1, left = 1, bottom = 1, right = 1},
        edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
        tileEdge = false,
        edgeSize = 1
    }
)
TalentTreeWindow.body.talents.box:SetBackdropColor(0, 0, 0, .5)
TalentTreeWindow.body.talents.box:SetBackdropBorderColor(188 / 255, 150 / 255, 28 / 255, .6)

TalentTreeWindow.body.mastery = CreateFrame("Frame", TalentTreeWindow.body.mastery, TalentTreeWindow.body)
TalentTreeWindow.body.mastery:SetPoint("TOPLEFT", 0, 0)
TalentTreeWindow.body.mastery:SetSize(TalentTreeWindow.body:GetWidth()/10, TalentTreeWindow.body:GetHeight())
TalentTreeWindow.body.mastery.prog = CreateFrame("StatusBar", TalentTreeWindow.body.mastery.prog, TalentTreeWindow.body.mastery)
TalentTreeWindow.body.mastery.prog:SetOrientation("Vertical")
TalentTreeWindow.body.mastery.prog:SetSize(TalentTreeWindow.body.mastery:GetWidth()-2*TT_SETTINGS.headerheight, TalentTreeWindow.body.talents.box:GetHeight())
TalentTreeWindow.body.mastery.prog:SetStatusBarColor(188 / 255, 150 / 255, 28 / 255, 1)
TalentTreeWindow.body.mastery.prog:SetMinMaxValues(0, 40)
TalentTreeWindow.body.mastery.prog:SetValue(20)
TalentTreeWindow.body.mastery.prog:SetStatusBarTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
TalentTreeWindow.body.mastery.prog:SetPoint("CENTER",TT_SETTINGS.headerheight/2,0)
TalentTreeWindow.body.mastery.prog:SetBackdrop(
    {
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        insets = {top = 1, left = 1, bottom = 1, right = 1},
        edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
        tileEdge = false,
        edgeSize = 1
    }
)
TalentTreeWindow.body.mastery.prog:SetBackdropColor(0, 0, 0, 0)
TalentTreeWindow.body.mastery.prog:SetBackdropBorderColor(188 / 255, 150 / 255, 28 / 255, .6)

TalentTreeWindow.body.mastery.button = CreateFrame("Button", TalentTreeWindow.body.mastery.button, TalentTreeWindow.body.mastery)
TalentTreeWindow.body.mastery.button:SetSize()

--Testing--
TalentLoadoutCache = TalentTree.TalentLoadoutCache

local function BuildLoadoutString()
    local out = ""

    out =
        out ..
        string.sub(
            Util.alpha,
            TalentTree.FORGE_SELECTED_TAB.TalentType + 1,
            TalentTree.FORGE_SELECTED_TAB.TalentType + 1
        )
    out = out .. string.sub(Util.alpha, TalentTree.FORGE_SELECTED_TAB.Id, TalentTree.FORGE_SELECTED_TAB.Id)
    out = out .. string.sub(Util.alpha, GetClassId(UnitClass("player")), GetClassId(UnitClass("player")))

    -- TODO: CLASS TREE
    for _, rank in ipairs(TreeCache.Spells[TalentTree.ClassTree]) do
        out = out .. string.sub(Util.alpha, rank + 1, rank + 1)
    end

    -- Spec tree last
    for _, rank in ipairs(TreeCache.Spells[TalentTree.FORGE_SELECTED_TAB.Id]) do
        out = out .. string.sub(Util.alpha, rank + 1, rank + 1)
    end

    return out
end

local function SetLoadoutButtonText(name)
    buttonText:SetText(name)
end

local function SaveLoadout(id, name, loadoutString)
    if not loadoutString then
        loadoutString = BuildLoadoutString()
    end
    local item = {
        name = name,
        loadout = loadoutString
    }
    TalentLoadoutCache[TalentTree.FORGE_SELECTED_TAB.Id][id] = item

    PushForgeMessage(ForgeTopic.SAVE_LOADOUT, tostring(id) .. ";" .. name .. ";" .. loadoutString)
    SetLoadoutButtonText(name)
end

function ApplyLoadoutAndUpdateCurrent(id)
    local loadout = TalentLoadoutCache[TalentTree.FORGE_SELECTED_TAB.Id][id]
    if loadout then
        SetLoadoutButtonText(id .. " " .. loadout.name)
        TalentTree.prevLoadout = TalentTree.currentLoadout
        TalentTree.currentLoadout = id
        TalentTree.activeString = loadout.loadout
        LoadTalentString(loadout.loadout)
    end
end

AcceptTalentsButton:SetScript(
    "OnClick",
    function()
        local out = ""

        -- tree metadata: type spec class
        out =
            out ..
            string.sub(
                Util.alpha,
                TalentTree.FORGE_SELECTED_TAB.TalentType + 1,
                TalentTree.FORGE_SELECTED_TAB.TalentType + 1
            )
        out = out .. string.sub(Util.alpha, TalentTree.FORGE_SELECTED_TAB.Id, TalentTree.FORGE_SELECTED_TAB.Id)
        out = out .. string.sub(Util.alpha, GetClassId(UnitClass("player")), GetClassId(UnitClass("player")))

        -- TODO: CLASS TREE
        for _, rank in ipairs(TreeCache.Spells[TalentTree.ClassTree]) do
            out = out .. string.sub(Util.alpha, rank + 1, rank + 1)
        end

        -- Spec tree last
        for _, rank in ipairs(TreeCache.Spells[TalentTree.FORGE_SELECTED_TAB.Id]) do
            out = out .. string.sub(Util.alpha, rank + 1, rank + 1)
        end

        if
            TreeCache.PreviousString[TalentTree.FORGE_SELECTED_TAB.TalentType + 1] ~= out or
                TalentTree.prevLoadout ~= TalentTree.currentLoadout
         then
            --print("Talent string to send: "..out.." length: "..string.len(out))
            local loadout = TalentLoadoutCache[TalentTree.FORGE_SELECTED_TAB.Id][TalentTree.currentLoadout]
            SaveLoadout(TalentTree.currentLoadout, loadout.name)
            PushForgeMessage(ForgeTopic.LEARN_TALENT, out)
        end
    end
)

local LoadoutDropButton = CreateFrame("Button", "LoadoutDropButton", TalentTreeWindow)
LoadoutDropButton:SetPoint("BOTTOMLEFT", TalentTreeWindow, "BOTTOMLEFT", -200, 35)
LoadoutDropButton:SetSize(180, 32)
LoadoutDropButton:SetFrameStrata("TOOLTIP")

LoadoutDropButton.bgTexture = LoadoutDropButton:CreateTexture(nil, "BACKGROUND")
LoadoutDropButton.bgTexture:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
LoadoutDropButton.bgTexture:SetPoint("CENTER")
LoadoutDropButton.bgTexture:SetWidth(250)
LoadoutDropButton.bgTexture:SetHeight(70)

buttonText = LoadoutDropButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
buttonText:SetText("Saved Loadouts")
buttonText:SetPoint("CENTER", LoadoutDropButton, "CENTER")

local arrowButton = CreateFrame("Button", nil, LoadoutDropButton)
arrowButton:SetSize(25, 25)
arrowButton:SetPoint("RIGHT", LoadoutDropButton, "RIGHT", 0, 1)

local arrowTexture = arrowButton:CreateTexture(nil, "OVERLAY")
arrowTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
arrowTexture:SetAllPoints(arrowButton)
arrowButton:SetNormalTexture(arrowTexture)

-- local function UpdateLoadoutMenu()
--     local menuItems = {
--         {
--             text = "Create Loadout",
--             colorCode = "|cff00ff00",
--             func = function()
--                 StaticPopup_Show("CREATE_LOADOUT_POPUP")
--             end,
--             notCheckable = true
--         }
--     }

--     for id, loadout in pairs(TalentLoadoutCache[TalentTree.FORGE_SELECTED_TAB.Id]) do
--         table.insert(
--             menuItems,
--             {
--                 text = id .. " " .. loadout.name,
--                 colorCode = "|cff0000ff",
--                 func = function()
--                     ApplyLoadoutAndUpdateCurrent(id)
--                     CloseDropDownMenus()
--                 end,
--                 notCheckable = true
--             }
--         )
--     end

--     return menuItemsq
-- end

-- local function UpdateLoadoutButtonText(name, isDefault)
--     if isDefault then
--         buttonText:SetText(name)
--         buttonText:SetTextColor(0, 0, 1)
--     else
--         buttonText:SetText(name)
--         buttonText:SetTextColor(0, 0.5, 1)
--     end
-- end

function DeleteLoadout(id)
    PushForgeMessage(ForgeTopic.DELETE_LOADOUT, id)
end

local function GenerateTalentString()
    local out = ""

    -- tree metadata: type spec class
    out =
        out ..
        string.sub(
            Util.alpha,
            TalentTree.FORGE_SELECTED_TAB.TalentType + 1,
            TalentTree.FORGE_SELECTED_TAB.TalentType + 1
        )
    out = out .. string.sub(Util.alpha, TalentTree.FORGE_SELECTED_TAB.Id, TalentTree.FORGE_SELECTED_TAB.Id)
    out = out .. string.sub(Util.alpha, GetClassId(UnitClass("player")), GetClassId(UnitClass("player")))

    -- CLASS TREE
    for _, rank in ipairs(TreeCache.Spells[TalentTree.ClassTree]) do
        out = out .. string.sub(Util.alpha, rank + 1, rank + 1)
    end

    -- Spec tree last
    for _, rank in ipairs(TreeCache.Spells[TalentTree.FORGE_SELECTED_TAB.Id]) do
        out = out .. string.sub(Util.alpha, rank + 1, rank + 1)
    end

    return out
end

local function ShareTalentString()
    local talentString = GenerateTalentString()
    local name, _ = UnitName("player")
    local fakeItemID = "123456"
    local fakeItemLink =
        "|cff9d9d9d|Hitem:" .. fakeItemID .. ":::::::::::" .. talentString .. ":::|h[" .. name .. " Talent Build]|h|r"
    print(fakeItemLink)
    SendChatMessage("Check out my custom talent build: " .. fakeItemLink, "SAY") -- Modifique para o canal de chat desejado
end

hooksecurefunc(
    "SetItemRef",
    function(link, _, _, _) -- text,button,chatFrame
        local type, id = strsplit(":", link)
        if type == "item" and id == "123456" then
            -- Abre um quadro de diálogo com a string de talentos que pode ser copiada.
            local editBox = ChatEdit_ChooseBoxForSend()
            local talentString = GenerateTalentString()
            ChatEdit_ActivateChat(editBox)
            editBox:SetText(talentString)
            editBox:HighlightText()
            -- Esconde a tooltip
            HideUIPanel(ItemRefTooltip)
            -- Informa ao usuário para pressionar Ctrl+C para copiar.
            print("Press Ctrl+C to copy the Loadout")
        end
    end
)

local function ShowLoadoutMenu()
    local menuItems = {}

    local maxLoadouts = 7 -- Incluindo o loadout padrão
    local currentLoadoutCount = #TalentLoadoutCache[TalentTree.FORGE_SELECTED_TAB.Id]

    -- Adiciona o item de menu "Create Loadout", mas desabilita se o limite for atingido
    local createLoadoutItem = {
        text = "Create Loadout",
        notCheckable = true,
        func = function()
            if currentLoadoutCount < maxLoadouts then
                StaticPopup_Show("CREATE_LOADOUT_POPUP")
            end
        end,
        colorCode = currentLoadoutCount < maxLoadouts and "|cff00ff00" or "|cff808080"
    }

    table.insert(menuItems, createLoadoutItem)

    for id, loadout in pairs(TalentLoadoutCache[TalentTree.FORGE_SELECTED_TAB.Id]) do
        -- Determine se este é o primeiro loadout no cache
        local isFirstLoadout = id == next(TalentLoadoutCache[TalentTree.FORGE_SELECTED_TAB.Id])

        local submenu = {}
        if not isFirstLoadout then -- Se não for o primeiro loadout, adicione opções no submenu
            -- Adiciona a opção de deletar
            table.insert(
                submenu,
                {
                    text = "Delete Loadout",
                    colorCode = "|cffFF0000",
                    func = function()
                        TalentLoadoutCache[TalentTree.FORGE_SELECTED_TAB.Id][id] = nil
                        DropDownList1:Hide()
                        buttonText:SetText("Saved Loadouts")
                        DeleteLoadout(id)
                    end,
                    notCheckable = true
                }
            )
            -- Adiciona a opção de compartilhar
            table.insert(
                submenu,
                {
                    text = "Share Loadout",
                    colorCode = "|cff00ccff",
                    func = function()
                        ShareTalentString() -- Chama a função ShareTalentString
                    end,
                    notCheckable = true
                }
            )
            table.insert(
                submenu,
                {
                    text = "Import Loadout",
                    colorCode = "|cff00ccff",
                    func = function()
                        StaticPopup_Show("IMPORT_LOADOUT_POPUP")
                    end,
                    notCheckable = true
                }
            )
        end

        table.insert(
            menuItems,
            {
                text = id .. " " .. loadout.name,
                colorCode = "|cffffffff",
                func = function()
                    ApplyLoadoutAndUpdateCurrent(id)
                end,
                notCheckable = true,
                hasArrow = not isFirstLoadout, -- Só mostra a seta se não for o primeiro loadout
                menuList = submenu
            }
        )
    end

    local menuFrame = CreateFrame("Frame", "LoadoutMenuFrame", UIParent, "UIDropDownMenuTemplate")

    UIDropDownMenu_Initialize(
        menuFrame,
        function(_, level, menuList)
            if level == 1 then
                for _, menuItem in ipairs(menuItems) do
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = menuItem.text
                    info.colorCode = menuItem.colorCode
                    info.notCheckable = menuItem.notCheckable
                    info.func = menuItem.func
                    info.hasArrow = menuItem.hasArrow
                    info.menuList = menuItem.menuList
                    UIDropDownMenu_AddButton(info)
                end
            elseif level == 2 and menuList then
                for _, menuItem in ipairs(menuList) do
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = menuItem.text
                    info.colorCode = menuItem.colorCode
                    info.notCheckable = menuItem.notCheckable
                    info.func = menuItem.func
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        end,
        "MENU"
    )

    ToggleDropDownMenu(1, nil, menuFrame, "cursor", 0, 0)
end

arrowButton:SetScript(
    "OnClick",
    function(_, _, _)
        ShowLoadoutMenu()
    end
)

StaticPopupDialogs["CREATE_LOADOUT_POPUP"] = {
    text = "Enter the name of your new loadout:",
    button1 = "OK",
    button2 = "Cancel",
    OnAccept = function(self)
        local text = self.editBox:GetText()
        local index = #TalentTree.TalentLoadoutCache[TalentTree.FORGE_SELECTED_TAB.Id] + 1
        SaveLoadout(index, text)
        buttonText:SetText(text)
        StaticPopup_Hide("CREATE_LOADOUT_POPUP")
    end,
    OnShow = function(self)
        self.editBox:SetMaxLetters(10) -- Seu código de OnShow aqui
        --local point, relativeTo, relativePoint, xOffset, yOffset = self:GetPoint()
        self:ClearAllPoints()
        self:SetPoint("CENTER", TalentFrame, "CENTER", 0, 100)
    end,
    hasEditBox = true,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
}

StaticPopupDialogs["IMPORT_LOADOUT_POPUP"] = {
    text = "Import Loadout",
    button1 = "OK",
    button2 = "Cancel",
    OnAccept = function(self)
        local text = self.editBox:GetText()
        if text and text ~= "" then
            local loadout = TalentLoadoutCache[TalentTree.FORGE_SELECTED_TAB.Id][TalentTree.currentLoadout]
            loadout.talentString = text
            LoadTalentString(text)
        end
        StaticPopup_Hide("IMPORT_LOADOUT_POPUP")
    end,
    hasEditBox = true,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
}

local function UpdateButtonDisplay(loadoutName)
    if loadoutName then
        buttonText:SetText(loadoutName)
    else
        buttonText:SetText("Saved Loadouts")
    end
end

UpdateButtonDisplay()
