# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

Describe 'Issue 2205' {
    It "does not fail the analysis when a command lookup hits the runspace affinity problem" -Skip:(-not $IsLinux) {
        $settingsPath = Join-Path $PSScriptRoot 'Issue2205/PSScriptAnalyzerSettings.psd1'
        $repositoryRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

        Invoke-ScriptAnalyzer -Path $repositoryRoot -Recurse -Settings $settingsPath -ErrorAction Stop | Out-Null
    }
}
