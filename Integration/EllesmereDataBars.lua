local dataBars = EllesmereUI
    and EllesmereUI._ModuleNS
    and EllesmereUI._ModuleNS.EllesmereUIDataBars

if not (dataBars
    and dataBars.BLOCK_TYPES
    and dataBars.BLOCK_DEFAULTS
    and dataBars.BlockFactories
    and dataBars.BlockKit
    and dataBars.BarsInOrder
    and dataBars.ApplyBar) then
    return
end

local BLOCK_TYPE = "rolodex"

for _, blockType in ipairs(dataBars.BLOCK_TYPES) do
    if blockType.key == BLOCK_TYPE then
        return
    end
end

dataBars.BLOCK_TYPES[#dataBars.BLOCK_TYPES + 1] = {
    key = BLOCK_TYPE,
    label = "Rolodex",
}
dataBars.BLOCK_DEFAULTS[BLOCK_TYPE] = {}

dataBars.BlockFactories[BLOCK_TYPE] = function(blockCfg, slot, content, barCtx)
    local button = CreateFrame("Button", nil, content)
    button:SetSize(64, 18)
    button:SetPoint("CENTER")
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp")

    local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("CENTER")
    label:SetText("ROLODEX")
    label:SetTextColor(1, 1, 1, 1)
    label:Show()

    button:SetScript("OnClick", function()
        if Rolodex and Rolodex.UI then
            Rolodex.UI:ToggleMainFrame()
        end
    end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Rolodex")
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    local inst = { cfg = blockCfg, slot = slot, content = content, ctx = barCtx }
    function inst:Refresh()
        local fontSize = math.max(9, math.floor(dataBars.BlockKit.CONTENT_BASE * 0.4333 + 0.5))
        dataBars.SetFont(label, fontSize, barCtx.cfg)
        label:SetText("ROLODEX")
        label:SetTextColor(1, 1, 1, 1)
        label:Show()
        local width = math.ceil(label:GetStringWidth() or 0) + 6
        button:SetSize(width, math.max(16, math.ceil(label:GetStringHeight() or fontSize)))
        button:Show()
    end
    function inst:Enable() button:Show() end
    function inst:Disable() button:Hide() end
    function inst:Destroy()
        button:Hide()
        self._dead = true
    end
    function inst:GetAutoLength()
        if barCtx.IsVertical() then
            return math.max(button:GetHeight() or 18, 18)
        end
        return math.max(button:GetWidth() or 64, 24)
    end

    return inst
end
