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


-- Create Main Frame
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

frame.ScrollFrame =
    CreateFrame(
        "ScrollFrame",
        nil,
        frame,
        "UIPanelScrollFrameTemplate"
    )

frame.ScrollFrame:SetPoint(
    "TOPLEFT",
    10,
    -60
)

frame.ScrollFrame:SetSize(
    780,
    400
)

frame.ScrollFrame:EnableMouseWheel(true)

frame.ScrollFrame:SetScript(
    "OnMouseWheel",
    function(_, delta)

        local current =
            frame.ScrollFrame:GetVerticalScroll()

        frame.ScrollFrame:SetVerticalScroll(
            math.max(
                0,
                current - (delta * 20)
            )
        )

        UI.ExpandedPlayer = nil

        UI: Refresh()

    end
)

-- Content Frame

frame.ScrollChild =
    CreateFrame(
        "Frame",
        nil,
        frame.ScrollFrame
    )

frame.ScrollChild:SetSize(
    760,
    2400
)

frame.ScrollFrame:SetScrollChild(
    frame.ScrollChild
)

-- Player Rows

frame.Rows = {}

for i = 1, 100 do

    frame.Rows[i] =
        addon.UI.BusinessCard:Create(
            frame.ScrollChild,
            i
        )

end

-- Detail Card

frame.DetailCard =
    addon.UI.DetailCard:Create(
        frame
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
                    addon.UI.Theme:FormatClassName(
                        pa.class
                    )

                local classB =
                    addon.UI.Theme:FormatClassName(
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

    local contentHeight =
        math.max(
            400,
            (#playerNames * 22) + 20
        )

    self.MainFrame.ScrollChild:SetHeight(
        contentHeight
    )

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

            addon.UI.BusinessCard:Refresh(
                row,
                player,
                playerName
            )

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

    addon.UI.DetailCard:Refresh(
        card,
        player
    )

    card:Show()
end

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
