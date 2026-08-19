# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

Describe 'Issue 2205' {
    It "does not fail the analysis when a command lookup hits the runspace affinity problem" -Skip:(-not $IsLinux) {
        $settingsPath = Join-Path $PSScriptRoot 'Issue2205/PSScriptAnalyzerSettings.psd1'
        # $PSScriptRoot is <repo>/Tests/Rules, so two levels up is the repository root.
        $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path

        Invoke-ScriptAnalyzer -Path $repositoryRoot -Recurse -Settings $settingsPath -ErrorAction Stop | Out-Null
    }
}
