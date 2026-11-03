local addon = Rolodex

addon.UI = addon.UI or {}

local ThemeMainFrame = {}

addon.UI.ThemeMainFrame = ThemeMainFrame

function ThemeMainFrame:Apply(frame)

    frame.Background =
        frame:CreateTexture(
            nil,
            "ARTWORK"
        )

    frame.Background:SetAllPoints()

    frame.Background:SetTexture(
        "Interface\\AddOns\\Rolodex\\Media\\Textures\\LeatherBackground.PNG"
    )

end