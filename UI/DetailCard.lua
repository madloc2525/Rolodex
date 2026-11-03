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
        parent
    )

    card:SetSize(470, 200)
    card:SetFrameStrata("HIGH")
    card:SetFrameLevel(100)
    card:Hide()
    if card.CloseButton then card.CloseButton:Hide()
    end
    if card.Bg then card.Bg:Hide()
    end
    addon.UI.ThemePaper:Apply(card)
    -- addon.UI.DetailCardTheme:Apply(card)

    --Hide blizzard art
    -- Notes
    card.NotesText = CreateText(
        card,
        "GameFontNormalSmall",
        "TOPLEFT",
        card,
        12,
        -30
        )
    addon.UI.Theme:ApplyBodyStyle(
        card.NotesText
    )
    card.NotesText:SetWidth(560)
    card.NotesText:SetJustifyH("LEFT")

-- Divider

card.Divider =
    card:CreateTexture(
        nil,
        "OVERLAY"
    )



card.Divider:SetSize(
    500,
    0
)

card.Divider:SetPoint(
    "TOPLEFT",
    card.NotesText,
    "BOTTOMLEFT",
    0,
    -10
)

addon.UI.Theme:ApplyDividerStyle(
    card.Divider
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

    addon.UI.Theme:ApplyHeaderStyle(
        card.CharacterHeader
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
    addon.UI.Theme:ApplyBodyStyle(
    card.LastLevelText)

card.LastRoleLabel =
    CreateText(
        card,
        "GameFontNormal",
        "TOPLEFT",
        card.LastLevelText,
        "BOTTOMLEFT",
        0,
        -10
    )
    addon.UI.Theme:ApplyBodyStyle(
    card.LastRoleLabel)


    card.LastRoleValue =
    CreateText(
        card,
        "GameFontNormal",
        "LEFT",
        card.LastRoleLabel,
        "RIGHT",
        5,
        0
    )

    card.DeletePlayerButton = CreateFrame(
        "Button",
        nil,
        card,
        "UIPanelButtonTemplate"
    )
    card.DeletePlayerButton:SetSize(60, 22)
    card.DeletePlayerButton:SetPoint(
        "TOPLEFT",
        card.LastRoleLabel,
        "BOTTOMLEFT",
        0,
        -12
    )
    card.DeletePlayerButton:SetText("Delete")
    card.DeletePlayerButton:SetScript(
        "OnClick",
        function()
            local playerName = UI.ExpandedPlayer
            if playerName then
                StaticPopup_Show(
                    "ROLODEX_DELETE_PLAYER",
                    playerName,
                    nil,
                    playerName
                )
            end
        end
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
addon.UI.Theme:ApplyHeaderStyle(
    card.RatingHeader
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
addon.UI.Theme:ApplyBodyStyle(
    card.CurrentRatingText)

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
addon.UI.Theme:ApplyHeaderStyle(
    card.HistoryHeader
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

addon.UI.Theme:ApplyBodyStyle(
    card.FirstSeenText
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
addon.UI.Theme:ApplyBodyStyle(
    card.LastSeenText
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
addon.UI.Theme:ApplyBodyStyle(
    card.RunsHistoryText
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
    addon.UI.Theme:ApplyBodyStyle(
    card.LastRatingText
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

-- Refresh function
-- ======================================================================
function DetailCard:Refresh(card, player) 

    local note = player.notes or ""
    if note == "" then
        note = "No notes recorded."
    end
    card.NotesText:SetText("Notes:\n" .. note)

    card.LastLevelText:SetText(
        "Last Level: " .. tostring(player.lastSeenLevel or "-")
    )
    card.LastRoleLabel:SetText(
    "Last Role:"
    )

    card.LastRoleValue:SetText(
        addon.UI.Theme:FormatRole(
            player.lastSeenRole
        )
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
