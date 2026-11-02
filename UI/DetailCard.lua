local addon = Rolodex

addon.UI = addon.UI or {}

local DetailCard = {}

addon.UI.DetailCard = DetailCard

local UI = addon.UI

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
        "BasicFrameTemplateWithInset"
    )

    card:SetSize(600, 250)
    card:SetFrameStrata("HIGH")
    card:SetFrameLevel(100)
    card:Hide()
    card.CloseButton:Hide()

   

-- Notes
    card.NotesText = CreateText(
        card,
        "GameFontNormalSmall",
        "TOPLEFT",
        card,
        12,
        -30
        )

    card.NotesText:SetWidth(560)
    card.NotesText:SetJustifyH("LEFT")

-- Divider

card.Divider =
    card:CreateTexture(
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
    560,
    1
)

card.Divider:SetPoint(
    "TOPLEFT",
    card.NotesText,
    "BOTTOMLEFT",
    0,
    -10
)

-- Character Column

card.CharacterHeader =
    CreateText(
        card,
        "GameFontHighlight",
        "TOPLEFT",
        card.Divider,
        "BOTTOMLEFT",
        0,
        -10
    )

card.CharacterHeader:SetText(
    "Character"
)

card.LastLevelText =
    CreateText(
        card,
        "GameFontNormal",
        "TOPLEFT",
        card.CharacterHeader,
        "BOTTOMLEFT",
        0,
        -10
    )

card.LastRoleText =
    CreateText(
        card,
        "GameFontNormal",
        "TOPLEFT",
        card.LastLevelText,
        "BOTTOMLEFT",
        0,
        -10
    )

-- Rating Column

card.RatingHeader =
    CreateText(
        card,
        "GameFontHighlight",
        "TOPLEFT",
        card.Divider,
        "BOTTOMLEFT",
        180,
        -10
    )

card.RatingHeader:SetText(
    "Rating"
)

card.CurrentRatingText =
    CreateText(
        card,
        "GameFontNormal",
        "TOPLEFT",
        card.RatingHeader,
        "BOTTOMLEFT",
        0,
        -10
    )

-- History Column

card.HistoryHeader =
    CreateText(
        card,
        "GameFontHighlight",
        "TOPLEFT",
        card.Divider,
        "BOTTOMLEFT",
        360,
        -10
    )

card.HistoryHeader:SetText(
    "History"
)

card.FirstSeenText =
    CreateText(
        card,
        "GameFontNormal",
        "TOPLEFT",
        card.HistoryHeader,
        "BOTTOMLEFT",
        0,
        -10
    )

card.LastSeenText =
    CreateText(
        card,
        "GameFontNormal",
        "TOPLEFT",
        card.FirstSeenText,
        "BOTTOMLEFT",
        0,
        -8
    )

card.RunsHistoryText =
    CreateText(
        card,
        "GameFontNormal",
        "TOPLEFT",
        card.LastSeenText,
        "BOTTOMLEFT",
        0,
        -8
    )
    
    -- Manual Rating Buttons
    card.Rating1Button = CreateFrame("Button", nil, card, "UIPanelButtonTemplate")
    card.Rating1Button:SetSize(25, 20)
    card.Rating1Button:SetPoint("TOPLEFT", card.CurrentRatingText, "BOTTOMLEFT", 0, -10)
    card.Rating1Button:SetText("1")

    card.Rating2Button = CreateFrame("Button", nil, card, "UIPanelButtonTemplate")
    card.Rating2Button:SetSize(25, 20)
    card.Rating2Button:SetPoint("LEFT", card.Rating1Button, "RIGHT", 5, 0)
    card.Rating2Button:SetText("2")

    card.Rating3Button = CreateFrame("Button", nil, card, "UIPanelButtonTemplate")
    card.Rating3Button:SetSize(25, 20)
    card.Rating3Button:SetPoint("LEFT", card.Rating2Button, "RIGHT", 5, 0)
    card.Rating3Button:SetText("3")

    card.LastRatingText =
    CreateText(
        card,
        "GameFontNormal",
        "TOPLEFT",
        card.Rating1Button,
        "BOTTOMLEFT",
        0,
        -10
    )
    

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

function DetailCard:Refresh(card, player) 

    local note = player.notes or ""
    if note == "" then
        note = "No notes recorded."
    end
    card.NotesText:SetText("Notes:\n" .. note)

    card.LastLevelText:SetText(
        "Last Level: " .. tostring(player.lastSeenLevel or "-")
    )
    card.LastRoleText:SetText(
        "Last Role: " .. addon.UI.Theme:FormatRole(player.lastSeenRole)
    )
    local averageRating =
    addon.DB:GetAverageRating(
        player.name
    )
        if averageRating == 0 then

            card.CurrentRatingText:SetText(
                "Current Rating: -"
            )
        else
            card.CurrentRatingText:SetText(
                string.format(
                    "Average: %.1f",
                    averageRating
                )
            )
        end
    card.LastRatingText:SetText(
        "Last Rating: " .. tostring(addon.DB:GetLastRating(player.name) or "-")
    )

    card.FirstSeenText:SetText(
        "First Seen:\n" .. addon:FormatTimestamp(player.firstSeen)
    )
    card.LastSeenText:SetText(
        "Last Seen:\n" .. addon:FormatTimestamp(player.lastSeen)
    )
    card.RunsHistoryText:SetText("Runs: " .. tostring(player.runs or 0))
end
