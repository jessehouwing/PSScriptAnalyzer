# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

Describe 'Issue 2205' {
    It "reproduces the Linux recursive analysis failure" -Skip:(-not $IsLinux) {
        $settingsPath = Join-Path $PSScriptRoot 'Issue2205/PSScriptAnalyzerSettings.psd1'
        $repositoryRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

        Invoke-ScriptAnalyzer -Path $repositoryRoot -Recurse -Settings $settingsPath -ErrorAction Stop | Out-Null
    }
}
