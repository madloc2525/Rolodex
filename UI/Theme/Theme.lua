-- Shared UI formatting, colors, and native WoW texture styling.
local addon = Rolodex

addon.UI = addon.UI or {}

local Theme = {}

addon.UI.Theme = Theme

local WHITE_TEXTURE = "Interface\\Buttons\\WHITE8X8"
local CLASSIC_BACKGROUND = "Interface\\DialogFrame\\UI-DialogBox-Background"
local FOREVER_BACKGROUND = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark"

local CLASSIC_COLORS = {
    PanelTint = { 0.96, 0.88, 0.73 },
    Border = { 0.50, 0.34, 0.17 },
    Divider = { 0.42, 0.27, 0.12 },
    Header = { 0.25, 0.13, 0.06 },
    Body = { 0.15, 0.11, 0.07 },
    WindowHeader = { 0.25, 0.13, 0.06 },
    WindowBody = { 0.15, 0.11, 0.07 },
    ListText = { 0.16, 0.12, 0.08 },
    Input = { 0.90, 0.81, 0.65 },
    ScrollTrack = { 0.12, 0.08, 0.04 },
    Accent = { 0.92, 0.60, 0.22 },
    Button = { 0.24, 0.16, 0.09 },
    ButtonHover = { 0.43, 0.28, 0.13 },
    ButtonText = { 0.98, 0.88, 0.69 },
    Row = { 0.08, 0.05, 0.02, 0.16 },
    RowHover = { 0.70, 0.43, 0.15, 0.22 },
    RowSelected = { 0.78, 0.49, 0.16, 0.34 },
    ColumnBand = { 0.12, 0.08, 0.04, 0.72 },
}

local FOREVER_COLORS = {
    PanelTint = { 0.32, 0.30, 0.27 },
    Border = { 0.35, 0.25, 0.18 },
    Divider = { 0.48, 0.35, 0.24 },
    Header = { 0.90, 0.76, 0.60 },
    Body = { 0.84, 0.88, 0.91 },
    WindowHeader = { 0.90, 0.76, 0.60 },
    WindowBody = { 0.84, 0.88, 0.91 },
    ListText = { 0.84, 0.88, 0.91 },
    Input = { 0.035, 0.06, 0.075 },
    ScrollTrack = { 0.035, 0.032, 0.03 },
    Accent = { 0.86, 0.65, 0.50 },
    Button = { 0.09, 0.075, 0.065 },
    ButtonHover = { 0.24, 0.16, 0.11 },
    ButtonText = { 0.90, 0.84, 0.75 },
    Row = { 0.035, 0.03, 0.025, 0.45 },
    RowHover = { 0.34, 0.20, 0.11, 0.48 },
    RowSelected = { 0.43, 0.25, 0.12, 0.62 },
    ColumnBand = { 0.035, 0.03, 0.025, 0.88 },
}

Theme.Panels = {}
Theme.Headers = {}
Theme.Bodies = {}
Theme.Dividers = {}
Theme.Buttons = {}
Theme.EditBoxes = {}
Theme.Checkboxes = {}
Theme.Rows = {}
Theme.Bands = {}

local function CreateEdge(frame)
    local edge = frame:CreateTexture(nil, "BORDER")
    edge:SetTexture(WHITE_TEXTURE)
    return edge
end

local function SetTextureColor(texture, color, alpha)
    texture:SetVertexColor(color[1], color[2], color[3], alpha or color[4] or 1)
end

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
    if self:IsClassicTheme() then
        return
    end

    self.Dividers[texture] = true
    local r, g, b = self:GetColor("Divider")
    texture:SetColorTexture(r, g, b, 1)
end

