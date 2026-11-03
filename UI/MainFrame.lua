-- ============================================================================
-- MainFrame.lua
--
-- Main Rolodex window.
--
-- Version 0.4
--
-- Features:
-- - Movable frame
-- - Clickable player rows
-- - Selected player tracking
-- - Detail card display
--
-- ============================================================================

local addon = Rolodex

addon.UI = addon.UI or {}

local UI = addon.UI

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


-- Create Main Frame
-- ============================================================================

function UI:CreateMainFrame()

    local frame = CreateFrame(
        "Frame",
        "RolodexMainFrame",
        UIParent,
        "BasicFrameTemplateWithInset"
    )

    frame:SetSize(600, 380)
    frame:SetPoint("CENTER")
    -- addon.UI.ThemeMainFrame:Apply(
    --     frame
    -- )
    if frame.Bg then
        frame.Bg:Hide()
    end

    frame:SetMovable(true)
    frame:EnableMouse(true)

    frame:RegisterForDrag("LeftButton")

    frame:SetScript(
        "OnDragStart",
        frame.StartMoving
    )

    frame:SetScript(
        "OnDragStop",
        frame.StopMovingOrSizing
    )

    frame:Hide()

    self.MainFrame = frame

    -- Title
    -- ==========================================================

    frame.title = frame:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontHighlight"
    )

    frame.title:SetPoint(
        "TOPLEFT",
        50,
        -8
    )

    frame.title:SetText("Rolodex")
    frame.title:SetTextColor(1, 1, 1)

    frame.SearchBox = addon.UI.Search:Create(frame)
    frame.SearchBox:SetTextColor(1, 1, 1)

    -- Sort button (cycling for now)
    -- =========================================================
    frame.SortButton = CreateFrame(
        "Button",
        nil,
        frame,
        "UIPanelButtonTemplate"
    )

    frame.SortButton:SetSize(100, 22)

    frame.SortButton:SetText(
        "Sort: Name"
    )
    frame.SortButton:SetScript(
        "OnClick",
        function()

            if UI.SortMode == "NAME" then

                UI.SortMode = "CLASS"

            elseif UI.SortMode == "CLASS" then

                UI.SortMode = "GUILD"

            elseif UI.SortMode == "GUILD" then

                UI.SortMode = "RATING"

            elseif UI.SortMode == "RATING" then

                UI.SortMode = "RUNS"

            else

                UI.SortMode = "NAME"

            end

            frame.SortButton:SetText(
                "Sort: " .. UI.SortMode
            )

            UI:Refresh()
        end
    )

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
    frame.SettingsButton.Icon:SetVertexColor(1, 0.2, 0.2)
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

    frame.SortButton:SetPoint(
        "RIGHT",
        frame.SettingsButton,
        "LEFT",
        -6,
        0
    )
    frame.SearchBox:SetPoint(
        "RIGHT",
        frame.SortButton,
        "LEFT",
        -8,
        0
    )

    local columnHeaders = {
        { "Flag", 25 },
        { "Name", 50 },
        { "Class", 205 },
        { "Guild", 285 },
        { "Rating", 425 },
        { "Runs", 475 },
        { "Notes", 525 }
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

frame.ColumnHeaders = {}
for index, column in ipairs(columnHeaders) do
    local header = frame.ColumnHeaderOverlay:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormalSmall"
    )
    header:SetPoint(
        "TOPLEFT",
        frame.ColumnHeaderOverlay,
        "TOPLEFT",
        column[2],
        -34
    )
    header:SetText(column[1])
    header:SetTextColor(1, 1, 1)
    frame.ColumnHeaders[index] = header
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
        frame
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

    addon.UI.ThemePaper:Apply(
        frame.NotesFrame
    )

    frame.NotesFrame:Hide()

    local notesFrame =
        frame.NotesFrame

    -- Note FrameTitle
    -- ==========================================================

    notesFrame.Title =
        notesFrame:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontHighlight"
        )

    notesFrame.Title:SetPoint(
        "TOP",
        0,
        -10
    )

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
            notesFrame.ScrollFrame)
    notesFrame.EditBox:SetMultiLine(true)
    notesFrame.EditBox:SetFontObject(ChatFontNormal)
    notesFrame.EditBox:SetAutoFocus(false)
    notesFrame.EditBox:EnableMouse(true)
    notesFrame.EditBox:SetWidth(320)
    notesFrame.EditBox:SetText("")
    addon.UI.Theme:ApplyBodyStyle(
        notesFrame.EditBox
    )
    notesFrame.ScrollFrame:SetScrollChild(
        notesFrame.EditBox
    )
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

    notesFrame.CancelButton =
        CreateFrame(
            "Button",
            nil,
            notesFrame,
            "UIPanelButtonTemplate"
        )

    notesFrame.CancelButton:SetSize(
        100,
        22
    )

    notesFrame.CancelButton:SetPoint(
        "BOTTOMRIGHT",
        -80,
        15
    )

    notesFrame.CancelButton:SetText(
        "Cancel"
    )

    notesFrame.CancelButton:SetScript(
        "OnClick",
        function()
            notesFrame:Hide()
        end
    )


end -- Close CreateMainFrame

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

    if self.SortMode == "NAME" then

    table.sort(
        playerNames,
        function(a, b)

            return a < b

        end
    )

    elseif self.SortMode == "CLASS" then

        table.sort(
            playerNames,
            function(a, b)

                local pa =
                    addon.DB:GetPlayer(a)

                local pb =
                    addon.DB:GetPlayer(b)

                local classA =
                    addon.UI.Theme:FormatClassName(
                        pa.class
                    )

                local classB =
                    addon.UI.Theme:FormatClassName(
                        pb.class
                    )

                -- Nulls last.
                local emptyA =
                    classA == "Unknown"

                local emptyB =
                    classB == "Unknown"

                if emptyA ~= emptyB then
                    return not emptyA
                end

                -- Tie-breaker.
                if classA == classB then
                    return a < b
                end

                return classA < classB

            end
        )

    elseif self.SortMode == "RATING" then

        table.sort(
            playerNames,
            function(a, b)

                return
                    addon.DB:GetAverageRating(a)
                    >
                    addon.DB:GetAverageRating(b)

            end
        )

    elseif self.SortMode == "RUNS" then

        table.sort(
            playerNames,
            function(a, b)

                local pa =
                    addon.DB:GetPlayer(a)

                local pb =
                    addon.DB:GetPlayer(b)

                return
                    (pa.runs or 0)
                    >
                    (pb.runs or 0)

            end
        )

    elseif self.SortMode == "GUILD" then

        table.sort(
            playerNames,
            function(a, b)

                local pa =
                    addon.DB:GetPlayer(a)

                local pb =
                    addon.DB:GetPlayer(b)

                local guildA =
                    pa.guild or ""

                local guildB =
                    pb.guild or ""

                return guildA < guildB

            end
        )

    end

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

    card:SetPoint(
        "TOPLEFT",
        selectedRow,
        "BOTTOMLEFT",
        17,
        25
    )

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
        return
    end

    if self.MainFrame:IsShown() then

        self.MainFrame:Hide()

    else

        self:Refresh()

        self.MainFrame:Show()

    end

end

-- ============================================================================
-- End MainFrame.lua
