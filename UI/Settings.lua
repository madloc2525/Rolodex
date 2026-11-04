-- Builds the addon settings window and its per-section controls.
local addon = Rolodex

addon.UI = addon.UI or {}

local Settings = {}
addon.UI.Settings = Settings

local function CreateSettingCheckbox(panel, setting, label, y, onChanged)
    local checkbox = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", 10, -y)
    checkbox:SetChecked(addon.DB:GetSetting(setting))

    local text = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", checkbox, "RIGHT", 4, 0)
    text:SetText(label)

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
    button:SetScript("OnClick", onClick)
    return button
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

    frame.Title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.Title:SetPoint("TOP", 0, -10)
    frame.Title:SetText("Rolodex Settings")

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
        frame.Tabs[tabInfo.name] = tab

        local panelName = tabInfo.name
        tab:SetScript("OnClick", function()
            Settings:ShowPanel(panelName)
        end)
    end

    frame.Content = CreateFrame("Frame", nil, frame)
    frame.Content:SetPoint("TOPLEFT", frame, "TOPLEFT", 140, -40)
    frame.Content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
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
    CreateSettingCheckbox(database, "ConfirmDatabaseWipe", "Confirm Before Wiping Database", 32)

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

    -- Reserved for settings planned for future releases.
    for _, panelName in ipairs({ "Skins", "Advanced" }) do
        local panel = CreateFrame("Frame", nil, frame.Content)
        frame.Panels[panelName] = panel
        panel:SetAllPoints()
        panel:Hide()

        local placeholder = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        placeholder:SetPoint("TOPLEFT", 10, -10)
        placeholder:SetText(panelName .. " settings are planned for a future release.")
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
            text:SetTextColor(1, 1, 1)
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
        text:SetTextColor(1, 0.82, 0)
    end
end