function Theme:ApplyHeaderStyle(text)
    if self:IsClassicTheme() then
        return
    end

    if not self.Headers[text] then
        local font, size, flags = text:GetFont()
        self.Headers[text] = {
            font = font,
            size = size,
            flags = flags,
        }
    end
    local base = self.Headers[text]
    local r, g, b = self:GetColor("Header")
    if self.EllesmereSkin then
        self.EllesmereSkin.Font(text, r, g, b)
        local font, size, flags = text:GetFont()
        text:SetFont(font, base.size + 2, flags)
    else
        text:SetFont(base.font, base.size + 2, base.flags)
    end
    text:SetTextColor(r, g, b)
    text:SetShadowColor(0, 0, 0, 0)
    text:SetShadowOffset(0, 0)
end

function Theme:ApplyBodyStyle(text)
    if self:IsClassicTheme() then
        return
    end

    self.Bodies[text] = true
    local r, g, b = self:GetColor("Body")
    if self.EllesmereSkin then
        self.EllesmereSkin.Font(text, r, g, b)
    end
    text:SetTextColor(r, g, b)
    text:SetShadowColor(0, 0, 0, 0)
    text:SetShadowOffset(0, 0)
end

function Theme:ApplyPaperBackground(frame, hasTitleBar)
    if self:IsClassicTheme()
        and (frame == self.MainFrame or frame.NineSlice or frame.Bg or frame.Inset
            or frame.TitleText or frame.CloseButton) then
        return
    end

    local panel = self.Panels[frame]
    if not panel then
        for _, name in ipairs({ "Bg", "NineSlice", "TitleBg", "TopTileStreaks" }) do
            local region = frame[name]
            if region and region.Hide then
                region:Hide()
            end
        end

        if frame.Inset and frame.Inset.Bg then
            frame.Inset.Bg:Hide()
        end

        panel = {
            Background = frame:CreateTexture(nil, "BACKGROUND"),
            Border = {
                CreateEdge(frame),
                CreateEdge(frame),
                CreateEdge(frame),
                CreateEdge(frame),
            },
            Accent = frame:CreateTexture(nil, "BORDER"),
        }
        panel.HasTitleBar = hasTitleBar and true or false

        panel.Background:SetPoint("TOPLEFT", 2, -2)
        panel.Background:SetPoint("BOTTOMRIGHT", -2, 2)
        panel.Background:SetDrawLayer("BACKGROUND", -1)

        panel.Border[1]:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
        panel.Border[1]:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
        panel.Border[2]:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 1)
        panel.Border[2]:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
        panel.Border[3]:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 1)
        panel.Border[3]:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
        panel.Border[4]:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
        panel.Border[4]:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
        panel.Border[1]:SetHeight(1)
        panel.Border[2]:SetHeight(1)
        panel.Border[3]:SetWidth(1)
        panel.Border[4]:SetWidth(1)

        panel.Accent:SetTexture(WHITE_TEXTURE)
        panel.Accent:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
        panel.Accent:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
        panel.Accent:SetHeight(2)

        self.Panels[frame] = panel
        frame.Background = panel.Background
    elseif hasTitleBar ~= nil then
        panel.HasTitleBar = hasTitleBar and true or false
    end

    self:ApplyPanelStyle(frame, panel)
end

function Theme:CreateTitlePlate(frame, title)
    if self:IsClassicTheme() then
        local titleText = frame.TitleText
        if not titleText then
            titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            titleText:SetPoint("TOP", frame, "TOP", 0, -8)
        end
        titleText:SetText(title)
        return { Title = titleText }
    end

    if not frame.TitlePlate then
        local plate = CreateFrame("Frame", nil, frame)
        plate:SetSize(174, 32)
        plate:SetPoint("TOPLEFT", frame, "TOPLEFT", 24, 6)
        plate:SetFrameLevel(frame:GetFrameLevel() + 2)

        plate.Title = plate:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        plate.Title:SetPoint("CENTER", 0, 1)
        plate.Title:SetText(title)
        frame.TitlePlate = plate
        self:ApplyPaperBackground(plate, false)
    end
    self:ApplyTitlePlateStyle(frame.TitlePlate)
    return frame.TitlePlate
end

