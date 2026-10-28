
-- Rolodex.lua


-- 1. Create the addon namespace.
-- 2. Create the shared event frame.
-- 3. Register startup events.
-- 4. Route events.
-- 5. Initialize modules.
--
-- If you fork this, don't bloat this file. Leave it small
--
-- Most functionality belongs in:
--
-- Core/ (<<- esp here)
-- Database/
-- UI/
-- Chat/
-- Integration/
--
-- ----------------------------------------------------------------------------
--
-- Load Order
--
-- 1. Rolodex.lua
-- 2. Core modules
-- 3. Database modules
-- 4. UI modules
-- 5. Chat modules
-- 6. Integration modules
--
-- ----------------------------------------------------------------------------

local ADDON_NAME = ...

-- Main addon namespace.
Rolodex = {}

-- Basic addon metadata.
Rolodex.Name = ADDON_NAME
Rolodex.Version = "0.1.0"

-- Module Namespaces
-- ----------------------------------------------------------------------------

Rolodex.Core = Rolodex.Core or {}
Rolodex.DB = Rolodex.DB or {}
Rolodex.UI = Rolodex.UI or {}
Rolodex.Chat = Rolodex.Chat or {}
Rolodex.Session = Rolodex.Session or {}
Rolodex.Integration = Rolodex.Integration or {}


-- Shared Event Frame
-- ----------------------------------------------------------------------------

-- One frame handles all addon events.
Rolodex.Frame = CreateFrame("Frame")


-- Utility Functions
-- ----------------------------------------------------------------------------

-- Standardized addon chat output.
--
-- Example:
-- [Rolodex] Database initialized.
--
function Rolodex:Print(message)

    DEFAULT_CHAT_FRAME:AddMessage(
        string.format(
            "|cff4db8ff[%s]|r %s",
            self.Name,
            tostring(message)
        )
    )

end

-- Development helper.
--
-- temp space
--
Rolodex.Debug = true

function Rolodex:DebugPrint(...)

    if not self.Debug then
        return
    end

    local parts = {}

    for i = 1, select("#", ...) do
        parts[#parts + 1] = tostring(select(i, ...))
    end

    self:Print(
        "|cffffaa00DEBUG:|r " ..
        table.concat(parts, " ")
    )

end

-- Returns current timestamp.
function Rolodex:GetTimestamp()
    return time()
end

-- Convenience helper.
function Rolodex:IsGrouped()

    return IsInGroup() or IsInRaid()

end

-- 
-- Event Registration
-- ----------------------------------------------------------------------------

-- Addon loading.
Rolodex.Frame:RegisterEvent("ADDON_LOADED")

-- Player fully logged in.
Rolodex.Frame:RegisterEvent("PLAYER_LOGIN")

-- 
-- Event Dispatcher
-- ----------------------------------------------------------------------------

Rolodex.Frame:SetScript("OnEvent", function(_, event, ...)

    local handler = Rolodex[event]

    if handler then
        handler(Rolodex, ...)
    end

end)


-- fun ADDON_LOADED
-- ----------------------------------------------------------------------------

function Rolodex:ADDON_LOADED(addonName)

    -- Ignore other addons loading.
    if addonName ~= self.Name then
        return
    end

    -- Initialize database first.
    if self.DB and self.DB.Initialize then
        self.DB:Initialize()
    end

    self:DebugPrint("ADDON_LOADED")

end


-- PLAYER_LOGIN
-- ----------------------------------------------------------------------------

function Rolodex:PLAYER_LOGIN()

    -- Core systems.
    if self.Core and self.Core.Initialize then
        self.Core:Initialize()
    end

    -- Session tracking.
    if self.Session and self.Session.Initialize then
        self.Session:Initialize()
    end

    -- User interface.
    if self.UI and self.UI.Initialize then
        self.UI:Initialize()
    end

    -- Chat integration.
    if self.Chat and self.Chat.Initialize then
        self.Chat:Initialize()
    end

    self:Print(
        string.format(
            "Loaded v%s",
            self.Version
        )
    )

    self:DebugPrint("PLAYER_LOGIN")

end

-- ----------------------------------------------------------------------------
-- End Rolodex.lua
