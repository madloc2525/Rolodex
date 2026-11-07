-- Registers group events, updates player data, and records group history.
local addon = Rolodex

addon.Core = addon.Core or {}
local Core = addon.Core

addon.ActiveSession = addon.ActiveSession or {}
addon.WasGrouped = false
addon.CurrentGroupMembers = {}
addon.SessionDeparted = {}

function Core:Initialize()
    addon:DebugPrint("Core initialized.")
    self:RegisterEvents()
    self:UpdateGroupRoster()
end

function Core:RegisterEvents()
    addon.Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    addon.Frame:RegisterEvent("GROUP_ROSTER_UPDATE")
    addon.Frame:RegisterEvent("PLAYER_GUILD_UPDATE")
    addon.Frame:RegisterEvent("UNIT_NAME_UPDATE")
    addon:DebugPrint("Core events registered.")
end

function addon:PLAYER_ENTERING_WORLD()
    addon:DebugPrint("PLAYER_ENTERING_WORLD")
    Core:UpdateGroupRoster()
end

function addon:GROUP_ROSTER_UPDATE()
    addon:DebugPrint("GROUP_ROSTER_UPDATE")

    Core:UpdateGroupRoster()
    if C_Timer and C_Timer.After then
        C_Timer.After(1, function()
            Core:ScanGroup()
        end)
    end
end

function addon:PLAYER_GUILD_UPDATE()
    Core:ScanGroup()
end

function addon:UNIT_NAME_UPDATE(unit)
    if type(unit) == "string"
        and (unit:match("^party%d+$") or unit:match("^raid%d+$")) then
        Core:ScanGroup()
    end
end

function Core:RecordDepartures(names)
    if not names or #names == 0 then
        return
    end

    local promptNames = {}
    for _, name in ipairs(names) do
        if not addon.SessionDeparted[name] then
            addon.SessionDeparted[name] = true
            addon.DB:IncrementGroups(name)
            promptNames[#promptNames + 1] = name
        end
    end

    if #promptNames > 0
        and addon.UI
        and addon.UI.RatingPrompt
        and addon.UI.RatingPrompt.Show
        and addon.DB:GetSetting("EnableRatingPrompt") then
        addon.UI.RatingPrompt:Show(promptNames)
    end

    if addon.UI and addon.UI.Refresh then
        addon.UI:Refresh()
    end
end

function Core:UpdateGroupRoster()
    local grouped = IsInGroup() or IsInRaid()
    if grouped and not addon.WasGrouped then
        addon.ActiveSession = {}
        addon.SessionDeparted = {}
        addon.CurrentGroupMembers = {}
    end

    local currentMembers = self:ScanGroup()
    if addon.WasGrouped then
        local departed = {}
        for name in pairs(addon.CurrentGroupMembers) do
            if not currentMembers[name] then
                departed[#departed + 1] = name
            end
        end

        if not grouped then
            for name in pairs(addon.ActiveSession) do
                if not addon.SessionDeparted[name] then
                    departed[#departed + 1] = name
                end
            end
        end

        self:RecordDepartures(departed)
    end

    if grouped then
        addon.CurrentGroupMembers = currentMembers
    else
        addon.CurrentGroupMembers = {}
        addon.ActiveSession = {}
        addon.SessionDeparted = {}
    end

    addon.WasGrouped = grouped
end

function Core:GetFullPlayerName(unit)
    local firstName, lastName = UnitName(unit)
    if not firstName then
        return nil
    end

    if lastName and lastName ~= "" then
        return firstName .. " " .. lastName
    end

    return firstName
end

function Core:ScanGroup()
    addon:DebugPrint("Scanning group...")
    local currentMembers = {}
    if not IsInGroup() and not IsInRaid() then
        addon:DebugPrint("No group detected.")
        return currentMembers
    end

    local isRaid = IsInRaid()
    local count = GetNumGroupMembers()
    addon:DebugPrint("Members found:", count)

    for index = 1, count do
        local unit = (isRaid and "raid" or "party") .. index
        if UnitExists(unit) then
            local name = self:GetFullPlayerName(unit)
            if name then
                local _, class = UnitClass(unit)
                local guild = GetGuildInfo(unit)
                local level = UnitLevel(unit)
                local role = UnitGroupRolesAssigned(unit)

                addon.DB:UpdateLastSeen(name)
                addon.DB:SetClass(name, class)
                if guild then
                    addon.DB:SetGuild(name, guild)
                end
                addon.DB:SetLastSeenLevel(name, level)
                addon.DB:SetLastSeenRole(name, role)

                currentMembers[name] = true
                addon.ActiveSession[name] = {
                    class = class,
                    role = role,
                }

                addon:DebugPrint(
                    "CHARACTER: " .. tostring(name)
                        .. " CLASS: " .. tostring(class)
                        .. " LEVEL: " .. tostring(level)
                        .. " ROLE: " .. tostring(role)
                )
            end
        end
    end

    if addon.UI
        and addon.UI.MainFrame
        and addon.UI.MainFrame:IsShown() then
        addon.UI:RefreshPlayerList()
    end

    return currentMembers
end
