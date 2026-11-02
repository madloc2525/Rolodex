function UI:OpenPlayer(
    playerName
)

    self.ExpandedPlayer =
        playerName

    self:Refresh()

    self.MainFrame:Show()

end