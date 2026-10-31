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

    row.Text = row:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    row.Text:SetPoint(
        "LEFT",
        5,
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

    -- ==========================================================
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

    -- ==========================================================
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
    -- Appears under the selected player row and overlays the
    -- rows below it, mimicking a Rolodex card being pulled out.
    -- ==========================================================

    frame.DetailCard = CreateFrame(
        "Frame",
        nil,
        frame,
        "BasicFrameTemplateWithInset"
    )

    frame.DetailCard:SetSize(250, 140)

    frame.DetailCard:SetFrameStrata("HIGH")
    frame.DetailCard:SetFrameLevel(100)

    frame.DetailCard:Hide()

    -- Card Title

    frame.DetailCard.NameText =
        frame.DetailCard:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontHighlight"
        )

    frame.DetailCard.NameText:SetPoint(
        "TOPLEFT",
        10,
        -30
    )

    -- Class

    frame.DetailCard.ClassText =
        frame.DetailCard:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    frame.DetailCard.ClassText:SetPoint(
        "TOPLEFT",
        frame.DetailCard.NameText,
        "BOTTOMLEFT",
        0,
        -5
    )

    -- Guild

    frame.DetailCard.GuildText =
        frame.DetailCard:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    frame.DetailCard.GuildText:SetPoint(
        "TOPLEFT",
        frame.DetailCard.ClassText,
        "BOTTOMLEFT",
        0,
        -5
    )

    -- Rating

    frame.DetailCard.RatingText =
        frame.DetailCard:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    frame.DetailCard.RatingText:SetPoint(
        "TOPLEFT",
        frame.DetailCard.GuildText,
        "BOTTOMLEFT",
        0,
        -5
    )

    -- Runs

    frame.DetailCard.RunsText =
        frame.DetailCard:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    frame.DetailCard.RunsText:SetPoint(
        "TOPLEFT",
        frame.DetailCard.RatingText,
        "BOTTOMLEFT",
        0,
        -5
    )

    -- Notes

    frame.DetailCard.NotesText =
        frame.DetailCard:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormalSmall"
        )

    frame.DetailCard.NotesText:SetWidth(220)

    frame.DetailCard.NotesText:SetJustifyH("LEFT")

    frame.DetailCard.NotesText:SetPoint(
        "TOPLEFT",
        frame.DetailCard.RunsText,
        "BOTTOMLEFT",
        0,
        -8
    )
end


-- ============================================================================
-- Refresh Player List
-- ============================================================================

function UI:RefreshPlayerList()

    if not self.MainFrame then
        return
    end

    local playerNames = {}

    for name in pairs(
        addon.DB:GetAllPlayers()
    ) do

        table.insert(
            playerNames,
            name
        )

    end

    table.sort(playerNames)

    if not self.SelectedPlayer
    and #playerNames > 0 then

        self.SelectedPlayer =
            playerNames[1]

    end

    for i, row in ipairs(
        self.MainFrame.Rows
    ) do

        local playerName =
            playerNames[i]

        if playerName then

            row.PlayerName =
                playerName

            row.Text:SetText(
                playerName
            )

            row:Show()

            if playerName ==
                self.SelectedPlayer then

                row.Text:SetTextColor(
                    1,
                    1,
                    0
                )

            else

                row.Text:SetTextColor(
                    1,
                    1,
                    1
                )

            end

        else

            row:Hide()

        end

    end

end


-- ============================================================================
-- Refresh Floating Detail Card
--
-- Updates card information and positions it beneath
-- the selected row.
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

    -- Move card beneath selected row.
    card:ClearAllPoints()

    card:SetPoint(
        "TOPLEFT",
        selectedRow,
        "BOTTOMLEFT",
        20,
        5
    )

    -- Calculate rating.

    local averageRating =
        addon.DB:GetAverageRating(
            player.name
        )

    -- Populate card.

    card.NameText:SetText(
        player.name
    )

    card.ClassText:SetText(
        "Class: " ..
        (player.class or "UNKNOWN")
    )

    card.GuildText:SetText(
        "Guild: " ..
        (player.guild or "")
    )

    card.RatingText:SetText(
        string.format(
            "Rating: %.2f",
            averageRating
        )
    )

    card.RunsText:SetText(
        "Runs: " ..
        tostring(player.runs or 0)
    )

    card.NotesText:SetText(
        player.notes or ""
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