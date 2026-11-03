
-- Creates a prompt to rate players based on end session (tracked in CoreEvents.lua)
-- Added a skip to close the window without rating
-- RatingPrompt should be toggle-able in settings in later patch.

-- ============================================================================
local addon = Rolodex

addon.UI = addon.UI or {}

local RatingPrompt = {}

addon.UI.RatingPrompt = RatingPrompt


-- Create Window


function RatingPrompt:CreateWindow()

    local frame =
        CreateFrame(
            "Frame",
            "RolodexRatingPrompt",
            UIParent
        )

    frame:SetSize(
        320,
        180
    )

    frame:SetPoint(
        "CENTER"
    )

    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetClampedToScreen(true)
    frame:SetScript(
        "OnDragStart",
        frame.StartMoving
    )
    frame:SetScript(
        "OnDragStop",
        function(prompt)
            prompt:StopMovingOrSizing()

            local left = prompt:GetLeft()
            local bottom = prompt:GetBottom()
            if left and bottom then
                RolodexDB = RolodexDB or {}
                RolodexDB.ratingPromptPosition = {
                    left = left,
                    bottom = bottom
                }
            end
        end
    )

    frame:SetFrameStrata(
        "DIALOG"
    )

    addon.UI.ThemePaper:Apply(frame)

    local savedPosition =
        RolodexDB and RolodexDB.ratingPromptPosition
    if savedPosition then
        frame:ClearAllPoints()
        frame:SetPoint(
            "BOTTOMLEFT",
            UIParent,
            "BOTTOMLEFT",
            savedPosition.left,
            savedPosition.bottom
        )
    end

    frame:Hide()

    frame.Title =
        frame:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontHighlight"
        )

    frame.Title:SetPoint(
        "TOP",
        0,
        -34
    )

    frame.Title:SetText(
        "Session Review"
    )
    addon.UI.Theme:ApplyHeaderStyle(frame.Title)
    -- Name
    frame.PlayerName =
        frame:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormalLarge"
        )

    frame.PlayerName:SetPoint(
        "TOP",
        0,
        -56
    )
    addon.UI.Theme:ApplyHeaderStyle(frame.PlayerName)

    -- Class

    frame.ClassText =
        frame:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    frame.ClassText:SetPoint(
        "TOP",
        frame.PlayerName,
        "BOTTOM",
        0,
        -4
    )
    addon.UI.Theme:ApplyBodyStyle(frame.ClassText)
    frame.ClassText:SetShadowColor(0, 0, 0, 1)
    frame.ClassText:SetShadowOffset(1, -1)

    -- Role

    frame.RoleText =
        frame:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    frame.RoleText:SetPoint(
        "TOP",
        frame.ClassText,
        "BOTTOM",
        0,
        -4
    )
    addon.UI.Theme:ApplyBodyStyle(frame.RoleText)
    frame.RoleText:SetShadowColor(0, 0, 0, 1)
    frame.RoleText:SetShadowOffset(1, -1)

    frame.GuildText =
        frame:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    frame.GuildText:SetPoint(
        "TOP",
        frame.RoleText,
        "BOTTOM",
        0,
        -5
    )
    addon.UI.Theme:ApplyBodyStyle(frame.GuildText)

    frame.RatingText =
        frame:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    frame.RatingText:SetPoint(
        "TOP",
        frame.GuildText,
        "BOTTOM",
        0,
        -10
    )
    addon.UI.Theme:ApplyBodyStyle(frame.RatingText)

    -- Rating 1

    frame.Rating1 =
        CreateFrame(
            "Button",
            nil,
            frame,
            "UIPanelButtonTemplate"
        )

    frame.Rating1:SetSize(
        40,
        22
    )

    frame.Rating1:SetPoint(
        "BOTTOMLEFT",
        65,
        20
    )

    frame.Rating1:SetText(
        "1"
    )

    -- Rating 2

    frame.Rating2 =
        CreateFrame(
            "Button",
            nil,
            frame,
            "UIPanelButtonTemplate"
        )

    frame.Rating2:SetSize(
        40,
        22
    )

    frame.Rating2:SetPoint(
        "LEFT",
        frame.Rating1,
        "RIGHT",
        10,
        0
    )

    frame.Rating2:SetText(
        "2"
    )

    -- Rating 3

    frame.Rating3 =
        CreateFrame(
            "Button",
            nil,
            frame,
            "UIPanelButtonTemplate"
        )

    frame.Rating3:SetSize(
        40,
        22
    )

    frame.Rating3:SetPoint(
        "LEFT",
        frame.Rating2,
        "RIGHT",
        10,
        0
    )

    frame.Rating3:SetText(
        "3"
    )

    -- Skip

    frame.SkipButton =
        CreateFrame(
            "Button",
            nil,
            frame,
            "UIPanelButtonTemplate"
        )

    frame.SkipButton:SetSize(
        40,
        22
    )

    frame.SkipButton:SetPoint(
        "LEFT",
        frame.Rating3,
        "RIGHT",
        10,
        0
    )

    frame.SkipButton:SetText(
        "»"
    )
    frame.SkipButton:SetScript(
        "OnEnter",
        function(button)
            GameTooltip:SetOwner(button, "ANCHOR_BOTTOM")
            GameTooltip:SetText("Skip")
            GameTooltip:Show()
        end
    )
    frame.SkipButton:SetScript(
        "OnLeave",
        function()
            GameTooltip:Hide()
        end
    )

    frame.Rating1:SetScript(
    "OnClick",
    function()

        RatingPrompt:Rate(1)

    end
    )

    frame.Rating2:SetScript(
        "OnClick",
        function()

            RatingPrompt:Rate(2)

        end
    )

    frame.Rating3:SetScript(
        "OnClick",
        function()

            RatingPrompt:Rate(3)

        end
    )

    frame.SkipButton:SetScript(
        "OnClick",
        function()

            RatingPrompt:NextPlayer()

        end
    )


    self.Frame = frame

