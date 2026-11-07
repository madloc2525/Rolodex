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

    row.FlagLayer = CreateFrame("Frame", nil, row)
    row.FlagLayer:SetSize(20, 20)
    row.FlagLayer:SetPoint("CENTER", row, "LEFT", 22.5, 0)
    row.FlagLayer:SetFrameLevel(row:GetFrameLevel() + 5)

    row.FlagIcon = row.FlagLayer:CreateTexture(nil, "OVERLAY", nil, 7)
    row.FlagIcon:SetSize(14, 14)
    row.FlagIcon:SetPoint("CENTER")

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

    row.FlagButton:SetPoint("CENTER", row.FlagIcon)
    row.FlagButton:SetFrameLevel(row.FlagLayer:GetFrameLevel() + 1)
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
        55,
        0
    )
    row.NameText:SetWidth(175)
    row.NameText:SetWordWrap(false)
    row.NameText:SetJustifyH("LEFT")
    -- Class
    row.ClassText = row:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    row.ClassText:SetPoint("LEFT", row, "LEFT", 180, 0)
    row.ClassText:SetJustifyH("LEFT")
    -- Guild
    row.GuildText = row:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormalSmall"
    )

    row.GuildText:SetPoint("LEFT", row, "LEFT", 260, 0)
    row.GuildText:SetJustifyH("LEFT")
    -- Rating
    row.RatingText = row:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
    )

    row.RatingText:SetPoint("LEFT", row, "LEFT", 400, 0)
    row.RatingText:SetWidth(75)
    row.RatingText:SetJustifyH("CENTER")
    -- Groups together
    row.GroupsText = row:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
    )

    row.GroupsText:SetPoint("LEFT", row, "LEFT", 450, 0)
    row.GroupsText:SetWidth(75)
    row.GroupsText:SetJustifyH("CENTER")
    row.MostRecentText = row:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormalSmall"
    )
    row.MostRecentText:SetPoint("LEFT", row, "LEFT", 500, 0)
    row.MostRecentText:SetWidth(105)
    row.MostRecentText:SetJustifyH("CENTER")
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

    row.NoteButton:SetPoint("CENTER", row, "LEFT", 522.5, 0)

    row.NoteButton.Icon = row.NoteButton:CreateTexture(nil, "ARTWORK")
    row.NoteButton.Icon:SetSize(14, 14)
    row.NoteButton.Icon:SetPoint("CENTER")
    row.NoteButton.Icon:SetTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")

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

    row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    row:SetScript("OnClick", function(_, button)
        if button == "RightButton" then
            UI:OpenPlayerContextMenu(row.PlayerName)
            return
        end

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

    row:SetScript("OnEnter", function(self)
        self.ThemeHovered = true
        UI.Theme:ApplyRowStyle(self)
    end)
    row:SetScript("OnLeave", function(self)
        self.ThemeHovered = false
        UI.Theme:ApplyRowStyle(self)
    end)
    UI.Theme:ApplyRowStyle(row)

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
        row.FlagIcon:SetAtlas("PetJournal-FavoritesIcon")
        row.FlagIcon:SetVertexColor(1, 0.82, 0.15)
        row.FlagIcon:Show()
    elseif player.avoid then
        row.FlagIcon:SetAtlas("common-icon-redx")
        row.FlagIcon:SetVertexColor(1, 0.3, 0.3)
        row.FlagIcon:Show()
    else
        row.FlagIcon:Hide()
    end
    row.FlagLayer:SetFrameLevel(row:GetFrameLevel() + 5)
    row.FlagButton:SetFrameLevel(row.FlagLayer:GetFrameLevel() + 1)

    -- Name
    -- =====================================================

    row.NameText:SetText(
        player.name or ""
    )
    local bodyR, bodyG, bodyB
    if not addon.UI.Theme:IsClassicTheme() then
        bodyR, bodyG, bodyB = addon.UI.Theme:GetColor("ListText")
        row.NameText:SetTextColor(bodyR, bodyG, bodyB)
    end

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

    elseif not addon.UI.Theme:IsClassicTheme() then

        row.ClassText:SetTextColor(
            1,
            1,
            1
        )

    end

    -- Guild
    -- =====================================================

    local guild = player.guild
    row.GuildText:SetText(guild and guild ~= "" and guild or "-")
    if bodyR then
        row.GuildText:SetTextColor(bodyR, bodyG, bodyB)
    end

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
    if bodyR then
        row.RatingText:SetTextColor(bodyR, bodyG, bodyB)
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
    if bodyR then
        row.GroupsText:SetTextColor(bodyR, bodyG, bodyB)
    end

    if addon.DB:GetSetting("ShowGroups") then
        row.GroupsText:Show()
    else
        row.GroupsText:Hide()
    end

    local mostRecent = player.lastGroupTogether or 0
    if mostRecent <= 0 then
        mostRecent = player.lastSeen or 0
    end
    if addon.DB:GetSetting("ShowMostRecent") and (player.groups or 0) > 0 and mostRecent > 0 then
        row.MostRecentText:SetText(date("%d %b %Y", mostRecent))
        if bodyR then
            row.MostRecentText:SetTextColor(bodyR, bodyG, bodyB)
        end
        row.MostRecentText:Show()
    else
        row.MostRecentText:SetText("-")
        if bodyR then
            row.MostRecentText:SetTextColor(bodyR, bodyG, bodyB)
        end
        row.MostRecentText:SetShown(addon.DB:GetSetting("ShowMostRecent"))
    end

    -- Notes Indicator
    -- =====================================================

    if player.notes
    and player.notes ~= "" then

        row.NoteButton.Icon:SetVertexColor(1, 0.82, 0.42, 1)
    else
        row.NoteButton.Icon:SetVertexColor(0.65, 0.65, 0.65, 0.55)
    end

    -- Highlight the expanded row.
    if playerName == UI.ExpandedPlayer and not UI.Theme:IsClassicTheme() then
        local accentR, accentG, accentB = UI.Theme:GetColor("Accent")
        row.NameText:SetTextColor(accentR, accentG, accentB)
    end

    UI.Theme:ApplyRowStyle(row)
    row.FlagLayer:SetFrameLevel(row:GetFrameLevel() + 5)
    row.FlagLayer:Show()
    row.FlagButton:SetFrameLevel(row.FlagLayer:GetFrameLevel() + 1)
end
