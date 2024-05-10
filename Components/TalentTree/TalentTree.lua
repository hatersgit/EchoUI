TalentTree = {
    FORGE_TABS = {},
    FORGE_ACTIVE_SPEC = {},
    FORGE_SPECS_TAB = {},
    FORGE_SPEC_SLOTS = {},
    FORGE_SELECTED_TAB = 0,
    FORGE_SPELLS_PAGES = {},
    FORGE_CURRENT_PAGE = 0,
    FORGE_MAX_PAGE = nil,
    FORGE_TALENTS = nil,
    INITIALIZED = false,
    SELECTED_SPEC = nil,
    MaxPoints = {},
    TalentLoadoutCache = {},
    currentLoadout = nil,
    prevLoadout = nil,
    activeString = nil,

    TabCount = 3,

    ROWS = 8,
    COLS = 6,
    ICON_SIZE = 1,
    SELECT_INIT = false,

    CLASS_SELECT = {
        [1]     = "Warrior",
        [2]     = "Paladin",
        [4]     = "Hunter",
        [8]     = "Rogue",
        [16]    = "Priest",
        [32]    = "Death Knight",
        [64]    = "Shaman",
        [128]   = "Mage",
        [256]   = "Warlock",
        [2048]   = "Shapshifter",
        [1024]  = "Druid"
    },
    CLASS_ICON = {
        [1]     = "Interface\\Icons\\Ability_Warrior_InnerRage",
        [2]     = "Interface\\Icons\\Ability_Paladin_artofwar",
        [4]     = "Interface\\Icons\\Ability_Hunter_HunterVsWild",
        [8]     = "Interface\\Icons\\Ability_Rogue_MasterOfSubtlety",
        [16]    = "Interface\\Icons\\Spell_Holy_DivineSpirit",
        [32]    = "Interface\\Icons\\spell_deathknight_classicon",
        [64]    = "Interface\\Icons\\Spell_Shaman_ImprovedStormstrike",
        [128]   = "Interface\\Icons\\Ability_Mage_Invisibility",
        [256]   = "Interface\\Icons\\Ability_Warlock_DemonicPower",
        [2048]   = "Interface\\Icons\\Ability_Druid_MasterShapeshifter",
        [1024]  = "Interface\\Icons\\Ability_Druid_ManaTree"
    }
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
    IndexToFrame = {},
    PrerequisiteLines = {},

    PrimaryClass = 0,
    SecondaryClass = 0,

    CurrentString = "",
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
TalentTreeWindow:SetSize(550, 450)
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

local function ColorForRank(rank, max, isSpell)
    if isSpell then
        if tonumber(rank) == tonumber(max) then
            return 71 / 255, 201 / 255, 156 / 255
        else
            return 199 / 255, 239 / 255, 207 / 255
        end
    else
        if tonumber(rank) == tonumber(max) then
            return 225 / 255, 96 / 255, 54 / 255
        else
            return 255 / 255, 227 / 255, 220 / 255
        end
    end
end

function DrawTabStates()
    for i = 1, TalentTree.TabCount, 1 do
        if TalentTree.FORGE_SELECTED_TAB == TalentTreeWindow.body.tabs.tab[i].id then
           TalentTreeWindow.body.tabs.tab[i].title:SetTextColor(255 / 255, 255 / 255, 255 / 255, 1)
           TalentTreeWindow.body.tabs.tab[i]:SetNormalTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]], "ADD")
           TalentTreeWindow.body.tabs.tab[i]:SetHighlightTexture("")
        else
            TalentTreeWindow.body.tabs.tab[i].title:SetTextColor(188 / 255, 150 / 255, 28 / 255, 1)
            TalentTreeWindow.body.tabs.tab[i]:SetNormalTexture("")
            TalentTreeWindow.body.tabs.tab[i]:SetHighlightTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]], "ADD")
        end
    end
end

