-- ============================================================================
-- Rolodex
-- Main Addon Namespace
-- ============================================================================

local ADDON_NAME = Rolodex

Rolodex = {}
Rolodex.Name = ADDON_NAME
Rolodex.Version = "0.1.0"

-- Architecture
Rolodex.Core = {}
Rolodex.DB = {}
Rolodex.UI = {}
Rolodex.Chat = {}
Rolodex.Session = {}
Rolodex.Integrations = {}

-- Shared Event Frame
Rolodex.Frame = CreateFrame("Frame")

-- Basic Debug Helper ((might die later))
function Rolodex:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(
        string.format("|cff4db8ff[%s]|r %s", self.Name, tostring(msg))
    )
end