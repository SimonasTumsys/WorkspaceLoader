# WorkspaceLoader

WokspaceLoader is a MacOS workspace automation tool, written in Lua, using Hammerspoon.

It opens and/or rearranges your apps based on configurations provided. Comes with BundleID finder, which helps you setup configuration files more easily.

## Installation

1. Install [Hammerspoon](https://github.com/Hammerspoon/hammerspoon?tab=readme-ov-file#how-do-i-install-it).
2. Grant Hammerspoon accessibility permission
   
   >*From Hammerspoon docs:*
   >> macOS manages the list of applications with access to accessibility features in System Preferences.
   >> Click on the `Security & Privacy` icon, then the `Privacy` tab and then `Accessibility` from the list.
   >> You should ensure that Hammerspoon is present in this list and is ticked.

3. Fork this repo or download the files and put them into `~/.hammerspoon` directory. If there is no such dir, create it.
4. Restart Hammerspoon (a hammer icon in the top right - press `Quit Hammerspoon` and open it again from Launchpad.

After installation, you will be prompted to choose a configuration file. You can experiment with the example file for now, so select it.
 
## Usage

There are a couple of keybindings already pre-configured. Feel free to change them to your liking.
They can be found in the `.hammerspoon` directory, `init.lua` file:
```lua:init.lua
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
```

## Configuration Setup
`Spoons/WorkspaceLoader.spoon/config_files/example_config.lua`
```lua:example_config.lua
local config = {
    -- Display 1
    [1] = {
        -- Currently only supports 1 app in one workspace
        [1] = {
            "com.apple.Notes" -- Notes on 1st Display's 1st Desktop (workspace)
        }
    },
    -- Display 2
    [2] = {
        [1] = {
            "com.microsoft.Outlook" -- Outlook on 2nd Display's 1st Desktop (workspace)
        },
        [2] = {
            "com.tinyspeck.slackmacgap" -- Slack on 2nd Display's 2nd workspace, etc.
        }
     }
}

return config
```
Place your configuration files in the `Spoons/WorkspaceLoader.spoon/config_files` directory.

Experiment to see which display is which in your setup. Currently works with App main windows (meaning that a couple of instances/windows of the same app will **not** work)

As you can see, to select apps to open/arrange, we need to pass their BundleIDs, not their names. For this, you can use `ctrl+option+cmd+S` hotkey. 
Enter a hint and press Enter, then choose the correct BundleID from the list - it will be copied to clipboard.


## Tips

When arranging applications, press the hotkey a couple of times, few seconds apart. Sometimes, not all apps move during the first try.

Create a couple of configuration files, to accomodate various display setups (`office.lua`, `home.lua`, etc.). Make sure to place them in the config directory.
Switch between these files at any time using `cmd+option+ctrl+C`

## Known issues

When attempting to open applications and move their main windows to respective workspaces, sometimes the script encounters a timeout and the some apps are not moved. 
To combat this, use the rearrange mapping - press it a couple of times to make sure the apps are moved correctly.

For now, even if no apps are open, the rearrange function creates workspaces in advance. This will be fixed shortly, so only the required spaces will be created.

## License (Hammerspoon)

[MIT](https://choosealicense.com/licenses/mit/)
