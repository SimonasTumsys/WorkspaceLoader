local config = {
    -- Display 1
    [1] = {
        -- Supports up to 2 apps in one workspace (windows split in half vertically)
        [1] = { 
            "com.Apple.Notes" -- Notes on 1st Display's 1st Desktop (workspace)
        },
        [2] = {
            "com.jetbrains.intellij.ce" -- IntelliJ on 1st Display's 2nd Desktop (workspace), etc.
        },
        [3] = {
            "org.mozilla.firefox"
        }
    },
    -- Display 2
    [2] = {
        [1] = {
            "com.microsoft.Outlook"
        },
        [2] = {
            "com.tinyspeck.slackmacgap"
        },
        [3] = {
            "com.postmanlabs.mac"
        }
    }
}

return config
