hs.ipc.cliInstall()
hs.loadSpoon("WorkspaceLoader")
hs.loadSpoon("BundleIdFinder")


hs.hotkey.bind({"cmd", "alt", "ctrl"}, "A", function ()
    spoon.WorkspaceLoader:createSpacesAndArrange(false)
end)


hs.hotkey.bind({"cmd", "alt", "ctrl"}, "O", function ()
    spoon.WorkspaceLoader:createSpacesAndArrange(true)
end)


hs.hotkey.bind({"cmd", "alt", "ctrl"}, "S", function ()
    spoon.BundleIdFinder:search()
end)


hs.hotkey.bind({"cmd", "alt", "ctrl"}, "C", function ()
    spoon.WorkspaceLoader:chooseConfig()
end)


