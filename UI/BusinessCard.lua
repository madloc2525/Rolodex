-- Handles the business card UI for displaying player information 

local addon = Rolodex

addon.UI = addon.UI or {}

local BusinessCard = {}

addon.UI.BusinessCard = BusinessCard

local UI = addon.UI

function BusinessCard:Create(parent, index)

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
    -- Flag toggle button
    row.FlagButton = CreateFrame(
    "Button",
    nil,
    row
    )

    row.FlagButton:SetSize(
        20,
        20
    )

    row.FlagButton:SetPoint(
        "CENTER",
        row.FlagText,
        "CENTER",
        0,
        0
    )
    row.FlagButton:SetScript(
    "OnClick",
        function()

            local player =
                addon.DB:GetPlayer(
                    row.PlayerName
                )

            if not player then
                return
            end

            if player.favorite then

                addon.DB:SetFavorite(
                    row.PlayerName,
                    false
                )

                addon.DB:SetAvoid(
                    row.PlayerName,
                    true
                )

            elseif player.avoid then

                addon.DB:SetAvoid(
                    row.PlayerName,
                    false
                )

            else

                addon.DB:SetFavorite(
                    row.PlayerName,
                    true
                )

            end

            UI:Refresh()

        end
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

function BusinessCard:Refresh(
    row,
    player,
    playerName
)

    -- Flag
    -- =====================================================

    if player.favorite then

        row.FlagText:SetText("★")

        row.FlagText:SetTextColor(
            1,
            1,
            0
        )

    elseif player.avoid then

        row.FlagText:SetText("⚠")

        row.FlagText:SetTextColor(
            1,
            0.2,
            0.2
        )

    else

        row.FlagText:SetText("·")

        row.FlagText:SetTextColor(
            0.5,
            0.5,
            0.5
        )

    end

    -- Name
    -- =====================================================

    row.NameText:SetText(
        player.name or ""
    )

    -- Class
    -- =====================================================

    row.ClassText:SetText(
        addon.UI.Theme:FormatClassName(
            player.class
        )
    )

    local classColor =
    addon.UI.Theme:GetClassColor(
        player.class
    )

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

        row.NoteButton.Text:SetText(
            "📝"
        )

    else

        row.NoteButton.Text:SetText(
            ""
        )

    end

    -- Highlight
    -- =====================================================

    if playerName ==
    UI.ExpandedPlayer then

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

end


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