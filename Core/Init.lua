local addon = Rolodex

function addon.Core:Initialize()

    addon:Print(
        "Core initialized."
    )

    if self.RegisterEvents then

        self:RegisterEvents()

    end

end