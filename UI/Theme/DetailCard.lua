local addon = Rolodex

addon.UI = addon.UI or {}

local DetailCardTheme = {}

addon.UI.DetailCardTheme = DetailCardTheme

function DetailCardTheme:Apply(frame)
    local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.BorderFrame = border
    border:SetAllPoints(frame)
    border:SetFrameLevel(frame:GetFrameLevel() + 1)
    border:SetBackdrop({
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 24,
        insets = {
            left = 6,
            right = 6,
            top = 6,
            bottom = 6,
        },
    })
end