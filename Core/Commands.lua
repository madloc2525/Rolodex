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

    addon:Print("Rolodex command received.")

    -- UI will eventually hook into this.
    if addon.UI and addon.UI.ToggleMainFrame then
        addon.UI:ToggleMainFrame()
        return
    end

        if addon.UI and addon.UI.ToggleMainFrame then

        addon.UI:ToggleMainFrame()

    else

        addon:Print("UI unavailable.")

    end

end

-- ============================================================================
-- Development Test Command
-- ============================================================================

SLASH_ROLODEXTEST1 = "/rolodextest"

SlashCmdList["ROLODEXTEST"] = function()

    addon:Print("Creating test player...")

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

    addon.DB:IncrementRuns(
        "Tankadin"
    )

    addon:Print("Test player created.")

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

        addon:Print(
            string.format(
                "Player '%s' not found.",
                name
            )
        )

        return
    end

    addon:Print("----------------------")
    addon:Print("Player: " .. player.name)
    addon:Print("Class: " .. player.class)
    addon:Print("Guild: " .. player.guild)
    addon:Print("Level: " .. player.level)
    addon:Print("Runs: " .. player.runs)

    addon:Print(
        string.format(
            "Average Rating: %.2f",
            addon.DB:GetAverageRating(name)
        )
    )

    addon:Print(
        "Favorite: " ..
        tostring(player.favorite)
    )

    addon:Print(
        "Avoid: " ..
        tostring(player.avoid)
    )

    addon:Print(
        "Note: " ..
        (player.notes or "")
    )

    addon:Print("----------------------")

end

-- ============================================================================
-- Database Statistics
-- ============================================================================

SLASH_ROLODEXCOUNT1 = "/rolodexcount"

SlashCmdList["ROLODEXCOUNT"] = function()

    local count = addon.DB:GetPlayerCount()

    addon:Print(
        string.format(
            "Database contains %d player(s).",
            count
        )
    )

end

-- ============================================================================
-- Debug Dump
-- ============================================================================

SLASH_ROLODEXDEBUG1 = "/rolodexdebug"

SlashCmdList["ROLODEXDEBUG"] = function(msg)

    local name = strtrim(msg or "")

    if name == "" then
        name = "Tankadin"
    end

    addon.DB:DebugPlayer(name)

end

-- ============================================================================
-- Create Arbitrary Test Player
--
-- Example:
--
-- /rolodexcreate Magebob
--
-- Useful for quickly populating the database during UI testing.
--
-- ============================================================================

SLASH_ROLODEXCREATE1 = "/rolodexcreate"

SlashCmdList["ROLODEXCREATE"] = function(msg)

    local name = strtrim(msg or "")

    if name == "" then

        addon:Print(
            "Usage: /rolodexcreate PlayerName"
        )

        return
    end

    local player = addon.DB:CreatePlayer(name)

    addon:Print(
        string.format(
            "Created player '%s'.",
            player.name
        )
    )

end

-- ============================================================================
-- Delete Player / Wipe
--
-- Example:
-- /rolodexdelete Tankadin
-- /rolodexwipe
-- 
--
-- ============================================================================

SLASH_ROLODEXDELETE1 = "/rolodexdelete"

SlashCmdList["ROLODEXDELETE"] = function(msg)

    local name = strtrim(msg or "")

    if name == "" then

        addon:Print(
            "Usage: /rolodexdelete PlayerName"
        )

        return
    end

    addon.DB:DeletePlayer(name)

    addon:Print(
        string.format(
            "Deleted player '%s'.",
            name
        )
    )

end

SLASH_ROLODEXWIPE1 = "/rolodexwipe"

SlashCmdList["ROLODEXWIPE"] = function()

    RolodexDB.players = {}

    Rolodex:Print(
        "Rolodex database wiped."
    )

    if Rolodex.UI then
        Rolodex.UI.SelectedPlayer = nil
        Rolodex.UI:RefreshPlayerList()
    end

end

-- ============================================================================
-- End Commands.lua
-- ============================================================================