EXPLORER_CACHE = {
    selected = "Your Perks"
}

function InitializePerkExplorer()
    if (PerkExplorer) then
        return
    end
    local perkBtnWidth = CharacterModelFrame:GetWidth() / 4
    local perkBtnHeight = perkBtnWidth / 5
    PerkExplorerButton =
        CreateEchosButton(PerkExplorerButton, CharacterModelFrame, perkBtnWidth, perkBtnHeight, "Show Perks", 12)
    PerkExplorerButton:SetPoint("TOP", 0, perkBtnHeight)
    PerkExplorerButton:SetScript(
        "OnLeave",
        function()
            if not PerkExplorer.body:IsVisible() then
                PerkExplorerButton.title:SetTextColor(188 / 255, 150 / 255, 28 / 255, 1)
            else
                PerkExplorerButton.title:SetTextColor(255 / 255, 255 / 255, 255 / 255, 1)
            end
        end
    )
    PerkExplorerButton:SetScript(
        "OnClick",
        function()
            ToggleBox(PerkExplorer.body:IsVisible())
        end
    )

    PerkExplorer = CreateFrame("FRAME", "PerkExplorer", nil)
    PerkExplorer:SetSize(400, 300)
    PerkExplorer:SetPoint("CENTER", 0, 0)
    PerkExplorer:SetFrameStrata("DIALOG")
    PerkExplorer:SetToplevel(true)
    PerkExplorer:EnableMouse(true)
    PerkExplorer:SetMovable(true)
    PerkExplorer:SetClampedToScreen(true)
    PerkExplorer:RegisterEvent("UNIT_LEVEL")
    PerkExplorer:SetScript(
        "OnEvent",
        function()
            PushForgeMessage(ForgeTopic.OFFER_SELECTION, GetSpecID())
        end
    )
    PerkExplorer:SetBackdrop(
        {
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            insets = {top = 1, left = 1, bottom = 1, right = 1},
            edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
            tileEdge = false,
            edgeSize = 1
        }
    )
    PerkExplorer:SetBackdropColor(0, 0, 0, .75)
    PerkExplorer:SetBackdropBorderColor(188 / 255, 150 / 255, 28 / 255, .6)

    PerkExplorer.header = CreateFrame("BUTTON", nil, PerkExplorer)
    PerkExplorer.header:SetSize(PerkExplorer:GetWidth(), TT_SETTINGS.headerheight)
    PerkExplorer.header:SetPoint("TOP", 0, 0)
    PerkExplorer.header:SetFrameLevel(4)
    PerkExplorer.header:EnableMouse(true)
    PerkExplorer.header:RegisterForClicks("AnyUp", "AnyDown")
    PerkExplorer.header:SetScript(
        "OnMouseDown",
        function()
            PerkExplorer:StartMoving()
        end
    )
    PerkExplorer.header:SetScript(
        "OnMouseUp",
        function()
            PerkExplorer:StopMovingOrSizing()
        end
    )

    local buttonsize = TT_SETTINGS.headerheight*.75
    local topPadding = TT_SETTINGS.headerheight/4

    PerkExplorer.header.close = CreateFrame("BUTTON", "InstallCloseButton", PerkExplorer.header, "UIPanelCloseButton")
    PerkExplorer.header.close:SetSize(buttonsize, buttonsize)
    PerkExplorer.header.close:SetNormalTexture(CONSTANTS.ASSETS.STOP)
    PerkExplorer.header.close:SetPushedTexture(CONSTANTS.ASSETS.STOP)
    PerkExplorer.header.close:SetPoint("RIGHT", PerkExplorer.header, "RIGHT", -topPadding, 0)
    PerkExplorer.header.close:SetScript(
        "OnClick",
        function()
            ToggleBox(PerkExplorer.body:IsVisible())
        end
    )
    PerkExplorer.header.close:SetFrameLevel(PerkExplorer.header:GetFrameLevel() + 2)

    PerkExplorer.header.title = PerkExplorer.header:CreateFontString("OVERLAY")
    PerkExplorer.header.title:SetPoint("CENTER", PerkExplorer.header, "CENTER")
    PerkExplorer.header.title:SetFont("Fonts\\FRIZQT__.TTF", 9)
    PerkExplorer.header.title:SetText("Perk Explorer")
    PerkExplorer.header.title:SetTextColor(188 / 255, 150 / 255, 28 / 255, 1)

    PerkExplorer.body = CreateFrame("FRAME", "PerkExplorerBody", PerkExplorer)
    PerkExplorer.body:SetPoint("TOP", 0, -TT_SETTINGS.headerheight)
    PerkExplorer.body:SetSize(PerkExplorer:GetWidth()-2, PerkExplorer:GetHeight()-TT_SETTINGS.headerheight-2)

    PerkExplorer.body.subheader = CreateFrame("FRAME", nil, PerkExplorer.body)
    PerkExplorer.body.subheader:SetSize(PerkExplorer.body:GetWidth(), TT_SETTINGS.headerheight)
    PerkExplorer.body.subheader:SetPoint("TOP", 0, 0)

    -- createArchtype()
    createYourPerks()
    createCatalog()
    ToggleBox(true)
