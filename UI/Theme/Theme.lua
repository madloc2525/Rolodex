
-- Shared UI formatting and colors.
-- ============================================================================
local addon = Rolodex

addon.UI = addon.UI or {}

local Theme = {}

addon.UI.Theme = Theme

function Theme:FormatClassName(class)
    if not class then
        return "Unknown"
    end

    class = string.lower(class)

    return string.upper(string.sub(class, 1, 1)) .. string.sub(class, 2)
end

function Theme:GetClassColor(class)
    return RAID_CLASS_COLORS[class or ""]
end

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

function Theme:ApplyDividerStyle(texture)
    local r, g, b = self:GetColor("Divider")
    texture:SetColorTexture(r, g, b, 1)
end

function Theme:ApplyHeaderStyle(text)
    local r, g, b = self:GetColor("Header")
    local font, size, flags = text:GetFont()
    text:SetFont(font, size + 2, flags)
    text:SetTextColor(r, g, b)
    text:SetShadowColor(0, 0, 0, 0)
    text:SetShadowOffset(0, 0)
end

function Theme:ApplyBodyStyle(text)
    local r, g, b = self:GetColor("Body")
    text:SetTextColor(r, g, b)
    text:SetShadowColor(0, 0, 0, 0)
    text:SetShadowOffset(0, 0)
end

function Theme:ApplyPaperBackground(frame)
    frame.Background = frame:CreateTexture(nil, "ARTWORK")
    frame.Background:SetPoint("TOPLEFT", 8, -28)
    frame.Background:SetPoint("BOTTOMRIGHT", -8, 8)
    frame.Background:SetTexture("Interface\\AddOns\\Rolodex\\Media\\Textures\\Parchment")
end

-- Shared UI palette used by headers, body text, and dividers.
Theme.Colors = {
    Parchment = { 0.92, 0.86, 0.70 },
    Divider = { 0.35, 0.25, 0.10 },
    Header = { 0.20, 0.10, 0.08 },
    Body = { 0.10, 0.08, 0.05 },
}

function Theme:GetColor(name)
    return unpack(self.Colors[name])
end