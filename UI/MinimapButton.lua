local addon = Rolodex

addon.UI = addon.UI or {}

local MinimapButton = {}

addon.UI.MinimapButton = MinimapButton

-- ============================================================================
-- Create
-- ============================================================================

function MinimapButton:Create()

    local button = CreateFrame(
        "Button",
        "RolodexMinimapButton",
        Minimap
    )

    button:SetSize(32, 32)

    button:SetFrameStrata(
        "MEDIUM"
    )

    -- Icon
    button.Icon =
        button:CreateTexture(
            nil,
            "ARTWORK"
        )

    button.Icon:SetAllPoints()

    button.Icon:SetTexture(
        "Interface\\AddOns\\Rolodex\\Media\\Icons\\MinimapIcon.PNG"
    )

    -- Position
    button:SetPoint(
        "TOPLEFT",
        Minimap,
        "TOPLEFT",
        -5,
        5
    )

    -- Highlight
    button.Highlight =
        button:CreateTexture(
            nil,
            "HIGHLIGHT"
        )

    button.Highlight:SetAllPoints()

    button.Highlight:SetTexture(
        "Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight"
    )

    button.Highlight:SetBlendMode(
        "ADD"
    )

    -- Clicks
    button:RegisterForClicks(
        "LeftButtonUp",
        "RightButtonUp"
    )

    button:SetScript(
        "OnClick",
        function(_, mouseButton)

            if mouseButton ==
                "LeftButton" then

                addon.UI:Toggle()

            elseif mouseButton ==
                "RightButton" then

                -- Future:
                -- Open Settings

            end

        end
    )

    -- Tooltip
    button:SetScript(
        "OnEnter",
        function()

            GameTooltip:SetOwner(
                button,
                "ANCHOR_LEFT"
            )

            GameTooltip:AddLine(
                "Rolodex",
                1,
                0.82,
                0
            )

            GameTooltip:AddLine(
                " "
            )

            GameTooltip:AddLine(
                "Left Click: Open / Close",
                1,
                1,
                1
            )

            GameTooltip:AddLine(
                "Right Click: Settings",
                1,
                1,
                1
            )

            GameTooltip:Show()

        end
    )

    button:SetScript(
        "OnLeave",
        function()

            GameTooltip:Hide()

        end
    )

    self.Button = button

    return button

end