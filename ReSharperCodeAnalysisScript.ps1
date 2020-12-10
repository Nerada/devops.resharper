$slnFile = Get-ChildItem -Path ".\**" -Filter *.sln -Recurse
$settingsFile = Get-ChildItem -Path ".\**" -Filter *.sln.DotSettings -Recurse
$severity = "WARNING"
$outputFile = ".\inspect-code-log.xml"

#just a container for Resharper CLT Nuget
$projectForResharperClt = ".\resharperProject.csproj"
Set-Content -Path $projectForResharperClt -Value '<Project><PropertyGroup><OutputType>Exe</OutputType><TargetFramework>net5.0</TargetFramework></PropertyGroup></Project>'
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
[xml]$xml = gc $outputFile
if ($xml.Report.Issues.ChildNodes.Count -gt 0)
{
 write-error ("`nIssues found in Code: `n" + ((gc $outputFile) -join "`n"))
}
else
{
 echo "No issues found"
}