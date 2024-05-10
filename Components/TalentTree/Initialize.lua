Util = {
    alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
}

function ToggleTalentFrame(openPet)
    if openPet and HasPetUI() and PetCanBeAbandoned() then
        TalentFrame_LoadUI()
        if (PlayerTalentFrame_Toggle) then
            PlayerTalentFrame_Toggle(true, 3)
        end
    else
        ToggleMainWindow()
    end
end

function TalentFrame_LoadUI() -- kill default frame load :)
end

function PlayerTalentFrame_Toggle(pet, suggestedTalentGroup)
    ToggleMainWindow();
end

function InitializeTalentTree()
    InitTalents()
    FirstRankToolTip = CreateFrame("GameTooltip", "firstRankToolTip", WorldFrame, "GameTooltipTemplate")
    FirstRankToolTip:SetBackdrop(
        {
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            insets = {top = 0, left = 0, bottom = 0, right = 0},
            edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeSize = 1,
            tile = false
        }
    )
    FirstRankToolTip:SetBackdropColor(0, 0, 0, .75)
    FirstRankToolTip:SetBackdropBorderColor(188 / 255, 150 / 255, 28 / 255, .6)

    SecondRankToolTip = CreateFrame("GameTooltip", "secondRankToolTip", WorldFrame, "GameTooltipTemplate")
    SecondRankToolTip:SetBackdrop(
        {
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            insets = {top = 0, left = 0, bottom = 0, right = 0},
            edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeSize = 1,
            tile = false
        }
    )
    SecondRankToolTip:SetBackdropColor(0, 0, 0, .75)
    SecondRankToolTip:SetBackdropBorderColor(188 / 255, 150 / 255, 28 / 255, .6)

    SubscribeToForgeTopic(
        ForgeTopic.TalentTree_LAYOUT,
        function(msg)
            LoadTalentTreeLayout(msg)
        end
    )
    PushForgeMessage(ForgeTopic.TalentTree_LAYOUT, "-1")
    SubscribeToForgeTopic(
        ForgeTopic.GET_CHARACTER_SPECS,
        function(msg)
            LoadCharacterSpecs(msg)
        end
    )
    PushForgeMessage(ForgeTopic.GET_CHARACTER_SPECS, "-1")

    SubscribeToForgeTopic(
        ForgeTopic.LEARN_TALENT_ERROR,
        function(msg)
            print("Talent Learn Error: " .. msg)
        end
    )

    PushForgeMessage(ForgeTopic.GET_TALENTS, "-1")
end



--local onUpdateFrame = CreateFrame("Frame")
SubscribeToForgeTopic(
    ForgeTopic.GET_TALENTS,
    function(msg)
        LoadTalentString(msg);
    end
)

function RevertAllTalents()
    -- only here to make sure no one presses anything during (somehow)
    TalentTreeWindow:Hide()
    ClassSpecWindow:Show()
    ClassSpecWindow.Lockout:Show()

    for index, rank in ipairs(TreeCache.Spells[tostring(SELECTED_SPEC)]) do
        if rank > 0 then
            local location = TreeCache.IndexToFrame[tostring(SELECTED_SPEC)][index]
            local frame = TalentTreeWindow.GridTalent.Talents[location.row][location.col]
            frame:GetScript("OnUpdate")()
            frame:GetScript("OnMouseDown")(frame, "RightButton")
        end
    end

    ClassSpecWindow.Lockout:Hide()
    TalentTreeWindow:Show()
    ClassSpecWindow:Hide()
end

SubscribeToForgeTopic(
    ForgeTopic.ACTIVATE_CLASS_SPEC,
    function(msg)
        --print(msg)
        ClassSpecWindow.Lockout:Hide()
    end
)

