# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

Describe "Concurrent command lookups" {
    BeforeAll {
        # The concurrency driver is written in C# so that the lookups really do run on separate
        # threads. Invoking a PowerShell script block on a thread pool thread would introduce
        # runspace affinity problems of its own and would not test the command info cache.
        $analyzerAssembly = [Microsoft.Windows.PowerShell.ScriptAnalyzer.Helper].Assembly.Location
        Add-Type -IgnoreWarnings -WarningAction SilentlyContinue -ReferencedAssemblies $analyzerAssembly, ([System.Management.Automation.PSObject].Assembly.Location) -TypeDefinition @'
using System.Threading.Tasks;
using Microsoft.Windows.PowerShell.ScriptAnalyzer;

public static class ConcurrentCommandLookup
{
    public static string[] Lookup(string[] commandNames)
    {
        var helper = Helper.Instance;
        var tasks = new Task<string>[commandNames.Length];
        for (int i = 0; i < commandNames.Length; i++)
        {
            string name = commandNames[i];
            tasks[i] = Task.Run(() =>
            {
                var commandInfo = helper.GetCommandInfo(name);
                return commandInfo == null ? null : commandInfo.Name;
            });
        }

        Task.WaitAll(tasks);

        var results = new string[tasks.Length];
        for (int i = 0; i < tasks.Length; i++)
        {
            results[i] = tasks[i].Result;
        }

        return results;
    }
}
'@
    }

    It "resolves commands from several threads without failing" {
        $commandNames = @(
            'Get-ChildItem', 'Where-Object', 'ForEach-Object', 'Get-Content', 'Write-Output',
            'Test-Path', 'Get-Command', 'Select-Object', 'Sort-Object', 'Measure-Object'
        ) * 4

        # A lookup that hits the thread safety problem throws, which fails the test.
        $results = [ConcurrentCommandLookup]::Lookup($commandNames)

        $results.Count | Should -Be $commandNames.Count
        # A failed lookup returns null, so every entry must name the command that was requested.
        for ($i = 0; $i -lt $commandNames.Count; $i++) {
            $results[$i] | Should -BeExactly $commandNames[$i]
        }
    }
}
