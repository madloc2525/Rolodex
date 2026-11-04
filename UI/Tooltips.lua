local addon = Rolodex

-- ============================================================================
-- Helpers
-- ============================================================================

local function GetFullPlayerName(data)

    if not data then
        return nil
    end

    local firstName =
        data.name

    if not firstName then
        return nil
    end

    local surname =
        data.surname

    if surname and surname ~= "" then

        return firstName ..
            " " ..
            surname

    end

    return firstName

end

-- ============================================================================
-- Unit Tooltips
-- ============================================================================

TooltipDataProcessor.AddTooltipPostCall(
    Enum.TooltipDataType.Unit,
    function(tooltip)
        if not RolodexDB.Settings.ShowRolodexTooltip then
            return
        end

        local data =
            tooltip:GetTooltipData()

        if not data then
            return
        end

        local tooltipName =
            data.lines[1].leftText

        local player =
            addon.DB:GetPlayerByFirstName(
                tooltipName
            )


        if not player then
            return
        end

        tooltip:AddLine(" ")

        local ratingText =
            string.format(
                "Rating: %.1f",
                addon.DB:GetAverageRating(
                    player.name
                )
            )

        if player.favorite then

            ratingText =
                ratingText ..
                " (★)"

        elseif player.avoid then

            ratingText =
                ratingText ..
                " (⚠)"

        end

        if player.favorite then

            tooltip:AddLine(
                ratingText,
                1,
                1,
                0
            )

        elseif player.avoid then

            tooltip:AddLine(
                ratingText,
                1,
                0.25,
                0.25
            )

        else

            tooltip:AddLine(
                ratingText,
                1,
                1,
                1
            )

        end

        tooltip:AddLine("Groups: " .. tostring(player.groups or 0), 1, 1, 1)

        if player.notes and player.notes ~= "" then
            tooltip:AddLine(" ")
            tooltip:AddLine("Notes:", 1, 1, 1)
            tooltip:AddLine(player.notes, 0.8, 0.8, 0.8)
        end
    end
)
