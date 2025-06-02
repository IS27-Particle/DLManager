# Example json variables
```
{
    "StallAge": "24",
    "OrphanAge": "360",
    "CompleteAge": "15",
    "FailedImportAge": 24,
    "StallList": "/config/StallList.json",
    "LogFile": "/config/Log-2.txt",
    "removeFromClient": true,
    "Torrents": [
        {
            "Name": "qbittorrent",
            "URL": "http://127.0.0.1:8082",
            "User": "admin",
            "PWD": "adminadmin",
            "downloadIDName": "hash",
            "stalledExecTest": "$Torrent -ne $Null -and $Torrent.state -ne 'downloading' -and $Torrent.state -ne 'forcedDL'",
            "idName": "hash",
            "removeCMD": "qbt torrent delete $StalledID --url $Client.URL --username $Client.User --password $Client.PWD -f",
            "incompleteCMD": "qbt torrent list --url $Client.URL --username $Client.User --password $Client.PWD --filter downloading --format json | convertfrom-json",
            "alltorrentsCMD": "qbt torrent list --url $Client.URL --username $Client.User --password $Client.PWD --format json | convertfrom-json",
            "ageTest": "($(Get-Date) - $(Get-Date -UnixTimeSeconds $Torrent.added_on)).Days -gt $CompleteAge",
            "ageEval": "($(Get-Date) - $(Get-Date -UnixTimeSeconds $Torrent.added_on)).Days",
            "dlProg": "$Torrent.completed"
        },
        {
            "Name": "transmission",
            "URL": "http://127.0.0.1:9091/transmission/rpc",
            "User": "UserforRPC",
            "PWD": "PasswordforRPC",
            "downloadIDName": "hashstring",
            "stalledExecTest": "$Torrent -ne $Null -and $Torrent.IsStalled",
            "idName": "id",
            "connectionCMD": "Set-TransmissionCredentials -Host $Client.URL -User $Client.User -Password $Client.PWD",
            "removeCMD": "$StalledID | Remove-TransmissionTorrents -DeleteData",
            "incompleteCMD": "Get-TransmissionTorrents -Incomplete",
            "alltorrentsCMD": "Get-TransmissionTorrents",
            "ageTest": "($(Get-Date) - $(Get-Date -UnixTimeSeconds $Torrent.AddedDate)).Days -gt $CompleteAge",
            "ageEval": "($(Get-Date) - $(Get-Date -UnixTimeSeconds $Torrent.AddedDate)).Days",
            "dlProg": "$Torrent.DownloadedEver"
        }
    ],
    "MediaManagers": [
        {
            "Name": "Sonarr",
            "apikey": "ExampleAPIforSonarr",
            "URL": "http://127.0.0.1:8989/api/v3",
            "blacklistname": "blacklist"
        },
        {
            "Name": "Radarr",
            "apikey": "ExampleAPIforRadarr",
            "URL": "http://127.0.0.1:7878/api/v3",
            "blacklistname": "blocklist"
        },
        {
            "Name": "Lidarr",
            "apikey": "ExampleAPIforLidarr",
            "URL": "http://127.0.0.1:8686/api/v1",
            "blacklistname": "blocklist"
        },
        {
            "Name": "Readarra",
            "apikey": "ExampleAPIforReadarr",
            "URL": "http://127.0.0.1:8788/api/v1",
            "blacklistname": "blacklist"
        },
        {
            "Name": "Readarrb",
            "apikey": "ExampleAPIforReadarr",
            "URL": "http://127.0.0.1:8787/api/v1",
            "blacklistname": "blacklist"
        }
    ]
}
```

## Breakdown of Variables
* StallAge - Amount of iterations of the script run to consider a torrent stalled. If the script is set to run every hour this is equivalent to the amount of hours.
* OrphanAge - Amount of days since torrent was added to client before final removal. Orphans are lingering torrents that are no longer present in the manager queue. When removeFromClient is false this is the amount of days until that torrent is finally removed.
* FailedImportAge - Amount of iterations to keep completed torrents left in the manager queue. They will remain in the queue when there was an issue importing the file so this will mean the download will be blacklisted. So if you want to allow yourself more time to manage manual imports set this value to something very high.
* StallList - File path to the Stalled torrent list database. Each time a torrent is confirmed stalled it will appear and the count will increase if there's no change in progress.
* LogFile - File Path for the log file.
* removeFromClient - When a torrent is detected as stalled, should it also be removed from the download client. Boolean value (true or false)
* Torrents - the list of download clients
* MediaManagers - the list of Media managers (Servarr apps)

