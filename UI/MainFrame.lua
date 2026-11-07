
-- Creates and manages the main Rolodex window and player list.

local addon = Rolodex

addon.UI = addon.UI or {}

local UI = addon.UI

local MIN_FRAME_WIDTH = 850
local DEFAULT_FRAME_WIDTH = 850

-- Helpers
-- ===========================================================================

-- Currently selected player.
UI.ExpandedPlayer = nil
-- Sort
UI.SortMode = "NAME"

-- ============================================================================
-- Initialize
-- ============================================================================

function UI:Initialize()

    self:CreateMainFrame()
    addon.UI.MinimapButton:Create()
    addon.UI.Settings:Create()

end

-- Refresh entire UI
-- ======================================================================

function UI:Refresh()

    if not self.MainFrame then
        return
    end

    self:RefreshPlayerList()
    self:RefreshDetailCard()

end

-- Handlers
function UI:IsFavoritePriority(a, b)
    if not addon.DB:GetSetting("ShowFavoritesFirst") then
        return nil
    end

    local favoriteA = addon.DB:IsFavorite(a) and true or false
    local favoriteB = addon.DB:IsFavorite(b) and true or false

    if favoriteA ~= favoriteB then
        return favoriteA
    end

    return nil
end


-- Create Main Frame
-- ============================================================================

function UI:CreateMainFrame()

    local frame = CreateFrame(
        "Frame",
        "RolodexMainFrame",
        UIParent,
        "BasicFrameTemplateWithInset"
    )

    frame:SetSize(
        math.max(MIN_FRAME_WIDTH, RolodexDB.Window.Width or DEFAULT_FRAME_WIDTH),
        RolodexDB.Window.Height
)
    frame:SetPoint(
        RolodexDB.Window.Point,
        UIParent,
        RolodexDB.Window.Point,
        RolodexDB.Window.X,
        RolodexDB.Window.Y
)

    frame:SetMovable(true)
    frame:EnableMouse(true)

    if addon.DB:GetSetting("LockMainFrame") then
        frame:RegisterForDrag()
    else
        frame:RegisterForDrag("LeftButton")
    end

    frame:SetScript(
        "OnDragStart",
        frame.StartMoving
    )

    frame:SetScript(
        "OnDragStop",
        function(self)

            self:StopMovingOrSizing()

            local point,
                _,
                relativePoint,
                x,
                y =
                self:GetPoint()

            RolodexDB.Window.Point =
                point

            RolodexDB.Window.X =
                x

            RolodexDB.Window.Y =
                y

        end
    )

    frame:SetResizable(addon.DB:GetSetting("AllowResize"))
    frame:SetScript(
        "OnSizeChanged",
        function(self, width, height)
            local minWidth = MIN_FRAME_WIDTH
            local minHeight = 315
            local clampedWidth = math.max(minWidth, width)
            local clampedHeight = math.max(minHeight, height)

            if clampedWidth ~= width or clampedHeight ~= height then
                self:SetSize(clampedWidth, clampedHeight)
            end

            RolodexDB.Window.Width = math.floor(clampedWidth)
            RolodexDB.Window.Height = math.floor(clampedHeight)
        end
    )

    frame.ResizeButton = CreateFrame("Button", nil, frame)
    frame.ResizeButton:SetSize(16, 16)
    frame.ResizeButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 4)
    frame.ResizeButton.Texture = frame.ResizeButton:CreateTexture(
        nil,
        "ARTWORK"
    )
    frame.ResizeButton.Texture:SetAllPoints()
    frame.ResizeButton.Texture:SetTexture(
        "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up"
    )
    frame.ResizeButton:SetScript(
        "OnMouseDown",
        function()
            frame:StartSizing("BOTTOMRIGHT")
        end
    )
    frame.ResizeButton:SetScript(
        "OnMouseUp",
        function()
            frame:StopMovingOrSizing()
        end
    )
    frame.ResizeButton:SetShown(addon.DB:GetSetting("AllowResize"))

    self.MainFrame = frame
    addon.UI.Theme:ApplyPaperBackground(frame, true)

    -- Title
    -- ==========================================================

    frame.title = addon.UI.Theme:CreateTitlePlate(frame, "Rolodex").Title

    frame.SearchBox = addon.UI.Search:Create(frame)
    addon.UI.Theme:ApplyEditBoxStyle(frame.SearchBox)

    frame.SettingsButton = CreateFrame(
        "Button",
        nil,
        frame,
        "UIPanelButtonTemplate"
    )
    frame.SettingsButton:SetSize(24, 24)
    frame.SettingsButton:SetPoint(
        "RIGHT",
        frame.CloseButton,
        "LEFT",
        -4,
        -2
    )
    frame.SettingsButton:SetText("")
    frame.SettingsButton.Icon = frame.SettingsButton:CreateTexture(
        nil,
        "ARTWORK"
    )
    frame.SettingsButton.Icon:SetPoint("TOPLEFT", 4, -4)
    frame.SettingsButton.Icon:SetPoint("BOTTOMRIGHT", -4, 4)
    frame.SettingsButton.Icon:SetTexture(
        "Interface\\Buttons\\UI-OptionsButton"
    )
    addon.UI.Theme:ApplyButtonStyle(frame.SettingsButton)
    frame.SettingsButton:SetScript(
        "OnEnter",
        function(button)
            GameTooltip:SetOwner(button, "ANCHOR_BOTTOM")
            GameTooltip:SetText("Settings")
            GameTooltip:Show()
        end
    )
    frame.SettingsButton:SetScript(
        "OnLeave",
        function()
            GameTooltip:Hide()
        end
    )
    frame.SettingsButton:SetScript(
        "OnClick",
        function()
            addon.UI.Settings:Toggle()
        end
    )

    frame.SearchBox:SetPoint(
        "RIGHT",
        frame.SettingsButton,
        "LEFT",
        -8,
        0
    )

    local columnHeaders = {
        { name = "Flag", x = 20, width = 55, sortMode = "FLAG" },
        { name = "Name", x = 80, width = 180, sortMode = "NAME" },
        { name = "Class", x = 205, width = 90, setting = "ShowClass", sortMode = "CLASS" },
        { name = "Guild", x = 285, width = 135, setting = "ShowGuild", sortMode = "GUILD" },
        { name = "Rating", x = 425, width = 75, setting = "ShowAverageRating", sortMode = "RATING" },
        { name = "Groups", x = 475, width = 75, setting = "ShowGroups", sortMode = "GROUPS" },
        { name = "Most Recent", x = 500, width = 105, setting = "ShowMostRecent", sortMode = "MOST_RECENT" },
        { name = "Notes", x = 625, width = 75, sortMode = "NOTES" }
    }

