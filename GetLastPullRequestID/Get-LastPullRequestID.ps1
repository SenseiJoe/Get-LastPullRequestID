#
<#
    .SYNOPSIS
    This script retrieves the last pull request Id
    .DESCRIPTION
    Grab the last pull request Id from the master branch
    .NOTES
    Make sure access to the OAuth token is enabled for the stage
    'Allow scripts to access the OAuth token'

    Written by Joe Sherwood
#>


[string]$PAT = Get-VstsInput -Name AccessToken
$Credential = ":$($PAT)"

if( [string]::IsNullOrEmpty($PAT) -and $env:SYSTEM_ENABLEACCESSTOKEN -eq "False" ) {
    Write-Host "##vso[task.setvariable variable=LastPullRequestId;]-1"
    Write-Host "##vso[task.debug]PAT and AccessToken are False"
    $LASTEXITCODE = 1
    Write-Error -Message "AccessToken(PAT) and OAuth are not available!" 
    return
}

$ApiHeader = @{Authorization = "Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($Credential)))" }

if( $env:SYSTEM_ENABLEACCESSTOKEN -eq "True" ) {
    $ApiHeader = @{Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN" }
}

$TFS = $env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI
$Project = $env:SYSTEM_TEAMPROJECT
$Repo = $env:BUILD_REPOSITORY_NAME

$Uri = "$($TFS)$($Project)/_apis/git/repositories/$($Repo)/pullrequests?searchCriteria.status=completed&searchCriteria.targetRefName=refs/heads/master&`$top=1"

try {
    $LastPullRequestId = (Invoke-RestMethod $Uri -Method 'GET' -Headers $ApiHeader).value.pullRequestId
    Write-Host "##vso[task.setvariable variable=LastPullRequestId;]$($LastPullRequestId)"
} 
catch { 
    Write-Host "##vso[task.setvariable variable=LastPullRequestId;]-1"
}

