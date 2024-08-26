local config = {
    -- Display 1
    [1] = {
        -- Currently only supports 1 app in one workspace
        [1] = { 
            "com.apple.Notes" -- Notes on 1st Display's 1st Desktop (workspace)
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
