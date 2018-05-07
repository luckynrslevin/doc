#!/bin/bash
#
# This script creates a ecoDMS backup of the ecoDMS data 
# running as docker on your Synology NAS.
#
# You have to set ECODMS_BACKUP_FOLDER environment variable below
# to match your environment.
# 
# Version 1.1: Enhanced logic to wait until backup is finished completely,
# before shutting down docker.
# 


DOCKER_SERVICE_ENABLED=2 # 0=disabled 1=enabled 2=unknown/error
ECODMS_BACKUP_FOLDER="/volume1/ecodms-backup"
DATE=`date +%Y%m%d`
BACKUP_FILE_WILDCARD="$ECODMS_BACKUP_FOLDER/DMSbackup$DATE*.zip"
BACKUP_FILE_EXISTS=`ls $BACKUP_FILE_WILDCARD 2>/dev/null | wc -l`

# FUNCTIONS
fail () {
  echo "An error occured during the backup of ecodms!"
  exit 1
}
# FUNCTIONS / END


# MAIN

# Exit if backup from today already exists
if [ "$BACKUP_FILE_EXISTS" -eq "1" ]; then
  echo "Today the backup was already done, file already exists:"
  ls -al $BACKUP_FILE_WILDCARD
  echo "Exiting ..."
  exit 0
fi

# Stop docker service if running
DOCKER_SERVICE_ENABLED=`synoservice --is-enabled pkgctl-Docker | grep enabled | wc -l`

if [ "$DOCKER_SERVICE_ENABLED" -eq "1" ]; then
  echo -n "Stop docker service ..."
  synoservicecfg --hard-stop pkgctl-Docker >> /dev/null 2>&1  || fail
  echo "OK"
fi

# Create file "create" in backup folder
# If ecodms gets started again it will automatically start the backup
echo -n "Create \"create\" file in ecodms backup folder ..."
touch "$ECODMS_BACKUP_FOLDER/create" || fail
echo "OK"
echo -n "Start docker service ..."
synoservicecfg --start pkgctl-Docker || fail
echo "OK"

# Wait for backup to finish successfully
# 1) Wait until backup file exists
while [ "$BACKUP_FILE_EXISTS" -ne "1" ]; do
  echo "Backup still running ..."
  sleep 30
  BACKUP_FILE_EXISTS=`ls $BACKUP_FILE_WILDCARD | wc -l`
done

# 2) Wait until backup file size stopped growing
BACKUP_FILE=`ls $BACKUP_FILE_WILDCARD`
SIZE_OF_BACKUP=0
SIZE_OF_BACKUP_STILL_GROWING=1
while [ "$SIZE_OF_BACKUP_STILL_GROWING" -eq "1" ]; do
  echo "Backup still running ..."
  sleep 30
  if [ "$SIZE_OF_BACKUP" -eq $(wc -c <"$BACKUP_FILE") ]; then
    SIZE_OF_BACKUP_STILL_GROWING="0"
  else
    SIZE_OF_BACKUP=`wc -c <"$BACKUP_FILE"`
  fi
done

echo "Backup finished."
# Wait for another 30 seconds before shutting down docker service
sleep 30

# Stop docker containers and docker daemon after backup
echo -n "Stop docker service ..."
synoservicecfg --stop pkgctl-Docker  >> /dev/null 2>&1 || fail
echo "OK"

# MAIN / END