end

function createYourPerks()
    PerkExplorer.body.subheader.yourPerksTab = CreateTab("Your Perks")
    PerkExplorer.body.subheader.yourPerksTab:SetPoint("TOPLEFT", 0, 0)
    PerkExplorer.body.subheader.yourPerksTab:SetScript(
        "OnClick",
        function()
            PerkExplorer.body.subheader.yourPerksTab:SetButtonState("PUSHED", 1)
            PerkExplorer.body.subheader.catalogue:SetButtonState("NORMAL")
            EXPLORER_CACHE.selected = "Your Perks"
            PerkExplorer.body.subheader.catalogue.title:SetTextColor(188 / 255, 150 / 255, 28 / 255, 1)
            PerkExplorer.body.subheader.yourPerksTab.title:SetTextColor(1, 1, 1, 1)
            PerkExplorer.body.perkbox:Show()
            PerkExplorer.body.catalogue:Hide()
        end
    )
    PerkExplorer.body.subheader.yourPerksTab:SetButtonState("PUSHED", 1)

    -- PERKS LIST
    PerkExplorer.body.perkbox = CreateFrame("FRAME", nil, PerkExplorer.body)
    PerkExplorer.body.perkbox:SetSize(PerkExplorer.body:GetWidth()-2, PerkExplorer.body:GetHeight()-TT_SETTINGS.headerheight-2)
    PerkExplorer.body.perkbox:SetPoint("TOP", 0, -TT_SETTINGS.headerheight)
    PerkExplorer.body.perkbox:SetFrameLevel(PerkExplorer.body:GetFrameLevel() + 2)

    PerkExplorer.body.perkbox.yourPerks = CreateFrame("FRAME", nil, PerkExplorer.body.perkbox)
    PerkExplorer.body.perkbox.yourPerks:SetSize(settings.width, settings.height)
    PerkExplorer.body.perkbox.yourPerks:SetPoint("TOP", 0, 0)
    PerkExplorer.body.perkbox.yourPerks:SetFrameLevel(PerkExplorer.body.perkbox:GetFrameLevel() + 2)

    PerkExplorer.body.perkbox.yourPerks.perks = {}
    local iconSize = (PerkExplorer.body.perkbox:GetWidth() - (settings.iconsPerRow+2)*settings.gap) / (settings.iconsPerRow)
    local depth = iconSize
    for i = 1, 40 do
        local num = (i - 1) % settings.iconsPerRow + 1
        if num == 1 then
            depth = depth - (settings.gap + iconSize)
        end

        local iconFrame = CreateFrame("BUTTON", "iconFrame" .. i, PerkExplorer.body.perkbox)
        iconFrame:SetHighlightTexture("")
        iconFrame:SetFrameLevel(PerkExplorer.body:GetFrameLevel() + 2)
        iconFrame:SetSize(iconSize, iconSize)
        iconFrame:SetPoint("TOPLEFT", settings.gap * (num) + (num - 1) * iconSize, depth)

        local texture = iconFrame:CreateTexture(nil, "ARTWORK")
        texture:SetAllPoints(iconFrame)
        texture:SetSize(iconSize, iconSize)

        local border = CreateFrame("Frame","PerkExplorer.body.perkbox.yourPerks.perks["..i.."].Border", iconFrame)
        border:SetFrameLevel(iconFrame:GetFrameLevel() +1)
        border:SetPoint("CENTER", 0, 0)
        border:SetSize(iconSize * 1.4, iconSize * 1.4)

        iconFrame.Border = border
        iconFrame.Texture = texture
        PerkExplorer.body.perkbox.yourPerks.perks[i] = iconFrame
        iconFrame:Hide()
    end
end

