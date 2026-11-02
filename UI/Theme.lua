
-- Shared UI formatting and colors.
-- ============================================================================
local addon = Rolodex

addon.UI = addon.UI or {}

local Theme = {}

addon.UI.Theme = Theme


-- Class Formatting


function Theme:FormatClassName(class)

    if not class then
        return "Unknown"
    end

    class = string.lower(class)

    return string.upper(
        string.sub(class, 1, 1)
    ) ..
    string.sub(class, 2)

end


-- Class Colors

function Theme:GetClassColor(class)

    return RAID_CLASS_COLORS[
        class or ""
    ]

end


-- Role Formatting


function Theme:FormatRole(role)

    if role == "TANK" then

        return "|cff6fa8dcTank|r"

    elseif role == "HEALER" then

        return "|cff93c47dHealer|r"

    elseif role == "DAMAGER" then

        return "|cfff6b26bDPS|r"

    end

    return "Unknown"

end