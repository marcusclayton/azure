$configData = @{
    AllNodes = @(
        @{
            NodeName = 'Server1'
            Role = @(
                'Web'
                'Database'
            )
        }

        @{
            NodeName = 'Server2'
            Role = @(
                'FileServer'
            )

            FileServerType = 'StandardFileServer'
        }
    )

    FileServerTypes = @{
        'StandardFileServer' = @{
            Shares = @(
                @{
                    Path = 'S:\SomeFolder'
                    ShareName = 'Public'
                    # Permissions, etc
                }
            )
        }
    }
}