# Example json variables
```
{
    "StallAge": "24",
    "OrphanAge": "360",
    "CompleteAge": "15",
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
* CompleteAge - Amount of iterations to keep completed torrents left in the manager queue. They will remain in the queue when there was an issue importing the file so this will mean the download will be blacklisted. So if you want to allow yourself more time to manage manual imports set this value to something very high.
* StallList - File path to the Stalled torrent list database. Each time a torrent is confirmed stalled it will appear and the count will increase if there's no change in progress.
* LogFile - File Path for the log file.
* removeFromClient - When a torrent is detected as stalled, should it also be removed from the download client. Boolean value (true or false)
* Torrents - the list of download clients
* MediaManagers - the list of Media managers (Servarr apps)