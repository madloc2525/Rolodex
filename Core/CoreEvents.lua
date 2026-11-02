-- ============================================================================
-- CoreEvents.lua
--
--
-- Responsibilities:
--
-- - Register core Blizzard events.
-- - Detect group changes.
-- - Scan current group members.
-- - Automatically create player records.
-- - Update basic player information.
--
-- WIP:
--
-- - Session tracking.
-- - Run history.
-- - Dungeon detection (instance detection)
-- - Queue rating prompts.
--
-- ============================================================================

local addon = Rolodex

addon.Core = addon.Core or {}

local Core = addon.Core

-- ============================================================================
-- Event Registration
-- ============================================================================

function Core:RegisterEvents()

    addon.Frame:RegisterEvent(
        "PLAYER_ENTERING_WORLD"
    )

    addon.Frame:RegisterEvent(
        "GROUP_ROSTER_UPDATE"
    )

    addon:DebugPrint(
        "Core events registered."
    )

end

-- ============================================================================
-- Event Handlers
-- ============================================================================

function addon:PLAYER_ENTERING_WORLD()

    addon:DebugPrint(
        "PLAYER_ENTERING_WORLD"
    )

    Core:ScanGroup()

end

function addon:GROUP_ROSTER_UPDATE()

    addon:DebugPrint(
        "GROUP_ROSTER_UPDATE"
    )

    Core:ScanGroup()

end

function Core:GetFullPlayerName(unit)

    local firstName, lastName =
        UnitName(unit)

    if not firstName then
        return nil
    end

    if lastName and lastName ~= "" then

        return firstName .. " " .. lastName

    end

    return firstName

end

-- ============================================================================
-- Group Scanner
--
-- Scans all visible group members and ensures
-- they exist in the database.
-- ============================================================================
--
-- MVP:
--
-- - Create players automatically.
-- - Update Last Seen timestamp.
-- - Update class.
-- - Update level.
--
-- Future:
--
-- - Guild.
-- - Role.
-- - Session tracking.
--
-- ============================================================================

function Core:ScanGroup()



    addon:DebugPrint(
        "Scanning group..."
    )

    -- Not grouped.
    if not IsInGroup()
    and not IsInRaid() then

        addon:DebugPrint(
            "No group detected."
        )

        return

    end

    local count =
        GetNumGroupMembers()

    addon:DebugPrint(
        "Members found:",
        count
    )

    for i = 1, count do

        local unit

        if IsInRaid() then

            unit = "raid" .. i

        else

            unit = "party" .. i

        end

        if UnitExists(unit) then

            local name =
                Core:GetFullPlayerName(unit)

            local _, class =
                UnitClass(unit)

            local level =
                UnitLevel(unit)

            local role =
                UnitGroupRolesAssigned(
                    unit
                )

            if name then

                addon.DB:UpdateLastSeen(
                    name
                )

                addon.DB:SetClass(
                    name,
                    class
                )

                addon.DB:SetLastSeenLevel(
                    name,
                    level
                )

                addon.DB:SetLastSeenRole(
                    name,
                    role
                )

                addon:DebugPrint(
                    "CHARACTER: " ..
                    tostring(name) ..
                    " CLASS: " ..
                    tostring(class) ..
                    " LEVEL: " ..
                    tostring(level) ..
                    " ROLE: " ..
                    tostring(role)
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

-- ============================================================================
-- End CoreEvents.lua
-- ============================================================================