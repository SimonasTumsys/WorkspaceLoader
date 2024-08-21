hs.ipc.cliInstall()

hs.loadSpoon("WorkspaceLoader")


function test()
    spoon.WorkspaceLoader:openAndMoveAppWindowToSpaceOnDisplay("com.tinyspeck.slackmacgap", 2, 2)
end
