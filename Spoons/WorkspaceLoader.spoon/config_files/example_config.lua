local config = {
    -- Display 1
    [1] = {
        -- Currently only supports 1 app per one workspace
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