function InitTalents()
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

    local buttonsize = TT_SETTINGS.headerheight*.75
    local topPadding = TT_SETTINGS.headerheight/4

    InfoToolTip = CreateFrame("GameTooltip", "InfoTT", UIParent, "GameTooltipTemplate")

    TalentTreeWindow.header.close = CreateFrame("BUTTON", "InstallCloseButton", TalentTreeWindow.header, "UIPanelCloseButton")
    TalentTreeWindow.header.close:SetSize(buttonsize, buttonsize)
    TalentTreeWindow.header.close:SetNormalTexture(CONSTANTS.ASSETS.STOP)
    TalentTreeWindow.header.close:SetPushedTexture(CONSTANTS.ASSETS.STOP)
    TalentTreeWindow.header.close:SetPoint("RIGHT", TalentTreeWindow.header, "RIGHT", -topPadding, 0)
    TalentTreeWindow.header.close:SetScript(
        "OnClick",
        function()
            TalentTreeWindow:Hide()
        end
    )
    TalentTreeWindow.header.close:SetFrameLevel(TalentTreeWindow.header:GetFrameLevel() + 1)


    TalentTreeWindow.header.reset = CreateFrame("BUTTON", "InstallMenuButton", TalentTreeWindow.header, "UIPanelCloseButton")
    TalentTreeWindow.header.reset:SetPoint("LEFT", TalentTreeWindow.header, "LEFT", topPadding, 0)
    TalentTreeWindow.header.reset:SetNormalTexture(CONSTANTS.ASSETS.REFRESH)
    TalentTreeWindow.header.reset:SetPushedTexture(CONSTANTS.ASSETS.REFRESH)
    TalentTreeWindow.header.reset:SetSize(buttonsize*.75, buttonsize*.75)
    TalentTreeWindow.header.reset:SetScript(
        "OnClick",
        function()
            UnlearnAllTalents()
            if TalentTree.FORGE_SELECTED_TAB ~= GetClassMaskForBaseClass() then
                BuildTalentString()
                PushForgeMessage(ForgeTopic.MULTICLASS, "1")
                TreeCache.SecondaryClass = 0
            end
        end
    )
    TalentTreeWindow.header.reset:SetScript("OnEnter", function()
        InfoToolTip:SetBackdrop(
            {
                bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
                insets = {top = 0, left = 0, bottom = 0, right = 0},
                edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
                edgeSize = 1,
                tile = false
            }
        )
        InfoToolTip:SetBackdropColor(0, 0, 0, .6)
        InfoToolTip:SetBackdropBorderColor(188 / 255, 150 / 255, 28 / 255, .6)
        InfoToolTip:SetOwner(TalentTreeWindow.header.reset,"ANCHOR_RIGHT", 0, 0)
        InfoToolTip:AddLine("Reset Talents")
        InfoToolTip:Show()

    end)
    TalentTreeWindow.header.reset:SetScript("OnLeave", function()
        InfoToolTip:ClearLines(0)
        InfoToolTip:Hide()

    end)
    TalentTreeWindow.header.reset:SetFrameLevel(TalentTreeWindow.header:GetFrameLevel() + 1)

    TalentTreeWindow.header.import = CreateFrame("BUTTON", "InstallMenuButton", TalentTreeWindow.header, "UIPanelCloseButton")
    TalentTreeWindow.header.import:SetPoint("LEFT", TalentTreeWindow.header, "LEFT", 2*topPadding+buttonsize*.75, 0)
    TalentTreeWindow.header.import:SetNormalTexture(CONSTANTS.ASSETS.GOLDARROW)
    TalentTreeWindow.header.import:SetPushedTexture(CONSTANTS.ASSETS.GOLDARROW)
    TalentTreeWindow.header.import:SetSize(buttonsize, buttonsize)
    TalentTreeWindow.header.import:SetScript(
        "OnClick",
        function()
            PushForgeMessage(ForgeTopic.LEARN_TALENT, TreeCache.CurrentString);
        end
    )
    TalentTreeWindow.header.import:SetFrameLevel(TalentTreeWindow.header:GetFrameLevel() + 1)
    TalentTreeWindow.header.import:SetScript("OnEnter", function()
        InfoToolTip:SetBackdrop(
            {
                bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
                insets = {top = 0, left = 0, bottom = 0, right = 0},
                edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
                edgeSize = 1,
                tile = false
            }
        )
        InfoToolTip:SetBackdropColor(0, 0, 0, .6)
        InfoToolTip:SetBackdropBorderColor(188 / 255, 150 / 255, 28 / 255, .6)
        InfoToolTip:SetOwner(TalentTreeWindow.header.import,"ANCHOR_RIGHT", 0, 0)
        InfoToolTip:AddLine("Save Talents")
        InfoToolTip:Show()

    end)
    TalentTreeWindow.header.import:SetScript("OnLeave", function()
        InfoToolTip:ClearLines(0)
        InfoToolTip:Hide()

    end)

    TalentTreeWindow.header.title = TalentTreeWindow.header:CreateFontString("OVERLAY")
    TalentTreeWindow.header.title:SetPoint("CENTER", TalentTreeWindow.header, "CENTER")
    TalentTreeWindow.header.title:SetFont("Fonts\\FRIZQT__.TTF", 9)
    TalentTreeWindow.header.title:SetText("Advancement")
    TalentTreeWindow.header.title:SetTextColor(188 / 255, 150 / 255, 28 / 255, 1)

    TalentTreeWindow.body = CreateFrame("Frame", TalentTreeWindow.body, TalentTreeWindow)
    TalentTreeWindow.body:SetPoint("TOP", 0, -TT_SETTINGS.headerheight)
    TalentTreeWindow.body:SetSize(TalentTreeWindow:GetWidth()-2, TalentTreeWindow:GetHeight()-TT_SETTINGS.headerheight-2)

    TalentTreeWindow.body.mastery = CreateFrame("Frame", "TalentTreeWindow.body.mastery", TalentTreeWindow.body)
    TalentTreeWindow.body.mastery:SetPoint("BOTTOM", 0, 0)
    TalentTreeWindow.body.mastery:SetSize(TalentTreeWindow.body:GetWidth(), TT_SETTINGS.headerheight/2)

    TalentTreeWindow.body.mastery.prog = CreateFrame("StatusBar", "TalentTreeWindow.body.mastery.prog", TalentTreeWindow.body.mastery)
    TalentTreeWindow.body.mastery.prog:SetOrientation("horizontal")
    TalentTreeWindow.body.mastery.prog:SetSize(TalentTreeWindow.body.mastery:GetWidth(), TalentTreeWindow.body.mastery:GetHeight())
    TalentTreeWindow.body.mastery.prog:SetMinMaxValues(0, 60)
    TalentTreeWindow.body.mastery.prog:SetStatusBarTexture("Interface\\Buttons\\CheckButtonHilight", "OVERLAY");
    TalentTreeWindow.body.mastery.prog:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8", "ARTWORK");
    TalentTreeWindow.body.mastery.prog:SetStatusBarColor(153 / 255, 0 / 255, 0 / 255, .5)
    TalentTreeWindow.body.mastery.prog:SetPoint("CENTER",0,0)
    TalentTreeWindow.body.mastery.prog:SetBackdrop(
        {
            bgFile = CONSTANTS.UI.NORMAL_BAR,
            insets = {top = 1, left = 1, bottom = 1, right = 1},
        }
    )
    TalentTreeWindow.body.mastery.prog:SetBackdropColor(1, 1, 1, .5)
    TalentTreeWindow.body.mastery.prog:SetValue(UnitLevel("player"))
    TalentTreeWindow.body.mastery.prog:EnableMouse(true)

    TalentTreeWindow:RegisterEvent("PLAYER_LEVEL_UP")
    TalentTreeWindow:SetScript("OnEvent", function(_,_,level) 
        TalentTreeWindow.body.mastery.prog:SetValue(level)
        DrawTabs(level)
    end)

    masterytt = CreateFrame("GameTooltip", "masterytt", UIParent, "GameTooltipTemplate")

    TalentTreeWindow.body.mastery.prog:SetScript("OnEnter", function()
        masterytt:SetBackdrop(
            {
                bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
                insets = {top = 0, left = 0, bottom = 0, right = 0},
                edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
                edgeSize = 1,
                tile = false
            }
        )
        masterytt:SetBackdropColor(0, 0, 0, .6)
        masterytt:SetOwner(TalentTreeWindow.body.mastery.prog,"ANCHOR_TOP", 0, 0)
        masterytt:AddDoubleLine(UnitName("player"), "Level "..UnitLevel("player"))
        masterytt:AddLine(UnitClass("player"), GetClassColorFor("player"))
        masterytt:AddLine("Place holder mastery ipsum. Increases something.", 1, 1, 1)
        masterytt:Show()
    end)

    TalentTreeWindow.body.mastery.prog:SetScript(
        "OnLeave",
        function()
            masterytt:ClearLines(0)
            masterytt:Hide()
        end
    )
    TalentTreeWindow.body.tabs = CreateFrame("Frame", TalentTreeWindow.body.tabs, TalentTreeWindow.body)
    TalentTreeWindow.body.tabs:SetPoint("BOTTOM", 0, -(TT_SETTINGS.headerheight+1))
    TalentTreeWindow.body.tabs:SetSize(TalentTreeWindow.body:GetWidth(), TT_SETTINGS.headerheight)
    TalentTreeWindow.body.tabs.tab = {}

    -- TALENT GRID
    TalentTreeWindow.body.talents = CreateFrame("Frame", "TalentTreeWindow.body.talents", TalentTreeWindow.body)
    TalentTreeWindow.body.talents:SetPoint("TOPLEFT", 0, 0)
    TalentTreeWindow.body.talents:SetSize(TalentTreeWindow.body:GetWidth(), TalentTreeWindow.body:GetHeight()-TT_SETTINGS.headerheight/2)
    TalentTreeWindow.body.talents.grid = {}

    InitGrid()

    TalentTreeWindow.TalentPoints = CreateFrame("Frame", "TalentPoints", TalentTreeWindow)
    TalentTreeWindow.TalentPoints:SetSize(100, TT_SETTINGS.headerheight)
    TalentTreeWindow.TalentPoints:SetPoint("BOTTOM", 0, 0)
    TalentTreeWindow.TalentPoints.Points = TalentTreeWindow:CreateFontString()
    TalentTreeWindow.TalentPoints.Points:SetFont("Fonts\\FRIZQT__.TTF", 8)
    TalentTreeWindow.TalentPoints.Points:SetTextColor(188 / 255, 150 / 255, 28 / 255, 1)
    TalentTreeWindow.TalentPoints.Points:SetPoint("BOTTOM", 0, TalentTreeWindow.body.mastery.prog:GetHeight()+3)

    TalentTreeWindow.body.multiclass = CreateFrame("Frame", "TalentTreeWindow.body.multiclass", TalentTreeWindow.body)
    TalentTreeWindow.body.multiclass:SetPoint("TOPLEFT", 0, 0)
    TalentTreeWindow.body.multiclass:SetSize(TalentTreeWindow.body:GetWidth(), TalentTreeWindow.body:GetHeight()-TT_SETTINGS.headerheight/2)

    TalentTreeWindow.body.multiclass:Hide()
