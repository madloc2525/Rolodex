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
local function FormatClassName(class)

    if not class then
        return "Unknown"
    end

    class = string.lower(class)

    return string.upper(
        string.sub(class, 1, 1)
    ) ..
    string.sub(class, 2)

end
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


-- ============================================================================
-- Create Player Row
-- ============================================================================

function UI:CreatePlayerRow(parent, index)

    local row = CreateFrame(
        "Button",
        nil,
        parent
    )

    row:SetSize(550, 20)

    row:SetPoint(
        "TOPLEFT",
        15,
        -40 - ((index - 1) * 22)
    )
    -- Flag (Favorite, Avoid or nil)
    row.FlagText = row:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
    )

    row.FlagText:SetPoint(
        "LEFT",
        5,
        0
    )
    -- Name
    row.NameText = row:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
    )

    row.NameText:SetPoint(
        "LEFT",
        25,
        0
    )
    -- Class
    row.ClassText = row:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    row.ClassText:SetPoint(
        "LEFT",
        180,
        0
    )
    -- Guild
    row.GuildText = row:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormalSmall"
    )

    row.GuildText:SetPoint(
        "LEFT",
        260,
        0
    )
    -- Rating
    row.RatingText = row:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
    )

    row.RatingText:SetPoint(
        "LEFT",
        400,
        0
    )
    -- Runs together
    row.RunsText = row:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
    )

    row.RunsText:SetPoint(
        "LEFT",
        450,
        0
    )
    -- Note
    row.NoteButton = CreateFrame(
    "Button",
    nil,
    row
)

    row.NoteButton:SetSize(
        20,
        20
    )

    row.NoteButton:SetPoint(
        "LEFT",
        500,
        0
    )

    row.NoteButton.Text =
        row.NoteButton:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    row.NoteButton.Text:SetAllPoints()

    row.NoteButton.Text:SetText("✎")

    row.NoteButton:SetScript(
    "OnClick",
    function()

        local player =
            addon.DB:GetPlayer(
                row.PlayerName
            )

        UI.NotePlayer =
            row.PlayerName

        UI.MainFrame.NotesFrame.Title:SetText(
            "Notes - " ..
            row.PlayerName
        )

        UI.MainFrame.NotesFrame.EditBox:SetText(
            player.notes or ""
        )

        UI.MainFrame.NotesFrame:Show()

        UI.MainFrame.NotesFrame.EditBox:SetFocus()

    end
)


    row:SetScript("OnClick", function()

        if UI.ExpandedPlayer ==
        row.PlayerName then

            UI.ExpandedPlayer = nil

        else

            UI.ExpandedPlayer =
                row.PlayerName

        end

        UI:Refresh()

    end)

    return row

end



-- Main Frame Creation
-- ============================================================================

