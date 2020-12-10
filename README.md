# ReSharper Script
Script for ReSharper code analysis, used in my Azure pipelines

```
    - task: PowerShell@2
      displayName: 'ReSharper code analysis'
      timeoutInMinutes: 5
      inputs:
        targetType: 'inline'
        script: 'iex (iwr https://raw.githubusercontent.com/Nerada/devops_resharperScript/master/ReSharperCodeAnalysisScript.ps1)'
```