function createCatalog()
    -- CATALOGUE TAB
    PerkExplorer.body.subheader.catalogue = CreateTab("Perk Catalogue") -- CreateFrame("BUTTON", nil, PerkExplorer.body.subheader)
    PerkExplorer.body.subheader.catalogue:SetPoint("TOPRIGHT", 0, 0)
    PerkExplorer.body.subheader.catalogue:SetScript(
        "OnClick",
        function()
            PerkExplorer.body.subheader.catalogue:SetButtonState("PUSHED", 1)
            PerkExplorer.body.subheader.yourPerksTab:SetButtonState("NORMAL")
            EXPLORER_CACHE.selected = "Perk Catalogue"
            PerkExplorer.body.subheader.yourPerksTab.title:SetTextColor(188 / 255, 150 / 255, 28 / 255, 1)
            PerkExplorer.body.subheader.catalogue.title:SetTextColor(1, 1, 1, 1)
            PerkExplorer.body.catalogue:Show()
            PerkExplorer.body.perkbox:Hide()
        end
    )

    PerkExplorer.body.catalogue = CreateFrame("FRAME", nil, PerkExplorer.body)
    PerkExplorer.body.catalogue:SetSize(PerkExplorer.body:GetWidth()-2, PerkExplorer.body:GetHeight()-TT_SETTINGS.headerheight-2)
    PerkExplorer.body.catalogue:SetPoint("TOP", 0, -TT_SETTINGS.headerheight)

    PerkExplorer.body.catalogue.searchBar = CreateFrame("EditBox", "PerkExplorer.body.catalogue.searchBar", PerkExplorer.body.catalogue)
    PerkExplorer.body.catalogue.searchBar:SetSize(PerkExplorer.body.catalogue:GetWidth()/2, TT_SETTINGS.headerheight-4)
    PerkExplorer.body.catalogue.searchBar:SetPoint("TOPRIGHT", -5, 0)
    PerkExplorer.body.catalogue.searchBar:SetMultiLine(false)
    PerkExplorer.body.catalogue.searchBar:SetFontObject(ChatFontNormal)
    PerkExplorer.body.catalogue.searchBar:SetWidth(PerkExplorer.body.catalogue:GetWidth()/2)
    PerkExplorer.body.catalogue.searchBar:SetFont("Fonts\\ARIALN.TTF", 9)
    PerkExplorer.body.catalogue.searchBar:SetMaxLetters(32)
    PerkExplorer.body.catalogue.searchBar:SetAutoFocus(false)
    PerkExplorer.body.catalogue.searchBar:SetScript(
        "OnTextChanged",
        function(self, input)
            if (input) then
                LoadAllPerksList(string.upper(self:GetText()))
            end
        end
    )
    PerkExplorer.body.catalogue.searchBar:SetScript(
        "OnEscapePressed",
        function(self, _)
            self:ClearFocus()
        end
    )
    PerkExplorer.body.catalogue.searchBar:SetBackdrop(
         {
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            insets = {top = 0, left = 0, bottom = 0, right = 0},
            edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeSize = 1,
            tile = false
        }
    )
    PerkExplorer.body.catalogue.searchBar:SetBackdropColor(0, 0, 0, .6)
    PerkExplorer.body.catalogue.searchBar:SetBackdropBorderColor(188 / 255, 150 / 255, 28 / 255, .6)

    searchtexBox = PerkExplorer.body.catalogue.searchBar:CreateTexture("", "BACKGROUND")
    searchtexBox:SetPoint("CENTER", PerkExplorer.body.catalogue.searchBar, "CENTER", 0, 0)
    searchtexBox:SetSize(PerkExplorer.body.catalogue.searchBar:GetWidth()-4, TT_SETTINGS.headerheight-2)

    -- PerkExplorer.body.catalogue.dropdown =
    --     CreateFrame("Frame", "classFilterDropdown", PerkExplorer.body.catalogue, "UIDropDownMenuTemplate")
    -- PerkExplorer.body.catalogue.dropdown:SetPoint("TOPRIGHT", -125, 0)
    -- PerkExplorer.body.catalogue.dropdown.classFilters = {
    --     {
    --         text = "Warrior",
    --         value = 1
    --     },
    --     {
    --         text = "Paladin",
    --         value = 2
    --     },
    --     {
    --         text = "Hunter",
    --         value = 3
    --     },
    --     {
    --         text = "Rogue",
    --         value = 4
    --     },
    --     {
    --         text = "Priest",
    --         value = 5
    --     },
    --     {
    --         text = "Death Knight",
    --         value = 6
    --     },
    --     {
    --         text = "Shaman",
    --         value = 7
    --     },
    --     {
    --         text = "Mage",
    --         value = 8
    --     },
    --     {
    --         text = "Warlock",
    --         value = 9
    --     },
    --     {
    --         text = "Druid",
    --         value = 11
    --     }
    -- }

    -- PerkExplorer.body.catalogue.dropdown.choice = 0

    -- UIDropDownMenu_Initialize(
    --     PerkExplorer.body.catalogue.dropdown,
    --     function(self, _, _) --level, menuList
    --         for _, item in ipairs(self.classFilters) do
    --             local info = UIDropDownMenu_CreateInfo()
    --             info.text = item.text
    --             info.value = item.value
    --             info.func = function(self)
    --                 if (PerkExplorer.body.catalogue.dropdown.choice == item.value) then
    --                     PerkExplorer.body.catalogue.dropdown.choice = 0
    --                     UIDropDownMenu_SetSelectedID(PerkExplorer.body.catalogue.dropdown, -1)
    --                     UIDropDownMenu_SetText(PerkExplorer.body.catalogue.dropdown, " ")
    --                 else
    --                     PerkExplorer.body.catalogue.dropdown.choice = item.value
    --                     UIDropDownMenu_SetSelectedID(PerkExplorer.body.catalogue.dropdown, self:GetID())
    --                     UIDropDownMenu_SetText(PerkExplorer.body.catalogue.dropdown, item.text)
    --                 end
    --                 CloseDropDownMenus()
    --                 LoadAllPerksList(PerkExplorer.body.catalogue.searchBar:GetText())
    --             end
    --             UIDropDownMenu_AddButton(info)
    --         end
    --     end
    -- )
    -- ToggleDropDownMenu(1, nil, PerkExplorer.body.catalogue.dropdown, "cursor", 0, 0)

    PerkExplorer.body.catalogue.clipframe = CreateFrame("FRAME", nil, PerkExplorer.body.catalogue)
    PerkExplorer.body.catalogue.clipframe:SetSize(PerkExplorer.body.catalogue:GetWidth(), PerkExplorer.body.catalogue:GetHeight())
    PerkExplorer.body.catalogue.clipframe:SetPoint("TOP", 0, 0)

    PerkExplorer.body.catalogue.clipframe.scroll =
        CreateFrame("ScrollFrame", "perkScroll", PerkExplorer.body.catalogue.clipframe, "UIPanelScrollFrameTemplate")
    PerkExplorer.body.catalogue.clipframe.scroll:SetPoint("TOPLEFT", 0, -TT_SETTINGS.headerheight)

    PerkExplorer.body.catalogue.clipframe.scroll:SetPoint("BOTTOMRIGHT", -(TT_SETTINGS.headerheight*1.5) +2, 0)

    local scrollcat = CreateFrame("FRAME")
    scrollcat:SetSize(1, 1)
    scrollcat.perks = {}
    PerkExplorer.body.catalogue.clipframe.scroll:SetScrollChild(scrollcat)
    PerkExplorer.body.catalogue:Hide()
