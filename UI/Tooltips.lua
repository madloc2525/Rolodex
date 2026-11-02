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

        local data =
            tooltip:GetTooltipData()

        if not data then
            return
        end


        local tooltipName =
        data.lines[1].leftText



        local player =
            addon.DB:GetPlayer(
                tooltipName
            )

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

        tooltip:AddLine(
            "Rolodex",
            1.0,
            0.82,
            0.0
        )

        tooltip:AddLine(
            string.format(
                "Rating: %.2f",
                addon.DB:GetAverageRating(
                    player.name
                )
            )
        )

        tooltip:AddLine(
            "Runs: " ..
            tostring(
                player.runs or 0
            )
        )
            if player.notes
        and player.notes ~= "" then

            tooltip:AddLine(" ")

            tooltip:AddLine(
                "Notes:",
                1,
                1,
                1
            )

            tooltip:AddLine(
                player.notes,
                0.8,
                0.8,
                0.8
            )

        end
    end
)