function Theme:ApplyTitlePlateStyle(plate)
    self:ApplyHeaderStyle(plate.Title)
end

function Theme:ApplyPanelStyle(frame, panel)
    if self.EllesmereSkin then
        if panel.HasTitleBar then
            self.EllesmereSkin.Shell(frame)
            if frame.CloseButton then
                self.EllesmereSkin.CloseButton(frame.CloseButton)
            end
        else
            self.EllesmereSkin.Panel(frame)
        end
        if frame.Inset then
            self.EllesmereSkin.Inset(frame.Inset)
        end
        return
    end

    local foreverUI = _G.EllesmereUI
    local hasForeverFrameArt = self:IsForeverTheme()
        and foreverUI
        and foreverUI.IS_FOREVER == true
        and type(foreverUI.ForeverHeavy) == "function"
        and type(foreverUI.ForeverHeavySeat) == "function"
        and type(foreverUI.ForeverHeavyFill) == "function"
        and type(foreverUI.ForeverHeavyTitle) == "function"
        and type(foreverUI.ForeverHeavyPaint) == "function"
        and type(foreverUI.ForeverHeavyShown) == "function"
        and type(foreverUI.ForeverHeavyOK) == "function"
        and foreverUI.ForeverHeavyOK()

    if hasForeverFrameArt then
        if not panel.ForeverRing then
            panel.ForeverRing = foreverUI.ForeverHeavy(frame, "ARTWORK", 0)
            if panel.ForeverRing then
                foreverUI.ForeverHeavySeat(panel.ForeverRing, frame, "TOPLEFT", 0, 0, 0, 0)
                foreverUI.ForeverHeavyFill(panel.ForeverRing, panel.Background, frame, "TOPLEFT", 0, 0, 0, 0)
                foreverUI.ForeverHeavyTitle(panel.ForeverRing, panel.HasTitleBar)
            end
        end

        if panel.ForeverRing then
            local fill = self:GetColorTable("PanelTint")
            panel.Background:SetTexture(FOREVER_BACKGROUND)
            panel.Background:SetVertexColor(fill[1], fill[2], fill[3], 1)
            foreverUI.ForeverHeavyPaint(panel.ForeverRing, 1, 1, 1, 1)
            foreverUI.ForeverHeavyShown(panel.ForeverRing, true)
            for _, edge in ipairs(panel.Border) do
                edge:Hide()
            end
            panel.Accent:Hide()
            return
        end
    end

    if panel.ForeverRing and foreverUI and type(foreverUI.ForeverHeavyShown) == "function" then
        foreverUI.ForeverHeavyShown(panel.ForeverRing, false)
    end

    local background = self:IsForeverTheme() and FOREVER_BACKGROUND or CLASSIC_BACKGROUND
    panel.Background:SetTexture(background)
    SetTextureColor(panel.Background, self:GetColorTable("PanelTint"))

    local border = self:GetColorTable("Border")
    for _, edge in ipairs(panel.Border) do
        edge:Show()
        SetTextureColor(edge, border)
    end
    panel.Accent:Show()
    SetTextureColor(panel.Accent, self:GetColorTable("Accent"))
end

function Theme:ApplyHeaderBand(texture)
    if self:IsClassicTheme() then
        texture:Hide()
        return
    end

    self.Bands[texture] = true
    if self.EllesmereSkin and self.EllesmereSkin.GetPanelColor then
        local r, g, b, a = self.EllesmereSkin.GetPanelColor()
        texture:SetColorTexture(r, g, b, a or 0.9)
        return
    end
    local colors = self:GetColorTable("ColumnBand")
    texture:SetTexture(WHITE_TEXTURE)
    SetTextureColor(texture, colors)
end