-- Player Rows
-- ==========================================================

frame.ScrollFrame =
    CreateFrame(
        "ScrollFrame",
        nil,
        frame
    )

frame.ScrollFrame:SetPoint(
    "TOPLEFT",
    10,
    -52
)

frame.ScrollFrame:SetPoint(
    "BOTTOMRIGHT",
    -30,
    14
)

frame.ScrollFrame:EnableMouseWheel(true)

frame.ScrollFrame:SetScript(
    "OnMouseWheel",
    function(_, delta)

        local maxScroll = math.max(
            0,
            frame.ScrollChild:GetHeight() - frame.ScrollFrame:GetHeight()
        )
        local nextScroll =
            frame.ScrollFrame:GetVerticalScroll() - (delta * 22)

        frame.ScrollBar:SetValue(
            math.max(
                0,
                math.min(maxScroll, nextScroll)
            )
        )

    end
)

-- Content Frame

frame.ScrollChild =
    CreateFrame(
        "Frame",
        nil,
        frame.ScrollFrame
    )

frame.ScrollChild:SetSize(
560,
    frame.ScrollFrame:GetHeight()
)

frame.ScrollFrame:SetScrollChild(
    frame.ScrollChild
)

frame.ScrollBar = CreateFrame(
    "Slider",
    nil,
    frame
)
frame.ScrollBar:SetPoint(
    "TOPRIGHT",
    frame,
    "TOPRIGHT",
    -8,
    -52
)
frame.ScrollBar:SetPoint(
    "BOTTOMRIGHT",
    frame,
    "BOTTOMRIGHT",
    -8,
    14
)
frame.ScrollBar:SetWidth(16)
frame.ScrollBar:SetOrientation("VERTICAL")
frame.ScrollBar.Track = frame.ScrollBar:CreateTexture(
    nil,
    "BACKGROUND"
)
frame.ScrollBar.Track:SetAllPoints(frame.ScrollBar)
frame.ScrollBar.Track:SetColorTexture(0.08, 0.06, 0.04, 0.8)
frame.ScrollBar:SetThumbTexture(
    "Interface\\Buttons\\UI-ScrollBar-Knob"
)
frame.ScrollBar:GetThumbTexture():SetSize(16, 28)
frame.ScrollBar:SetMinMaxValues(0, 0)
frame.ScrollBar:SetValueStep(22)
frame.ScrollBar:SetObeyStepOnDrag(true)
frame.ScrollBar:SetScript(
    "OnValueChanged",
    function(_, value)
        frame.ScrollFrame:SetVerticalScroll(value)
    end
)
frame.ScrollFrame:SetScript(
    "OnVerticalScroll",
    function(_, offset)
        frame.ScrollBar:SetValue(offset)
    end
)

