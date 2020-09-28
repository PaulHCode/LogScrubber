﻿Set-PSFConfig -Module 'LogScrubber' -Name 'Client.Uri' -Value $null -Initialize -Validation 'string' -Description "Url to connect to the LogScrubber Azure function"
Set-PSFConfig -Module 'LogScrubber' -Name 'Client.UnprotectedToken' -Value '' -Initialize -Validation 'string' -Description "The unencrypted access token to the LogScrubber Azure function. ONLY use this from secure locations or non-sensitive functions!"
Set-PSFConfig -Module 'LogScrubber' -Name 'Client.ProtectedToken' -Value $null -Initialize -Validation 'credential' -Description "An encrypted access token to the LogScrubber Azure function. Use this to persist an access token in a way only the current user on the current system can access."