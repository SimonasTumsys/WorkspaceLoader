local obj = {}
obj._index = obj


function obj:init() 
    print("BundleID finder Spoon initialized")
end


local function findBundleIdByKeyword(keyword)
    local command = string.format([[
        mdfind "kMDItemContentType == 'com.apple.application-bundle'" |
        grep -i %s |
        while read -r app; do
        defaults read "$app/Contents/Info.plist" CFBundleIdentifier
    done
    ]], keyword)

    return hs.execute(command)
end


local function showSelectionDialog(items)
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


function obj:search() 
    local _, hint = hs.dialog.textPrompt("Search for app's BundleID", 
        "Provide search hint for App Name, e.g. slack")
    local result = splitByNewline(findBundleIdByKeyword(hint))
    showSelectionDialog(result)
end


return obj


