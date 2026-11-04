
-- Database.lua
--
-- Central database API for Rolodex.
--
--
-- 1. Other modules should NEVER directly modify RolodexDB.
-- 2. Use the functions in this file for all database operations.
-- 3. Ratings are stored individually

-- ---------------------------------------------------------------------------



local addon = Rolodex

addon.DB = addon.DB or {}

local DB = addon.DB


-- Constants
-- ---------------------------------------------------------------------------

DB.VERSION = 2

-- Settings
DB.DEFAULT_SETTINGS = {

    -- General
    ShowMinimapButton = true,
    EnableRatingPrompt = true,
    LockMainFrame = false,
    AllowResize = true,
    ShowRolodexTooltip = true,

    -- Business card columns and sorting
    ShowClass = true,
    ShowGuild = true,
    ShowGroups = true,
    ShowAverageRating = true,
    ShowFavoritesFirst = false,
    AutoExpandSelectedPlayer = true,

    -- Detail card sections
    ShowNotes = true,
    ShowCharacterSection = true,
    ShowRatingSection = true,
    ShowGroupHistory = true,
    ShowRatingHistory = true,
    EnableManualRating = true,

    -- Database maintenance
    ConfirmDatabaseWipe = true,
}

-- Initialization
-- --------------------------------------------------------------------------------------

function DB:Initialize()

    -- Create root database if it doesn't exist.
    RolodexDB = RolodexDB or {}

    -- Database version for future migrations.
    RolodexDB.version = RolodexDB.version or DB.VERSION

    -- Main player storage.
    RolodexDB.players = RolodexDB.players or {}

    -- Settings
    RolodexDB.Settings =
        RolodexDB.Settings or {}

    local settings = RolodexDB.Settings
    if settings.AllowResize == nil and settings.LockWindowSize ~= nil then
        settings.AllowResize = not settings.LockWindowSize
    end
    settings.LockWindowSize = nil
    if settings.ShowGroups == nil then
        settings.ShowGroups = settings.ShowRuns
    end
    if settings.ShowGroupHistory == nil then
        local showHistorySection = settings.ShowHistorySection
        if showHistorySection == nil then
            showHistorySection = DB.DEFAULT_SETTINGS.ShowGroupHistory
        end

        local showGroupHistory = settings.ShowRunsHistory
        if showGroupHistory == nil then
            showGroupHistory = DB.DEFAULT_SETTINGS.ShowGroupHistory
        end

        settings.ShowGroupHistory = showHistorySection and showGroupHistory
    end
    settings.ShowRuns = nil
    settings.ShowHistorySection = nil
    settings.ShowRunsHistory = nil

    for key, value in pairs(
        DB.DEFAULT_SETTINGS
    ) do

        if RolodexDB.Settings[key] == nil then

            RolodexDB.Settings[key] = value

        end

    end

    -- Move pre-1.0 run terminology to group terminology in saved player records.
    for _, player in pairs(RolodexDB.players) do
        player.groups = player.groups or player.runs or 0
        player.groupHistory = player.groupHistory or player.runHistory or {}
        player.firstGroupTogether = player.firstGroupTogether or player.firstRunTogether
        player.lastGroupTogether = player.lastGroupTogether or player.lastRunTogether

        player.runs = nil
        player.runHistory = nil
        player.firstRunTogether = nil
        player.lastRunTogether = nil
    end
    RolodexDB.version = math.max(RolodexDB.version or 0, DB.VERSION)

    addon:DebugPrint(
        "Database initialized."
    )

    RolodexDB.Window = RolodexDB.Window or {}
    RolodexDB.Window.Width = RolodexDB.Window.Width or 600
    RolodexDB.Window.Height = RolodexDB.Window.Height or 380
    RolodexDB.Window.Point = RolodexDB.Window.Point or "CENTER"
    RolodexDB.Window.X = RolodexDB.Window.X or 0
    RolodexDB.Window.Y = RolodexDB.Window.Y or 0

end


-- Player Creation (defensive)
-- -------------------------------------------------------------------------------------

function DB:CreatePlayer(name)


    if not name or name == "" then
        return nil
    end

    -- Safety net.
    RolodexDB = RolodexDB or {}
    RolodexDB.players = RolodexDB.players or {}

    -- Return existing player if already present.
    if RolodexDB.players[name] then
        return RolodexDB.players[name]
    end

    local player = {
        name = name,
        class = "UNKNOWN",
        guild = "",
        lastSeenLevel = 0,
        lastSeenSpec = "Unknown",
        firstGroupTogether = time(),
        lastGroupTogether = time(),
        firstSeen = time(),
        lastSeen = time(),
        groups = 0,
        groupHistory = {},
        favorite = false,
        avoid = false,
        notes = "",
        ratings = {},
    }

    RolodexDB.players[name] = player

    


    return player

end

-- 
-- Player Retrieval (defensive, update later)
-- ----------------------------------------------------------------------------------

function DB:GetPlayer(name)

    if not name then
        return nil
    end

    if not RolodexDB then
        return nil
    end

    if not RolodexDB.players then
        return nil
    end

    return RolodexDB.players[name]

end


-- ----------------------------------------------------------------------------------

function DB:GetOrCreatePlayer(name)

    local player = self:GetPlayer(name)

    if player then
        return player
    end

    return self:CreatePlayer(name)

end




-- Delete Player and wipe database
-- ----------------------------------------------------------------------------------

function DB:DeletePlayer(name)
    if not name then
        return
    end
    RolodexDB.players[name] = nil
end