end

function InitGrid()
    local _, _, icon = GetSpellInfo(1)
    local spaceBetweeny = TT_SETTINGS.headerheight
    local iconSize = (TalentTreeWindow.body.talents:GetHeight() - (TalentTree.ROWS*spaceBetweeny + TT_SETTINGS.headerheight))/(TalentTree.ROWS+1)
    local spaceBetweenx = (TalentTreeWindow.body.talents:GetWidth() - (iconSize*TalentTree.COLS + 2*TT_SETTINGS.headerheight))/(TalentTree.COLS+1)
    TalentTree.ICON_SIZE = iconSize

    local yoffSet = TT_SETTINGS.headerheight/4
    for y = 0, TalentTree.ROWS, 1 do
        TalentTreeWindow.body.talents.grid[y] = {}
        local xoffSet = (TalentTreeWindow.body.talents:GetWidth()-(iconSize*(TalentTree.COLS+1) + spaceBetweenx*(TalentTree.COLS)))/2
        posY = yoffSet + (y * (iconSize + spaceBetweeny))
        for x = 0, TalentTree.COLS, 1 do
            posX = xoffSet + (x * (iconSize + spaceBetweenx))

            if not TalentTreeWindow.body.talents.grid[y][x] then
                TalentTreeWindow.body.talents.grid[y][x] = CreateFrame("Button", "TalentTreeWindow.body.talents.grid"..x..":"..y, TalentTreeWindow.body.talents)
                TalentTreeWindow.body.talents.grid[y][x]:SetFrameLevel(9)
                TalentTreeWindow.body.talents.grid[y][x]:SetSize(iconSize, iconSize)
                TalentTreeWindow.body.talents.grid[y][x]:SetPoint("TOPLEFT", posX, -posY) -- Usando posY aqui

                TalentTreeWindow.body.talents.grid[y][x].TextureIcon = TalentTreeWindow.body.talents.grid[y][x]:CreateTexture(nil, "ARTWORK")
                TalentTreeWindow.body.talents.grid[y][x].TextureIcon:SetAllPoints()
                TalentTreeWindow.body.talents.grid[y][x].TextureIcon:SetSize(iconSize, iconSize)
            
                TalentTreeWindow.body.talents.grid[y][x].Border =
                    CreateFrame(
                    "Frame",
                    TalentTreeWindow.body.talents.grid[y][x].Border,
                    TalentTreeWindow.body.talents.grid[y][x]
                )
                TalentTreeWindow.body.talents.grid[y][x].Border:SetFrameLevel(10)
                TalentTreeWindow.body.talents.grid[y][x].Border:SetPoint("CENTER", 0, 0)
                TalentTreeWindow.body.talents.grid[y][x].Border:SetSize(iconSize * 1.4, iconSize * 1.4)
                TalentTreeWindow.body.talents.grid[y][x].Border.texture =
                    TalentTreeWindow.body.talents.grid[y][x].Border:CreateTexture(nil, "ARTWORK")

                TalentTreeWindow.body.talents.grid[y][x].Border.texture:SetAllPoints(true)

                TalentTreeWindow.body.talents.grid[y][x].Ranks =
                    CreateFrame("Frame", nil, TalentTreeWindow.body.talents.grid[y][x])
                TalentTreeWindow.body.talents.grid[y][x].Ranks:SetFrameLevel(13)
                TalentTreeWindow.body.talents.grid[y][x].Ranks:SetPoint("BOTTOM", 0, 0)
                TalentTreeWindow.body.talents.grid[y][x].Ranks:SetSize(32, 26)
                TalentTreeWindow.body.talents.grid[y][x].RankText =
                    TalentTreeWindow.body.talents.grid[y][x].Ranks:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                TalentTreeWindow.body.talents.grid[y][x].RankText:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE")
                TalentTreeWindow.body.talents.grid[y][x].RankText:SetPoint("BOTTOM", 0, -TalentTreeWindow.body.talents.grid[y][x].RankText:GetStringHeight())
            end
            TalentTreeWindow.body.talents.grid[y][x].RankText:SetText(x.."/"..y)
            SetPortraitToTexture(TalentTreeWindow.body.talents.grid[y][x].TextureIcon, icon)

            TalentTreeWindow.body.talents.grid[y][x].node = {}
            TalentTreeWindow.body.talents.grid[y][x]:Hide()
        end
    end