function aLoadTalentString(msg)
    RevertAllTalents()
    local type, _ = string.find(Util.alpha, string.sub(msg, 1, 1))
    local spec, _ = string.find(Util.alpha, string.sub(msg, 2, 2))

    if
        type - 1 == tonumber(CharacterPointType.TALENT_SKILL_TREE) and string.len(msg) > 3 and
            tonumber(spec) == tonumber(TalentTree.FORGE_SELECTED_TAB.Id)
     then
        if not TreeCache.PreviousString[type] then
            TreeCache.PreviousString[type] = "empty :)"
        end
        
        if not TalentTree.FORGE_TALENTS then
            TalentTree.FORGE_TALENTS = {}
        end

        local specTreeLen = 0
        if TreeCache.Spells[tostring(spec)] then
            specTreeLen = #TreeCache.Spells[tostring(spec)]
        end

        -- ZERO EVERY STRUCT
        TreeCache.Points[tostring(type - 1)] = TalentTree.MaxPoints[tostring(type - 1)]
        TreeCache.PointsSpent[tostring(spec)] = 0

        if type - 1 == 0 then
            TreeCache.Points["7"] = TalentTree.MaxPoints["7"]
            TreeCache.PointsSpent["7"] = 0
        end

        for i = 0, 50, 5 do
            TreeCache.Investments[tostring(spec)][i] = 0
            TreeCache.Investments[TalentTree.ClassTree][i] = 0
            TreeCache.TotalInvests[i] = 0
        end

        SelectTab(TalentTree.FORGE_TABS[spec])

        local nodeInd = 1
        local classBlock = 3 + classTreeLen
        if (4 >= classBlock) then
            local classString = string.sub(msg, 4, classBlock)
            for i = 1, classTreeLen, 1 do
                TreeCache.Spells[TalentTree.ClassTree][nodeInd] = 0
                local rank = string.find(Util.alpha, string.sub(classString, i, i)) - 1
                for j = 1, rank, 1 do
                    local location = TreeCache.IndexToFrame[TalentTree.ClassTree][nodeInd]
                    local frame = TalentTreeWindow.GridTalent.Talents[location.row][location.col]
                    frame:GetScript("OnUpdate")()
                    frame:GetScript("OnMouseDown")(frame, "LeftButton")
                end
                nodeInd = nodeInd + 1
            end
        end

        local specBlock = classBlock + specTreeLen
        --print("starts: "..(classBlock+1).." ends: "..specBlock)
        nodeInd = 1
        local specString = string.sub(msg, classBlock + 1, specBlock)
        for i = 1, specTreeLen, 1 do
            TreeCache.Spells[tostring(spec)][nodeInd] = 0
            local rank = string.find(Util.alpha, string.sub(specString, i, i)) - 1
            for j = 1, rank, 1 do
                local location = TreeCache.IndexToFrame[tostring(spec)][nodeInd]
                local frame = TalentTreeWindow.GridTalent.Talents[location.row][location.col]
                frame:GetScript("OnUpdate")()
                frame:GetScript("OnMouseDown")(frame, "LeftButton")
            end
            nodeInd = nodeInd + 1
        end

        TreeCache.PreviousString[type] = msg
    end
    --end
end

SubscribeToForgeTopic(
    ForgeTopic.GET_LOADOUTS,
    function(msg)
        local listOfObjects = DeserializeMessage(DeserializerDefinitions.GET_LOADOUTS, msg)
        for _, obj in ipairs(listOfObjects) do
            if not TalentTree.TalentLoadoutCache[obj.spec] then
                TalentTree.TalentLoadoutCache[obj.spec] = {}
            end

            for _, loadout in ipairs(obj.loadouts) do
                local item = {
                    name = loadout.name,
                    loadout = loadout.talents
                }

                TalentTree.TalentLoadoutCache[obj.spec][loadout.id] = item
                if loadout.active > 0 and obj.spec == TalentTree.FORGE_SELECTED_TAB.Id then
                    ApplyLoadoutAndUpdateCurrent(loadout.id)
                end
            end
        end
    end
)

function GetClassId(classString)
    if classString == "Warrior" then
        return 1
    elseif classString == "Paladin" then
        return 2
    elseif classString == "Hunter" then
        return 3
    elseif classString == "Rogue" then
        return 4
    elseif classString == "Priest" then
        return 5
    elseif classString == "Death Knight" then
        return 6
    elseif classString == "Shaman" then
        return 7
    elseif classString == "Mage" then
        return 8
    elseif classString == "Warlock" then
        return 9
    else
        return 11
    end
end
