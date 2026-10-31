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



-- Currently selected player.
UI.SelectedPlayer = nil
-- Sort
UI.SortMode = "NAME"

-- ============================================================================
-- Initialize
-- ============================================================================

function UI:Initialize()

    self:CreateMainFrame()

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

    row:SetSize(350, 20)

    row:SetPoint(
        "TOPLEFT",
        15,
        -40 - ((index - 1) * 22)
    )

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

    row.GuildText = row:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormalSmall"
    )

    row.GuildText:SetPoint(
        "LEFT",
        120,
        0
    )

    row.RatingText = row:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
    )

    row.RatingText:SetPoint(
        "LEFT",
        220,
        0
    )

    row.RunsText = row:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
    )

    row.RunsText:SetPoint(
        "LEFT",
        270,
        0
    )

    row.NoteText = row:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
    )

    row.NoteText:SetPoint(
        "LEFT",
        320,
        0
    )

    row:SetScript("OnClick", function()

        UI.SelectedPlayer = row.PlayerName

        UI:RefreshPlayerList()
        UI:RefreshDetailCard()

    end)

    return row

end


-- ============================================================================
-- Main Frame Creation
-- ============================================================================

function UI:CreateMainFrame()

    local frame = CreateFrame(
        "Frame",
        "RolodexMainFrame",
        UIParent,
        "BasicFrameTemplateWithInset"
    )

    frame:SetSize(400, 500)
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

                UI.SortMode = "RATING"

            elseif UI.SortMode == "RATING" then

                UI.SortMode = "RUNS"

            elseif UI.SortMode == "RUNS" then

                UI.SortMode = "GUILD"

            else

                UI.SortMode = "NAME"

            end

            frame.SortButton:SetText(
                "Sort: " .. UI.SortMode
            )

            UI:RefreshPlayerList()

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

        -- ==========================================================
    -- Floating Detail Card
    --
    -- Appears beneath the selected row and overlays any rows
    -- underneath it, mimicking a Rolodex card being pulled out.
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

    -- ==========================================================
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

    -- Auto-select first player if nothing selected.
    if not self.SelectedPlayer
    and #playerNames > 0 then

        self.SelectedPlayer =
            playerNames[1]

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

            -- =====================================================
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

            -- =====================================================
            -- Name
            -- =====================================================

            row.NameText:SetText(
                player.name or ""
            )

            -- =====================================================
            -- Guild
            -- =====================================================

            row.GuildText:SetText(
                player.guild or "-"
            )

            -- =====================================================
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

            -- =====================================================
            -- Runs
            -- =====================================================

            row.RunsText:SetText(
                tostring(
                    player.runs or 0
                )
            )

            -- =====================================================
            -- Notes Indicator
            -- =====================================================

            if player.notes
            and player.notes ~= "" then

                row.NoteText:SetText(
                    "📝"
                )

            else

                row.NoteText:SetText(
                    ""
                )

            end

            -- =====================================================
            -- Highlight Selected Row
            -- =====================================================

            if playerName ==
                self.SelectedPlayer then

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

    if not self.SelectedPlayer then

        self.MainFrame.DetailCard:Hide()

        return

    end

    local player =
        addon.DB:GetPlayer(
            self.SelectedPlayer
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
            self.SelectedPlayer then

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

    card.NotesText:SetText(
        "Notes:\n" ..
        (player.notes or "")
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

        self:RefreshPlayerList()
        self:RefreshDetailCard()

        self.MainFrame:Show()

    end

end

-- ============================================================================
-- End MainFrame.lua
-- ============================================================================