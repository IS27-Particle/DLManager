TR_TORRENT_NAME="$1"
TR_TORRENT_APP="$2"
TR_TORRENT_DIR="/downloads/qcomplete"
echo "$TR_TORRENT_DIR/$TR_TORRENT_APP/$TR_TORRENT_NAME"
unrar x -r "$TR_TORRENT_DIR/$TR_TORRENT_APP/$TR_TORRENT_NAME/*.rar" "$TR_TORRENT_DIR/$TR_TORRENT_APP/$TR_TORRENT_NAME/"
unrar x -r "$TR_TORRENT_DIR/$TR_TORRENT_APP/$TR_TORRENT_NAME/*.zip" "$TR_TORRENT_DIR/$TR_TORRENT_APP/$TR_TORRENT_NAME/"
chown -R 2006:2006 "$TR_TORRENT_DIR/$TR_TORRENT_APP/$TR_TORRENT_NAME/"
chmod -R u+rwx,g+rwx "$TR_TORRENT_DIR/$TR_TORRENT_APP/$TR_TORRENT_NAME/"