frame.ColumnHeaderOverlay = CreateFrame(
    "Frame",
    nil,
    frame
)
frame.ColumnHeaderOverlay:SetAllPoints(frame)
frame.ColumnHeaderOverlay:SetFrameLevel(
    frame.ScrollChild:GetFrameLevel() + 1
)

frame.ColumnHeaderBand = frame:CreateTexture(nil, "ARTWORK")
frame.ColumnHeaderBand:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -27)
frame.ColumnHeaderBand:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -30, -27)
frame.ColumnHeaderBand:SetHeight(22)
addon.UI.Theme:ApplyHeaderBand(frame.ColumnHeaderBand)

frame.ColumnHeaders = {}
for _, column in ipairs(columnHeaders) do
    local header = CreateFrame("Button", nil, frame.ColumnHeaderOverlay)
    header:SetSize(column.width, 22)
    header:SetPoint(
        "TOPLEFT",
        frame.ColumnHeaderOverlay,
        "TOPLEFT",
        column.x,
        -34
    )
    header.Label = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header.Label:SetAllPoints(header)
    local centeredHeader = column.name == "Flag"
        or column.name == "Rating"
        or column.name == "Groups"
        or column.name == "Most Recent"
        or column.name == "Notes"
    header.Label:SetJustifyH(centeredHeader and "CENTER" or "LEFT")
    header.Label:SetJustifyV("MIDDLE")
    header.Label:SetText(column.name)
    header.Highlight = header:CreateTexture(nil, "BACKGROUND")
    header.Highlight:SetAllPoints()
    header.Highlight:SetColorTexture(1, 1, 1, 0.12)
    header.Highlight:Hide()
    header.VisibilitySetting = column.setting
    header.SortMode = column.sortMode
    if not addon.UI.Theme:IsClassicTheme() then
        header:SetScript("OnEnter", function(self)
            self.Highlight:Show()
        end)
        header:SetScript("OnLeave", function(self)
            self.Highlight:Hide()
        end)
    end
    if column.sortMode then
        header:SetScript("OnClick", function(self)
            UI.SortMode = self.SortMode
            UI:Refresh()
        end)
    end
    frame.ColumnHeaders[column.name] = header
end

-- Player Rows

frame.Rows = {}

-- Detail Card