### Torrents
**Download Clients Object**
* Name - (required) A name for the Download Client. This is to help organize the list and is used in logging output.
* URL - (optional) The URL used to interact with the client API.
* User - (optional) The username to authenticate the API
* PWD - (optional) The password to authenticate the API
* downloadIDName - (required) The key or value which uniquely identifies each torrent from the perspective of the manager (TODO: move this into the MediaManagers)
* stalledExecTest - (required) The Boolean test evaluation which identifies a torrent as Stalled
* idName - (optional) The name of the key which uniquely identifies the torrent from the perspective of the download client
* connectionCMD - (optional) Required if the download client requires a connection initialization
* removeCMD - (required) The command used to remove the torrent from the client, used for Orphan torrent removal.
* incompleteCMD - (required) The command used to gather a list of incomplete torrents (TODO: is this needed now that Completed Stall handling has been implemented?)
* allTorrentsCMD - (required) The command used to get all torrents in the download client.
* ageTest - (required) Command used for day based evaluations to determine the age of the torrent in the download client. (TODO: Determine redundancy based on ageEval key)
* ageEval - (required) Command used to get the value in days of the torrent's age.
* dlProg - (required) Command used to get the progress of a torrent.

### MediaManagers
**Only Servarr Platform Supported** (TODO: expand to be more dynamic)
* Name - (required) Value used to identify this manager instance, used to organize the config JSON and output to logs.
* apiKey - (required) Value used to authenticate to the manager API
* URL - (required) Value used to communicate with the manager platform
* blacklistName - (required) Name of the query parameter used for blocking a release in the manager platform.

## Custom Commands
Below refers to the values stored in the following Variables:
* `Torrents.[].stalledExecTest`
* `Torrents.[].removeCMD`
* `Torrents.[].incompleteCMD`
* `Torrents.[].allTorrentsCMD`
* `Torrents.[].ageTest`
* `Torrents.[].ageEval`
* `Torrents.[].dlProg`

**Syntax**: PowerShell

**stalledExecTest**
qBittorrent: `$Torrent -ne $Null -and $Torrent.state -ne 'downloading' -and $Torrent.state -ne 'forcedDL'`


