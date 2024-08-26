local MAX_RETRIES = 7
local RETRY_INTERVAL = 500000 -- 0.5s
local WAIT_INTERVAL = 3.6 -- 3.6s (max retries x interval + 0.1s)
local CONFIG_FILE = "config_files/config.lua"


local obj = {}
obj.__index = obj


-- load configuration
function obj:init()
    local configFilePath = hs.spoons.resourcePath(CONFIG_FILE)
    if configFilePath then
        obj.configTable = dofile(configFilePath)
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


function obj:findBundleIdByKeyword(keyword)
    local command = string.format([[
        mdfind "kMDItemContentType == 'com.apple.application-bundle'" |
        grep -i %s |
        while read -r app; do
        defaults read "$app/Contents/Info.plist" CFBundleIdentifier
    done
    ]], keyword)

    return hs.execute(command)
end


function showSelectionDialog(items)
    local choices = {}
    for i, item in ipairs(items) do
        table.insert(choices, {
            text = item,
            index = i
        })
    end

    local chooser = hs.chooser.new(function(choice)
        if not choice then return end
        local selectedItem = items[choice.index]
        hs.pasteboard.setContents(selectedItem)
        hs.alert.show("Copied to clipboard: " .. selectedItem)
    end)

    chooser:choices(choices)
    chooser:width(30)
    chooser:rows(#choices)

    chooser:show()
end


local function splitByNewline(str)
    local t = {}
    for line in str:gmatch("[^\r\n]+") do
        table.insert(t, line)
    end
    return t
end


function obj:searchForAppBundleId() 
    local _, hint = hs.dialog.textPrompt("Provide search hint for App Name", "hint")
    local result = splitByNewline(self:findBundleIdByKeyword(hint))
    showSelectionDialog(result)
end


local function getWaitInterval(shouldOpenApps)
    if shouldOpenApps then return WAIT_INTERVAL else return 0 end
end


function obj:createSpacesAndArrange(shouldOpenApps)
    local waitInterval = getWaitInterval(shouldOpenApps)
    local allScreens = hs.screen.allScreens()

    for displayIndex, spaces in pairs(self.configTable) do
        local targetScreen = allScreens[displayIndex]
        local screenFrame = targetScreen:fullFrame()

        if not targetScreen then
            hs.alert.show("Invalid display index")
            goto continueDisplay -- if failed, go to another display
        end

        for spaceIndex, apps in pairs(spaces) do
            local spaceId = ensureSpaceOnScreen(targetScreen, spaceIndex)
            if not spaceId then
                goto continueSpace -- if failed, go to another workspace
            end

            for _, appBundleId in pairs(apps) do
                if shouldOpenApps then 
                    openOrFocusApp(appBundleId)
                end

                local app = hs.application.find(appBundleId)
                if not app then
                    goto continueApp -- if failed, go to another app
                end

                local win = getAppMainWindowWithRetries(app, MAX_RETRIES)
                if not win then
                    goto continueApp -- if failed, go to another app
                end

                -- happens in separate threads. Waiting ensures app had time to open and window was retrieved
                hs.timer.doAfter(waitInterval, function()
                    hs.spaces.moveWindowToSpace(win:id(), spaceId)
                    win:setTopLeft(hs.geometry.point(screenFrame.x, screenFrame.y))
                    win:maximize()
                end)
                if shouldOpenApps then
                    waitInterval = waitInterval + WAIT_INTERVAL
                end
            end
            ::continueApp::
        end
        ::continueSpace::
    end
    ::continueDisplay::
end


return obj


