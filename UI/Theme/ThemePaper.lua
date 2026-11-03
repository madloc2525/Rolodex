local addon = Rolodex

addon.UI = addon.UI or {}

local ThemePaper = {}

addon.UI.ThemePaper = ThemePaper

-- Helpers


function ThemePaper:Apply(frame)



    frame.Background =
        frame:CreateTexture(
            nil,
            "ARTWORK"
        )

    frame.Background:SetPoint(
        "TOPLEFT",
        8,
        -28
    )

    frame.Background:SetPoint(
        "BOTTOMRIGHT",
        -8,
        8
    )

    frame.Background:SetTexture(
        "Interface\\AddOns\\Rolodex\\Media\\Textures\\Parchment"
    )


end