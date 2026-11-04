-- Creates and refreshes the player rows shown in the main window.

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
        -4 - ((index - 1) * 22)
    )

    -- Favorite, avoid, or unflagged state
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

    row.ClassText:SetPoint("LEFT", row, "LEFT", 180, 0)
    -- Guild
    row.GuildText = row:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormalSmall"
    )

    row.GuildText:SetPoint("LEFT", row, "LEFT", 260, 0)
    -- Rating
    row.RatingText = row:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
    )

    row.RatingText:SetPoint("LEFT", row, "LEFT", 400, 0)
    -- Groups together
    row.GroupsText = row:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
    )

    row.GroupsText:SetPoint("LEFT", row, "LEFT", 450, 0)
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

    row.NoteButton:SetPoint("LEFT", row, "LEFT", 500, 0)

    row.NoteButton.Text =
        row.NoteButton:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    row.NoteButton.Text:SetAllPoints()

    row.NoteButton.Text:SetText("✎")

    row.NoteButton:SetScript("OnClick", function()
        local player = addon.DB:GetPlayer(row.PlayerName)
        if not player then
            return
        end

        UI.NotePlayer = row.PlayerName
        UI.MainFrame.NotesFrame.Title:SetText("Notes - " .. row.PlayerName)
        UI.MainFrame.NotesFrame.EditBox:SetText(player.notes or "")
        UI.MainFrame.NotesFrame:Show()
        UI.MainFrame.NotesFrame.EditBox:SetFocus()
    end)

    row:SetScript("OnClick", function()
        if UI.SelectedRow == row then
            UI.SelectedRow = nil
            UI.ExpandedPlayer = nil
        else
            UI.SelectedRow = row
            UI.ExpandedPlayer = RolodexDB.Settings.AutoExpandSelectedPlayer
                and row.PlayerName
                or nil
        end
        UI:Refresh()
    end)

    return row
end

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

    if addon.DB:GetSetting("ShowClass") then
        row.ClassText:Show()
    else
        row.ClassText:Hide()
    end

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

    if addon.DB:GetSetting("ShowGuild") then
        row.GuildText:Show()
    else
        row.GuildText:Hide()
    end

    -- Rating
    -- =====================================================

    local averageRating =
        addon.DB:GetAverageRating(player.name)
    if averageRating == 0 then
        row.RatingText:SetText("-")
    else
        row.RatingText:SetText(
            string.format("%.1f", averageRating)
        )
    end

    if addon.DB:GetSetting("ShowAverageRating") then
        row.RatingText:Show()
    else
        row.RatingText:Hide()
    end

    -- Groups
    -- =====================================================

    row.GroupsText:SetText(
        tostring(
            player.groups or 0
        )
    )

    if addon.DB:GetSetting("ShowGroups") then
        row.GroupsText:Show()
    else
        row.GroupsText:Hide()
    end

    -- Notes Indicator
    -- =====================================================

    if player.notes
    and player.notes ~= "" then

        row.NoteButton.Text:SetText(
            "📝"
        )

    else

        row.NoteButton.Text:SetText(
            "✎"
        )

    end

    -- Highlight the expanded row.
    if playerName == UI.ExpandedPlayer then
        row.NameText:SetTextColor(1, 1, 0)
    else
        row.NameText:SetTextColor(1, 1, 1)
    end
end