function Theme:ApplyRowStyle(row)
    if self:IsClassicTheme() then
        if row.ThemeBackground then
            row.ThemeBackground:Hide()
        end
        if row.ThemeAccent then
            row.ThemeAccent:Hide()
        end
        if row.ThemeSeparator then
            row.ThemeSeparator:Hide()
        end
        return
    end

    if not row.ThemeBackground then
        row.ThemeBackground = row:CreateTexture(nil, "BACKGROUND")
        row.ThemeBackground:SetAllPoints()
        row.ThemeBackground:SetTexture(WHITE_TEXTURE)
    end
    if not row.ThemeSeparator then
        row.ThemeSeparator = row:CreateTexture(nil, "OVERLAY", nil, 7)
        row.ThemeSeparator:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 5, -1)
        row.ThemeSeparator:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -5, -1)
        row.ThemeSeparator:SetHeight(2)
    end

    self.Rows[row] = true
    if self.EllesmereSkin then
        self.EllesmereSkin.Button(row)
        row.ThemeBackground:Hide()
        if not row.ThemeAccent then
            row.ThemeAccent = row:CreateTexture(nil, "OVERLAY")
            row.ThemeAccent:SetPoint("TOPLEFT", 1, -2)
            row.ThemeAccent:SetPoint("BOTTOMLEFT", 1, 2)
            row.ThemeAccent:SetWidth(2)
        end
        if addon.UI.SelectedRow == row then
            local r, g, b = self:GetColor("Accent")
            row.ThemeAccent:SetColorTexture(r, g, b, 1)
            row.ThemeAccent:Show()
        else
            row.ThemeAccent:Hide()
        end
        local r, g, b = self:GetColor("Accent")
        row.ThemeSeparator:SetColorTexture(r, g, b, 0.18)
        row.ThemeSeparator:Show()
        return
    end

    if not row.ThemeAccent then
        row.ThemeAccent = row:CreateTexture(nil, "OVERLAY")
        row.ThemeAccent:SetPoint("TOPLEFT", 1, -2)
        row.ThemeAccent:SetPoint("BOTTOMLEFT", 1, 2)
        row.ThemeAccent:SetWidth(2)
    end
    row.ThemeBackground:Show()
    local colorName = "Row"
    if addon.UI.SelectedRow == row then
        colorName = "RowSelected"
    elseif row.ThemeHovered then
        colorName = "RowHover"
    end

    SetTextureColor(row.ThemeBackground, self:GetColorTable(colorName))
    local accentR, accentG, accentB = self:GetColor("Accent")
    local selected = addon.UI.SelectedRow == row
    local hovered = row.ThemeHovered
    row.ThemeAccent:SetColorTexture(
        accentR,
        accentG,
        accentB,
        selected and 0.9 or (hovered and 0.5 or 0.15)
    )
    row.ThemeAccent:Show()
    local dividerR, dividerG, dividerB = self:GetColor("Divider")
    row.ThemeSeparator:SetColorTexture(dividerR, dividerG, dividerB, 0.65)
    row.ThemeSeparator:Show()
end

