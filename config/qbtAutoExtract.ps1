#!/usr/bin/pwsh

Start-Transcript "$PSScriptRoot/qbtExtract.log"
$Server = "127.0.0.1"
$MediaManagers = @(
        @{
                Name = "Sonarr"
                apikey = "0a4a58aa0ebc4ac4bc362f8ec09e32f9"
                URL = "http://$($Server):8989/sonarr/api/v3"
                QPath = "tv-sonarr"
        }
        @{
                Name = "Radarr"
                apikey = "53b5e1bf668f402aa92828ea7e649b0e"
                URL = "http://$($Server):7878/radarr/api/v3"
                QPath = "radarr"
        }
        @{
                Name = "Lidarr"
                apikey = "1f3c3833b4b44d6582fe2500c9964f6b"
                URL = "http://$($Server):8686/lidarr/api/v1"
                QPath = "lidarr"
        }
        @{
                Name = "Readarra"
                apikey = "1e7d22430a244b23bf1cb5f9ee38d4da"
                URL = "http://$($Server):8788/readarra/api/v1"
                QPath = "readarra"
        }
        @{
                Name = "Readarrb"
                apikey = "f085ea58aae04249b19542a924823197"
                URL = "http://$($Server):8787/readarrb/api/v1"
                QPath = "readarrb"
        }
)

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
<#
"Starting Sonarr" | Out-File "$PSScriptRoot/Log.txt" -Append
$apiKey = "0a4a58aa0ebc4ac4bc362f8ec09e32f9"
$AuthURL = "apikey=$apiKey"
$URL = "http://10.255.255.20:8989/sonarr/api/v3"
$QueueURL = "$URL/queue"

$page = 1
$headers = @{
    'X-api-key'=$apiKey
}
$Queue = Invoke-RestMethod -Uri "$($QueueURL)?page=$($page)&pageSize=20&sortDirection=descending&sortKey=progress" -Headers $headers
$Queue = Invoke-RestMethod -Uri "$($QueueURL)?page=$($page)&pageSize=$($Queue.totalRecords)&sortDirection=descending&sortKey=progress" -Headers $headers
$Queue.page
$page

$completed = $Queue.records | Where {$_.status -eq "completed" -and $_.downloadClient -eq "QBittorrent" -and $_.trackedDownloadState -eq "importPending"}
[System.Collections.ArrayList]$performed=@()

ForEach ($item in $completed) {
    if ($item.downloadId -notin $performed) {
        sudo -u plex unrar x "$($item.outputPath)/*.rar" "$($item.outputPath)/"
        sudo -u plex unrar x "$($item.outputPath)/*.zip" "$($item.outputPath)/"
        $performed.add($item.downloadId)
    }
}

"Starting Radarr" | Out-File "$PSScriptRoot/Log.txt" -Append
$apiKey = "53b5e1bf668f402aa92828ea7e649b0e"
$AuthURL = "apikey=$apiKey"
$URL = "http://10.255.255.20:7878/radarr/api/v3"
$QueueURL = "$URL/queue"

$page = 1
$headers = @{
    'X-api-key'=$apiKey
}
$Queue = Invoke-RestMethod -Uri "$($QueueURL)?page=$($page)&pageSize=20&sortDirection=descending&sortKey=progress" -Headers $headers
$Queue = Invoke-RestMethod -Uri "$($QueueURL)?page=$($page)&pageSize=$($Queue.totalRecords)&sortDirection=descending&sortKey=progress" -Headers $headers
$Queue.page
$page

$completed = $Queue.records | Where {$_.status -eq "completed" -and $_.downloadClient -eq "QBittorrent" -and $_.trackedDownloadState -eq "importPending"}
[System.Collections.ArrayList]$performed=@()

ForEach ($item in $completed) {
    if ($item.downloadId -notin $performed) {
        sudo -u plex unrar x "$($item.outputPath)/*.rar" "$($item.outputPath)/"
        sudo -u plex unrar x "$($item.outputPath)/*.zip" "$($item.outputPath)/"
        $performed.add($item.downloadId)
    }
}

