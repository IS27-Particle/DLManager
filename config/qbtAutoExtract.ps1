#!/usr/bin/pwsh

Start-Transcript "$PSScriptRoot/qbtExtract.log" -Force
$config = Get-Content /config/config.json | ConvertFrom-Json
$MediaManagers = $config.MediaManagers

ForEach ($Manager in $MediaManagers) {
    "Starting $($Manager.Name)"
    $apiKey = $Manager.apikey
    $AuthURL = "apikey=$apiKey"
    $URL = $Manager.URL
    $QueueURL = "$URL/queue"
    $page = 1
    $headers = @{
        'X-api-key'=$apiKey
    }
    $Queue = Invoke-RestMethod -Uri "$($QueueURL)?page=$($page)&pageSize=20&sortDirection=descending&sortKey=progress" -Headers $headers
    $Queue = Invoke-RestMethod -Uri "$($QueueURL)?page=$($page)&pageSize=$($Queue.totalRecords)&sortDirection=descending&sortKey=progress" -Headers $headers
    $completed = $Queue.records | Where {$_.status -eq "completed" -and $_.downloadClient -eq "QBittorrent" -and $_.trackedDownloadState -eq "importPending"}
    [System.Collections.ArrayList]$performed=@()

    ForEach ($item in $completed) {
        if ($item.downloadId -notin $performed) {
            sh /config/qbtExtract.sh `"$($item.title)`" `"$($Manager.QPath)`"
            $performed.add($item.downloadId)
        }
    }
}
Stop-Transcript