end

function RatingPrompt:BuildQueue()

    self.PlayerQueue = {}

    for name in pairs(
        addon.ActiveSession
    ) do

        table.insert(
            self.PlayerQueue,
            name
        )

    end

    table.sort(
        self.PlayerQueue
    )

    self.CurrentIndex = 1

end

function RatingPrompt:Refresh()

    local playerName =
        self.PlayerQueue[
            self.CurrentIndex
        ]

    if not playerName then

        addon.ActiveSession = {}

        self.Frame:Hide()

        return

    end

    self.Frame.Title:SetText(
        string.format(
            "Session Review (%d/%d)",
            self.CurrentIndex,
            #self.PlayerQueue
        )
    )

    local player =
        addon.DB:GetPlayer(
            playerName
        )

    self.Frame.PlayerName:SetText(
        playerName
    )

    local className =
    player.class or
    "Unknown"

    self.Frame.ClassText:SetText(
        className
    )

    local classColor =
        RAID_CLASS_COLORS[
            player.class or ""
        ]

    if classColor then

        self.Frame.ClassText:SetTextColor(
            classColor.r,
            classColor.g,
            classColor.b
        )

    else

        self.Frame.ClassText:SetTextColor(
            1,
            1,
            1
        )

    end


    local role =
        player.lastSeenRole

    self.Frame.RoleText:SetText(
    addon.UI.Theme:FormatRole(
        player.lastSeenRole
        )
    )

    self.Frame.GuildText:SetText(
        player.guild or
        "-"
    )

    local average =
    addon.DB:GetAverageRating(
        playerName
    )

    if average == 0 then

        self.Frame.RatingText:SetText(
            "Current Rating: -"
        )

    else

        self.Frame.RatingText:SetText(
            string.format(
                "Current Rating: %.1f",
                average
            )
        )

    end

end

function RatingPrompt:NextPlayer()

    self.CurrentIndex =
        self.CurrentIndex + 1

    self:Refresh()

end

function RatingPrompt:Rate(value)

    local playerName =
        self.PlayerQueue[
            self.CurrentIndex
        ]

    addon.DB:AddRating(
        playerName,
        value
    )

    self:NextPlayer()

end

function RatingPrompt:Show()

    if not self.Frame then

        self:CreateWindow()

    end

    self:BuildQueue()

    self:Refresh()

    self.Frame:Show()

end
