-- ============================================================================
-- Commands.lua
--
-- Slash Commands
--
-- User Commands
--
-- /rolodex
--
-- Opens the main Rolodex window.
--
--
-- Developer Commands
--
-- /rolodextest
-- /rolodexshow
-- /rolodexcount
-- /rolodexdebug
--
-- These commands exist to speed up development and may be removed,
-- renamed, or hidden before release.
--
-- ============================================================================

local addon = Rolodex

-- ============================================================================
-- Main Command
-- ============================================================================


SLASH_ROLODEX1 = "/rolodex"

SlashCmdList["ROLODEX"] = function()

    addon:DebugPrint("Rolodex command received.")

    -- UI will eventually hook into this.
    if addon.UI and addon.UI.ToggleMainFrame then
        addon.UI:ToggleMainFrame()
        return
    end

        if addon.UI and addon.UI.ToggleMainFrame then

        addon.UI:ToggleMainFrame()

    else

        addon:DebugPrint("UI unavailable.")

    end

end

-- ============================================================================
-- Development Test Command
-- ============================================================================

SLASH_ROLODEXTEST1 = "/rolodextest"

SlashCmdList["ROLODEXTEST"] = function()

    addon:DebugPrint("Creating test player...")

    addon.DB:CreatePlayer("Tankadin")

    addon.DB:SetClass("Tankadin", "PALADIN")

    addon.DB:SetGuild(
        "Tankadin",
        "Knights of Azeroth"
    )

    addon.DB:SetLevel(
        "Tankadin",
        60
    )

    addon.DB:SetFavorite(
        "Tankadin",
        true
    )

    addon.DB:SetNote(
        "Tankadin",
        "Excellent tank. Calm pulls. Recommended."
    )

    addon.DB:AddRating(
        "Tankadin",
        3
    )

    addon.DB:IncrementGroups(
        "Tankadin"
    )

    if addon.UI and addon.UI.Refresh then
        addon.UI:Refresh()
    end

    addon:DebugPrint("Test player created.")

end

-- ============================================================================
-- Show Player Information
-- ============================================================================

SLASH_ROLODEXSHOW1 = "/rolodexshow"

SlashCmdList["ROLODEXSHOW"] = function(msg)

    local name = strtrim(msg or "")

    if name == "" then
        name = "Tankadin"
    end

    local player = addon.DB:GetPlayer(name)

    if not player then

        addon:DebugPrint(
            string.format(
                "Player '%s' not found.",
                name
            )
        )

        return
    end

    addon:DebugPrint("----------------------")
    addon:DebugPrint("Player: " .. player.name)
    addon:DebugPrint("Class: " .. player.class)
    addon:DebugPrint("Guild: " .. player.guild)
    addon:DebugPrint("Level: " .. player.level)
    addon:DebugPrint("Groups: " .. player.groups)

    addon:DebugPrint(
        string.format(
            "Average Rating: %.2f",
            addon.DB:GetAverageRating(name)
        )
    )

    addon:DebugPrint(
        "Favorite: " ..
        tostring(player.favorite)
    )

    addon:DebugPrint(
        "Avoid: " ..
        tostring(player.avoid)
    )

    addon:DebugPrint(
        "Note: " ..
        (player.notes or "")
    )

    addon:DebugPrint("----------------------")

end

-- ============================================================================
-- Database Statistics
-- ============================================================================

SLASH_ROLODEXCOUNT1 = "/rolodexcount"

SlashCmdList["ROLODEXCOUNT"] = function()

    local count = addon.DB:GetPlayerCount()

    addon:DebugPrint(
        string.format(
            "Database contains %d player(s).",
            count
        )
    )

end

-- ============================================================================
-- Debug Mode
-- ============================================================================

SLASH_ROLODEXDEBUG1 = "/rolodexdebug"

SlashCmdList["ROLODEXDEBUG"] = function()

    Rolodex.DebugEnabled =
        not Rolodex.DebugEnabled

    Rolodex:Print(
        "Debug: " ..
        tostring(Rolodex.DebugEnabled)
    )

end



-- Delete Player / Wipe
-- Example:
-- /rolodexdelete Tankadin
-- /rolodexwipe
-- ============================================================================

SLASH_ROLODEXDELETE1 = "/rolodexdelete"

SlashCmdList["ROLODEXDELETE"] = function(msg)

    local name = strtrim(msg or "")

    if name == "" then

        addon:DebugPrint(
            "Usage: /rolodexdelete PlayerName"
        )

        return
    end

    addon.DB:DeletePlayer(name)

    addon:DebugPrint(
        string.format(
            "Deleted player '%s'.",
            name
        )
    )

end

SLASH_ROLODEXWIPE1 = "/rolodexwipe"
SlashCmdList["ROLODEXWIPE"] = function()
    Rolodex.DB:WipeDatabase()
end


-- ============================================================================
-- End Commands.lua
-- ============================================================================