function Theme:ApplyButtonStyle(button)
    if self:IsClassicTheme() then
        return
    end

    if not button.ThemeStyle then
        button.ThemeStyle = {
            Border = {
                CreateEdge(button),
                CreateEdge(button),
                CreateEdge(button),
                CreateEdge(button),
            },
        }

        button.ThemeStyle.Border[1]:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
        button.ThemeStyle.Border[1]:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, 0)
        button.ThemeStyle.Border[2]:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 0)
        button.ThemeStyle.Border[2]:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
        button.ThemeStyle.Border[3]:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 0)
        button.ThemeStyle.Border[3]:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
        button.ThemeStyle.Border[4]:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
        button.ThemeStyle.Border[4]:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, 0)
        button.ThemeStyle.Border[1]:SetHeight(1)
        button.ThemeStyle.Border[2]:SetHeight(1)
        button.ThemeStyle.Border[3]:SetWidth(1)
        button.ThemeStyle.Border[4]:SetWidth(1)
        for _, edge in ipairs(button.ThemeStyle.Border) do
            edge:SetDrawLayer("OVERLAY")
        end

        button:SetNormalTexture(WHITE_TEXTURE)
        button:SetPushedTexture(WHITE_TEXTURE)
        button:SetHighlightTexture(WHITE_TEXTURE, "ADD")
    end

    self.Buttons[button] = true
    if self.EllesmereSkin then
        local keepKeys = button.Icon and { "Icon" } or nil
        self.EllesmereSkin.Button(button, keepKeys)
        local text = button:GetFontString()
        if text then
            local colorName = button.ThemeActive and "Accent" or "ButtonText"
            local r, g, b = self:GetColor(colorName)
            text:SetTextColor(r, g, b)
        end
        return
    end

    local normal = button:GetNormalTexture()
    local pushed = button:GetPushedTexture()
    local highlight = button:GetHighlightTexture()
    local buttonColor = self:GetColorTable(button.ThemeColor or "Button")
    local hoverColor = self:GetColorTable("ButtonHover")
    local borderColor = self:GetColorTable("Border")
    local texturedButtons = self:GetSkinStyle() == "forever"
        and not self.EllesmereSkin
    local buttonTexture = texturedButtons and FOREVER_BACKGROUND or WHITE_TEXTURE

    if normal then
        normal:SetTexture(buttonTexture)
    end
    if pushed then
        pushed:SetTexture(buttonTexture)
    end

    if normal then
        if texturedButtons then
            normal:SetVertexColor(0.58, 0.46, 0.34, 1)
        else
            SetTextureColor(normal, buttonColor)
        end
    end
    if pushed then
        if texturedButtons then
            pushed:SetVertexColor(0.78, 0.62, 0.43, 1)
        else
            SetTextureColor(pushed, hoverColor)
        end
    end
    if highlight then
        SetTextureColor(highlight, hoverColor, 0.45)
    end
    for _, edge in ipairs(button.ThemeStyle.Border) do
        SetTextureColor(edge, borderColor)
    end

    local text = button:GetFontString()
    if text then
        local colorName = button.ThemeActive and "Accent" or "ButtonText"
        local r, g, b = self:GetColor(colorName)
        text:SetTextColor(r, g, b)
        text:SetShadowColor(0, 0, 0, 0.8)
        text:SetShadowOffset(1, -1)
    end
end

