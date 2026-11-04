local addon = Rolodex

addon.UI = addon.UI or {}

local Settings = {}

addon.UI.Settings = Settings

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

    if not RolodexDB.Settings.LockMainFrame then
    frame:RegisterForDrag(
        "LeftButton"
    )

    end

    frame:SetScript(
        "OnDragStart",
        frame.StartMoving
    )

    frame:SetScript(
        "OnDragStop",
        frame.StopMovingOrSizing
    )

    frame:Hide()

    frame.Title = frame:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontHighlight"
    )

    frame.Title:SetPoint(
        "TOP",
        0,
        -10
    )

    frame.Title:SetText(
        "Rolodex Settings"
    )

    -- Tabs
    frame.Tabs = {}

    local tabs = {
        { name = "General", label = "General" },
        { name = "BusinessCards", label = "Business Cards" },
        { name = "DetailCards", label = "Detail Cards" },
        { name = "Database", label = "Database" },
        { name = "Skins", label = "Skins" },
        { name = "Advanced", label = "Advanced" }
    }

    for i, tabInfo in ipairs(tabs) do

        local tab = CreateFrame(
            "Button",
            nil,
            frame,
            "UIPanelButtonTemplate"
        )

        tab:SetSize(
            110,
            24
        )

        tab:SetPoint(
            "TOPLEFT",
            frame,
            "TOPLEFT",
            10,
            -40 - ((i - 1) * 28)
        )

        tab:SetText(tabInfo.label)

        frame.Tabs[tabInfo.name] = tab

        local panelName = tabInfo.name

        tab:SetScript(
            "OnClick",
            function()
                Settings:ShowPanel(panelName)
            end
        )

    end

    frame.Content =
        CreateFrame(
            "Frame",
            nil,
            frame
        )

    frame.Content:SetPoint(
        "TOPLEFT",
        frame,
        "TOPLEFT",
        140,
        -40
    )

    frame.Content:SetPoint(
        "BOTTOMRIGHT",
        frame,
        "BOTTOMRIGHT",
        -10,
        10
    )

    frame.Panels = {}

    frame.Panels.General = CreateFrame("Frame",nil,frame.Content)
        -- Toggle Lock MainFrame Position
        frame.Panels.General.LockMainFrameCheckbox =CreateFrame("CheckButton",nil,frame.Panels.General,"UICheckButtonTemplate")
        frame.Panels.General.LockMainFrameCheckbox:SetPoint("TOPLEFT",10,-20)
        frame.Panels.General.LockMainFrameCheckbox:SetChecked(RolodexDB.Settings.LockMainFrame)
        local lockLabel = frame.Panels.General:CreateFontString(nil,"OVERLAY","GameFontNormal")
        lockLabel:SetPoint("LEFT",frame.Panels.General.LockMainFrameCheckbox,"RIGHT",4,0)
        lockLabel:SetText("Lock Main Window")
        frame.Panels.General.LockMainFrameCheckbox:SetScript("OnClick",function(self)
        local checked = self:GetChecked()
        RolodexDB.Settings.LockMainFrame =checked
        if checked then
            addon.UI.MainFrame:RegisterForDrag()
        else
            addon.UI.MainFrame:RegisterForDrag(
                "LeftButton")
        end
        end)

        -- Toggle Lock MainFrame Size
        frame.Panels.General.LockWindowSizeCheckbox =CreateFrame("CheckButton",nil,frame.Panels.General,"UICheckButtonTemplate")
        frame.Panels.General.LockWindowSizeCheckbox:SetPoint("TOPLEFT",10,-50)
        frame.Panels.General.LockWindowSizeCheckbox:SetChecked(RolodexDB.Settings.LockWindowSize)
        local lockSizeLabel = frame.Panels.General:CreateFontString(nil,"OVERLAY","GameFontNormal")
        lockSizeLabel:SetPoint("LEFT",frame.Panels.General.LockWindowSizeCheckbox,"RIGHT",4,0)
        lockSizeLabel:SetText("Lock Window Size")
        frame.Panels.General.LockWindowSizeCheckbox:SetScript("OnClick",
        function(self)
        local checked = self:GetChecked()
        RolodexDB.Settings.LockWindowSize = checked
        if checked then
            addon.UI.MainFrame:SetResizable(false)
            if addon.UI.MainFrame.ResizeButton then addon.UI.MainFrame.ResizeButton:Hide() end
        else
            addon.UI.MainFrame:SetResizable(true)
            if addon.UI.MainFrame.ResizeButton then addon.UI.MainFrame.ResizeButton:Show()
            end end end)
                if RolodexDB.Settings.LockWindowSize then frame:SetResizable(false)
        if frame.ResizeButton then frame.ResizeButton:Hide() end
                else frame:SetResizable(true)
        end


        -- Toggle minimap button
        frame.Panels.General.MinimapButtonCheckbox = CreateFrame("CheckButton",nil,frame.Panels.General,"UICheckButtonTemplate")
        frame.Panels.General.MinimapButtonCheckbox:SetPoint("TOPLEFT",10,-80)
        frame.Panels.General.MinimapButtonCheckbox:SetChecked(addon.DB:GetSetting("ShowMinimapButton"))
        local minimapLabel = frame.Panels.General:CreateFontString(nil,"OVERLAY","GameFontNormal")
        minimapLabel:SetPoint("LEFT",frame.Panels.General.MinimapButtonCheckbox,"RIGHT",4,0)
        minimapLabel:SetText("Show Minimap Button")
        frame.Panels.General.MinimapButtonCheckbox:SetScript("OnClick",function(self)addon.UI.MinimapButton:SetShown(self:GetChecked())end)

        -- Toggle Rating Prompt
        frame.Panels.General.EnableRatingPromptCheckbox = CreateFrame("CheckButton",nil,frame.Panels.General,"UICheckButtonTemplate")
        frame.Panels.General.EnableRatingPromptCheckbox:SetPoint("TOPLEFT",10,-110)
        frame.Panels.General.EnableRatingPromptCheckbox:SetChecked(
        addon.DB:GetSetting("EnableRatingPrompt"))
        local ratingPromptLabel = frame.Panels.General:CreateFontString(nil,"OVERLAY","GameFontNormal")
        ratingPromptLabel:SetPoint("LEFT",frame.Panels.General.EnableRatingPromptCheckbox,"RIGHT",4,0)
        ratingPromptLabel:SetText("Enable Rating Prompt")
        frame.Panels.General.EnableRatingPromptCheckbox:SetScript("OnClick",function(self)
        local enabled = self:GetChecked()
        addon.DB:SetSetting("EnableRatingPrompt", enabled)
        if not enabled
        and addon.UI.RatingPrompt
        and addon.UI.RatingPrompt.Frame then
            addon.UI.RatingPrompt.Frame:Hide()
        end
        end)

        -- Enable Rolodex in Tooltip
        frame.Panels.General.ShowRolodexTooltipCheckbox = CreateFrame("CheckButton",nil, frame.Panels.General, "UICheckButtonTemplate")
        frame.Panels.General.ShowRolodexTooltipCheckbox:SetPoint("TOPLEFT",10,-140)
        frame.Panels.General.ShowRolodexTooltipCheckbox:SetChecked(
            addon.DB:GetSetting("ShowRolodexTooltip")
        )
        local tooltipLabel = frame.Panels.General:CreateFontString(nil,"OVERLAY","GameFontNormal")
        tooltipLabel:SetPoint("LEFT",frame.Panels.General.ShowRolodexTooltipCheckbox,"RIGHT",4,0)
        tooltipLabel:SetText("Enable Rolodex in Tooltips")
        frame.Panels.General.ShowRolodexTooltipCheckbox:SetScript(
            "OnClick",
            function(self)
                addon.DB:SetSetting("ShowRolodexTooltip", self:GetChecked())
            end
        )


        -- Reset Position button
        frame.Panels.General.ResetPositionButton =CreateFrame("Button",nil,frame.Panels.General,"UIPanelButtonTemplate")
        frame.Panels.General.ResetPositionButton:SetSize(180,24)
        frame.Panels.General.ResetPositionButton:SetPoint("TOPLEFT",10,-190)
        frame.Panels.General.ResetPositionButton:SetText("Reset Position")
        frame.Panels.General.ResetPositionButton:SetScript("OnClick",function()addon.UI:ResetWindowPosition()end)

        -- Reset Size button
        frame.Panels.General.ResetSizeButton =CreateFrame("Button",nil,frame.Panels.General,"UIPanelButtonTemplate")
        frame.Panels.General.ResetSizeButton:SetSize(180,24)
        frame.Panels.General.ResetSizeButton:SetPoint("TOPLEFT",10,-228)
        frame.Panels.General.ResetSizeButton:SetText("Reset Size")
        frame.Panels.General.ResetSizeButton:SetScript("OnClick",function()addon.UI:ResetWindowSize()end)


    frame.Panels.General:SetAllPoints()

