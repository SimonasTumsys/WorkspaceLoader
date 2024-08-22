local MAX_RETRIES = 7
local RETRY_INTERVAL = 500000 -- 0.5s
local WAIT_INTERVAL = 3.6 -- 3.6s

local obj = {}
obj.__index = obj


-- load configuration
function obj:init()
    local configFilePath = hs.spoons.resourcePath("config_files/config.lua")
    if configFilePath then
        local configTable = dofile(configFilePath)
        obj.configTable = configTable
    end
end


local function ensureSpaceOnScreen(targetScreen, spaceIndex)
    local spaces = hs.spaces.spacesForScreen(targetScreen)
    if not spaces then
        hs.alert.show("Could not find spaces table for target display")
        return
    end

    local currentSpaceCount = #spaces
    if spaceIndex <= currentSpaceCount then
        return spaces[spaceIndex]
    end

    for _ = currentSpaceCount, spaceIndex do
        hs.spaces.addSpaceToScreen(targetScreen:id())
    end

    spaces = hs.spaces.spacesForScreen(targetScreen)
    return spaces[spaceIndex]
end


local function getAppMainWindowWithRetries(app, remainingRetries)
    if remainingRetries <= 0 then
        hs.alert.show("Could not find app's main window. Retry limit reached")
        return
    end

    local win = app:mainWindow()
    if win then
        return win end

    hs.timer.usleep(RETRY_INTERVAL)
    hs.alert.show("Retrying to find app's main window... Remaining retries: " .. remainingRetries - 1)
    return getAppMainWindowWithRetries(app, remainingRetries - 1)
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
    local waitInterval = WAIT_INTERVAL
    local allScreens = hs.screen.allScreens()
    for displayIndex, spaces in pairs(self.configTable) do

        local targetScreen = allScreens[displayIndex]
        local screenFrame = targetScreen:fullFrame()

        if not targetScreen then
            hs.alert.show("Invalid display index")
            goto continueDisplay
        end

        for spaceIndex, apps in pairs(spaces) do
            local spaceId = ensureSpaceOnScreen(targetScreen, spaceIndex)
            if not spaceId then
                goto continueSpace
            end

            for _, appBundleId in pairs(apps) do

                openOrFocusApp(appBundleId)

                local app = hs.application.find(appBundleId)
                if not app then
                    hs.alert.show("Error opening application " .. appBundleId)
                    goto continueApp
                end

                local win = getAppMainWindowWithRetries(app, MAX_RETRIES)
                if not win then
                    hs.alert.show("Error getting main application window" .. appBundleId)
                    goto continueApp
                end


                hs.timer.doAfter(WAIT_INTERVAL, function()
                    hs.spaces.moveWindowToSpace(win:id(), spaceId)
                    win:setTopLeft(hs.geometry.point(screenFrame.x, screenFrame.y))
                    win:maximize()
                    hs.alert.show(appBundleId .. " window moved to space " .. spaceIndex
                        .. " on display " .. displayIndex)
                end)
                waitInterval = waitInterval + WAIT_INTERVAL
            end
            ::continueApp::
        end
        ::continueSpace::
    end
    ::continueDisplay::
end




return obj