function Theme:ApplyEditBoxStyle(editBox)
    if self:IsClassicTheme() then
        return
    end

    if not editBox.ThemeStyle then
        for _, name in ipairs({ "Left", "Middle", "Right", "Background" }) do
            local region = editBox[name]
            if region and region.Hide then
                region:Hide()
            end
        end

        local background = editBox:CreateTexture(nil, "BACKGROUND")
        background:SetPoint("TOPLEFT", -3, 3)
        background:SetPoint("BOTTOMRIGHT", 3, -3)
        background:SetTexture(WHITE_TEXTURE)
        background:SetDrawLayer("BACKGROUND", -1)

        local border = {
            CreateEdge(editBox),
            CreateEdge(editBox),
            CreateEdge(editBox),
            CreateEdge(editBox),
        }
        border[1]:SetPoint("TOPLEFT", editBox, "TOPLEFT", -3, 3)
        border[1]:SetPoint("TOPRIGHT", editBox, "TOPRIGHT", 3, 3)
        border[2]:SetPoint("BOTTOMLEFT", editBox, "BOTTOMLEFT", -3, -3)
        border[2]:SetPoint("BOTTOMRIGHT", editBox, "BOTTOMRIGHT", 3, -3)
        border[3]:SetPoint("BOTTOMLEFT", editBox, "BOTTOMLEFT", -3, -3)
        border[3]:SetPoint("TOPLEFT", editBox, "TOPLEFT", -3, 3)
        border[4]:SetPoint("BOTTOMRIGHT", editBox, "BOTTOMRIGHT", 3, -3)
        border[4]:SetPoint("TOPRIGHT", editBox, "TOPRIGHT", 3, 3)
        border[1]:SetHeight(1)
        border[2]:SetHeight(1)
        border[3]:SetWidth(1)
        border[4]:SetWidth(1)

        editBox.ThemeStyle = { Background = background, Border = border }
    end

    self.EditBoxes[editBox] = true
    if self.EllesmereSkin then
        self.EllesmereSkin.EditBox(editBox, { padInput = true })
        return
    end

    local foreverUI = _G.EllesmereUI
    local hasForeverBorder = self:GetSkinStyle() == "forever"
        and foreverUI
        and type(foreverUI.ForeverBorderOK) == "function"
        and foreverUI.ForeverBorderOK()
        and type(foreverUI.ForeverBorder) == "function"
        and type(foreverUI.ForeverBorderSeat) == "function"
        and type(foreverUI.ForeverBorderPaint) == "function"
        and type(foreverUI.ForeverBorderShown) == "function"
    if hasForeverBorder then
        local style = editBox.ThemeStyle
        if not style.ForeverBorder then
            local borderFrame = CreateFrame("Frame", nil, editBox)
            borderFrame:SetAllPoints(editBox)
            borderFrame:SetFrameLevel(editBox:GetFrameLevel() + 1)
            style.ForeverBorderFrame = borderFrame
            style.ForeverBorder = foreverUI.ForeverBorder(borderFrame, "OVERLAY", 2)
            if style.ForeverBorder then
                foreverUI.ForeverBorderSeat(
                    style.ForeverBorder,
                    editBox,
                    "TOPLEFT",
                    -3,
                    3,
                    3,
                    -3
                )
            end
        end
        if style.ForeverBorder then
            foreverUI.ForeverBorderPaint(style.ForeverBorder, 1, 1, 1, 1)
            foreverUI.ForeverBorderShown(style.ForeverBorder, true)
            for _, edge in ipairs(style.Border) do
                edge:Hide()
            end
        end
    elseif editBox.ThemeStyle.ForeverBorder
        and foreverUI
        and type(foreverUI.ForeverBorderShown) == "function" then
        foreverUI.ForeverBorderShown(editBox.ThemeStyle.ForeverBorder, false)
    end

    if self:GetSkinStyle() == "forever" then
        editBox.ThemeStyle.Background:SetTexture(FOREVER_BACKGROUND)
        editBox.ThemeStyle.Background:SetVertexColor(0.32, 0.30, 0.27, 1)
    else
        editBox.ThemeStyle.Background:SetTexture(WHITE_TEXTURE)
        SetTextureColor(editBox.ThemeStyle.Background, self:GetColorTable("Input"), 0.98)
    end
    for _, edge in ipairs(editBox.ThemeStyle.Border) do
        if not hasForeverBorder then
            edge:Show()
            SetTextureColor(edge, self:GetColorTable("Border"))
        end
    end
end

function Theme:ApplyCheckboxStyle(checkbox)
    self.Checkboxes[checkbox] = true
    if self.EllesmereSkin then
        self.EllesmereSkin.Checkbox(checkbox)
    end
end

function Theme:GetSkinStyle()
    local style = addon.DB and addon.DB:GetSetting("SkinStyle")
    if style == "classic" or style == "ellesmereui" then
        return style
    end
    return "forever"
end

function Theme:IsClassicTheme()
    return self:GetSkinStyle() == "classic"
end

function Theme:IsForeverTheme()
    return self:GetSkinStyle() ~= "classic"
end

function Theme:IsEllesmereUIAvailable()
    local eui = _G.EllesmereUI
    local isLoaded = _G.IsAddOnLoaded
    if _G.C_AddOns and _G.C_AddOns.IsAddOnLoaded then
        isLoaded = _G.C_AddOns.IsAddOnLoaded
    end
    return eui
        and type(eui.RegisterSkin) == "function"
        and isLoaded
        and isLoaded("EllesmereUIBlizzardSkin")
        and true
        or false
end

function Theme:ApplyEllesmereSkin(skin)
    self.EllesmereSkin = skin
    self:Refresh()
end