end

function DrawTabs(level)
    local offset = TT_SETTINGS.headerheight/2
    local i = 1
    TalentTree.TabCount = #TalentTree.FORGE_TABS

    local classId = 2 ^ (GetClassId(UnitClass("player"))-1)
    local classTab = TalentTree.FORGE_TABS[classId]

    for id, tab in pairs(TalentTree.FORGE_TABS) do
        TalentTree.TabCount = i
        if id == classId then
            if not TalentTreeWindow.body.tabs.tab[1] then
                TalentTreeWindow.body.tabs.tab[1] = CreateATab(TalentTreeWindow.body.tabs, classTab.Name, classId)
                TalentTreeWindow.body.tabs.tab[1]:SetPoint("LEFT", TT_SETTINGS.headerheight/2, -1)
            end

            TalentTreeWindow.body.tabs.tab[1].Id = id
            TalentTreeWindow.body.tabs.tab[1].title:SetText(tab.Name)
            TalentTreeWindow.body.tabs.tab[1]:SetWidth(TalentTreeWindow.body.tabs.tab[1].title:GetStringWidth() + TT_SETTINGS.headerheight)
            TalentTreeWindow.body.tabs.tab[1]:SetScript("OnClick", function()
                ActivateTab(id)
            end)
            i = i+1
        else
            if not TalentTreeWindow.body.tabs.tab[2] then
                TalentTreeWindow.body.tabs.tab[2] = CreateATab(TalentTreeWindow.body.tabs, classTab.Name, classId)
                TalentTreeWindow.body.tabs.tab[2]:SetPoint("LEFT", offset, -1)
            end

            TalentTreeWindow.body.tabs.tab[2].Id = id
            TalentTreeWindow.body.tabs.tab[2].title:SetText(tab.Name)
            TalentTreeWindow.body.tabs.tab[2]:SetWidth(TalentTreeWindow.body.tabs.tab[2].title:GetStringWidth() + TT_SETTINGS.headerheight)
            TalentTreeWindow.body.tabs.tab[2]:SetScript("OnClick", function()
                ActivateTab(id)
            end)
            i = i+1
        end
    end

    if TalentTree.TabCount == 1 then
        if not level then
            level = UnitLevel("player")
        end
        if level >= 30 then
            if not TalentTreeWindow.body.tabs.tab[2] then
                TalentTreeWindow.body.tabs.tab[2] = CreateATab(TalentTreeWindow.body.tabs, "Select a Second Class", 1025)
            end
            TalentTreeWindow.body.tabs.tab[2].title:SetText("Select a Second Class")
            TalentTreeWindow.body.tabs.tab[2].Id = 1025
            TalentTreeWindow.body.tabs.tab[2]:SetWidth(TalentTreeWindow.body.tabs.tab[i].title:GetStringWidth() + TT_SETTINGS.headerheight)
            TalentTreeWindow.body.tabs.tab[2]:SetPoint("LEFT", TT_SETTINGS.headerheight/2 + TalentTreeWindow.body.tabs.tab[1]:GetWidth() + 3, -1)

            TalentTreeWindow.body.tabs.tab[2]:SetScript("OnClick", function()
                ShowMulticlassSelect()
                DrawTabStates()
            end)
            TalentTreeWindow.body.tabs.tab[2]:Show()
        else
            if TalentTreeWindow.body.tabs.tab[2] then
                TalentTreeWindow.body.tabs.tab[2]:Hide()
            end
        end
    else
        local lastTab = TalentTreeWindow.body.tabs.tab[i-1]
        if TalentTreeWindow.body.tabs.tab[2] then
            TalentTreeWindow.body.tabs.tab[2]:SetPoint("LEFT", TT_SETTINGS.headerheight/2 + TalentTreeWindow.body.tabs.tab[1]:GetWidth() + 3, -1)
        end
    end
    
    DrawTabStates()
end

