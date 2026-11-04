-- Registers group events, updates player data, and records group history.
local addon = Rolodex

addon.Core = addon.Core or {}
local Core = addon.Core

addon.ActiveSession = addon.ActiveSession or {}
addon.WasGrouped = false

function Core:Initialize()
    addon:DebugPrint("Core initialized.")
    self:RegisterEvents()
end

function Core:RegisterEvents()
    addon.Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    addon.Frame:RegisterEvent("GROUP_ROSTER_UPDATE")
    addon:DebugPrint("Core events registered.")
end

function addon:PLAYER_ENTERING_WORLD()
    addon:DebugPrint("PLAYER_ENTERING_WORLD")
    Core:ScanGroup()
end

function addon:GROUP_ROSTER_UPDATE()
    addon:DebugPrint("GROUP_ROSTER_UPDATE")

    local grouped = IsInGroup() or IsInRaid()
    if addon.WasGrouped and not grouped then
        -- Count one group encounter for each member tracked in this session.
        addon:DebugPrint("Group session ended.")
        for name in pairs(addon.ActiveSession) do
            addon.DB:IncrementGroups(name)
        end

        if addon.UI
            and addon.UI.RatingPrompt
            and addon.UI.RatingPrompt.Show
            and addon.DB:GetSetting("EnableRatingPrompt") then
            addon.UI.RatingPrompt:Show()
        end

        addon.ActiveSession = {}
        if addon.UI and addon.UI.Refresh then
            addon.UI:Refresh()
        end
    end

    addon.WasGrouped = grouped
    Core:ScanGroup()
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
    if not IsInGroup() and not IsInRaid() then
        addon:DebugPrint("No group detected.")
        return
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
                local level = UnitLevel(unit)
                local role = UnitGroupRolesAssigned(unit)

                addon.DB:UpdateLastSeen(name)
                addon.DB:SetClass(name, class)
                addon.DB:SetLastSeenLevel(name, level)
                addon.DB:SetLastSeenRole(name, role)

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
end