"Starting Lidarr" | Out-File "$PSScriptRoot/Log.txt" -Append
$apiKey = "1f3c3833b4b44d6582fe2500c9964f6b"
$AuthURL = "apikey=$apiKey"
$URL = "http://10.255.255.20:8686/lidarr/api/v1"
$QueueURL = "$URL/queue"

$page = 1
$headers = @{
    'X-api-key'=$apiKey
}
$Queue = Invoke-RestMethod -Uri "$($QueueURL)?page=$($page)&pageSize=20&sortDirection=descending&sortKey=progress" -Headers $headers
$Queue = Invoke-RestMethod -Uri "$($QueueURL)?page=$($page)&pageSize=$($Queue.totalRecords)&sortDirection=descending&sortKey=progress" -Headers $headers
$Queue.page
$page

$completed = $Queue.records | Where {$_.status -eq "completed" -and $_.downloadClient -eq "QBittorrent" -and $_.trackedDownloadState -eq "importPending"}
[System.Collections.ArrayList]$performed=@()

ForEach ($item in $completed) {
    if ($item.downloadId -notin $performed) {
        sudo -u plex unrar x "$($item.outputPath)/*.rar" "$($item.outputPath)/"
        sudo -u plex unrar x "$($item.outputPath)/*.zip" "$($item.outputPath)/"
        $performed.add($item.downloadId)
    }
}

"Starting Readarra" | Out-File "$PSScriptRoot/Log.txt" -Append
$apiKey = "1e7d22430a244b23bf1cb5f9ee38d4da"
$AuthURL = "apikey=$apiKey"
$URL = "http://10.255.255.20:8788/readarra/api/v1"
$QueueURL = "$URL/queue"

$page = 1
$headers = @{
    'X-api-key'=$apiKey
}
$Queue = Invoke-RestMethod -Uri "$($QueueURL)?page=$($page)&pageSize=20&sortDirection=descending&sortKey=progress" -Headers $headers
$Queue = Invoke-RestMethod -Uri "$($QueueURL)?page=$($page)&pageSize=$($Queue.totalRecords)&sortDirection=descending&sortKey=progress" -Headers $headers
$Queue.page
$page

$completed = $Queue.records | Where {$_.status -eq "completed" -and $_.downloadClient -eq "QBittorrent" -and $_.trackedDownloadState -eq "importPending"}
[System.Collections.ArrayList]$performed=@()

ForEach ($item in $completed) {
    if ($item.downloadId -notin $performed) {
        sudo -u plex unrar x "$($item.outputPath)/*.rar" "$($item.outputPath)/"
        sudo -u plex unrar x "$($item.outputPath)/*.zip" "$($item.outputPath)/"
        $performed.add($item.downloadId)
    }
}

"Starting Readarrb" | Out-File "$PSScriptRoot/Log.txt" -Append
$apiKey = "f085ea58aae04249b19542a924823197"
$AuthURL = "apikey=$apiKey"
$URL = "http://10.255.255.20:8787/readarrb/api/v1"
$QueueURL = "$URL/queue"

$page = 1
$headers = @{
    'X-api-key'=$apiKey
}
$Queue = Invoke-RestMethod -Uri "$($QueueURL)?page=$($page)&pageSize=20&sortDirection=descending&sortKey=progress" -Headers $headers
$Queue = Invoke-RestMethod -Uri "$($QueueURL)?page=$($page)&pageSize=$($Queue.totalRecords)&sortDirection=descending&sortKey=progress" -Headers $headers
$Queue.page
$page

$completed = $Queue.records | Where {$_.status -eq "completed" -and $_.downloadClient -eq "QBittorrent" -and $_.trackedDownloadState -eq "importPending"}
[System.Collections.ArrayList]$performed=@()

ForEach ($item in $completed) {
    if ($item.downloadId -notin $performed) {
        sudo -u plex unrar x "$($item.outputPath)/*.rar" "$($item.outputPath)/"
        sudo -u plex unrar x "$($item.outputPath)/*.zip" "$($item.outputPath)/"
        $performed.add($item.downloadId)
    }
}#>