function ShowMulticlassSelect()
    TalentTreeWindow.body.talents:Hide();
    TalentTreeWindow.body.multiclass:Show();
    local classesPerRow = 5

    if not TalentTreeWindow.body.multiclass.options then
        TalentTreeWindow.body.multiclass.options = CreateFrame("Frame", "TalentTreeWindow.body.multiclass.options", TalentTreeWindow.body.multiclass)
        TalentTreeWindow.body.multiclass.options:SetPoint("CENTER", 0, 0)
        TalentTreeWindow.body.multiclass.options:SetSize(TalentTreeWindow.body.multiclass:GetWidth()*.7, TalentTreeWindow.body.multiclass:GetHeight()/3);
        TalentTreeWindow.body.multiclass.options.list = {}

        TalentTreeWindow.body.multiclass.options.title = TalentTreeWindow.body.multiclass.options:CreateFontString("OVERLAY")
        TalentTreeWindow.body.multiclass.options.title:SetFont("Fonts\\FRIZQT__.TTF", 12)
        TalentTreeWindow.body.multiclass.options.title:SetText("Select a second class:")
        TalentTreeWindow.body.multiclass.options.title:SetTextColor(188 / 255, 150 / 255, 28 / 255, 1)
        TalentTreeWindow.body.multiclass.options.title:SetPoint("TOP", TalentTreeWindow.body.multiclass.options, "TOP", 0, TalentTreeWindow.body.multiclass.options.title:GetStringHeight())

        local offset = TT_SETTINGS.headerheight/2
        local iconW = (TalentTreeWindow.body.multiclass.options:GetWidth() - (classesPerRow-1)*offset)/classesPerRow
        
        for y = 0, 1, 1 do
            posY = offset + y*(offset+iconW)
            if not TalentTreeWindow.body.multiclass.options.list[y] then
                TalentTreeWindow.body.multiclass.options.list[y] = {};
            end
            for x = 0, classesPerRow-1, 1 do
                posX =  x * (offset+iconW)

                TalentTreeWindow.body.multiclass.options.list[y][x] = CreateFrame("Button", "TalentTreeWindow.body.multiclass.options.list"..y..":"..x, TalentTreeWindow.body.multiclass.options)
                TalentTreeWindow.body.multiclass.options.list[y][x]:SetSize(iconW, iconW)
                TalentTreeWindow.body.multiclass.options.list[y][x]:SetPoint("TOPLEFT", posX, -posY) -- Usando posY aqui

                TalentTreeWindow.body.multiclass.options.list[y][x].TextureIcon = TalentTreeWindow.body.multiclass.options.list[y][x]:CreateTexture(nil, "ARTWORK")
                TalentTreeWindow.body.multiclass.options.list[y][x].TextureIcon:SetAllPoints()
                TalentTreeWindow.body.multiclass.options.list[y][x].TextureIcon:SetSize(iconW, iconW)

               TalentTreeWindow.body.multiclass.options.list[y][x].Border =
                    CreateFrame("Frame",TalentTreeWindow.body.multiclass.options.list[y][x].Border,TalentTreeWindow.body.multiclass.options.list[y][x])
                TalentTreeWindow.body.multiclass.options.list[y][x].Border:SetFrameLevel(10)
                TalentTreeWindow.body.multiclass.options.list[y][x].Border:SetPoint("CENTER", 0, 0)
                TalentTreeWindow.body.multiclass.options.list[y][x].Border:SetSize(iconW * 1.4, iconW * 1.4)

                TalentTreeWindow.body.multiclass.options.list[y][x].Border.texture =
                    TalentTreeWindow.body.multiclass.options.list[y][x].Border:CreateTexture(nil, "ARTWORK")
                TalentTreeWindow.body.multiclass.options.list[y][x].Border.texture:SetAllPoints(true)

                TalentTreeWindow.body.multiclass.options.list[y][x]:Hide()
            end
        end
        TalentTree.SELECT_INIT = true
    end

    local x = 0
    local y = 0
    for i, class in pairs(TalentTree.CLASS_SELECT) do
        if i ~= GetClassMaskForBaseClass() then
            local icon = TalentTree.CLASS_ICON[i]
            local frame = TalentTreeWindow.body.multiclass.options.list[y][x]
            frame.id = i

            frame.TextureIcon:SetTexture(icon)
            frame:Show()

            frame:SetScript("OnEnter", function()
                InfoToolTip:SetBackdrop(
                    {
                        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
                        insets = {top = 0, left = 0, bottom = 0, right = 0},
                        edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
                        edgeSize = 1,
                        tile = false
                    }
                )
                InfoToolTip:SetBackdropColor(0, 0, 0, .6)
                InfoToolTip:SetBackdropBorderColor(188 / 255, 150 / 255, 28 / 255, .6)
                InfoToolTip:SetOwner(frame,"ANCHOR_RIGHT", 0, 0)
                InfoToolTip:AddLine(class)
                InfoToolTip:Show()

            end)
            frame:SetScript("OnLeave", function()
                InfoToolTip:ClearLines(0)
                InfoToolTip:Hide()
            end)
            frame:SetScript("OnClick", function()
                PushForgeMessage(ForgeTopic.MULTICLASS, "0;"..frame.id)
            end)

            x = x+1
            if x == classesPerRow then
                x = 0
                y = y+1
            end
        end
    end
end

function DrawTalentPoints(cpt, tabId)
    local tab = TalentTree.FORGE_TABS[tabId]
    if not tab then
        return
    end

    local maxPoints = TalentTree.MaxPoints[cpt]
    for id, number in pairs(TreeCache.PointsSpent) do
        maxPoints = maxPoints - number
    end

    TreeCache.Points[cpt] = maxPoints

    TalentTreeWindow.TalentPoints.Points:SetText("Points available: "..TreeCache.Points[cpt])
end

function ResetGrid()
    if TreeCache.PrerequisiteLines then
        for id, lines in pairs(TreeCache.PrerequisiteLines) do
            for _, line in pairs(lines) do
                if id == TalentTree.FORGE_SELECTED_TAB then
                    line:Show()
                else
                    line:Hide()
                end
            end
        end
    end

    for y = 0, TalentTree.ROWS, 1 do
        for x = 0, TalentTree.COLS, 1 do
            TalentTreeWindow.body.talents.grid[y][x].RankText:SetText("")
            if TalentTreeWindow.body.talents.grid[y][x].node then
                for spell, line in pairs(TalentTreeWindow.body.talents.grid[y][x].node) do
                    line:Hide()
                end
            end

            SetPortraitToTexture(TalentTreeWindow.body.talents.grid[y][x].TextureIcon, icon)
            TalentTreeWindow.body.talents.grid[y][x]:Hide()
        end
    end
end

function GetPositionXY(frame)
    local position = {
        x = 0,
        y = 0
    }
    local _, _, _, xOfs, yOfs = frame:GetPoint()
    position.x = xOfs
    position.y = yOfs
    return position
end

function FindPreReq(spells, spellId)
    for _, spell in pairs(spells) do
        if tonumber(spell.SpellId) == spellId then
            return spell
        end
    end
end

function CreatePrereqArrow(name, startIndex, endIndex)
    local iconSize = TalentTree.ICON_SIZE

    local startLoc = TreeCache.IndexToFrame[TalentTree.FORGE_SELECTED_TAB][startIndex]
    local endLoc = TreeCache.IndexToFrame[TalentTree.FORGE_SELECTED_TAB][endIndex]

    if startLoc and endLoc then
        local startFrame = TalentTreeWindow.body.talents.grid[startLoc.row][startLoc.col]
        local endFrame = TalentTreeWindow.body.talents.grid[endLoc.row][endLoc.col]

        local _, _, relTo1, x1, y1 = startFrame:GetPoint()
        local _, _, relTo2, x2, y2 = endFrame:GetPoint()

        local dx = x2 - x1
        local dy = y1 - y2

        local angle = math.atan2(dy, dx)
        local length = math.sqrt(dx^2 + dy^2)

        local cx = ((x1-iconSize + x2-iconSize) / 2) -1
        local cy = (y1 + y2) / 2


        local frame = CreateFrame("Frame", name, TalentTreeWindow.body.talents)
        frame:SetSize(length, TT_SETTINGS.headerheight)
        frame:SetPoint("TOPLEFT", cx, cy)
        frame:SetBackdrop(
            { bgFile = CONSTANTS.UI.CONNECTOR }
        )

        frame.animation = frame:CreateAnimationGroup()
        frame.animation.spin = frame.animation:CreateAnimation("Rotation")
        frame.animation.spin:SetOrder(1)
        frame.animation.spin:SetDuration(0)
        frame.animation.spin:SetDegrees(90)
        frame.animation.spin:SetEndDelay(999999)
        frame.animation:Play()

        return frame
    end
end

