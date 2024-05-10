function CreateRankedTooltip(id, parent, tt, depth, width, anchor, unique)
    if not GetSpellInfo(id) then
        tt:ClearLines()
        tt:SetSize(0, 0)
        tt:Hide()
        return
    end
    tt:SetOwner(parent, anchor, -2, -1 * depth)
    tt:SetHyperlink("spell:" .. id) 
    if unique == 1 then
        tt:AddLine("")
        tt:AddLine("|cffF7AF9DUnique\124r")
    else
        tt:AddLine("")
        tt:AddLine("|cff6FEDB7Stackable\124r")
    end


    tt:SetHeight(tt:GetHeight() + 10)

    if width == 0 then
        tt:SetSize(tt:GetWidth(), tt:GetHeight())
    else
        tt:SetSize(width, tt:GetHeight())
    end
end

function SetUpRankedTooltip(parent, id, anchor)
    CreateRankedTooltip(id, parent, perkTooltip, 0, 0, anchor, 0)
end

function SetUpSingleTooltip(parent, id, anchor, maxrank)
    CreateRankedTooltip(id, parent, perkTooltip, 0, 0, anchor, maxrank)
end

function clearTooltips()
    perkTooltip:ClearLines(0)
    perkTooltip:SetSize(0, 0)
    perkTooltip:Hide()
end

function SetRankTexture(current, rank)
    if not current.Border.Rank then
        current.Border.Rank = current.Border:CreateFontString("OVERLAY")
    end
    current.Border.Rank:SetSize(current:GetWidth(), current:GetHeight() / 3)
    current.Border.Rank:SetPoint("TOPLEFT", 0, 0)
    current.Border.Rank:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    current.Border.Rank:SetTextColor(1, 1, 1, 1)
    current.Border.Rank:SetText("Lv. "..rank)
end