end

function CreateTab(titleText)
    local tab = CreateFrame("BUTTON", nil, PerkExplorer.body.subheader)
    tab:SetSize(PerkExplorer.body:GetWidth() / 2, PerkExplorer.body.subheader:GetHeight())

    tab.title = tab:CreateFontString("OVERLAY")
    tab.title:SetPoint("CENTER", tab, "CENTER")
    tab.title:SetFont("Fonts\\FRIZQT__.TTF", 9)
    tab.title:SetText(titleText)

    if EXPLORER_CACHE.selected == titleText then
        tab.title:SetTextColor(1, 1, 1, 1)
    else
        tab.title:SetTextColor(188 / 255, 150 / 255, 28 / 255, 1)
    end
    tab:SetScript("OnEnter", function() 
        tab.title:SetTextColor(1, 1, 1, 1)
    end)
    tab:SetScript("OnLeave", function()
        if (EXPLORER_CACHE.selected ~= titleText) then
            tab.title:SetTextColor(188 / 255, 150 / 255, 28 / 255, 1)
        end
    end)

    return tab
end

function ToggleBox(visible)
    if (visible) then
        PerkExplorerButton.title:SetTextColor(188 / 255, 150 / 255, 28 / 255, 1)
        PerkExplorer:Hide()
    else
        PerkExplorer:Show()
    end
end