**Context**
### global scope 
```{powershell}
$config = Get-Content /config/config.json | ConvertFrom-Json
# The configuration file shown above
...
$LogFile = $config.LogFile
# LogFile value in $config. Logging is done by Start-Transcript
...
$StallAge = $config.StallAge
# Stalled Torrent Age
...
$OrphanAge = $config.OrphanAge
# Orphan Torrent Removal Age
...
$FailedImportAge = $config.FailedImportAge
# Completed Torrent Import Failure Age
...
$StallListFile = $config.StallListFile
# The file which contains the JSON array database
...
$Torrents = $config.Torrents
# The array for Download Clients
...
$global:StallList = @{}
if (test-path $StallListFile) {
        $global:StallList = $(Get-Content $StallListFile | convertfrom-json -AsHashtable)
}
# Stall List data table, initializes as an empty hash table, otherwise convert JSON file to hashtable
...
$global:OrigList = $global:StallList.Clone()
# OrigList is cloned from StallList to ensure continually stalled items are only marked once (applies to Bulk based torrents in manager queue)
...
$global:Marked = @{}
ForEach ($key in $global:StallList.keys) {
        $global:Marked[$key] = $false
}
# This appears like duplicate logic,  (TODO: evaluate logic)
...
$MediaManagers = $config.MediaManagers
# The Servarr instances
...
```
### Manager scope
```{powershell}
ForEach ($Manager in $MediaManagers) {
# $Manager is the specific Servarr instances
...
$apiKey = $Manager.apikey
# Instance API key for requests
...
$AuthURL = "apikey=$apiKey"
# Authorization Query for URL concatenate (TODO: Can probably be omitted)
...
$URL = $Manager.URL
# URL for web requests to manager API
...
$QueueURL = "$URL/queue"
# URL for gathering the queue from the manager
...
$page = 1
# Pagination
...
$headers = @{
     'X-api-key'=$apiKey
}
# Servarr API header
...
$Queue = Invoke-RestMethod -Uri "$($QueueURL)?page=$($page)&pageSize=20&sortDirection=descending&sortKey=progress" -Headers $headers
# Initial GET for queue to use the totalRecords value
...
$Queue = Invoke-RestMethod -Uri "$($QueueURL)?page=$($page)&pageSize=$($Queue.totalRecords)&sortDirection=descending&sortKey=progress" -Headers $headers
# Gets entire queue
...
```
### Download Client Scope
```{powershell}
ForEach ($Client in $Torrents) {
# $Client will refer to an individual download client definition
...
Invoke-Expression -Command $Client.connectionCMD
# Usage of connectionCMD
...
$Client.Torrents = Invoke-Expression -Command $Client.incompleteCMD
# Usage of incompleteCMD stores the result in a Torrents key inside the object so this cannot be used for anything else (TODO: this should attach to the Manager object, not the Client object)
...
$AllTorrents = Invoke-Expression -Command $Client.alltorrentsCMD
# Usage of allTorrentsCMD (TODO: Should be prepared once per client prior to loop)
...
$Stalled = $Queue.records | Where-Object {$_.downloadClient -eq "$($Client.Name)"}
# Filter the related queue items (TODO: for dynamic manager usage the names will require defining from manager perspective)
```
### Queue Item Scope
```{powershell}
Foreach ($QEpisode in $Stalled) {
...
$Torrent = $Client.Torrents | Where-Object {$_."$($Client.downloadIDName)" -eq $QEpisode.downloadId}
### usage of downloadIDName filters the list of queue items
...
$Torrent = $AllTorrents | Where-Object {$_."$($Client.downloadIDName)" -eq $QEpisode.downloadId}
# Filter all torrents for the item
...
If ((Invoke-Expression -Command $($Client.stalledExecTest)) -or $QEpisode.status -eq "completed") {
# usage of stalledExecTest
...
$StallID = $($Torrent."$($Client.idName)")
# Usage of idName and capture of id value
...
If ((([int]$StallList["$($StallID)"] -gt $StallAge -or $(Invoke-Expression -Command $Client.ageTest)) -and $QEpisode.status -ne "completed") -or ($QEpisode.status -eq "completed" -and [int]$StallList["$($StallID)"] -gt $FailedImportAge)) {
# Usage of age test and implementation of StallAge and FailedImportAge
...
Invoke-RestMethod -Method 'DELETE' -Uri "$QueueURL/$($QEpisode.id)?$($AuthURL)&$($Manager.blacklistname)=true&removeFromClient=$($config.removeFromClient)"
# Deletion of queue items in Servarr Platform 
...
If ($StallList["$($StallID)Prog"] -eq $(Invoke-Expression -Command $Client.dlProg)) {
# Implementation of dlProg
```
### End Queue Item Scope
### End Client Scope
### End Manager Scope
### Client Scope
```{powershell}
ForEach ($Client in $Torrents) {
# Iterate Clients
...
$StalledIDs = $Client.Torrents["$($Client.idName)"]
# (TODO: This works? what is this doing?)
```
### Client Item Scope
```{powershell}
Foreach ($StalledID in $StalledIDs) {
# $StalledID is the torrent item
...
If ([int]$OrigList["$($StalledID)"] -gt $OrphanAge) {
# Orphan Age Implementation
...
Invoke-Expression -Command $Client.removeCMD
# usage of removeCMD
```
### End Client Item Scope
### Client item scope
```{powershell}
If (Invoke-Expression -Command $Client.ageTest) {
# Age Test implementation
...
$StalledID = $Torrent."$($Client.idName)"
# ID of item
...
Write-Host "$($Torrent.Name) will be removed, Torrent age is $(Invoke-Expression -Command $Client.ageEval)"
# Age Eval implementation 
...
Invoke-Expression -Command $Client.removeCMD
# Usage of removeCMD
```