function UI:CreateMainFrame()

    local frame = CreateFrame(
        "Frame",
        "RolodexMainFrame",
        UIParent,
        "BasicFrameTemplateWithInset"
    )

    frame:SetSize(800, 500)
    frame:SetPoint("CENTER")

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
        "TOP",
        0,
        -8
    )

    frame.title:SetText("Rolodex")


    -- Sort button (cycling for now)
    -- =========================================================
    frame.SortButton = CreateFrame(
        "Button",
        nil,
        frame,
        "UIPanelButtonTemplate"
    )

    frame.SortButton:SetSize(100, 22)

    frame.SortButton:SetPoint(
        "TOPRIGHT",
        -110,
        -28
    )

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

    -- Player Rows
    -- ==========================================================

    frame.Rows = {}

    for i = 1, 20 do

        frame.Rows[i] = self:CreatePlayerRow(
            frame,
            i
        )

    end


    -- Detail Card
    -- ==========================================================

    frame.DetailCard = CreateFrame(
        "Frame",
        nil,
        frame,
        "BasicFrameTemplateWithInset"
    )

    frame.DetailCard:SetSize(340, 250)

    frame.DetailCard:SetFrameStrata("HIGH")
    frame.DetailCard:SetFrameLevel(100)

    frame.DetailCard:Hide()

    -- Position is set dynamically in RefreshDetailCard().

    local card = frame.DetailCard

    card.CloseButton:Hide()


    -- CORE SECTION
    -- ==========================================================

    card.NameText = card:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontHighlight"
    )

    card.NameText:SetPoint(
        "TOPLEFT",
        10,
        -30
    )

    card.ClassText = card:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    card.ClassText:SetPoint(
        "TOPLEFT",
        card.NameText,
        "BOTTOMLEFT",
        0,
        -5
    )

    card.GuildText = card:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    card.GuildText:SetPoint(
        "TOPLEFT",
        card.ClassText,
        "BOTTOMLEFT",
        0,
        -5
    )

    card.RatingText = card:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    card.RatingText:SetPoint(
        "TOPLEFT",
        card.GuildText,
        "BOTTOMLEFT",
        0,
        -5
    )

    card.RunsText = card:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    card.RunsText:SetPoint(
        "TOPLEFT",
        card.RatingText,
        "BOTTOMLEFT",
        0,
        -5
    )

    card.NotesText = card:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormalSmall"
    )

    card.NotesText:SetWidth(300)
    card.NotesText:SetJustifyH("LEFT")

    card.NotesText:SetPoint(
        "TOPLEFT",
        card.RunsText,
        "BOTTOMLEFT",
        0,
        -8
    )

    -- ==========================================================
    -- Divider
    -- ==========================================================

    card.Divider = card:CreateTexture(
        nil,
        "ARTWORK"
    )

    card.Divider:SetColorTexture(
        0.4,
        0.4,
        0.4,
        1
    )

    card.Divider:SetSize(
        300,
        1
    )

    card.Divider:SetPoint(
        "TOPLEFT",
        card.NotesText,
        "BOTTOMLEFT",
        0,
        -10
    )

    -- ==========================================================
    -- HISTORICAL SECTION
    -- ==========================================================

    card.FirstSeenText = card:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    card.FirstSeenText:SetPoint(
        "TOPLEFT",
        card.Divider,
        "BOTTOMLEFT",
        0,
        -10
    )

    card.LastSeenText = card:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    card.LastSeenText:SetPoint(
        "TOPLEFT",
        card.FirstSeenText,
        "BOTTOMLEFT",
        0,
        -5
    )

    card.LastLevelText = card:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    card.LastLevelText:SetPoint(
        "TOPLEFT",
        card.LastSeenText,
        "BOTTOMLEFT",
        0,
        -5
    )

    card.LastSpecText = card:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    card.LastSpecText:SetPoint(
        "TOPLEFT",
        card.LastLevelText,
        "BOTTOMLEFT",
        0,
        -5
    )

    card.LastRatingText = card:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    card.LastRatingText:SetPoint(
        "TOPLEFT",
        card.LastSpecText,
        "BOTTOMLEFT",
        0,
        -5
    )

    card.RatingHistoryText = card:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormalSmall"
    )

    card.RatingHistoryText:SetWidth(300)
    card.RatingHistoryText:SetJustifyH("LEFT")

    card.RatingHistoryText:SetPoint(
        "TOPLEFT",
        card.LastRatingText,
        "BOTTOMLEFT",
        0,
        -5
    )

    -- Note Frame Editor Window
    -- ==========================================================

    frame.NotesFrame = CreateFrame(
        "Frame",
        nil,
        frame,
        "BasicFrameTemplateWithInset"
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

    -- Build sortable name list.
    for name in pairs(
        addon.DB:GetAllPlayers()
    ) do

        table.insert(
            playerNames,
            name
        )

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
                    FormatClassName(
                        pa.class
                    )

                local classB =
                    FormatClassName(
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

            -- Flag
            -- =====================================================

            local flag = ""

            if player.favorite then

                flag = "★"

            elseif player.avoid then

                flag = "⚠"

            end

            row.FlagText:SetText(
                flag
            )
            -- Name
            -- =====================================================

            row.NameText:SetText(
                player.name or ""
            )
            -- Class
            -- =====================================================
           
            row.ClassText:SetText(
                FormatClassName(
                    player.class
                )
            )
            local classColor =
                RAID_CLASS_COLORS[
                    player.class or ""
                ]
            if classColor then

                row.ClassText:SetTextColor(
                    classColor.r,
                    classColor.g,
                    classColor.b
                )
            else
                row.ClassText:SetTextColor(
                    1,
                    1,
                    1
                )
            end
            -- Guild
            -- =====================================================
            row.GuildText:SetText(
                player.guild or "-"
            )
            -- Rating
            -- =====================================================

            row.RatingText:SetText(
                string.format(
                    "%.1f",
                    addon.DB:GetAverageRating(
                        player.name
                    )
                )
            )


            -- Runs
            -- =====================================================

            row.RunsText:SetText(
                tostring(
                    player.runs or 0
                )
            )


            -- Notes Indicator
            -- =====================================================

            if player.notes
                and player.notes ~= "" then

                    row.NoteButton:SetText(
                        "📝"
                    )

                else

                    row.NoteButton:SetText(
                        ""
                    )

                end

            -- Highlight Selected Row
            -- =====================================================

            if playerName ==
                self.ExpandedPlayer then

                row.NameText:SetTextColor(
                    1,
                    1,
                    0
                )

            else

                row.NameText:SetTextColor(
                    1,
                    1,
                    1
                )

            end

            row:Show()

        else

            row:Hide()

        end

    end

end


-- ============================================================================
-- Refresh Detail Card
--
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

    -- ==========================================================
    -- Position Card
    -- ==========================================================

    card:ClearAllPoints()

    card:SetPoint(
        "TOPLEFT",
        selectedRow,
        "BOTTOMLEFT",
        20,
        5
    )

    -- ==========================================================
    -- Notes / Context
    -- ==========================================================

    local note =
    player.notes or ""

    if note == "" then

        note = "No notes recorded."

    end

    card.NotesText:SetText(
        "Notes:\n\n" ..
        note
    )

    -- ==========================================================
    -- Historical Information
    -- ==========================================================

    card.FirstSeenText:SetText(
        "First Seen: " ..
        addon:FormatTimestamp(
            player.firstSeen
        )
    )

    card.LastSeenText:SetText(
        "Last Seen: " ..
        addon:FormatTimestamp(
            player.lastSeen
        )
    )

    card.LastLevelText:SetText(
        "Last Seen Level: " ..
        tostring(
            player.lastSeenLevel or 0
        )
    )

    card.LastSpecText:SetText(
        "Last Seen Spec: " ..
        tostring(
            player.lastSeenSpec or
            "Unknown"
        )
    )

    card.LastRatingText:SetText(
        "Latest Rating: " ..
        tostring(
            addon.DB:GetLastRating(
                player.name
            )
        )
    )

    card.RatingHistoryText:SetText(
        "Rating History: " ..
        addon.DB:GetRatingHistoryString(
            player.name
        )
    )

    card:Show()

end

-- ============================================================================
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
-- ============================================================================