# devops_resharperScript
Script for ReSharper code analysis to use in azure pipeline

```
- task: PowerShell@2
  displayName: 'ReSharper code analysis'
  inputs:
	targetType: 'inline'
	script: '. { iwr -useb https://raw.githubusercontent.com/Nerada/devops_resharperScript/master/ReSharperCodeAnalysisScript.ps1 } | iex; ReSharperCodeAnalysisScript'
```