function FillGridForTab(id, spells)
    local tab = TalentTree.FORGE_TABS[id]

    if not TreeCache.PrerequisiteLines[id] then
        TreeCache.PrerequisiteLines[id] = {}
    end

    ResetGrid()
    for _, spell in pairs(spells) do
        local CurrentRank, SpellId, NextSpellId = GetSpellIdAndNextRank(id, spell)
        local _, _, icon = GetSpellInfo(spell.SpellId)
        local ColumnIndex = tonumber(spell.ColumnIndex)
        local RowIndex = tonumber(spell.RowIndex)
        local NumberOfRanks = tonumber(spell.NumberOfRanks)

        local frame = TalentTreeWindow.body.talents.grid[RowIndex][ColumnIndex]
        if not frame then
            return
        end

        if not TreeCache.IndexToFrame[id][spell.nodeIndex] then
            TreeCache.IndexToFrame[id][spell.nodeIndex] = {row = RowIndex, col = ColumnIndex}
        end
        if not TreeCache.Spells[id][spell.nodeIndex] then
            TreeCache.Spells[id][spell.nodeIndex] = 0
        end

        frame.Border:SetBackdrop({
            bgFile = CONSTANTS.UI.BORDER_SPELL
        })

        frame.CanUprank = false
        frame.CanDerank = false
        frame.update = false
        frame.reqsMet = false

        SpellCache = {}
        if not TreeCache.PointsSpent[id] then
            TreeCache.PointsSpent[id] = 0
        end
        if not TreeCache.Investments[id] then
            TreeCache.Investments[id] = {}
        end

        TreeCache.Investments[id][spell.TabPointReq] = 0
        TreeCache.TotalInvests[spell.TabPointReq] = 0

        if spell.Prereqs then
            for _, prereq in pairs(spell.Prereqs) do
                if not TreeCache.PrerequisiteLines[id][prereq.Talent] then
                    local prev = FindPreReq(spells, tonumber(prereq.Talent))

                    TreeCache.PrerequisiteLines[id][prereq.Talent] 
                    = CreatePrereqArrow("PrereqLine"..id..":"..prereq.Talent, prev.nodeIndex, spell.nodeIndex)
                end
            end
        end
        frame.Init = true
        if NumberOfRanks == 0 then
            frame:SetSize(38, 38)
            frame.Ranks:Hide()
            frame.Border:Hide()
            frame.TextureIcon:SetTexture(icon)
        else
            frame:SetScript( "OnEnter", function()
                if spell.nodeType <= 1 then
                    UpdateTooltip(spell, spell.SpellId, NextSpellId, frame, CurrentRank)
                    frame.IsTooltipActive = true
                end
            end)
            frame:SetScript("OnLeave", function()
                FirstRankToolTip:ClearLines(0)
                FirstRankToolTip:Hide()
                SecondRankToolTip:ClearLines(0)
                SecondRankToolTip:Hide()
                frame.IsTooltipActive = false
            end)
            if NumberOfRanks > 1 then
                frame.RankText:SetText(TreeCache.Spells[id][spell.nodeIndex].."/"..NumberOfRanks)
            else
                frame.RankText:SetText("")
            end
            frame:RegisterForClicks("AnyDown")
            frame:SetScript("OnMouseDown", function(_, button)
                local spellRank = TreeCache.Spells[id][spell.nodeIndex]
                local change = false
                if (button == "LeftButton" and frame.CanUprank) then
                    if TreeCache.Spells[id][spell.nodeIndex] < NumberOfRanks then
                        TreeCache.Spells[id][spell.nodeIndex] = spellRank + 1

                        TreeCache.PointsSpent[tab.Id] = TreeCache.PointsSpent[tab.Id] + spell.RankCost
                        TreeCache.Investments[tab.Id][spell.TabPointReq] =
                            TreeCache.Investments[tab.Id][spell.TabPointReq] + spell.RankCost

                        --print("Spell IDs in Cache:", table.concat(spellIds, ", "))  -- Imprime todos os IDs em uma linha
                        CurrentRank = TreeCache.Spells[id][spell.nodeIndex]
                        TreeCache.PrereqUnlocks[id][spell.SpellId] = CurrentRank
                        TreeCache.PrereqRev[spell.SpellId] = {}

                        if #spell.Prereqs > 0 then
                            for _, req in ipairs(spell.Prereqs) do
                                if
                                    TreeCache.PrereqRev[req.Talent] and
                                        tonumber(req.RequiredRank) <=
                                            TreeCache.PrereqUnlocks[req.TalentTabId][req.Talent]
                                 then
                                    TreeCache.PrereqRev[req.Talent][spell.SpellId] = true
                                end
                            end
                        end

                        TreeCache.Points[tab.TalentType] = TreeCache.Points[tab.TalentType] - spell.RankCost

                        change = true
                    end
                elseif (button ~= "LeftButton" and frame.CanDerank) then
                    if TreeCache.Spells[id][spell.nodeIndex] > 0 then
                        TreeCache.Spells[id][spell.nodeIndex] = spellRank - 1

                        TreeCache.PointsSpent[tab.Id] = TreeCache.PointsSpent[tab.Id] - spell.RankCost
                        TreeCache.Investments[tab.Id][spell.TabPointReq] =
                            TreeCache.Investments[tab.Id][spell.TabPointReq] - spell.RankCost

                        CurrentRank = TreeCache.Spells[id][spell.nodeIndex]
                        TreeCache.PrereqUnlocks[id][spell.SpellId] = CurrentRank

                        if #spell.Prereqs > 0 then
                            for _, req in ipairs(spell.Prereqs) do
                                if TreeCache.PrereqRev[req.Talent] and TreeCache.Spells[id][spell.nodeIndex] < 1 then
                                    TreeCache.PrereqRev[req.Talent][spell.SpellId] = nil
                                end
                            end
                        end

                        TreeCache.Points[tab.TalentType] = TreeCache.Points[tab.TalentType] + spell.RankCost

                        change = true
                    end
                end

                if change then
                    local cumulative = 0
                    for i = 0, 30, 1 do
                        local value = TreeCache.Investments[tab.Id][i]
                        if value then
                            cumulative = cumulative + value
                            TreeCache.TotalInvests[i] = cumulative
                        end
                    end

                    frame.update = true
                    if NumberOfRanks > 1 then
                        frame.RankText:SetText(TreeCache.Spells[id][spell.nodeIndex].."/"..spell.NumberOfRanks)
                    end

                    if frame.IsTooltipActive then
                        UpdateTooltip(spell, spell.SpellId, NextSpellId, frame, CurrentRank)
                    end

                    DrawTalentPoints(tab.TalentType, id)
                    BuildTalentString()
                end
                --print(dump(TreeCache.Investments))
                --print(dump(TreeCache.PrereqRev))
                --print(dump(TreeCache.PrereqUnlocks))
                -- Aqui você pode adicionar qualquer outra lógica necessária para outros tipos de nodeType
            end)
        end
        frame:SetScript("OnUpdate", function()
            local next = next
            local allow = false
            if TreeCache.PrereqRev[spell.SpellId] then
                if next(TreeCache.PrereqRev[spell.SpellId]) then
                    allow = true
                end
            end
            frame.CanDerank = not allow

            if next(spell.Prereqs) then
                for _, prereq in ipairs(spell.Prereqs) do
                    if TreeCache.PrereqUnlocks[prereq.TalentTabId] then
                        local reqUnlocked = TreeCache.PrereqUnlocks[prereq.TalentTabId][prereq.Talent]
                        if reqUnlocked then
                            if tonumber(reqUnlocked) >= tonumber(prereq.RequiredRank) then
                                frame.reqsMet = true
                            else
                                frame.reqsMet = false
                            end
                        else
                            frame.reqsMet = false
                        end
                    else
                        frame.reqsMet = false
                    end
                end
            else
                frame.reqsMet = true
            end

            if
                (tonumber(TreeCache.Points[tab.TalentType]) < tonumber(spell.RankCost) or
                    TreeCache.PointsSpent[id] < spell.TabPointReq or
                    UnitLevel("player") < tonumber(spell.RequiredLevel) or
                    not frame.reqsMet)
             then
                -- Aplica o efeito cinza se o spellID não estiver na SpellCache
                if (tonumber(spell.NumberOfRanks) > TreeCache.Spells[id][spell.nodeIndex]) then
                    frame.TextureIcon:SetDesaturated(true)
                    if frame.Border and frame.Border.texture then
                        frame.Border:SetBackdropColor(1,1,1,1)
                    end
                else
                    frame.TextureIcon:SetDesaturated(false)
                    frame.Border:SetBackdropColor(ColorForRank(TreeCache.Spells[id][spell.nodeIndex], spell.NumberOfRanks, spell.nodeType == 1))
                end
                frame.CanUprank = false
            else
                -- Remove o efeito cinza se o spellID estiver na SpellCache
                frame.TextureIcon:SetDesaturated(false)
                if frame.Border and frame.Border.texture then
                    frame.Border.texture:SetDesaturated(false)
                    frame.Border:SetBackdropColor(ColorForRank(TreeCache.Spells[id][spell.nodeIndex], spell.NumberOfRanks, spell.nodeType == 1))
                end
                frame.CanUprank = true
            end
            frame.RankText:SetText(TreeCache.Spells[id][spell.nodeIndex].."/"..spell.NumberOfRanks)
        end)
        SetPortraitToTexture(frame.TextureIcon, icon)
        frame.TextureIcon:ClearAllPoints()
        frame.TextureIcon:SetPoint("CENTER", frame.Border, "CENTER")

        frame:Show()
    end
