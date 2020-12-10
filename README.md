# ReSharper Script
Script for ReSharper code analysis, used in my Azure pipelines

```
- task: PowerShell@2
  displayName: 'ReSharper code analysis'
  inputs:
	targetType: 'inline'
	script: '. { iwr -useb https://raw.githubusercontent.com/Nerada/devops_resharperScript/master/ReSharperCodeAnalysisScript.ps1 } | iex; ReSharperCodeAnalysisScript'
```
