local addon = Rolodex

addon.UI = addon.UI or {}

local Search = {}

addon.UI.Search = Search

function Search:Create(parent)
    local searchBox = CreateFrame(
        "EditBox",
        nil,
        parent,
        "InputBoxTemplate"
    )

    searchBox:SetSize(135, 22)
    searchBox:SetAutoFocus(false)
    searchBox:SetFontObject(GameFontHighlightSmall)
    searchBox:SetTextInsets(6, 6, 0, 0)

    searchBox.Placeholder = searchBox:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontDisableSmall"
    )
    searchBox.Placeholder:SetPoint(
        "LEFT",
        searchBox,
        "LEFT",
        8,
        0
    )
    searchBox.Placeholder:SetText("Search players")
    addon.UI.Theme:ApplyBodyStyle(searchBox.Placeholder)

    searchBox:SetScript(
        "OnTextChanged",
        function(box)
            addon.UI.SearchText = box:GetText()
            box.Placeholder:SetShown(
                addon.UI.SearchText == "" and not box:HasFocus()
            )

            addon.UI.ExpandedPlayer = nil
            if addon.UI.MainFrame then
                addon.UI.MainFrame.ScrollFrame:SetVerticalScroll(0)
            end
            addon.UI:Refresh()
        end
    )

    searchBox:SetScript(
        "OnEditFocusGained",
        function(box)
            box.Placeholder:Hide()
        end
    )

    searchBox:SetScript(
        "OnEditFocusLost",
        function(box)
            box.Placeholder:SetShown(box:GetText() == "")
        end
    )

    searchBox:SetScript(
        "OnEscapePressed",
        function(box)
            box:ClearFocus()
        end
    )

    return searchBox
end

function Search:Matches(playerName, player, query)
    local searchTerms = {}

    for term in string.lower(query or ""):gmatch("%S+") do
        table.insert(searchTerms, term)
    end

    if #searchTerms == 0 then
        return true
    end

    local hasNotes = player.notes and player.notes:match("%S") ~= nil
    local averageRating = addon.DB:GetAverageRating(playerName)
    local isFavorite = player.favorite == true
    local isAvoid = player.avoid == true

    local className = addon.UI.Theme:FormatClassName(player.class)
    local roleName = addon.UI.Theme:FormatRole(player.lastSeenRole)
    local searchableText = string.lower(
        table.concat({
            playerName or "",
            className or "",
            player.class or "",
            roleName or "",
            player.lastSeenRole or "",
            player.guild or ""
        }, " ")
    )

    for _, term in ipairs(searchTerms) do
        local minimumRating = tonumber(
            term:match("^%+(%d+%.?%d*)$")
        )

        if term == "note" or term == "notes" then
            if not hasNotes then
                return false
            end
        elseif term == "favorite" or term == "favorites" then
            if not isFavorite then
                return false
            end
        elseif term == "avoid" or term == "avoids" then
            if not isAvoid then
                return false
            end
        elseif minimumRating then
            if averageRating < minimumRating then
                return false
            end
        elseif not string.find(searchableText, term, 1, true) then
            return false
        end
    end

    return true
end