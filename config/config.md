# Example json variables
```
{
    "StallAge": "24",
    "OrphanAge": "360",
    "CompleteAge": "15",
    "StallList": "/config/StallList.json",
    "LogFile": "/config/Log-2.txt",
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