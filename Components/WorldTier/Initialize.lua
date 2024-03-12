function InitWorldTierSelect()
    createWorldTierSelectWindow()
    CreateWorldTierDisplay()
    PushForgeMessage(ForgeTopic.SET_WORLD_TIER, "?")
end