end

function UnlearnAllTalents()
    for tab, nodes in pairs(TreeCache.Spells) do
        if TalentTree.FORGE_TABS[tab] then
            local cpt = TalentTree.FORGE_TABS[tab].TalentType
            for index = #nodes, 1, -1 do
                local rank = nodes[index]
                if rank > 0 then
                    local location = TreeCache.IndexToFrame[tab][index]
                    local frame = TalentTreeWindow.body.talents.grid[location.row][location.col]
                    --print(index.."  at  "..location.row.." : "..location.col)
                    for i = 1, rank, 1 do
                        frame:GetScript("OnUpdate")()
                        frame:GetScript("OnMouseDown")(frame, 'RightBu4tton')
                    end
                end
            end
            DrawTalentPoints(cpt, tab)
        end
    end
end

function BuildTalentString()
    local tab = TalentTree.FORGE_TABS[TalentTree.FORGE_SELECTED_TAB]
    local out = "" 
    out = out .. string.sub(Util.alpha, tab.TalentType + 1, tab.TalentType + 1 )
    out = out .. string.sub(Util.alpha, GetClassIdFromMask(TreeCache.PrimaryClass), GetClassIdFromMask(TreeCache.PrimaryClass))
    out = out .. string.sub(Util.alpha, GetClassIdFromMask(TreeCache.SecondaryClass), GetClassIdFromMask(TreeCache.SecondaryClass))
    
    if TreeCache.Spells[TreeCache.PrimaryClass] then
        for _, rank in ipairs(TreeCache.Spells[TreeCache.PrimaryClass]) do
            out = out .. string.sub(Util.alpha, rank + 1, rank + 1)
        end

        if TreeCache.SecondaryClass > 0 then
            if not TreeCache.Spells[TreeCache.SecondaryClass] then
                ActivateTab(TreeCache.SecondaryClass)
            end
            for _, rank in ipairs(TreeCache.Spells[TreeCache.SecondaryClass]) do
                out = out .. string.sub(Util.alpha, rank + 1, rank + 1)
            end
        end
        TreeCache.CurrentString = out
    end
end

