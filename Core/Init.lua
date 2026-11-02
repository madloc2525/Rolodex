local addon = Rolodex

function addon.Core:Initialize()

    addon:DebugPrint(
        "Core initialized."
    )

    if self.RegisterEvents then

        self:RegisterEvents()

    end

end