function DB:WipeDatabase()
    RolodexDB.players = {}
    if addon.UI then
        addon.UI.ExpandedPlayer = nil
        addon.UI.SelectedRow = nil
        if addon.UI.Refresh then
            addon.UI:Refresh()
        elseif addon.UI.RefreshPlayerList then
            addon.UI:RefreshPlayerList()
        end
    end
    addon.ActiveSession = {}
    addon:DebugPrint("Rolodex database wiped.")
end


-- Metadata
-- ----------------------------------------------------------------------------------

function DB:SetClass(name, class)

    local player = self:GetOrCreatePlayer(name)

    player.class = class or "UNKNOWN"

end

function DB:SetGuild(name, guild)

    local player = self:GetOrCreatePlayer(name)

    player.guild = guild or ""

end

function DB:SetLastSeenRole(
    name,
    role
)

    local player =
        self:GetOrCreatePlayer(name)

    player.lastSeenRole =
        role

end


function DB:UpdateLastSeen(name)

    local player = self:GetOrCreatePlayer(name)

    player.lastSeen = time()

end

function DB:SetLastSeenLevel(name, level)

    local player = self:GetOrCreatePlayer(name)

    player.lastSeenLevel = level or 0

end

function DB:SetLastSeenSpec(name, spec)

    local player = self:GetOrCreatePlayer(name)

    player.lastSeenSpec = spec or "Unknown"

end

function DB:IncrementGroups(name)
    local player = self:GetOrCreatePlayer(name)
    local now = time()

    player.groupHistory = player.groupHistory or {}
    player.groups = (player.groups or 0) + 1
    player.lastGroupTogether = now
    table.insert(player.groupHistory, { timestamp = now })
end

-- Get Group History (and str)
function DB:GetGroupHistory(name)
    local player =
        self:GetPlayer(name)
    if not player then
        return {}
    end
    return player.groupHistory or {}
end

function DB:GetGroupHistoryStrings(name)
    local history =
        self:GetGroupHistory(name)

    local result = {}
    for _, entry in ipairs(history) do
        local timestamp = type(entry) == "table"
            and entry.timestamp
            or entry
        table.insert(
            result,
            date(
                "%d %b %Y %H:%M",
                timestamp
            )
        )
    end
    return result
end

-- Notes on Players
-- ----------------------------------------------------------------------------------

function DB:SetNote(name, note)

    local player = self:GetOrCreatePlayer(name)

    player.notes = note or ""

end

function DB:GetNote(name)

    local player = self:GetPlayer(name)

    if not player then
        return ""
    end

    return player.notes or ""

end


-- Favorite mark
-- ----------------------------------------------------------------------------------

function DB:SetFavorite(name, state)

    local player = self:GetOrCreatePlayer(name)

    player.favorite = state and true or false

end

function DB:IsFavorite(name)

    local player = self:GetPlayer(name)

    if not player then
        return false
    end

    return player.favorite

end


-- Avoid Flag mark
-- ----------------------------------------------------------------------------------

function DB:SetAvoid(name, state)

    local player = self:GetOrCreatePlayer(name)

    player.avoid = state and true or false

end

function DB:IsAvoided(name)

    local player = self:GetPlayer(name)

    if not player then
        return false
    end

    return player.avoid

end



-- Ratings
-- ----------------------------------------------------------------------------------

function DB:AddRating(name, rating)

    local player = self:GetOrCreatePlayer(name)

    rating = tonumber(rating)

    -- Only allow the Rolodex rating scale.
    if rating ~= 1 and rating ~= 2 and rating ~= 3 then
        return false
    end

    table.insert(player.ratings, {
        value = rating,
        timestamp = time(),
    })

    return true

end

function DB:GetRatings(name)

    local player = self:GetPlayer(name)

    if not player then
        return {}
    end

    return player.ratings

end

function DB:GetAverageRating(name)

    local player = self:GetPlayer(name)

    if not player then
        return 0
    end

    if #player.ratings == 0 then
        return 0
    end

    local total = 0

    for _, rating in ipairs(player.ratings) do
        total = total + rating.value
    end

    return total / #player.ratings

end

function DB:GetRatingHistoryString(name)

    local player =
        self:GetPlayer(name)

    if not player then
        return ""
    end

    if not player.ratings then
        return ""
    end

    local history = {}

    for _, rating in ipairs(
        player.ratings
    ) do

        table.insert(
            history,
            tostring(
                rating.value
            )
        )

    end

    return table.concat(
        history,
        ", "
    )

end

function DB:GetLastRating(name)

    local ratings =
        self:GetRatings(name)

    if #ratings == 0 then
        return nil
    end

    return ratings[#ratings].value

end

-- Settings handler

function DB:GetSetting(setting)

    return RolodexDB.Settings[setting]

end

function DB:SetSetting(setting, value)

    RolodexDB.Settings[setting] = value

end

-- Utility / misc
-- ----------------------------------------------------------------------------------
function DB:GetPlayerCount()

    local count = 0

    for _ in pairs(RolodexDB.players) do
        count = count + 1
    end

    return count

end

function DB:GetAllPlayers()

    return RolodexDB.players

end

function DB:PlayerExists(name)

    return RolodexDB.players[name] ~= nil

end

-- Find the first player record matching a unit tooltip's first name.
function DB:GetPlayerByFirstName(firstName)

    for _, player in pairs(RolodexDB.players) do

        local storedFirstName =
            string.match(
                player.name,
                "^[^ ]+"
            )

        if storedFirstName == firstName then
            return player
        end

    end

    return nil

end

-- ----------------------------------------------------------------------------------
-- End Database.lua