function LoadTalentString(talents)
    UnlearnAllTalents()
    local type, _ = string.find(Util.alpha, string.sub(talents, 1, 1))
    local primary, _ = string.find(Util.alpha, string.sub(talents, 2, 2))
    local secondary, _ = string.find(Util.alpha, string.sub(talents, 3, 3))

    local primaryTree = GetClassMaskFromId(tonumber(primary))
    local secondaryTree = GetClassMaskFromId(tonumber(secondary))

    if not TalentTree.FORGE_TALENTS then
        TalentTree.FORGE_TALENTS = {}
    end

    TreeCache.Points[tostring(type - 1)] = TalentTree.MaxPoints[tostring(type - 1)]
    TreeCache.PointsSpent[primaryTree] = 0
    
    if TreeCache.PrimaryClass == primaryTree then
        ActivateTab(primaryTree)
        local primaryTreeLen = 0
        if TreeCache.Spells[primaryTree] then
            primaryTreeLen = #TreeCache.Spells[primaryTree]
        end

        local nodeInd = 1
        local primaryBlock = 3 + primaryTreeLen
        if (4 <= primaryBlock) then
            local primaryString = string.sub(talents, 4, primaryBlock)
            for i = 1, primaryTreeLen, 1 do
                TreeCache.Spells[primaryTree][nodeInd] = 0
                local rank = string.find(Util.alpha, string.sub(primaryString, i, i)) - 1
                for j = 1, rank, 1 do
                    local location = TreeCache.IndexToFrame[primaryTree][nodeInd]
                    local frame = TalentTreeWindow.body.talents.grid[location.row][location.col]
                    frame:GetScript("OnUpdate")()
                    frame:GetScript("OnMouseDown")(frame, "LeftButton")
                end
                nodeInd = nodeInd + 1
            end
        end

        if secondary ~= 64 then
            if secondaryTree ~= TreeCache.SecondaryClass then
                PushForgeMessage(ForgeTopic.MULTICLASS, "1")
                PushForgeMessage(ForgeTopic.MULTICLASS, "0;"..secondaryTree)
            end
            ActivateTab(secondaryTree)

            local secondaryTreeLen = 0
            if TreeCache.Spells[secondaryTree] then
                secondaryTreeLen = #TreeCache.Spells[secondaryTree]
            end

            nodeInd = 1
            local secondaryBlock = primaryBlock + secondaryTreeLen
            if (4 <= secondaryBlock) then
                local secondaryString = string.sub(talents, primaryBlock+1, secondaryBlock)
                for i = 1, secondaryTreeLen, 1 do
                    TreeCache.Spells[secondaryTree][nodeInd] = 0
                    local rank = string.find(Util.alpha, string.sub(secondaryString, i, i)) - 1
                    for j = 1, rank, 1 do
                        local location = TreeCache.IndexToFrame[secondaryTree][nodeInd]
                        local frame = TalentTreeWindow.body.talents.grid[location.row][location.col]
                        frame:GetScript("OnUpdate")()
                        frame:GetScript("OnMouseDown")(frame, "LeftButton")
                    end
                    nodeInd = nodeInd + 1
                end
            end
        end
        TreeCache.CurrentString = out
    end
end

function ActivateTab(id)
    TalentTreeWindow.body.multiclass:Hide()
    TalentTreeWindow.body.talents:Show()
    if TalentTree.FORGE_SELECTED_TAB ~= id then
        TalentTree.FORGE_SELECTED_TAB = id
        local tab = TalentTree.FORGE_TABS[id]
        if tab.TalentType == CharacterPointType.TALENT_SKILL_TREE then
            if not TreeCache.Spells[tab.Id] then
                TreeCache.Spells[tab.Id] = {}
            end
            if not TreeCache.PrereqUnlocks[tab.Id] then
                TreeCache.PrereqUnlocks[tab.Id] = {}
            end
            if not TreeCache.IndexToFrame[tab.Id] then
                TreeCache.IndexToFrame[tab.Id] = {}
            end

            DrawTalentPoints(tab.TalentType, tab.Id)
            if tab.Talents then
                FillGridForTab(id, tab.Talents)
                BuildTalentString()
            end
        end
    end
end

function LoadTalentTreeLayout(msg)
    local listOfObjects = DeserializeMessage(DeserializerDefinitions.TalentTree_LAYOUT, msg)
    talentLen = 0
    TalentTree.FORGE_TABS = {}
    TreeCache.PrimaryClass = GetClassMaskForBaseClass()
    for _, tab in ipairs(listOfObjects) do
        TalentTree.FORGE_TABS[tab.Id] = tab

        if tab.Id ~= TreeCache.PrimaryClass then
            TreeCache.SecondaryClass = tab.Id
        end
    end
    DrawTabs()
end

function LoadCharacterSpecs(msg)
    local listOfObjects = DeserializeMessage(DeserializerDefinitions.GET_CHARACTER_SPECS, msg)
    for _, spec in ipairs(listOfObjects) do
        if spec.Active == "1" then
            for _, pointStruct in ipairs(spec.TalentPoints) do
                TreeCache.Points[pointStruct.CharacterPointType] = pointStruct.AvailablePoints
                TalentTree.MaxPoints[pointStruct.CharacterPointType] = pointStruct.Earned
            end
        else
            table.insert(TalentTree.FORGE_SPEC_SLOTS, spec)
        end
    end

    if TalentTree.FORGE_SELECTED_TAB then
        if TalentTree.FORGE_SELECTED_TAB ~= TreeCache.PrimaryClass then
            if TalentTree.FORGE_SELECTED_TAB > 0 and TalentTree.FORGE_SELECTED_TAB == TreeCache.SecondaryClass then
                ActivateTab(TreeCache.SecondaryClass)
            else
                if TalentTreeWindow.body.tabs.tab[2] then
                    ActivateTab(TreeCache.PrimaryClass)
                    TalentTreeWindow.body.tabs.tab[2]:GetScript("OnClick")(TalentTreeWindow.body.tabs.tab[2], 'LeftButton')
                else
                    ActivateTab(TreeCache.PrimaryClass)
                end
            end
        else
            ActivateTab(TreeCache.PrimaryClass)
        end
    else
        ActivateTab(TreeCache.PrimaryClass)
    end

    local selectedTab = TalentTree.FORGE_TABS[TalentTree.FORGE_SELECTED_TAB]
    if not selectedTab then
        selectedTab = TalentTree.FORGE_TABS[TreeCache.PrimaryClass]
    end

    if TalentTree.INITIALIZED and TalentTree.FORGE_SELECTED_TAB then
        DrawTalentPoints(selectedTab.TalentType, TalentTree.FORGE_SELECTED_TAB)
    end
    TalentTree.INITIALIZED = true
end

function CreateATab(parent, titleText, id)
    local tab = CreateFrame("BUTTON", id..titleText, parent)
    tab:SetHighlightTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]], "ADD")
    tab:SetBackdrop(
        {
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            insets = {top = 1, left = 1, bottom = 1, right = 1},
            edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
            tileEdge = false,
            edgeSize = .5
        }
    )
    tab:SetBackdropColor(0, 0, 0, .75)
    tab:SetBackdropBorderColor(188 / 255, 150 / 255, 28 / 255, .6)
    tab.Id = id

    tab.title = tab:CreateFontString("OVERLAY")
    tab.title:SetPoint("CENTER", tab, "CENTER")
    tab.title:SetFont("Fonts\\FRIZQT__.TTF", 8)
    tab.title:SetText(titleText)
    tab.title:SetTextColor(188 / 255, 150 / 255, 28 / 255, 1)

    tab:SetSize(tab.title:GetStringWidth() + TT_SETTINGS.headerheight, parent:GetHeight())
    return tab
end

--Testing--
TalentLoadoutCache = TalentTree.TalentLoadoutCache

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
