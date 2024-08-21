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
        hs.spaces.addSpaceToScreen(targetScreen:id(), false)
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
        print("Gaunam win")
        return win end

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
    for displayIndex, spaces in pairs(self.configTable) do 

        local targetScreen = allScreens[displayIndex]
        local screenFrame = targetScreen:fullFrame()

        if not targetScreen then
            hs.alert.show("Invalid display index")
            return
        end

        for spaceIndex, apps in pairs(spaces) do 
            local spaceId = ensureSpaceOnScreen(targetScreen, spaceIndex)
            if not spaceId then return end
            for _, appBundleId in pairs(apps) do 

                openOrFocusApp(appBundleId)

                local app = hs.application.find(appBundleId)
                if not app then
                    hs.alert.show("Error opening application " .. appBundleId)
                    return
                end

                local win = getAppMainWindowWithRetries(app, MAX_RETRIES)
                if not win then
                    print("NOT WIN :(")
                    return
                end

               hs.spaces.moveWindowToSpace(win:id(), spaceId)
               win:setTopLeft(hs.geometry.point(screenFrame.x, screenFrame.y))
               win:maximize()

               hs.alert.show(appBundleId .. " window moved to space " .. spaceIndex
                   .. " on display " .. displayIndex)

            end
        end
    end
end



return obj