frame.DetailCard =
    addon.UI.DetailCard:Create(
        frame
    )


    -- Note Frame Editor Window
    -- ==========================================================

    frame.NotesFrame = CreateFrame(
        "Frame",
        nil,
        frame,
        addon.UI.Theme:IsClassicTheme() and "BasicFrameTemplateWithInset" or nil
    )

    frame.NotesFrame:SetSize(
        400,
        280
    )

    frame.NotesFrame:SetPoint(
        "CENTER"
    )

    frame.NotesFrame:SetFrameStrata(
        "DIALOG"
    )

    addon.UI.Theme:ApplyPaperBackground(frame.NotesFrame, true)

    frame.NotesFrame:Hide()

    local notesFrame =
        frame.NotesFrame

    -- Note FrameTitle
    -- ==========================================================

    notesFrame.Title = notesFrame.TitleText
    if not notesFrame.Title then
        notesFrame.Title =
            notesFrame:CreateFontString(
                nil,
                "OVERLAY",
                "GameFontHighlight"
            )

        notesFrame.Title:SetPoint(
            "TOP",
            0,
            -17
        )
    end

    notesFrame.Title:SetText(
        "Player Notes"
    )

    addon.UI.Theme:ApplyHeaderStyle(
        notesFrame.Title
    )

    -- Note Frame Scroll
    -- ==========================================================

    notesFrame.ScrollFrame =
        CreateFrame(
            "ScrollFrame",
            nil,
            notesFrame,
            "UIPanelScrollFrameTemplate"
        )

    notesFrame.ScrollFrame:SetPoint(
        "TOPLEFT",
        15,
        -35
    )

    notesFrame.ScrollFrame:SetPoint(
        "BOTTOMRIGHT",
        -30,
        50
    )



    -- Note FrameEdit Box
    -- ==========================================================

    notesFrame.EditBox =
        CreateFrame(
            "EditBox",
            nil,
            notesFrame.ScrollFrame,
            addon.UI.Theme:IsClassicTheme() and "InputBoxTemplate" or nil
        )
    notesFrame.EditBox:SetMultiLine(true)
    notesFrame.EditBox:SetFontObject(ChatFontNormal)
    notesFrame.EditBox:SetAutoFocus(false)
    notesFrame.EditBox:EnableMouse(true)
    notesFrame.EditBox:SetPoint("TOPLEFT", notesFrame.ScrollFrame, "TOPLEFT", 2, -2)
    notesFrame.EditBox:SetTextInsets(6, 6, 6, 6)
    if notesFrame.EditBox.SetNonSpaceWrap then
        notesFrame.EditBox:SetNonSpaceWrap(true)
    end
    notesFrame.EditBox:SetText("")
    addon.UI.Theme:ApplyBodyStyle(
        notesFrame.EditBox
    )
    addon.UI.Theme:ApplyEditBoxStyle(notesFrame.EditBox)
    notesFrame.ScrollFrame:SetScrollChild(
        notesFrame.EditBox
    )
    local function UpdateNotesEditBoxSize()
        local width = math.max(1, notesFrame.ScrollFrame:GetWidth() - 2)
        notesFrame.EditBox:SetWidth(width)
        local textHeight = notesFrame.EditBox:GetStringHeight() + 16
        notesFrame.EditBox:SetHeight(math.max(notesFrame.ScrollFrame:GetHeight(), textHeight))
    end
    notesFrame.ScrollFrame:SetScript("OnSizeChanged", UpdateNotesEditBoxSize)
    notesFrame.EditBox:SetScript("OnTextChanged", UpdateNotesEditBoxSize)
    notesFrame:SetScript("OnShow", UpdateNotesEditBoxSize)
    UpdateNotesEditBoxSize()
    -- Note Frame Save Button
    -- ==========================================================

    notesFrame.SaveButton =
        CreateFrame(
            "Button",
            nil,
            notesFrame,
            "UIPanelButtonTemplate"
        )

    notesFrame.SaveButton:SetSize(
        100,
        22
    )

    notesFrame.SaveButton:SetPoint(
        "BOTTOMLEFT",
        80,
        15
    )

    notesFrame.SaveButton:SetText(
        "Save"
    )
    addon.UI.Theme:ApplyButtonStyle(notesFrame.SaveButton)

    notesFrame.SaveButton:SetScript(
    "OnClick",
    function()

        addon.DB:SetNote(
            UI.NotePlayer,
            notesFrame.EditBox:GetText()
        )

        UI:Refresh()

        notesFrame:Hide()

    end
    )
    -- Note Frame Cancel Button
    -- ==========================================================

    notesFrame.CancelButton = CreateFrame("Button", nil, notesFrame, "UIPanelButtonTemplate")
    notesFrame.CancelButton:SetSize(100, 22)
    notesFrame.CancelButton:SetPoint("BOTTOMRIGHT", -80, 15)
    notesFrame.CancelButton:SetText("Cancel")
    addon.UI.Theme:ApplyButtonStyle(notesFrame.CancelButton)
    notesFrame.CancelButton:SetScript("OnClick", function()
        notesFrame:Hide()
    end)
    addon.UI.Theme:ApplyMainFrame(frame)
    frame:Hide()
end

-- Main-window preference actions
function UI:ResetWindowPosition()
    local frame = self.MainFrame

    frame:ClearAllPoints()
    frame:SetPoint("CENTER")

    RolodexDB.Window.Point = "CENTER"
    RolodexDB.Window.X = 0
    RolodexDB.Window.Y = 0
end

function UI:ResetWindowSize()
    local frame = self.MainFrame

    frame:SetSize(DEFAULT_FRAME_WIDTH, 500)

    RolodexDB.Window.Width = DEFAULT_FRAME_WIDTH
    RolodexDB.Window.Height = 500
end

