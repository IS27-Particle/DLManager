#!/usr/bin/pwsh
import-module Transmission
$config = Get-Content /config/config.json | ConvertFrom-Json
$LogFile = $config.LogFile
Start-Transcript -Path $LogFile -Append -Force

$StallAge = $config.StallAge
$OrphanAge = $config.OrphanAge
$CompleteAge = $config.CompleteAge
$FailedImportAge = $config.FailedImportAge
$StallListFile = $config.StallListFile

$Torrents = $config.Torrents

#StallList and Marked Array for Validation
$global:StallList = @{}
if (test-path $StallListFile) {
        $global:StallList = $(Get-Content $StallListFile | convertfrom-json -AsHashtable)
}
$global:OrigList = $global:StallList.Clone()
$global:Marked = @{}
ForEach ($key in $global:StallList.keys) {
        $global:Marked[$key] = $false
}

$MediaManagers = $config.MediaManagers

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
		Write-Host "Starting $Client"
                $Client.Torrents = Invoke-Expression -Command $Client.incompleteCMD
                $AllTorrents = Invoke-Expression -Command $Client.alltorrentsCMD
                $Stalled = $Queue.records | Where-Object {$_.status -ne "completed" -and $_.downloadClient -eq "$($Client.Name)"}
                $Stalled = $Queue.records | Where-Object {$_.downloadClient -eq "$($Client.Name)"}
                Foreach ($QEpisode in $Stalled) {
                        $Torrent = $Client.Torrents | Where-Object {$_."$($Client.downloadIDName)" -eq $QEpisode.downloadId}
                        Write-Host "$($QEpisode.status) - $($QEpisode.title)"
                        Write-Host "QEpisode"
                        Write-Host $QEpisode
                        If ($Torrent -eq $null -and $QEpisode.status -eq "completed") {
                                $Torrent = $AllTorrents | Where-Object {$_."$($Client.downloadIDName)" -eq $QEpisode.downloadId}
                        } ElseIf ($Torrent -eq $null) {
                                Write-Host "$($QEpisode.status) - $($QEpisode.title)"
                                Write-Host "Skipping due to not found in Client"
                                continue
                        }
			Write-Host "Torrent - $Torrent"
                        If ((Invoke-Expression -Command $($Client.stalledExecTest)) -or $QEpisode.status -eq "completed") {
                                Write-Host "Stalled Exec Test Passed"
                                $StallID = $($Torrent."$($Client.idName)")
                                If ($StallList.containsKey("$($StallID)")){
                                        Write-Host "$StallID exists in StallList"
                                        If ((([int]$StallList["$($StallID)"] -gt $StallAge -or $(Invoke-Expression -Command $Client.ageTest)) -and $QEpisode.status -ne "completed") -or ($QEpisode.status -eq "completed" -and [int]$StallList["$($StallID)"] -gt $FailedImportAge)) {
                                                Write-Host "Removing Stalled Torrent - $($Torrent.Name)"
                                                Invoke-RestMethod -Method 'DELETE' -Uri "$QueueURL/$($QEpisode.id)?$($AuthURL)&$($Manager.blacklistname)=true&removeFromClient=$($config.removeFromClient)"
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
                                                        Write-Host "Removing $($Torrent.Name) from Counter JSON"
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
	if ($Client.Torrents.length -gt 0) {
	        $StalledIDs = $Client.Torrents["$($Client.idName)"]
	} else {
		$StalledIDs = @()
                write-host "$($Client.Name) had no stalled torrents"
	}
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

$StallList | Convertto-JSON | Out-File $StallListFile

Stop-Transcript
