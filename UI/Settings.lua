-- Builds the addon settings window and its per-section controls.
local addon = Rolodex

addon.UI = addon.UI or {}

local Settings = {}
addon.UI.Settings = Settings

StaticPopupDialogs["ROLODEX_RELOAD_SKIN"] = {
    text = "Reload the user interface to apply the selected skin?",
    button1 = RELOADUI,
    button2 = CANCEL,
    OnAccept = function()
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local function CreateSettingCheckbox(panel, setting, label, y, onChanged)
    local checkbox = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", 10, -y)
    checkbox:SetChecked(addon.DB:GetSetting(setting))
    addon.UI.Theme:ApplyCheckboxStyle(checkbox)

    local text = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", checkbox, "RIGHT", 4, 0)
    text:SetText(label)
    addon.UI.Theme:ApplyBodyStyle(text)

    checkbox:SetScript("OnClick", function(self)
        local checked = self:GetChecked() and true or false
        addon.DB:SetSetting(setting, checked)
        if onChanged then
            onChanged(checked)
        end
    end)

    return checkbox
end

local function CreateButton(panel, label, y, onClick)
    local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    button:SetSize(180, 24)
    button:SetPoint("TOPLEFT", 10, -y)
    button:SetText(label)
    addon.UI.Theme:ApplyButtonStyle(button)
    button:SetScript("OnClick", onClick)
    return button
end

local function CreateSkinOption(panel, skin, label, y)
    local checkbox = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", 10, -y)
    addon.UI.Theme:ApplyCheckboxStyle(checkbox)

    local text = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", checkbox, "RIGHT", 4, 0)
    text:SetText(label)
    addon.UI.Theme:ApplyBodyStyle(text)

    checkbox:SetScript("OnClick", function()
        if addon.DB:GetSetting("SkinStyle") == skin then
            checkbox:SetChecked(true)
            return
        end

        addon.DB:SetSetting("SkinStyle", skin)
        for style, option in pairs(panel.SkinOptions) do
            option:SetChecked(style == skin)
        end
        panel.ReloadNotice:SetText("Skin saved. Reload the UI to apply the change.")
        StaticPopup_Show("ROLODEX_RELOAD_SKIN")
    end)

    panel.SkinOptions[skin] = checkbox
    return checkbox
end

local function RefreshUI()
    addon.UI:Refresh()
end

function Settings:Create()
    if self.Frame then
        return self.Frame
    end

    local frame = CreateFrame(
        "Frame",
        "RolodexSettingsFrame",
        UIParent,
        "BasicFrameTemplateWithInset"
    )
    frame:SetSize(500, 400)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    addon.UI.Theme:ApplyPaperBackground(frame, true)

    frame.Title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.Title:SetPoint("TOP", 0, -20)
    frame.Title:SetText("Rolodex Settings")
    addon.UI.Theme:ApplyHeaderStyle(frame.Title)

    frame.Tabs = {}
    local tabs = {
        { name = "General", label = "General" },
        { name = "BusinessCards", label = "Business Cards" },
        { name = "DetailCards", label = "Detail Cards" },
        { name = "Database", label = "Database" },
        { name = "Skins", label = "Skins" },
        { name = "Advanced", label = "Advanced" },
    }

    for index, tabInfo in ipairs(tabs) do
        local tab = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        tab:SetSize(110, 24)
        tab:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -40 - ((index - 1) * 28))
        tab:SetText(tabInfo.label)
        addon.UI.Theme:ApplyButtonStyle(tab)
        frame.Tabs[tabInfo.name] = tab

        local panelName = tabInfo.name
        tab:SetScript("OnClick", function()
            Settings:ShowPanel(panelName)
        end)
    end

    frame.Content = CreateFrame("Frame", nil, frame)
    frame.Content:SetPoint("TOPLEFT", frame, "TOPLEFT", 140, -40)
    frame.Content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
    addon.UI.Theme:ApplyPaperBackground(frame.Content, false)
    frame.Panels = {}

    -- General options
    local general = CreateFrame("Frame", nil, frame.Content)
    frame.Panels.General = general
    general:SetAllPoints()

    local mainFrame = addon.UI.MainFrame
    CreateSettingCheckbox(
        general,
        "LockMainFrame",
        "Lock Main Window",
        20,
        function(locked)
            if locked then
                mainFrame:RegisterForDrag()
            else
                mainFrame:RegisterForDrag("LeftButton")
            end
        end
    )

    CreateSettingCheckbox(
        general,
        "AllowResize",
        "Allow Window Resizing",
        50,
        function(allowed)
            mainFrame:SetResizable(allowed)
            mainFrame.ResizeButton:SetShown(allowed)
        end
    )

    CreateSettingCheckbox(
        general,
        "ShowMinimapButton",
        "Show Minimap Button",
        80,
        function(shown)
            addon.UI.MinimapButton:SetShown(shown)
        end
    )

    CreateSettingCheckbox(
        general,
        "EnableRatingPrompt",
        "Enable Rating Prompt",
        110,
        function(enabled)
            if not enabled and addon.UI.RatingPrompt.Frame then
                addon.UI.RatingPrompt.Frame:Hide()
            end
        end
    )

    CreateSettingCheckbox(general, "ShowRolodexTooltip", "Enable Rolodex in Tooltips", 140)

    general.ResetPositionButton = CreateButton(
        general,
        "Reset Position",
        190,
        function()
            addon.UI:ResetWindowPosition()
        end
    )
    general.ResetSizeButton = CreateButton(
        general,
        "Reset Size",
        228,
        function()
            addon.UI:ResetWindowSize()
        end
    )

    -- Business card options
    local businessCards = CreateFrame("Frame", nil, frame.Content)
    frame.Panels.BusinessCards = businessCards
    businessCards:SetAllPoints()
    businessCards:Hide()

    CreateSettingCheckbox(businessCards, "AutoExpandSelectedPlayer", "Auto Expand Selected Player", 10, RefreshUI)
    CreateSettingCheckbox(businessCards, "ShowFavoritesFirst", "Always Show Favorites First", 40, RefreshUI)
    CreateSettingCheckbox(businessCards, "ShowClass", "Show Class", 90, RefreshUI)
    CreateSettingCheckbox(businessCards, "ShowGuild", "Show Guild", 120, RefreshUI)
    CreateSettingCheckbox(businessCards, "ShowAverageRating", "Show Average Rating", 150, RefreshUI)
    CreateSettingCheckbox(businessCards, "ShowGroups", "Show Groups", 180, RefreshUI)
    CreateSettingCheckbox(businessCards, "ShowMostRecent", "Show Most Recent", 210, RefreshUI)

    -- Detail card options
    local detailCards = CreateFrame("Frame", nil, frame.Content)
    frame.Panels.DetailCards = detailCards
    detailCards:SetAllPoints()
    detailCards:Hide()

    CreateSettingCheckbox(detailCards, "ShowNotes", "Show Notes", 10, RefreshUI)
    CreateSettingCheckbox(detailCards, "ShowCharacterSection", "Show Character Section", 50, RefreshUI)
    CreateSettingCheckbox(detailCards, "ShowRatingSection", "Show Rating Section", 80, RefreshUI)
    CreateSettingCheckbox(detailCards, "ShowRatingHistory", "Show Rating History", 110, RefreshUI)
    CreateSettingCheckbox(detailCards, "ShowGroupHistory", "Show Group History", 140, RefreshUI)
    CreateSettingCheckbox(detailCards, "EnableManualRating", "Enable Manual Rating", 170, RefreshUI)

    -- Database controls
    local database = CreateFrame("Frame", nil, frame.Content)
    frame.Panels.Database = database
    database:SetAllPoints()
    database:Hide()

    database.EntryCountText = database:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    database.EntryCountText:SetPoint("TOPLEFT", 10, -10)
    addon.UI.Theme:ApplyBodyStyle(database.EntryCountText)
    CreateSettingCheckbox(database, "ConfirmDatabaseWipe", "Confirm Before Wiping Database", 32)

    local function SetDatabaseStatus(message, isError)
        database.StatusText:SetText(message)
        if isError then
            database.StatusText:SetTextColor(1, 0.35, 0.25)
        else
            addon.UI.Theme:ApplyBodyStyle(database.StatusText)
        end
    end

    database.StatusText = database:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    database.StatusText:SetPoint("TOPLEFT", 10, -128)
    database.StatusText:SetWidth(315)
    database.StatusText:SetJustifyH("LEFT")
    addon.UI.Theme:ApplyBodyStyle(database.StatusText)
    SetDatabaseStatus("Export to copy a backup, or paste JSON below to import.", false)

    database.ImportScroll = CreateFrame(
        "ScrollFrame",
        nil,
        database,
        "UIPanelScrollFrameTemplate"
    )
    database.ImportScroll:SetPoint("TOPLEFT", 10, -166)
    database.ImportScroll:SetPoint("BOTTOMRIGHT", -30, 42)

    database.ImportBox = CreateFrame("EditBox", nil, database.ImportScroll)
    database.ImportBox:SetMultiLine(true)
    database.ImportBox:SetAutoFocus(false)
    database.ImportBox:SetFontObject(GameFontHighlightSmall)
    database.ImportBox:SetTextInsets(6, 6, 6, 6)
    if database.ImportBox.SetNonSpaceWrap then
        database.ImportBox:SetNonSpaceWrap(true)
    end
    database.ImportBox:SetWidth(280)
    database.ImportBox:SetHeight(160)
    database.ImportBox:SetText("")
    database.ImportBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    addon.UI.Theme:ApplyEditBoxStyle(database.ImportBox)
    database.ImportScroll:SetScrollChild(database.ImportBox)
    database.ImportBox:SetScript("OnTextChanged", function(self)
        local textHeight = self:GetHeight()
        if self.GetStringHeight then
            textHeight = self:GetStringHeight() + 16
        end
        self:SetHeight(math.max(160, textHeight))
    end)

    StaticPopupDialogs["ROLODEX_CONFIRM_WIPE"] = {
        text = "This will permanently delete all Rolodex player data. Are you sure?",
        button1 = YES,
        button2 = CANCEL,
        OnAccept = function()
            addon.DB:WipeDatabase()
            Settings:RefreshDatabasePanel()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    database.WipeDatabaseButton = CreateButton(
        database,
        "Wipe Database",
        62,
        function()
            if addon.DB:GetSetting("ConfirmDatabaseWipe") then
                StaticPopup_Show("ROLODEX_CONFIRM_WIPE")
            else
                addon.DB:WipeDatabase()
                Settings:RefreshDatabasePanel()
            end
        end
    )

    database.ExportButton = CreateButton(database, "Export", 98, function()
        local serialized, err = addon.DB:ExportDatabase()
        if not serialized then
            SetDatabaseStatus(err, true)
            return
        end
        database.ImportBox:SetText(serialized)
        database.ImportBox:SetCursorPosition(0)
        database.ImportBox:HighlightText()
        database.ImportBox:SetFocus()
        SetDatabaseStatus(
            "Export ready. Copy the selected text and save it somewhere safe.",
            false
        )
    end)
    database.ExportButton:SetSize(100, 24)

    database.MergeImportButton = CreateButton(database, "Merge Import", 98, function()
        local result, err = addon.DB:ImportDatabase(database.ImportBox:GetText(), "merge")
        if not result then
            SetDatabaseStatus(err, true)
            return
        end
        Settings:RefreshDatabasePanel()
        SetDatabaseStatus(
            string.format(
                "Merged: %d added, %d updated. %d total players.",
                result.added,
                result.updated,
                result.total
            ),
            false
        )
    end)
    database.MergeImportButton:SetSize(105, 24)
    database.MergeImportButton:ClearAllPoints()
    database.MergeImportButton:SetPoint("TOPLEFT", database, "TOPLEFT", 117, -98)

    database.ReplaceImportButton = CreateButton(database, "Replace", 98, function()
        local serialized = database.ImportBox:GetText()
        local imported, err = addon.DB:DecodeImport(serialized)
        if not imported then
            SetDatabaseStatus(err, true)
            return
        end
        StaticPopup_Show("ROLODEX_CONFIRM_IMPORT_REPLACE", nil, nil, serialized)
    end)
    database.ReplaceImportButton:SetSize(105, 24)
    database.ReplaceImportButton:ClearAllPoints()
    database.ReplaceImportButton:SetPoint("TOPLEFT", database, "TOPLEFT", 229, -98)

    StaticPopupDialogs["ROLODEX_CONFIRM_IMPORT_REPLACE"] = {
        text = "Replace all Rolodex player data with the pasted import?",
        button1 = "Replace",
        button2 = CANCEL,
        OnAccept = function(_, serialized)
            local result, err = addon.DB:ImportDatabase(serialized, "replace")
            if not result then
                SetDatabaseStatus(err, true)
                return
            end
            Settings:RefreshDatabasePanel()
            SetDatabaseStatus(
                string.format("Database replaced with %d players.", result.total),
                false
            )
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    local skins = CreateFrame("Frame", nil, frame.Content)
    frame.Panels.Skins = skins
    skins:SetAllPoints()
    skins:Hide()

    skins.SkinOptions = {}
    CreateSkinOption(skins, "forever", "WoW Forever", 20)
    CreateSkinOption(skins, "classic", "Classic", 50)
    if addon.UI.Theme:IsEllesmereUIAvailable() then
        CreateSkinOption(skins, "ellesmereui", "EllesmereUI", 80)
    end

    skins.ReloadNotice = skins:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    skins.ReloadNotice:SetPoint("TOPLEFT", 10, -122)
    skins.ReloadNotice:SetWidth(320)
    skins.ReloadNotice:SetJustifyH("LEFT")
    addon.UI.Theme:ApplyBodyStyle(skins.ReloadNotice)
    local selectedSkin = addon.UI.Theme:GetSkinStyle()
    for style, option in pairs(skins.SkinOptions) do
        option:SetChecked(style == selectedSkin)
    end
    if selectedSkin == "ellesmereui" and not skins.SkinOptions.ellesmereui then
        skins.ReloadNotice:SetText(
            "EllesmereUI is selected, but its Blizzard Skinning API is not loaded."
        )
    elseif selectedSkin == "ellesmereui" then
        skins.ReloadNotice:SetText("EllesmereUI style applies after /reload.")
    else
        skins.ReloadNotice:SetText("Skin changes apply after /reload.")
    end

    -- Reserved for settings planned for future releases.
    do
        local panelName = "Advanced"
        local panel = CreateFrame("Frame", nil, frame.Content)
        frame.Panels[panelName] = panel
        panel:SetAllPoints()
        panel:Hide()

        local placeholder = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        placeholder:SetPoint("TOPLEFT", 10, -10)
        placeholder:SetText(panelName .. " settings are planned for a future release.")
        addon.UI.Theme:ApplyBodyStyle(placeholder)
    end

    self.Frame = frame
    self:ShowPanel("General")
    return frame
end

function Settings:Toggle()
    if not self.Frame then
        self:Create()
    end

    if self.Frame:IsShown() then
        self.Frame:Hide()
    else
        self.Frame:Show()
    end
end

function Settings:RefreshDatabasePanel()
    local panel = self.Frame and self.Frame.Panels.Database
    if panel and panel.EntryCountText then
        panel.EntryCountText:SetText(
            "Entries in Rolodex database: " .. addon.DB:GetPlayerCount()
        )
    end
end

function Settings:ShowPanel(panelName)
    local frame = self.Frame

    for _, panel in pairs(frame.Panels) do
        panel:Hide()
    end

    for _, tab in pairs(frame.Tabs) do
        local text = tab:GetFontString()
        if text then
            tab.ThemeActive = false
            addon.UI.Theme:ApplyButtonStyle(tab)
        end
    end

    local panel = frame.Panels[panelName]
    if panel then
        panel:Show()
    end

    if panelName == "Database" then
        self:RefreshDatabasePanel()
    end

    local tab = frame.Tabs[panelName]
    local text = tab and tab:GetFontString()
    if text then
        tab.ThemeActive = true
        addon.UI.Theme:ApplyButtonStyle(tab)
    end
end
