local MAX_RETRIES = 7
local RETRY_INTERVAL = 1

local obj = {}
obj.__index = obj


-- load configuration
function obj:init()
    local configFilePath = hs.spoons.resourcePath("config.lua")
    if configFilePath then
        local configTable = dofile(configFilePath)
        obj.configTable = configTable
    end
end


local function createSpaces(targetScreen, lastSpaceIndex)
    local spaces = hs.spaces.spacesForScreen(targetScreen)

    if not spaces then
        hs.alert.show("Could not find any spaces for target display")
        return
    end

    local spacesNeeded = lastSpaceIndex - #spaces

    if spacesNeeded < 1 then return spaces end

    for _ = 1, spacesNeeded do
        hs.spaces.addSpaceToScreen(targetScreen:id(), true)
    end

    return hs.spaces.spacesForScreen(targetScreen)
end


local function getAppMainWindowWithRetries(app, remainingRetries)
    if remainingRetries <= 0 then
        hs.alert.show("Could not find app's main window. Retry limit reached")
        return
    end

    local win = app:mainWindow()
    if win then return win end

    hs.timer.doAfter(RETRY_INTERVAL, function()
        hs.alert.show("Retrying to find app's main window... Remaining retries: " .. remainingRetries - 1)
        getAppMainWindowWithRetries(app, remainingRetries - 1)
    end)
end


local function openOrFocusApp(appBundleId)
    hs.alert.show("Launching application " .. appBundleId)
    return hs.timer.waitUntil(
        hs.application.launchOrFocusByBundleID(appBundleId),
        function()
            hs.alert.show("Opened app " .. appBundleId)
        end
    ):start()
end


function obj:openAndMoveAppWindowToSpaceOnDisplay()
    local allScreens = hs.screen.allScreens()
    local targetScreen = allScreens[displayIndex]
    local screenFrame = targetScreen:fullFrame()

    if not targetScreen then
        hs.alert.show("Invalid display index")
        return
    end

    local spaces = createSpaces(targetScreen, spaceIndex)
    if not spaces then return end

    openOrFocusApp(appBundleId)

    local app = hs.application.find(appBundleId)
    if not app then
        hs.alert.show("Error opening application " .. appBundleId)
        return
    end

    local win = getAppMainWindowWithRetries(app, MAX_RETRIES)
    if not win then return end

    hs.spaces.moveWindowToSpace(win:id(), spaces[spaceIndex])
    win:setTopLeft(hs.geometry.point(screenFrame.x, screenFrame.y))
    win:maximize()

    hs.alert.show(appBundleId .. " window moved to space " .. spaceIndex
        .. " on display " .. displayIndex)

end



return obj


