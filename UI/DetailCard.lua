local addon = Rolodex

addon.UI = addon.UI or {}

local DetailCard = {}

addon.UI.DetailCard = DetailCard

local UI = addon.UI

StaticPopupDialogs["ROLODEX_DELETE_PLAYER"] = {
    text = "Delete %s from the Rolodex?",
    button1 = YES,
    button2 = CANCEL,
    OnAccept = function(_, playerName)
        addon.DB:DeletePlayer(playerName)
        UI.ExpandedPlayer = nil
        UI.SelectedRow = nil
        UI:Refresh()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
}

local function CreateText(card, template, ...)
    local text = card:CreateFontString(nil, "OVERLAY", template)
    text:SetPoint(...)
    return text
end

function DetailCard:Create(parent)
    local card = CreateFrame(
        "Frame",
        nil,
        parent,
        addon.UI.Theme:IsClassicTheme() and "BasicFrameTemplateWithInset" or nil
    )

    card:SetSize(480, 240)
    card:SetFrameStrata("HIGH")
    card:SetFrameLevel(100)
    card:Hide()
    if card.CloseButton and not addon.UI.Theme:IsClassicTheme() then
        card.CloseButton:Hide()
    end
    if card.TitleText then
        card.TitleText:SetText("Player Details")
    end
    if card.CloseButton then
        card.CloseButton:SetScript("OnClick", function()
            UI.SelectedRow = nil
            UI.ExpandedPlayer = nil
            UI:Refresh()
        end)
    end
    if card.Bg and not addon.UI.Theme:IsClassicTheme() then
        card.Bg:Hide()
    end
    addon.UI.Theme:ApplyPaperBackground(card)

    local content = CreateFrame("Frame", nil, card)
    content:SetAllPoints(card)
    content:SetFrameLevel(card:GetFrameLevel() + 2)
    card.Content = content

    -- Notes
    card.NotesHeader = CreateText(
        content,
        "GameFontHighlight",
        "TOPLEFT",
        card,
        12,
        -30
    )
    card.NotesHeader:SetText("Notes")
    addon.UI.Theme:ApplyHeaderStyle(card.NotesHeader)

    card.NotesText = CreateText(
        content,
        "GameFontNormalSmall",
        "TOPLEFT",
        card.NotesHeader,
        "BOTTOMLEFT",
        0,
        -5
    )
    addon.UI.Theme:ApplyBodyStyle(
        card.NotesText
    )
    card.NotesText:SetWidth(450)
    card.NotesText:SetJustifyH("LEFT")

    -- Divider
    card.Divider = content:CreateTexture(nil, "OVERLAY")
    card.Divider:SetSize(450, 0)
    card.Divider:SetPoint("TOPLEFT", card.NotesText, "BOTTOMLEFT", 0, -10)
    addon.UI.Theme:ApplyDividerStyle(card.Divider)

    -- Character column
    card.CharacterHeader = CreateText(
        content,
        "GameFontHighlight",
        "TOPLEFT",
        card.Divider,
        "BOTTOMLEFT",
        0,
        -10
    )
    card.CharacterHeader:SetText("Character")
    addon.UI.Theme:ApplyHeaderStyle(card.CharacterHeader)

    card.LastLevelText = CreateText(
        content,
        "GameFontNormal",
        "TOPLEFT",
        card.CharacterHeader,
        "BOTTOMLEFT",
        0,
        -10
    )
    addon.UI.Theme:ApplyBodyStyle(card.LastLevelText)

    card.LastRoleLabel = CreateText(
        content,
        "GameFontNormal",
        "TOPLEFT",
        card.LastLevelText,
        "BOTTOMLEFT",
        0,
        -10
    )
    addon.UI.Theme:ApplyBodyStyle(card.LastRoleLabel)

    card.LastRoleValue = CreateText(
        content,
        "GameFontNormal",
        "LEFT",
        card.LastRoleLabel,
        "RIGHT",
        5,
        0
    )

    card.DeletePlayerButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    card.DeletePlayerButton:SetSize(60, 22)
    card.DeletePlayerButton:SetPoint("TOPLEFT", card.LastRoleLabel, "BOTTOMLEFT", 0, -12)
    card.DeletePlayerButton:SetText("Delete")
    addon.UI.Theme:ApplyButtonStyle(card.DeletePlayerButton)
    card.DeletePlayerButton:SetScript("OnClick", function()
        local playerName = UI.ExpandedPlayer
        if playerName then
            StaticPopup_Show("ROLODEX_DELETE_PLAYER", playerName, nil, playerName)
        end
    end)

    -- Rating column
    card.RatingHeader = CreateText(
        content,
        "GameFontHighlight",
        "TOPLEFT",
        card.Divider,
        "BOTTOMLEFT",
        150,
        -10
    )
    card.RatingHeader:SetText("Rating")
    addon.UI.Theme:ApplyHeaderStyle(card.RatingHeader)

    card.CurrentRatingText = CreateText(
        content,
        "GameFontNormal",
        "TOPLEFT",
        card.RatingHeader,
        "BOTTOMLEFT",
        0,
        -10
    )
    addon.UI.Theme:ApplyBodyStyle(card.CurrentRatingText)

    -- Group history column
    card.HistoryHeader = CreateText(
        content,
        "GameFontHighlight",
        "TOPLEFT",
        card.Divider,
        "BOTTOMLEFT",
        300,
        -10
    )
    card.HistoryHeader:SetText("Group History")
    addon.UI.Theme:ApplyHeaderStyle(card.HistoryHeader)

    card.HistoryScrollFrame = CreateFrame("ScrollFrame", nil, content, "UIPanelScrollFrameTemplate")
    card.HistoryScrollFrame:SetPoint("TOPLEFT", card.HistoryHeader, "BOTTOMLEFT", 0, -8)
    card.HistoryScrollFrame:SetSize(170, 150)
    card.HistoryContent = CreateFrame("Frame", nil, card.HistoryScrollFrame)
    card.HistoryContent:SetSize(140, 1)
    card.HistoryScrollFrame:SetScrollChild(card.HistoryContent)
    card.HistoryRows = {}

    -- Manual rating controls
    card.Rating1Button = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    card.Rating1Button:SetSize(25, 20)
    card.Rating1Button:SetPoint("TOPLEFT", card.CurrentRatingText, "BOTTOMLEFT", 0, -10)
    card.Rating1Button:SetText("1")

    card.Rating2Button = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    card.Rating2Button:SetSize(25, 20)
    card.Rating2Button:SetPoint("LEFT", card.Rating1Button, "RIGHT", 5, 0)
    card.Rating2Button:SetText("2")

    card.Rating3Button = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    card.Rating3Button:SetSize(25, 20)
    card.Rating3Button:SetPoint("LEFT", card.Rating2Button, "RIGHT", 5, 0)
    card.Rating3Button:SetText("3")
    addon.UI.Theme:ApplyButtonStyle(card.Rating1Button)
    addon.UI.Theme:ApplyButtonStyle(card.Rating2Button)
    addon.UI.Theme:ApplyButtonStyle(card.Rating3Button)

    card.LastRatingText = CreateText(
        content,
        "GameFontNormal",
        "TOPLEFT",
        card.Rating1Button,
        "BOTTOMLEFT",
        0,
        -10
    )
    addon.UI.Theme:ApplyBodyStyle(card.LastRatingText)

    local function AddRating(rating)
        local playerName = UI.ExpandedPlayer
        if not playerName then
            return
        end

        addon.DB:AddRating(playerName, rating)
        UI:Refresh()
    end

    card.Rating1Button:SetScript("OnClick", function()
        AddRating(1)
    end)
    card.Rating2Button:SetScript("OnClick", function()
        AddRating(2)
    end)
    card.Rating3Button:SetScript("OnClick", function()
        AddRating(3)
    end)

    return card
