#!/usr/bin/pwsh
import-module Transmission
Start-Transcript -Path "$PSScriptRoot/Log-2.txt" -Append

$ServerAddr = "127.0.0.1"

$StallAge = 24
$OrphanAge = 360
$CompleteAge = 15

# Torrent Client Auth
[System.Collections.Arraylist]$Torrents = @()
$Torrents = @(
        @{
                Name="qbittorrent"
                URL="http://$($ServerAddr):8082"
                User="admin"
                PWD="adminadmin"
                downloadIDName="hash"
                stalledExecTest='$Torrent -ne $Null -and $Torrent.state -ne "downloading" -and $Torrent.state -ne "forcedDL"'
                idName="hash"
                removeCMD='qbt torrent delete $StalledID --url $Client.URL --username $Client.User --password $Client.PWD -f'
                incompleteCMD='qbt torrent list --url $($Client["URL"]) --username $($Client["User"]) --password $($Client["PWD"]) --filter downloading --format json | convertfrom-json'
                alltorrentsCMD='qbt torrent list --url $($Client["URL"]) --username $($Client["User"]) --password $($Client["PWD"]) --format json | convertfrom-json'
                ageTest='($(Get-Date) - $(Get-Date -UnixTimeSeconds $Torrent.added_on)).Days -gt $CompleteAge'
                ageEval='($(Get-Date) - $(Get-Date -UnixTimeSeconds $Torrent.added_on)).Days'
                dlProg='$Torrent.completed'
        }
        @{
                Name="transmission"
                URL="http://$($ServerAddr):9091/transmission/rpc"
                User="matt"
                PWD="Wiggin8!3"
                downloadIDName="hashstring"
                stalledExecTest='$Torrent -ne $Null -and $Torrent.IsStalled'
                idName="id"
                connectionCMD='Set-TransmissionCredentials -Host $Client.URL -User $Client.User -Password $Client.PWD'
                removeCMD='$StalledID | Remove-TransmissionTorrents -DeleteData'
                incompleteCMD='Get-TransmissionTorrents -Incomplete'
                alltorrentsCMD='Get-TransmissionTorrents'
                ageTest='($(Get-Date) - $(Get-Date -UnixTimeSeconds $Torrent.AddedDate)).Days -gt $CompleteAge'
                ageEval='($(Get-Date) - $(Get-Date -UnixTimeSeconds $Torrent.AddedDate)).Days'
                dlProg='$Torrent.DownloadedEver'
        }
)

#StallList and Marked Array for Validation
$global:StallList = @{}
if (test-path "$PSScriptRoot/StallList.json") {
        $global:StallList = $(Get-Content "$PSScriptRoot/StallList.json" | convertfrom-json -AsHashtable)
}
$global:OrigList = $global:StallList.Clone()
$global:Marked = @{}
ForEach ($key in $global:StallList.keys) {
        $global:Marked[$key] = $false
}

$MediaManagers = @(
        @{
                Name = "Sonarr"
                apikey = "0a4a58aa0ebc4ac4bc362f8ec09e32f9"
                URL = "http://$($ServerAddr):8989/sonarr/api/v3"
                blacklistname = "blacklist"
        }
        @{
                Name = "Radarr"
                apikey = "53b5e1bf668f402aa92828ea7e649b0e"
                URL = "http://$($ServerAddr):7878/radarr/api/v3"
                blacklistname = "blocklist"
        }
        @{
                Name = "Lidarr"
                apikey = "1f3c3833b4b44d6582fe2500c9964f6b"
                URL = "http://$($ServerAddr):8686/lidarr/api/v1"
                blacklistname = "blocklist"
        }
        @{
                Name = "Readarra"
                apikey = "1e7d22430a244b23bf1cb5f9ee38d4da"
                URL = "http://$($ServerAddr):8788/readarra/api/v1"
                blacklistname = "blacklist"
        }
        @{
                Name = "Readarrb"
                apikey = "f085ea58aae04249b19542a924823197"
                URL = "http://$($ServerAddr):8787/readarrb/api/v1"
                blacklistname = "blacklist"
        }
)

