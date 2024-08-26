hs.ipc.cliInstall()
hs.loadSpoon("WorkspaceLoader")
hs.loadSpoon("BundleIdFinder")

-- Open applications and attempt moving them to their pre-configured spaces
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "A", function ()
    spoon.WorkspaceLoader:createSpacesAndArrange(false)
end)

-- Rearrange open applications to pre-configured spaces
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "O", function ()
    spoon.WorkspaceLoader:createSpacesAndArrange(true)
end)

-- Find application BundleIDs
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "S", function ()
    spoon.BundleIdFinder:search()
end)

-- Load a different configuration file
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "C", function ()
    spoon.WorkspaceLoader:chooseConfig()
end)