function UI:UpdateColumnLayout()
    local frame = self.MainFrame
    local headers = frame.ColumnHeaders
    local cursor = 235
    local mostRecent = addon.DB:GetSetting("ShowMostRecent")

    local function setRowAnchor(field, x, width, centered)
        for _, row in ipairs(frame.Rows) do
            row[field]:ClearAllPoints()
            row[field]:SetPoint("LEFT", row, "LEFT", x, 0)
            if width then
                row[field]:SetWidth(width)
            end
            if centered then
                row[field]:SetJustifyH("CENTER")
            end
        end
    end

    local function setHeaderAnchor(name, x, width)
        local header = headers[name]
        header:ClearAllPoints()
        if width then
            header:SetWidth(width)
        end
        header:SetPoint(
            "TOPLEFT",
            frame.ColumnHeaderOverlay,
            "TOPLEFT",
            x,
            -34
        )
    end

    local function configureColumn(name, setting, field, spacing, centered)
        local enabled = addon.DB:GetSetting(setting)
        local header = headers[name]

        if enabled then
            setRowAnchor(field, cursor, spacing, centered)
            setHeaderAnchor(name, cursor + 25, spacing)
            header:Show()
            cursor = cursor + spacing
        else
            header:Hide()
            for _, row in ipairs(frame.Rows) do
                row[field]:Hide()
            end
        end
    end

    configureColumn("Class", "ShowClass", "ClassText", 90)
    configureColumn("Guild", "ShowGuild", "GuildText", 135)
    configureColumn("Rating", "ShowAverageRating", "RatingText", 75, true)
    configureColumn("Groups", "ShowGroups", "GroupsText", 75, true)

    if mostRecent then
        setRowAnchor("MostRecentText", cursor, 105, true)
        setHeaderAnchor("Most Recent", cursor + 25, 105)
        headers["Most Recent"]:Show()
        cursor = cursor + 105
    else
        headers["Most Recent"]:Hide()
        for _, row in ipairs(frame.Rows) do
            row.MostRecentText:Hide()
        end
    end

    setRowAnchor("NoteButton", cursor + 27.5)
    setHeaderAnchor("Notes", cursor + 25, 75)

    local requiredContentWidth = cursor + 75
    local rowWidth = math.max(720, requiredContentWidth)
    for _, row in ipairs(frame.Rows) do
        row:SetWidth(rowWidth)
    end
    local scrollChildWidth = rowWidth + 15
    frame.ScrollChild:SetWidth(scrollChildWidth)
    local requiredFrameWidth = scrollChildWidth + 40
    if frame:GetWidth() < requiredFrameWidth then
        frame:SetWidth(requiredFrameWidth)
    end

    headers.Flag:Show()
    headers.Name:Show()
    headers.Notes:Show()
end

