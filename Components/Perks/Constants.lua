PATH = "Interface\\AddOns\\ForgedWoWCommunication\\UI\\"
settings = {
    selectionIconSize = 60,
    iconsPerRow = 9,
    gap = 12,
    width = GetScreenWidth() / 2.18,
    height = GetScreenHeight() / 1.4,
    tabCount = 2,
    header = 30
}

assets = {
    rankone = PATH .. "Perk\\rank1",
    ranktwo = PATH .. "Perk\\rank2",
    rankthree = PATH .. "Perk\\rank3",
    hourglass = PATH .. "Perk\\hourglass",
    highlight = PATH .. "Perk\\highlight",
    minimize = "Interface\\BUTTONS\\UI-Panel-SmallerButton-Up",
    minPushed = "Interface\\BUTTONS\\UI-Panel-SmallerButton-Down",
    maximize = "Interface\\BUTTONS\\UI-Panel-BiggerButton-Up",
    maxPushed = "Interface\\BUTTONS\\UI-Panel-BiggerButton-Down"
}

PerkExplorerInternal = {
    PERKS_SPEC = {},
    PERKS_ALL = {},
    PERKS_SEARCH = {}
}

perkTooltip = CreateFrame("GameTooltip", "perkTooltip", UIParent, "GameTooltipTemplate")

-- perkBG:SetBackdropColor(0, 0, 1, .5)
lastSelectedSpell = 0
StaticPopupDialogs["REROLL_PERK"] = {
    text = "Are you sure you want to reroll %s?",
    button1 = "Yes",
    button2 = "No",
    spellId = "%s",
    spellName = "%s",
    OnAccept = function(_)
        PushForgeMessage(ForgeTopic.REROLL_PERK, "1;" .. lastSelectedSpell)
    end,
    sound = "levelup2",
    timeout = 30,
    whileDead = true,
    hideOnEscape = true
}

PerkDeserializerDefinitions = {
    PERKSEL = {
        OBJECT = "*",
        FIELDS = {
            DELIMITER = "^",
            FIELDS = {
                {
                    NAME = "SpellId"
                },
                {
                    NAME = "carryover",
                    TYPE = FieldType.NUMBER
                }
            }
        }
    },
    PERKCHAR = {
        OBJECT = ";",
        FIELDS = {
            DELIMITER = "^",
            FIELDS = {
                {
                    NAME = "SpecId"
                },
                {
                    NAME = "Perk",
                    OBJECT = "*",
                    FIELDS = {
                        DELIMITER = "&",
                        FIELDS = {
                            {
                                NAME = "spellId"
                            },
                            {
                                NAME = "Meta",
                                OBJECT = "@",
                                FIELDS = {
                                    DELIMITER = "~",
                                    FIELDS = {
                                        {
                                            NAME = "classMask",
                                            TYPE = FieldType.NUMBER
                                        },
                                        {
                                            NAME = "group",
                                            TYPE = FieldType.NUMBER
                                        },
                                        {
                                            NAME = "isAura",
                                            TYPE = FieldType.NUMBER
                                        },
                                        {
                                            NAME = "unique",
                                            TYPE = FieldType.NUMBER
                                        },
                                        {
                                            NAME = "tags"
                                        },
                                        {
                                            NAME = "rank",
                                            TYPE = FieldType.NUMBER
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    },
    PERKCAT = {
        OBJECT = ";",
        FIELDS = {
            FIELDS = {
                {
                    NAME = "Perk",
                    OBJECT = "*",
                    FIELDS = {
                        DELIMITER = "&",
                        FIELDS = {
                            {
                                NAME = "spellId"
                            },
                            {
                                NAME = "Meta",
                                OBJECT = "@",
                                FIELDS = {
                                    DELIMITER = "~",
                                    FIELDS = {
                                        {
                                            NAME = "classMask",
                                            TYPE = FieldType.NUMBER
                                        },
                                        {
                                            NAME = "group",
                                            TYPE = FieldType.NUMBER
                                        },
                                        {
                                            NAME = "isAura",
                                            TYPE = FieldType.NUMBER
                                        },
                                        {
                                            NAME = "unique",
                                            TYPE = FieldType.NUMBER
                                        },
                                        {
                                            NAME = "tags"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