function LoadAllPerksList(filterText)
    local iconsPerRow = 9
    local columnID = 1
    --local depth = iconSize
    local iconSize = (PerkExplorer.body.perkbox:GetWidth() - (settings.iconsPerRow+2)*settings.gap) / (settings.iconsPerRow)
    local depth = iconSize
    local perkFrame = PerkExplorer.body.catalogue.clipframe.scroll:GetScrollChild()
    for _, v in ipairs(perkFrame.perks) do
        v:Hide()
    end

    local i = 1
    for spellId, meta in pairs(PerkExplorerInternal.PERKS_ALL) do
        local metainfo = meta[1]
        local name, _, icon = GetSpellInfo(spellId)

        if (columnID > iconsPerRow) then
            columnID = 1
        end
        if name then
            if
                (string.match(string.upper(name), filterText) or filterText == "") --and
            --         isBitFlipped(tonumber(metainfo["classMask"]), PerkExplorer.body.catalogue.dropdown.choice))
            then
                if (not perkFrame.perks[i]) then
                    perkFrame.perks[i] = CreateFrame("BUTTON", perkFrame.perks[i], perkFrame)
                    perkFrame.perks[i]:SetHighlightTexture("")
                    perkFrame.perks[i]:SetFrameLevel(perkFrame:GetFrameLevel())
                    perkFrame.perks[i]:SetSize(iconSize, iconSize)
                    perkFrame.perks[i]:SetPoint(
                        "TOPLEFT",
                        settings.gap * columnID + (columnID - 1) * iconSize ,
                        iconSize - math.ceil(i / iconsPerRow) * (iconSize + 5)
                    )
                    perkFrame.perks[i].Texture = perkFrame.perks[i]:CreateTexture()
                    perkFrame.perks[i].Texture:SetAllPoints()
                    perkFrame.perks[i].Texture:SetPoint("CENTER", 0, 0)
                end
                perkFrame.perks[i].Texture:SetTexture(icon)
 
                perkFrame.perks[i]:SetScript(
                    "OnEnter",
                    function()
                        local side, _, _, xOfs = PerkExplorer:GetPoint()
                        if
                            (side == "LEFT" or
                                ((xOfs > -(GetScreenWidth() * .1879) and xOfs < 0) and side == "CENTER"))
                         then
                            SetUpSingleTooltip(PerkExplorer.body.perkbox, spellId, "ANCHOR_RIGHT", metainfo.unique)
                        else
                            SetUpSingleTooltip(PerkExplorer.body.perkbox, spellId, "ANCHOR_LEFT", metainfo.unique)
                        end
                    end
                )
                perkFrame.perks[i]:SetScript(
                    "OnLeave",
                    function()
                        clearTooltips()
                    end
                )
                perkFrame.perks[i]:Show()
                columnID = columnID + 1
                i = i + 1
            end
        end
    end
end

function GetTypeBorderColor(maxRank)
    if maxRank > 1 then
        return 111/255, 237/255, 183/255, 1
    else
        return 247/255, 175/255, 157/255, 1
    end
end

function LoadCurrentPerks(_) --spec
    HideCharPerks()
    local i = 1
    for _, perk in ipairs(PerkExplorerInternal.PERKS_SPEC) do --specId, perk
        for spellId, meta in pairs(perk) do
            local name, _, icon = GetSpellInfo(spellId)
            local rank = meta[1].rank
            local current = PerkExplorer.body.perkbox.yourPerks.perks[i]
            if current then
                SetRankTexture(current, rank)
                SetPortraitToTexture(current.Texture, icon)

                current.Border:SetBackdrop({
                    bgFile = CONSTANTS.UI.BORDER_SPELL
                })
                current.Border:SetBackdropColor(GetTypeBorderColor(meta[1].unique))

                current:HookScript(
                    "OnEnter",
                    function()
                        local side, _, _, xOfs = PerkExplorer:GetPoint()
                        if (side == "LEFT" or ((xOfs > -(GetScreenWidth() * .1879) and xOfs < 0) and side == "CENTER")) then
                            SetUpSingleTooltip(PerkExplorer.body.perkbox, spellId, "ANCHOR_RIGHT", meta[1].unique)
                        else
                            SetUpSingleTooltip(PerkExplorer.body.perkbox, spellId, "ANCHOR_LEFT", meta[1].unique)
                        end
                    end
                )
                current:SetScript(
                    "OnLeave",
                    function()
                        clearTooltips()
                    end
                )
                current:SetScript(
                    "OnClick",
                    function()
                        lastSelectedSpell = spellId
                        StaticPopup_Show("REROLL_PERK", name)
                    end
                )
                current:Show()
                i = i + 1
            end
        end
    end
end

function HideCharPerks()
    for i = 1, 40, 1 do
        PerkExplorer.body.perkbox.yourPerks.perks[i]:Hide()
    end
end

function isBitFlipped(mask, bitPosition)
    if (bitPosition == 0) then
        return true
    end
    local shifted = 2 ^ (bitPosition - 1)
    return mask % (shifted * 2) >= shifted
end