-- ============================================================================
-- Refresh Player List
--
-- Updates all visible player rows.
-- ============================================================================
function UI:RefreshPlayerList()

    if not self.MainFrame then
        return
    end

    local playerNames = {}
    local searchText = string.lower(
        self.SearchText or ""
    )

    -- Build sortable name list.
    for name in pairs(
        addon.DB:GetAllPlayers()
    ) do

        local player = addon.DB:GetPlayer(name)
        if addon.UI.Search:Matches(name, player, searchText) then
            table.insert(
                playerNames,
                name
            )
        end

    end
    table.sort(
        playerNames,
        function(a, b)
            local playerA = addon.DB:GetPlayer(a)
            local playerB = addon.DB:GetPlayer(b)

            if self.SortMode == "FLAG" then
                local flagPriorityA = playerA.favorite and 0 or (playerA.avoid and 2 or 1)
                local flagPriorityB = playerB.favorite and 0 or (playerB.avoid and 2 or 1)

                if flagPriorityA ~= flagPriorityB then
                    return flagPriorityA < flagPriorityB
                end
            else
                local favoritePriority = self:IsFavoritePriority(a, b)
                if favoritePriority ~= nil then
                    return favoritePriority
                end
            end

            if self.SortMode == "CLASS" then
                local classA = addon.UI.Theme:FormatClassName(playerA.class)
                local classB = addon.UI.Theme:FormatClassName(playerB.class)
                local emptyA = classA == "Unknown"
                local emptyB = classB == "Unknown"

                if emptyA ~= emptyB then
                    return not emptyA
                end
                if classA ~= classB then
                    return classA < classB
                end
            elseif self.SortMode == "RATING" then
                local ratingA = addon.DB:GetAverageRating(a)
                local ratingB = addon.DB:GetAverageRating(b)

                if ratingA ~= ratingB then
                    return ratingA > ratingB
                end
            elseif self.SortMode == "GROUPS" then
                local groupsA = playerA.groups or 0
                local groupsB = playerB.groups or 0

                if groupsA ~= groupsB then
                    return groupsA > groupsB
                end
            elseif self.SortMode == "MOST_RECENT" then
                local mostRecentA = playerA.lastGroupTogether or 0
                local mostRecentB = playerB.lastGroupTogether or 0

                if mostRecentA <= 0 then
                    mostRecentA = playerA.lastSeen or 0
                end
                if mostRecentB <= 0 then
                    mostRecentB = playerB.lastSeen or 0
                end

                if mostRecentA ~= mostRecentB then
                    return mostRecentA > mostRecentB
                end
            elseif self.SortMode == "GUILD" then
                local guildA = playerA.guild or ""
                local guildB = playerB.guild or ""

                if guildA ~= guildB then
                    return guildA < guildB
                end
            elseif self.SortMode == "NOTES" then
                local hasNotesA = playerA.notes and playerA.notes ~= ""
                local hasNotesB = playerB.notes and playerB.notes ~= ""

                if hasNotesA ~= hasNotesB then
                    return hasNotesA
                end
            end

            return a < b
        end
    )
    local viewportHeight =
        self.MainFrame.ScrollFrame:GetHeight()
    local contentHeight = viewportHeight
    if #playerNames > 0 then
        contentHeight = math.max(
            viewportHeight,
            24 + ((#playerNames - 1) * 22)
        )
    end
    self.MainFrame.ScrollChild:SetHeight(
        contentHeight
    )
    for i = #self.MainFrame.Rows + 1, #playerNames do
        self.MainFrame.Rows[i] =
            addon.UI.BusinessCard:Create(
                self.MainFrame.ScrollChild,
                i
            )
    end
    self:UpdateColumnLayout()

    local maxScroll = math.max(
        0,
        contentHeight - viewportHeight
    )
    self.MainFrame.ScrollFrame:SetVerticalScroll(
        math.min(
            self.MainFrame.ScrollFrame:GetVerticalScroll(),
            maxScroll
        )
    )
    self.MainFrame.ScrollBar:SetMinMaxValues(0, maxScroll)
    self.MainFrame.ScrollBar:SetValue(
        math.min(
            self.MainFrame.ScrollFrame:GetVerticalScroll(),
            maxScroll
        )
    )

    -- Populate rows.
    for i, row in ipairs(
        self.MainFrame.Rows
    ) do

        local playerName =
            playerNames[i]

        if playerName then

            local player =
                addon.DB:GetPlayer(
                    playerName
                )

            row.PlayerName =
                playerName          

            addon.UI.BusinessCard:Refresh(
                row,
                player,
                playerName
            )

            row:Show()

        else

            row:Hide()

        end

    end

end



-- Refresh Detail Card
-- Displays additional context and historical information.
-- ============================================================================

function UI:RefreshDetailCard()

    if not self.ExpandedPlayer then

        self.MainFrame.DetailCard:Hide()

        return

    end

    local player =
        addon.DB:GetPlayer(
            self.ExpandedPlayer
        )

    if not player then

        self.MainFrame.DetailCard:Hide()

        return

    end

    local selectedRow = nil

    for _, row in ipairs(
        self.MainFrame.Rows
    ) do

        if row.PlayerName ==
            self.ExpandedPlayer then

            selectedRow = row
            break

        end

    end

    if not selectedRow then

        self.MainFrame.DetailCard:Hide()

        return

    end

        local card =
        self.MainFrame.DetailCard

    -- Position Card
    -- ==========================================================

    card:ClearAllPoints()

    card:SetPoint("TOPLEFT", selectedRow, "BOTTOMLEFT", 17, -8)

    addon.UI.DetailCard:Refresh(
        card,
        player
    )

    card:Show()
end

-- Toggle Window
-- ============================================================================

function UI:ToggleMainFrame()

    if not self.MainFrame then
        self:CreateMainFrame()
    end

    if self.MainFrame:IsShown() then

        self.MainFrame:Hide()

    else

        self.MainFrame:Show()
        self:Refresh()

    end

end

function UI:ShowPlayer(playerName)
    if not addon.DB:GetPlayer(playerName) then
        return false
    end

    if not self.MainFrame then
        self:CreateMainFrame()
    end

    local frame = self.MainFrame
    frame:Show()
    frame.SearchBox:SetText(playerName)
    self.SearchText = playerName
    self.SelectedRow = nil
    self.ExpandedPlayer = nil
    self:Refresh()

    for _, row in ipairs(frame.Rows) do
        if row.PlayerName == playerName then
            self.SelectedRow = row
            self.ExpandedPlayer = playerName
            break
        end
    end

    self:Refresh()
    return self.ExpandedPlayer == playerName
end

-- ============================================================================
-- End MainFrame.lua