ForEach ($Manager in $MediaManagers) {
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
        ForEach ($Client in $Torrents) {
                If ($null -ne $Client.connectionCMD) {
                        Invoke-Expression -Command $Client.connectionCMD
                }
                $Client.Torrents = Invoke-Expression -Command $Client.incompleteCMD
                $Stalled = $Queue.records | Where-Object {$_.status -ne "completed" -and $_.downloadClient -eq "$($Client.Name)"}
                Foreach ($QEpisode in $Stalled) {
                        $Torrent = $Client.Torrents | Where-Object {$_."$($Client.downloadIDName)" -eq $QEpisode.downloadId}
                        Write-Host $QEpisode.title
                        If (Invoke-Expression -Command $($Client.stalledExecTest)) {
                                $StallID = $($Torrent."$($Client.idName)")
                                If ($StallList.containsKey("$($StallID)")){
                                        If ([int]$StallList["$($StallID)"] -gt $StallAge -or $(Invoke-Expression -Command $Client.ageTest)) {
                                                Write-Host "Removing Stalled Torrent - $($Torrent.Name)"
                                                Invoke-RestMethod -Method 'DELETE' -Uri "$QueueURL/$($QEpisode.id)?$($AuthURL)&$($Client.blacklistname)=true"
                                                $StallList.remove("$($StallID)")
                                                $StallList.remove("$($StallID)Prog")
                                                $OrigList.remove("$($StallID)")
                                                $OrigList.remove("$($StallID)Prog")
                                                $Marked.remove("$($StallID)")
                                                $Marked.remove("$($StallID)Prog")
                                        } ElseIf (-not $Marked["$($Torrent.id)"]) {
                                                If ($StallList["$($StallID)Prog"] -eq $(Invoke-Expression -Command $Client.dlProg)) {
                                                        Write-Host "Promoted from $([string]$([int]$($StallList["$($StallID)"]))) to $([string]$([int]$($StallList["$($StallID)"])+1))"
                                                        $StallList["$($StallID)"] = [string]$([int]$($StallList["$($StallID)"])+1)
                                                        $StallList["$($StallID)Prog"] = $(Invoke-Expression -Command $Client.dlProg)
                                                        $OrigList.remove("$($StallID)")
                                                        $OrigList.remove("$($StallID)Prog")
                                                        $Marked["$($StallID)"] = $true
                                                } else {
                                                        Write-Host "Removing $($StallID)"
                                                        $StallList.remove("$($StallID)")
                                                        $StallList.remove("$($StallID)Prog")
                                                        $OrigList.remove("$($StallID)")
                                                        $OrigList.remove("$($StallID)Prog")
                                                        $Marked.remove("$($StallID)")
                                                        $Marked.remove("$($StallID)Prog")
                                                }
                                        }
                                } Else {
                                        Write-Host "Adding $($Torrent.Name) to Counter JSON"
                                        $StallList["$($StallID)"] = "1"
                                        $StallList["$($StallID)Prog"] = Invoke-Expression -Command $Client.dlProg
                                        $Marked["$($StallID)"] = $true
                                }
                        }
                }
        }
}

Write-Host "Cleaning Torrents"
###===========================
### Pause Program for 30 seconds
### - Matt Brown, 2008
###===========================
$x = 30#15*60
$length = $x / 100
while($x -gt 0) {
  $min = [int](([string]($x/60)).split('.')[0])
  $text = " " + $min + " minutes " + ($x % 60) + " seconds left"
  Write-Progress "Pausing Script" -status $text -perc ($x/$length)
  start-sleep -s 1
  $x--
}

ForEach ($Client in $Torrents) {
        $StalledIDs = $Client.Torrents["$($Client.idName)"]
        Foreach ($StalledID in $StalledIDs) {
                If ($OrigList.containsKey("$($StalledID)")) {
                        If ([int]$OrigList["$($StalledID)"] -gt $OrphanAge) {
                                Invoke-Expression -Command $Client.removeCMD
                                $OrigList.remove($StalledID)
                                $StallList.remove($StalledID)
                                $OrigList.remove("$($StalledID)Prog")
                                $StallList.remove("$($StalledID)Prog")
                        } Else {
                                If ($StallList["$($StallID)Prog"] -eq $(Invoke-Expression -Command $Client.dlProg)) {
                                        $StallList["$($StalledID)"] = [string]$([int]$($StallList["$($StalledID)"])+1)
                                        $StallList["$($StalledID)Prog"] = $(Invoke-Expression -Command $Client.dlProg)
                                        $OrigList.remove($StalledID)
                                        $OrigList.remove("$($StalledID)Prog")
                                } Else {
                                        $OrigList.remove($StalledID)
                                        $StallList.remove($StalledID)
                                        $OrigList.remove("$($StalledID)Prog")
                                        $StallList.remove("$($StalledID)Prog")
                                }
                        }
                } Else {
                        If (-not $StallList.containsKey("$($StalledID)")){
                                $StallList["$($StalledID)"] = "1"
                                $StallList["$($StalledID)Prog"] = Invoke-Expression -Command $Client.dlProg
                        }
                }
        }
        $AllTorrents = Invoke-Expression -Command $Client.alltorrentsCMD
        Foreach ($Torrent in $AllTorrents) {
                If (Invoke-Expression -Command $Client.ageTest) {
                        $StalledID = $Torrent."$($Client.idName)"
                        Write-Host "$($Torrent.Name) will be removed, Torrent age is $(Invoke-Expression -Command $Client.ageEval)"
                        Invoke-Expression -Command $Client.removeCMD
                }
        }
}

Foreach ($item in $OrigList.keys) {
        $StallList.remove("$item")
        $StallList.remove("$($item)Prog")
}

$StallList | Convertto-JSON | Out-File "$PSScriptRoot/StallList.json"

Stop-Transcript