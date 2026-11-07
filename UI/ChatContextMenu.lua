local addon = Rolodex

function addon.UI:OpenPlayerContextMenu(playerName)
    if type(UnitPopupManager) ~= "table"
        or type(UnitPopupManager.OpenMenu) ~= "function" then
        addon:Print("Unable to open the player context menu; the WoW menu API is unavailable.")
        return
    end

    UnitPopupManager:OpenMenu("FRIEND", {
        name = playerName,
    })
end

local function AddCandidate(candidates, seen, name)
    if type(name) == "string" and name ~= "" and not seen[name] then
        seen[name] = true
        candidates[#candidates + 1] = name
    end
end

local function FindPlayerRecord(contextData)
    if type(contextData) ~= "table" then
        return nil
    end

    local name = contextData.name
    local server = contextData.server or contextData.realm
    if contextData.unit and UnitName then
        local unitName, unitRealm = UnitName(contextData.unit)
        if unitName then
            name = unitName
            server = unitRealm or server
        end
    end
    if type(name) ~= "string" or name == "" then
        return nil
    end
    if type(server) ~= "string" or server == "" then
        server = nil
    end

    local candidates, seen = {}, {}
    AddCandidate(candidates, seen, name)

    if server then
        AddCandidate(candidates, seen, name .. " " .. server)
        AddCandidate(candidates, seen, name .. "-" .. server)
    end

    local firstName, nameRealm = name:match("^([^%-]+)%-(.+)$")
    if firstName then
        AddCandidate(candidates, seen, firstName .. " " .. nameRealm)
    end

    if not server and GetRealmName then
        local localRealm = GetRealmName()
        if localRealm and localRealm ~= "" then
            AddCandidate(candidates, seen, name .. " " .. localRealm)
        end
    end

    for _, candidate in ipairs(candidates) do
        if addon.DB:GetPlayer(candidate) then
            return candidate
        end
    end
end

local function RegisterLegacyMenuEntries()
    if type(UnitPopupMenus) ~= "table"
        or type(UnitPopupButtons) ~= "table"
        or type(UnitPopup_OnClick) ~= "function" then
        return false
    end

    UnitPopupButtons.ROLODEX = UnitPopupButtons.ROLODEX or {
        text = ">Rolodex",
        dist = 0,
    }

    local entries = UnitPopupMenus.FRIEND
    if type(entries) == "table" then
        for index = #entries, 1, -1 do
            if entries[index] == "ROLODEX" then
                table.remove(entries, index)
            end
        end
        entries[#entries + 1] = "ROLODEX"
    end

    if not addon.LegacyFriendDropdownHooked
        and type(FriendsFrame_ShowDropdown) == "function" then
        hooksecurefunc("FriendsFrame_ShowDropdown", function(name)
            addon.LegacyFriendMenuName = name
        end)
        addon.LegacyFriendDropdownHooked = true
    end

    if not addon.LegacyUnitPopupHooked then
        hooksecurefunc("UnitPopup_OnClick", function(button)
            if not button or button.value ~= "ROLODEX" then
                return
            end

            local menu = _G.UIDROPDOWNMENU_OPEN_MENU
                or _G.UIDROPDOWNMENU_INIT_MENU
            local playerName = FindPlayerRecord({
                name = button.arg1 or (menu and menu.name) or addon.LegacyFriendMenuName,
                server = menu and menu.server,
            })
            if playerName then
                addon.UI:ShowPlayer(playerName)
            end
        end)
        addon.LegacyUnitPopupHooked = true
    end

    return true
end

local function RegisterModernMenuEntry()
    if addon.ChatFriendMenuRegistered then
        return true
    end
    if not Menu or not Menu.ModifyMenu then
        return false
    end

    Menu.ModifyMenu("MENU_UNIT_FRIEND", function(_, rootDescription, contextData)
        rootDescription:CreateButton(">Rolodex", function()
            local playerName = FindPlayerRecord(contextData)
            if playerName then
                addon.UI:ShowPlayer(playerName)
            end
        end)
    end)
    addon.ChatFriendMenuRegistered = true
    return true
end

if not RegisterModernMenuEntry() and not RegisterLegacyMenuEntries() then
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("ADDON_LOADED")
    eventFrame:RegisterEvent("PLAYER_LOGIN")
    eventFrame:SetScript("OnEvent", function(self, event)
        local modernReady = RegisterModernMenuEntry()
        local legacyReady = modernReady or RegisterLegacyMenuEntries()
        if legacyReady then
            self:UnregisterAllEvents()
        elseif event == "PLAYER_LOGIN" then
            addon:DebugPrint("WoW player menu API unavailable; chat context integration was not registered.")
            self:UnregisterAllEvents()
        end
    end)
end
