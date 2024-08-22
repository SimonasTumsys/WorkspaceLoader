hs.ipc.cliInstall()

hs.loadSpoon("WorkspaceLoader")


function test(shouldOpen)
    spoon.WorkspaceLoader:createSpacesAndArrange(shouldOpen)
end

function findBundleId(hint)
    local result = spoon.WorkspaceLoader:findBundleIdByKeyword(hint)
    print(result)
end