end

-- Refresh function
-- ======================================================================
function DetailCard:Refresh(card, player) 

    local settings = RolodexDB.Settings
    -- Move columns down with visible notes, but keep top padding when notes are hidden.

    if settings.ShowNotes then
        local note = player.notes or ""
        if note == "" then
            note = "No notes recorded."
        end
        card.NotesText:SetText(note)
        card.NotesHeader:Show()
        card.NotesText:Show()
        card.Divider:ClearAllPoints()
        card.Divider:SetPoint("TOPLEFT", card.NotesText, "BOTTOMLEFT", 0, -10)
    else
        card.NotesHeader:Hide()
        card.NotesText:Hide()
        card.Divider:ClearAllPoints()
        card.Divider:SetPoint("TOPLEFT", card, "TOPLEFT", 12, -40)
    end

    local showCharacterSection = not not settings.ShowCharacterSection
    card.CharacterHeader:SetShown(showCharacterSection)
    card.LastLevelText:SetShown(showCharacterSection)
    card.LastRoleLabel:SetShown(showCharacterSection)
    card.LastRoleValue:SetShown(showCharacterSection)
    card.DeletePlayerButton:SetShown(showCharacterSection)

    local showRatingSection = not not settings.ShowRatingSection
    local showManualRating = showRatingSection and not not settings.EnableManualRating
    local showRatingHistory = showRatingSection and not not settings.ShowRatingHistory
    card.RatingHeader:SetShown(showRatingSection)
    card.CurrentRatingText:SetShown(showRatingSection)
    card.Rating1Button:SetShown(showManualRating)
    card.Rating2Button:SetShown(showManualRating)
    card.Rating3Button:SetShown(showManualRating)
    card.LastRatingText:SetShown(showRatingHistory)

    card.LastLevelText:SetText(
        "Last Level: " .. tostring(player.lastSeenLevel or "-")
    )
    card.LastRoleLabel:SetText("Last Role:")

    card.LastRoleValue:SetText(addon.UI.Theme:FormatRole(player.lastSeenRole))

    local averageRating = addon.DB:GetAverageRating(player.name)
    if averageRating == 0 then
        card.CurrentRatingText:SetText("Current Rating: -")
    else
        card.CurrentRatingText:SetText(string.format("Average: %.1f", averageRating))
    end
    card.LastRatingText:SetText("Last Rating: " .. tostring(addon.DB:GetLastRating(player.name) or "-"))
    local history = addon.DB:GetGroupHistory(player.name)
    local rowIndex = 1
    for i = #history, 1, -1 do
        local entry = history[i]
        local timestamp = type(entry) == "table"
            and entry.timestamp
            or entry
        local row = card.HistoryRows[rowIndex]

        if not row then
            row = CreateText(
                card.HistoryContent,
                "GameFontNormal",
                "TOPLEFT",
                card.HistoryContent,
                "TOPLEFT",
                0,
                -((rowIndex - 1) * 18)
            )
            addon.UI.Theme:ApplyBodyStyle(row)
            card.HistoryRows[rowIndex] = row
        end

        row:SetText(
            date(
                "%d %b %Y %H:%M",
                timestamp
            )
        )
        row:Show()
        rowIndex = rowIndex + 1
    end

    for i = rowIndex, #card.HistoryRows do
        card.HistoryRows[i]:Hide()
    end

    card.HistoryContent:SetHeight(
        math.max(1, (#history * 18))
    )

    card.HistoryHeader:SetShown(settings.ShowGroupHistory)
    card.HistoryScrollFrame:SetShown(settings.ShowGroupHistory)

end
