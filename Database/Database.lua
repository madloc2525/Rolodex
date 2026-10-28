
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

DB.VERSION = 1


-- Initialization
-- --------------------------------------------------------------------------------------

function DB:Initialize()

    -- Create root database if it doesn't exist.
    RolodexDB = RolodexDB or {}

    -- Database version for future migrations.
    RolodexDB.version = RolodexDB.version or DB.VERSION

    -- Main player storage.
    RolodexDB.players = RolodexDB.players or {}

    addon:Print("Database initialized.")

end


-- Player Creation
-- -------------------------------------------------------------------------------------

function DB:CreatePlayer(name)

    if not name or name == "" then
        return nil
    end

    -- Return existing player if already present.
    if RolodexDB.players[name] then
        return RolodexDB.players[name]
    end

    local player = {

        name = name,

        class = "UNKNOWN",
        guild = "",
        level = 0,

        firstSeen = time(),
        lastSeen = time(),

        runs = 0,

        favorite = false,
        avoid = false,

        notes = "",

        ratings = {}
    }

    RolodexDB.players[name] = player

    return player

end

-- 
-- Player Retrieval
-- ----------------------------------------------------------------------------------

function DB:GetPlayer(name)

    if not name then
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


-- Delete Player
-- ----------------------------------------------------------------------------------

function DB:DeletePlayer(name)

    if not name then
        return
    end

    RolodexDB.players[name] = nil

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

function DB:SetLevel(name, level)

    local player = self:GetOrCreatePlayer(name)

    player.level = level or 0

end

function DB:UpdateLastSeen(name)

    local player = self:GetOrCreatePlayer(name)

    player.lastSeen = time()

end

function DB:IncrementRuns(name)

    local player = self:GetOrCreatePlayer(name)

    player.runs = player.runs + 1

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

    -- Only allow the Rolodex scale.
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

-- 
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

-- 
-- Debug (temp)
-- ----------------------------------------------------------------------------------

function DB:DebugPlayer(name)

    local player = self:GetPlayer(name)

    if not player then
        addon:Print("Player not found.")
        return
    end

    addon:Print("Name: " .. player.name)
    addon:Print("Runs: " .. player.runs)
    addon:Print("Average Rating: " .. string.format("%.2f", self:GetAverageRating(name)))
    addon:Print("Favorite: " .. tostring(player.favorite))
    addon:Print("Avoid: " .. tostring(player.avoid))

end

-- ----------------------------------------------------------------------------------
-- End Database.lua