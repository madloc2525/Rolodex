local addon = Rolodex

addon.UI = addon.UI or {}

local MinimapButton = {}

addon.UI.MinimapButton = MinimapButton

local BUTTON_SIZE = 32
local ICON_SIZE = 20
local BORDER_SIZE = 54
local ICON_MASK = "Interface\\CHARACTERFRAME\\TempPortraitAlphaMask"

local function PositionButton(button, angle)
    local radius = (math.min(Minimap:GetWidth(), Minimap:GetHeight()) / 2)
        + (BUTTON_SIZE / 2)
        - 4
    local radians = math.rad(angle)

    button:ClearAllPoints()
    button:SetPoint(
        "CENTER",
        Minimap,
        "CENTER",
        math.cos(radians) * radius,
        math.sin(radians) * radius
    )
end

-- ============================================================================
-- Create
-- ============================================================================

function MinimapButton:Create()

    local button = CreateFrame(
        "Button",
        "RolodexMinimapButton",
        Minimap
    )

    button:SetSize(BUTTON_SIZE, BUTTON_SIZE)

    button:SetFrameStrata(
        "MEDIUM"
    )

    button:SetClampedToScreen(true)
    button:RegisterForDrag("LeftButton")

    -- Icon
    button.Icon =
        button:CreateTexture(
            nil,
            "ARTWORK"
        )

    button.Icon:SetTexture(
        "Interface\\AddOns\\" .. addon.Name .. "\\Media\\Icons\\MinimapIcon.png"
    )

    button.Icon:SetSize(
        ICON_SIZE,
        ICON_SIZE
    )
    button.Icon:SetPoint(
        "TOPLEFT",
        button,
        "TOPLEFT",
        7,
        -5
    )
    button.IconMask = button:CreateMaskTexture(
        nil,
        "ARTWORK"
    )
    button.IconMask:SetTexture(ICON_MASK)
    button.IconMask:SetAllPoints(button.Icon)
    button.Icon:AddMaskTexture(button.IconMask)

    -- Blizzard's minimap tracking ring frames the circularly masked icon.
    button.Border =
        button:CreateTexture(
            nil,
            "OVERLAY"
        )

    button.Border:SetTexture(
        "Interface\\Minimap\\MiniMap-TrackingBorder"
    )
    button.Border:SetSize(
        BORDER_SIZE,
        BORDER_SIZE
    )
    button.Border:SetPoint(
        "TOPLEFT",
        button,
        "TOPLEFT"
    )

    -- Mouse-over glow
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

    local savedAngle = RolodexDB and RolodexDB.minimapButtonAngle
    PositionButton(button, savedAngle or 135)

    button:SetScript(
        "OnMouseDown",
        function(self, mouseButton)
            if mouseButton == "LeftButton" then
                self.WasDragged = false
            end
        end
    )

    button:SetScript(
        "OnDragStart",
        function(self)
            self.WasDragged = true
            self:SetScript(
                "OnUpdate",
                function()
                    local cursorX, cursorY = GetCursorPosition()
                    local scale = Minimap:GetEffectiveScale()
                    local centerX, centerY = Minimap:GetCenter()
                    centerX = centerX * scale
                    centerY = centerY * scale

                    local angle = math.deg(
                        math.atan2(
                            cursorY - centerY,
                            cursorX - centerX
                        )
                    )

                    PositionButton(self, angle)
                    self.Angle = angle
                end
            )
        end
    )

    button:SetScript(
        "OnDragStop",
        function(self)
            self:SetScript("OnUpdate", nil)
            if self.Angle then
                RolodexDB = RolodexDB or {}
                RolodexDB.minimapButtonAngle = self.Angle
            end
        end
    )

    button:SetScript("OnClick", function(self, mouseButton)
    if mouseButton == "LeftButton" then
        addon.UI:ToggleMainFrame()
    elseif mouseButton == "RightButton" then
        addon.UI.Settings:Toggle()
    end
    end)

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
                1.0,
                0.82,
                0.0
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

    if not addon.DB:GetSetting("ShowMinimapButton") then

        button:Hide()

    end

    return button

end

function MinimapButton:SetShown(shown)

    addon.DB:SetSetting("ShowMinimapButton", shown)

    if not self.Button then
        return
    end

    if shown then
        self.Button:Show()
    else
        self.Button:Hide()
    end

end