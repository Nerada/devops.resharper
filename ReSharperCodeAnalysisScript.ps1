#  -------------------------------------------
#      Author: Ramon Bollen
#        File: ReSharperCodeAnalysisScript.ps1
#  Created on: 20201210
#  -------------------------------------------

# --- Helper Functions ---
function WriteXmlToScreen ([xml]$xml)
{
    $StringWriter = New-Object System.IO.StringWriter;
    $XmlWriter = New-Object System.Xml.XmlTextWriter $StringWriter;
    $XmlWriter.Formatting = "indented";
    $xml.WriteTo($XmlWriter);
    $XmlWriter.Flush();
    $StringWriter.Flush();
    Write-Output $StringWriter.ToString();
}

# --- Header ---
echo "`n"
echo "  ---------------------------------------------"
echo " |     Author: Ramon Bollen                    |"
echo " |       File: ReSharperCodeAnalysisScript.ps1 |"
echo " | Created on: 20201210                        |"
echo " |                                      v1.1.3 |"
echo "  ---------------------------------------------"
echo "`n"
echo "`n"
# --- Main Script ---
$slnFile = Get-ChildItem -Path ".\**" -Filter *.sln -Recurse
$settingsFile = Get-ChildItem -Path ".\**" -Filter *.sln.DotSettings -Recurse
$severity = "WARNING"
$outputFile = ".\inspect-code-log.xml"

#Container project for Resharper CLT Nuget
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

#Rmove container project
Remove-Item $projectForResharperClt

#processing result file
[xml]$xml = Get-Content $outputFile

echo "`n"
WriteXmlToScreen $xml

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