local OriginalSetItemRef =
    SetItemRef

SetItemRef = function(
    link,
    text,
    button,
    frame
)

    -- Custom Rolodex link

    if string.sub(
        link,
        1,
        8
    ) == "rolodex:" then

        local playerName =
            string.sub(
                link,
                9
            )

        addon.UI:OpenPlayer(
            playerName
        )

        return

    end

    return OriginalSetItemRef(
        link,
        text,
        button,
        frame
    )

end