function Theme:ApplyMainFrame(frame)
    self.MainFrame = frame
    self:Refresh()
end

function Theme:Refresh()
    for frame, panel in pairs(self.Panels) do
        if frame and panel then
            self:ApplyPanelStyle(frame, panel)
        end
    end

    for text in pairs(self.Headers) do
        if text then
            self:ApplyHeaderStyle(text)
        end
    end

    for text in pairs(self.Bodies) do
        if text then
            self:ApplyBodyStyle(text)
        end
    end

    for texture in pairs(self.Dividers) do
        if texture then
            self:ApplyDividerStyle(texture)
        end
    end

    for texture in pairs(self.Bands) do
        if texture then
            self:ApplyHeaderBand(texture)
        end
    end

    for row in pairs(self.Rows) do
        if row then
            self:ApplyRowStyle(row)
        end
    end

    for button in pairs(self.Buttons) do
        if button then
            self:ApplyButtonStyle(button)
        end
    end

    for editBox in pairs(self.EditBoxes) do
        if editBox then
            self:ApplyEditBoxStyle(editBox)
        end
    end

    for checkbox in pairs(self.Checkboxes) do
        if checkbox then
            self:ApplyCheckboxStyle(checkbox)
        end
    end

    local frame = self.MainFrame
    if frame and self:IsClassicTheme() and frame.ScrollBar.Track then
        frame.ScrollBar.Track:Hide()
    elseif frame and not self:IsClassicTheme() then
        local headerR, headerG, headerB = self:GetColor("WindowHeader")
        local bodyR, bodyG, bodyB = self:GetColor("WindowBody")
        local trackR, trackG, trackB = self:GetColor("ScrollTrack")
        local accentR, accentG, accentB = self:GetColor("Accent")
        frame.title:SetTextColor(headerR, headerG, headerB)
        for _, header in pairs(frame.ColumnHeaders) do
            header.Label:SetTextColor(headerR, headerG, headerB)
        end
        frame.SearchBox:SetTextColor(bodyR, bodyG, bodyB)
        if frame.ScrollBar.Track then
            frame.ScrollBar.Track:SetColorTexture(
                trackR,
                trackG,
                trackB,
                self:IsForeverTheme() and 0.9 or 0.8
            )
        end
        if self:GetSkinStyle() == "forever" then
            frame.SettingsButton.Icon:SetVertexColor(1, 0.88, 0.52)
        else
            frame.SettingsButton.Icon:SetVertexColor(accentR, accentG, accentB)
        end
        local thumb = frame.ScrollBar.GetThumbTexture and frame.ScrollBar:GetThumbTexture()
        if thumb then
            thumb:SetVertexColor(accentR, accentG, accentB)
        end
        frame.ResizeButton.Texture:SetVertexColor(accentR, accentG, accentB)
    end

    local ratingPrompt = addon.UI.RatingPrompt
    if ratingPrompt and ratingPrompt.Frame and ratingPrompt.Frame:IsShown() then
        ratingPrompt:Refresh()
    end
end

function Theme:GetColorTable(name)
    if self.EllesmereSkin then
        if name == "Accent" and self.EllesmereSkin.GetAccentColor then
            return { self.EllesmereSkin.GetAccentColor() }
        elseif name == "PanelTint" and self.EllesmereSkin.GetPanelColor then
            return { self.EllesmereSkin.GetPanelColor() }
        end
    end
    local colors = self:IsForeverTheme() and FOREVER_COLORS or CLASSIC_COLORS
    return colors[name]
end

function Theme:GetColor(name)
    return unpack(self:GetColorTable(name))
end

local ellesmereUI = _G.EllesmereUI
if ellesmereUI and type(ellesmereUI.RegisterSkin) == "function" then
    ellesmereUI.RegisterSkin("Rolodex", function(skin)
        if Theme:GetSkinStyle() == "ellesmereui" then
            Theme:ApplyEllesmereSkin(skin)
        end
    end)
end