frame.Panels.BusinessCards = CreateFrame("Frame",nil,frame.Content)
    -- Toggle Auto Expand Selected Player
    frame.Panels.BusinessCards.AutoExpandCheckbox = CreateFrame("CheckButton",nil,frame.Panels.BusinessCards,"UICheckButtonTemplate")
    frame.Panels.BusinessCards.AutoExpandCheckbox:SetPoint("TOPLEFT",10,-10)
    frame.Panels.BusinessCards.AutoExpandCheckbox:SetChecked(RolodexDB.Settings.AutoExpandSelectedPlayer)
    local autoExpandLabel = frame.Panels.BusinessCards:CreateFontString(nil,"OVERLAY","GameFontNormal")
    autoExpandLabel:SetPoint("LEFT",frame.Panels.BusinessCards.AutoExpandCheckbox,"RIGHT",4,0)
    autoExpandLabel:SetText("Auto Expand Selected Player")
    frame.Panels.BusinessCards.AutoExpandCheckbox:SetScript("OnClick",function(self)
    RolodexDB.Settings.AutoExpandSelectedPlayer =self:GetChecked() end)
    -- Show Favorites First
    frame.Panels.BusinessCards.FavoritesFirstCheckbox = CreateFrame("CheckButton",nil,frame.Panels.BusinessCards,"UICheckButtonTemplate")
    frame.Panels.BusinessCards.FavoritesFirstCheckbox:SetPoint("TOPLEFT",10,-40)
    frame.Panels.BusinessCards.FavoritesFirstCheckbox:SetChecked(
        addon.DB:GetSetting("ShowFavoritesFirst"))
    local favoritesLabel =
    frame.Panels.BusinessCards:CreateFontString(nil,"OVERLAY","GameFontNormal")
    favoritesLabel:SetPoint("LEFT",frame.Panels.BusinessCards.FavoritesFirstCheckbox,"RIGHT",4,0)
    favoritesLabel:SetText("Always Show Favorites First")
    frame.Panels.BusinessCards.FavoritesFirstCheckbox:SetScript(
        "OnClick",
        function(self)
            addon.DB:SetSetting("ShowFavoritesFirst", self:GetChecked())
            addon.UI:Refresh()
        end)
    -- Show Class
    frame.Panels.BusinessCards.ShowClassCheckbox = CreateFrame("CheckButton",nil,frame.Panels.BusinessCards,"UICheckButtonTemplate")
    frame.Panels.BusinessCards.ShowClassCheckbox:SetPoint("TOPLEFT",10,-90)
    frame.Panels.BusinessCards.ShowClassCheckbox:SetChecked(RolodexDB.Settings.ShowClass)
    local showClassLabel = frame.Panels.BusinessCards:CreateFontString(nil,"OVERLAY","GameFontNormal")
    showClassLabel:SetPoint("LEFT",
    frame.Panels.BusinessCards.ShowClassCheckbox,"RIGHT",4,0)
    showClassLabel:SetText("Show Class")
    frame.Panels.BusinessCards.ShowClassCheckbox:SetScript("OnClick",
    function(self)
        RolodexDB.Settings.ShowClass = self:GetChecked()
        addon.UI:Refresh()
    end)

    -- Show Guild
    frame.Panels.BusinessCards.ShowGuildCheckbox = CreateFrame("CheckButton",nil,frame.Panels.BusinessCards,"UICheckButtonTemplate")
    frame.Panels.BusinessCards.ShowGuildCheckbox:SetPoint("TOPLEFT",10,-120)
    frame.Panels.BusinessCards.ShowGuildCheckbox:SetChecked(RolodexDB.Settings.ShowGuild)
    local showGuildLabel =
    frame.Panels.BusinessCards:CreateFontString(nil,"OVERLAY","GameFontNormal")
    showGuildLabel:SetPoint("LEFT",frame.Panels.BusinessCards.ShowGuildCheckbox,"RIGHT",4,0)
    showGuildLabel:SetText("Show Guild")
    frame.Panels.BusinessCards:SetAllPoints()
    frame.Panels.BusinessCards:Hide()
    frame.Panels.BusinessCards.ShowGuildCheckbox:SetScript("OnClick",
    function(self)
        RolodexDB.Settings.ShowGuild =self:GetChecked()
        addon.UI:Refresh()
    end)

     -- Show Rating
    frame.Panels.BusinessCards.ShowRatingCheckbox = CreateFrame("CheckButton",nil,frame.Panels.BusinessCards,"UICheckButtonTemplate")
    frame.Panels.BusinessCards.ShowRatingCheckbox:SetPoint("TOPLEFT",10,-150)
    frame.Panels.BusinessCards.ShowRatingCheckbox:SetChecked(RolodexDB.Settings.ShowAverageRating)
    local showRatingLabel =
    frame.Panels.BusinessCards:CreateFontString(nil,"OVERLAY","GameFontNormal")
    showRatingLabel:SetPoint("LEFT",frame.Panels.BusinessCards.ShowRatingCheckbox,"RIGHT",4,0)
    showRatingLabel:SetText("Show Average Rating")
    frame.Panels.BusinessCards.ShowRatingCheckbox:SetScript("OnClick",
    function(self)
        RolodexDB.Settings.ShowAverageRating = self:GetChecked()
        addon.UI:Refresh()
    end)

    -- Show Groups
    frame.Panels.BusinessCards.ShowGroupsCheckbox = CreateFrame("CheckButton", nil, frame.Panels.BusinessCards,"UICheckButtonTemplate")
    frame.Panels.BusinessCards.ShowGroupsCheckbox:SetPoint("TOPLEFT",10,-180)
    frame.Panels.BusinessCards.ShowGroupsCheckbox:SetChecked(RolodexDB.Settings.ShowGroups)
    local showGroupsLabel =
    frame.Panels.BusinessCards:CreateFontString(nil,"OVERLAY","GameFontNormal")
    showGroupsLabel:SetPoint("LEFT",frame.Panels.BusinessCards.ShowGroupsCheckbox,"RIGHT",4,0)
    showGroupsLabel:SetText("Show Groups")
    frame.Panels.BusinessCards.ShowGroupsCheckbox:SetScript("OnClick",
    function(self)
        RolodexDB.Settings.ShowGroups = self:GetChecked() and true or false
        addon.UI:Refresh()
    end)

    -- Detail Cards settings
    -- ==============================================================================
    frame.Panels.DetailCards = CreateFrame("Frame",nil,frame.Content)
    -- Show Notes
    frame.Panels.DetailCards.ShowNotesCheckbox = CreateFrame("CheckButton",nil,frame.Panels.DetailCards,"UICheckButtonTemplate")
    frame.Panels.DetailCards.ShowNotesCheckbox:SetPoint("TOPLEFT",10,-10)
    frame.Panels.DetailCards.ShowNotesCheckbox:SetChecked(RolodexDB.Settings.ShowNotes)
    local showNotesLabel =frame.Panels.DetailCards:CreateFontString(nil,"OVERLAY","GameFontNormal")
    showNotesLabel:SetPoint("LEFT",frame.Panels.DetailCards.ShowNotesCheckbox,"RIGHT",4,0)
    showNotesLabel:SetText("Show Notes")
    frame.Panels.DetailCards.ShowNotesCheckbox:SetScript(
        "OnClick",
        function(self)
            RolodexDB.Settings.ShowNotes = self:GetChecked() and true or false
            addon.UI:Refresh()
        end
    )

    -- Show Character Column
    frame.Panels.DetailCards.ShowCharacterSectionCheckbox = CreateFrame("CheckButton",nil,frame.Panels.DetailCards,"UICheckButtonTemplate")
    frame.Panels.DetailCards.ShowCharacterSectionCheckbox:SetPoint("TOPLEFT",10,-50)
    frame.Panels.DetailCards.ShowCharacterSectionCheckbox:SetChecked(RolodexDB.Settings.ShowCharacterSection)
    local showCharacterSectionLabel = frame.Panels.DetailCards:CreateFontString(nil,"OVERLAY","GameFontNormal")
    showCharacterSectionLabel:SetPoint("LEFT",frame.Panels.DetailCards.ShowCharacterSectionCheckbox,"RIGHT",4,0)
    showCharacterSectionLabel:SetText("Show Character Section")
    frame.Panels.DetailCards.ShowCharacterSectionCheckbox:SetScript(
        "OnClick",
        function(self)
            RolodexDB.Settings.ShowCharacterSection = self:GetChecked() and true or false
            addon.UI:Refresh()
        end
    )

    -- Show Rating Column
    frame.Panels.DetailCards.ShowRatingSectionCheckbox = CreateFrame("CheckButton",nil,frame.Panels.DetailCards,"UICheckButtonTemplate")
    frame.Panels.DetailCards.ShowRatingSectionCheckbox:SetPoint("TOPLEFT",10,-80)
    frame.Panels.DetailCards.ShowRatingSectionCheckbox:SetChecked(RolodexDB.Settings.ShowRatingSection)
    local showRatingSectionLabel = frame.Panels.DetailCards:CreateFontString(nil,"OVERLAY","GameFontNormal")
    showRatingSectionLabel:SetPoint("LEFT",frame.Panels.DetailCards.ShowRatingSectionCheckbox,"RIGHT",4,0)
    showRatingSectionLabel:SetText("Show Rating Section")
    frame.Panels.DetailCards.ShowRatingSectionCheckbox:SetScript(
        "OnClick",
        function(self)
            RolodexDB.Settings.ShowRatingSection = self:GetChecked() and true or false
            addon.UI:Refresh()
        end
    )

    -- Show Rating History
    frame.Panels.DetailCards.ShowRatingHistoryCheckbox = CreateFrame("CheckButton",nil,frame.Panels.DetailCards,"UICheckButtonTemplate")
    frame.Panels.DetailCards.ShowRatingHistoryCheckbox:SetPoint("TOPLEFT",10,-110)
    frame.Panels.DetailCards.ShowRatingHistoryCheckbox:SetChecked(RolodexDB.Settings.ShowRatingHistory)
    local showRatingHistoryLabel =
    frame.Panels.DetailCards:CreateFontString(nil,"OVERLAY","GameFontNormal")
    showRatingHistoryLabel:SetPoint("LEFT",frame.Panels.DetailCards.ShowRatingHistoryCheckbox,"RIGHT",4,0)
    showRatingHistoryLabel:SetText("Show Rating History")
    frame.Panels.DetailCards.ShowRatingHistoryCheckbox:SetScript(
        "OnClick",
        function(self)
            RolodexDB.Settings.ShowRatingHistory = self:GetChecked() and true or false
            addon.UI:Refresh()
        end
    )

    -- Show Group History
    frame.Panels.DetailCards.ShowGroupHistoryCheckbox = CreateFrame("CheckButton",nil,frame.Panels.DetailCards,"UICheckButtonTemplate")
    frame.Panels.DetailCards.ShowGroupHistoryCheckbox:SetPoint("TOPLEFT",10,-140)
    frame.Panels.DetailCards.ShowGroupHistoryCheckbox:SetChecked(RolodexDB.Settings.ShowGroupHistory)
    local showGroupHistoryLabel =
    frame.Panels.DetailCards:CreateFontString(nil,"OVERLAY","GameFontNormal")
    showGroupHistoryLabel:SetPoint("LEFT",frame.Panels.DetailCards.ShowGroupHistoryCheckbox,"RIGHT",4,0)
    showGroupHistoryLabel:SetText("Show Group History")
    frame.Panels.DetailCards.ShowGroupHistoryCheckbox:SetScript(
        "OnClick",
        function(self)
            RolodexDB.Settings.ShowGroupHistory = self:GetChecked() and true or false
            addon.UI:Refresh()
        end
    )

    -- Enable Manual Rating
    frame.Panels.DetailCards.EnableManualRatingCheckbox = CreateFrame("CheckButton",nil,frame.Panels.DetailCards,"UICheckButtonTemplate")
    frame.Panels.DetailCards.EnableManualRatingCheckbox:SetPoint("TOPLEFT",10,-170)
    frame.Panels.DetailCards.EnableManualRatingCheckbox:SetChecked(RolodexDB.Settings.EnableManualRating)
    local enableManualRatingLabel = frame.Panels.DetailCards:CreateFontString(nil,"OVERLAY","GameFontNormal")
    enableManualRatingLabel:SetPoint("LEFT",frame.Panels.DetailCards.EnableManualRatingCheckbox,"RIGHT",4,0)
    enableManualRatingLabel:SetText("Enable Manual Rating")
    frame.Panels.DetailCards.EnableManualRatingCheckbox:SetScript(
        "OnClick",
        function(self)
            RolodexDB.Settings.EnableManualRating = self:GetChecked() and true or false
            addon.UI:Refresh()
        end
    )

    frame.Panels.DetailCards:SetAllPoints()
    frame.Panels.DetailCards:Hide()

    -- Database Settings
    -- =============================================================================================================================================================================
    frame.Panels.Database = CreateFrame("Frame",nil,frame.Content)
    -- Number of entries in database
    frame.Panels.Database.EntryCountText = frame.Panels.Database:CreateFontString(nil,"OVERLAY","GameFontNormal")
    frame.Panels.Database.EntryCountText:SetPoint("TOPLEFT",10,-10)
    frame.Panels.Database.ConfirmDatabaseWipeCheckbox = CreateFrame("CheckButton",nil,frame.Panels.Database,"UICheckButtonTemplate")
    frame.Panels.Database.ConfirmDatabaseWipeCheckbox:SetPoint("TOPLEFT",10,-32)
    frame.Panels.Database.ConfirmDatabaseWipeCheckbox:SetChecked(RolodexDB.Settings.ConfirmDatabaseWipe)
    local confirmWipeLabel = frame.Panels.Database:CreateFontString(nil,"OVERLAY","GameFontNormal")
    confirmWipeLabel:SetPoint("LEFT",frame.Panels.Database.ConfirmDatabaseWipeCheckbox,"RIGHT",4,0)
    confirmWipeLabel:SetText("Confirm Before Wiping Database")
    frame.Panels.Database.ConfirmDatabaseWipeCheckbox:SetScript(
        "OnClick",
        function(self)
            RolodexDB.Settings.ConfirmDatabaseWipe = self:GetChecked() and true or false
        end
    )

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

    frame.Panels.Database.WipeDatabaseButton = CreateFrame("Button",nil,frame.Panels.Database,"UIPanelButtonTemplate")
    frame.Panels.Database.WipeDatabaseButton:SetSize(180,24)
    frame.Panels.Database.WipeDatabaseButton:SetPoint("TOPLEFT",10,-62)
    frame.Panels.Database.WipeDatabaseButton:SetText("Wipe Database")
    frame.Panels.Database.WipeDatabaseButton:SetScript(
        "OnClick",
        function()
            if RolodexDB.Settings.ConfirmDatabaseWipe then
                StaticPopup_Show("ROLODEX_CONFIRM_WIPE")
            else
                addon.DB:WipeDatabase()
                Settings:RefreshDatabasePanel()
            end
        end
    )

    -- Export database button
    frame.Panels.Database.ExportButton = CreateFrame("Button",nil,frame.Panels.Database,"UIPanelButtonTemplate")
    frame.Panels.Database.ExportButton:SetSize(180,24)
    frame.Panels.Database.ExportButton:SetPoint("TOPLEFT",10,-96)
    frame.Panels.Database.ExportButton:SetText("Export Database")
    frame.Panels.Database.ExportButton:SetScript("OnClick",function()addon:DebugPrint("Export not yet implemented.")end)
    -- Import database button
    frame.Panels.Database.ImportButton = CreateFrame("Button",nil,frame.Panels.Database,"UIPanelButtonTemplate")
    frame.Panels.Database.ImportButton:SetSize(180,24)
    frame.Panels.Database.ImportButton:SetPoint("TOPLEFT",10,-130)
    frame.Panels.Database.ImportButton:SetText("Import Database")
    frame.Panels.Database.ImportButton:SetScript("OnClick",function()addon:DebugPrint("Import not yet implemented.")end)

    frame.Panels.Database:SetAllPoints()
    frame.Panels.Database:Hide()

    frame.Panels.Skins = CreateFrame("Frame",nil,frame.Content)
    frame.Panels.Skins:SetAllPoints()
    frame.Panels.Skins:Hide()

    frame.Panels.Advanced = CreateFrame("Frame",nil,frame.Content)
    frame.Panels.Advanced:SetAllPoints()
    frame.Panels.Advanced:Hide()

    self.Frame = frame

    self:ShowPanel("General")

    return frame

end

-- Helper fun etc.
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

    -- Hide all panels
    for _, panel in pairs(frame.Panels) do
        panel:Hide()
    end

    -- Reset tab colors
    for _, tab in pairs(frame.Tabs) do

        if tab:GetFontString() then

            tab:GetFontString():SetTextColor(
                1,
                1,
                1
            )

        end

    end

    -- Show selected panel
    if frame.Panels[panelName] then

        frame.Panels[panelName]:Show()

    end

    if panelName == "Database" then
        self:RefreshDatabasePanel()
    end

    -- Highlight selected tab
    if frame.Tabs[panelName]
    and frame.Tabs[panelName]:GetFontString() then

        frame.Tabs[panelName]:GetFontString():SetTextColor(
            1,
            0.82,
            0
        )

    end

end