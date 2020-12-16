#  -----------------------------------------------
#      Author: Ramon Bollen
#        File: ReSharperCodeAnalysisScript.ps1
#  Created on: 20201210
#  -----------------------------------------------
$slnFile = Get-ChildItem -Path ".\**" -Filter *.sln -Recurse
$settingsFile = Get-ChildItem -Path ".\**" -Filter *.sln.DotSettings -Recurse
$severity = "WARNING"
$outputFile = ".\inspect-code-log.xml"

#just a container for Resharper CLT Nuget
$projectForResharperClt = ".\resharperProject.csproj"
Set-Content -Path $projectForResharperClt -Value '<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><TargetFramework>net5.0</TargetFramework></PropertyGroup></Project>'
$packageDirectory = ".\packages"

echo "Configuration-slnFile:      $slnFile"
echo "Configuration-settingsFile: $settingsFile"
echo "Configuration-severity:     $severity`n"
echo "Configuration-csproj:     $projectForResharperClt"
echo "Configuration-packageDir: $packageDirectory"
echo "Configuration-output:     $outputFile"

#Preparing inspectCode tool
& dotnet add $projectForResharperClt package JetBrains.ReSharper.CommandLineTools --package-directory $packageDirectory

#Running code analysis
$inspectCode = Get-ChildItem -Path ".\**" -Filter *inspectcode.exe -Recurse
& $inspectCode --profile=$settingsFile $slnFile -o="$outputFile" -s="$severity"

#processing result file
[xml]$xml = Get-Content $outputFile
if ($xml.Report.Issues.ChildNodes.Count -gt 0)
{
    echo "`nIssues found in Code:"

    foreach ($node in $xml.Report.Issues.ChildNodes.SelectNodes("//*[@Message]")) 
    {
        $file = $node.attributes['File'].value
        $line = $node.attributes['Line'].value
        $message = $node.attributes['Message'].value

        write-host "##vso[task.LogIssue type=warning;] [$file $line] [$message]"
    }

    echo "##vso[task.complete result=Failed;]"
}
else
{
    echo "`nNo issues found"
}