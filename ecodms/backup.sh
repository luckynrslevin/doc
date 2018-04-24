#!/bin/bash

DOCKER_SERVICE_ENABLED=2 # 0=disabled 1=enabled 2=unknown/error
ECODMS_BACKUP_FOLDER="/volume1/ecodms-backup"

# FUNCTIONS
fail () {
  echo "An error occured during the backup of ecodms!"
  exit 1
}
# FUNCTIONS / END


# MAIN
DOCKER_SERVICE_ENABLED=`synoservice --is-enabled pkgctl-Docker | grep enabled | wc -l`
# Stop docker service if running
if [ $DOCKER_SERVICE_ENABLED -eq 1 ]; then
  echo -n "Stop docker service ..."
  synoservicecfg --hard-stop pkgctl-Docker || fail
  echo "OK"
fi

# Create file "create" in backup folder
# If ecodms gets started again it will automatically start the backup
echo -n "Create \"create\" file in ecodms backup folder ..."
touch $ECODMS_BACKUP_FOLDER/create || fail
echo "OK"
echo -n "Start docker service ..."
synoservicecfg --start pkgctl-Docker || fail
echo "OK"

# Wait for backup to finish successfully
#DATE=`date +%Y%m%d`
#BACKUP_FILE_EXISTS=`ls -al $ECODMS_BACKUP_FOLDER/DMSbackup$DATE*.zip | wc -l`
while [ -f $ECODMS_BACKUP_FOLDER/create ]; do
  echo "Backup still running ..."
  sleep 30
done

# Stop docker containers and docker daemon after backup
echo -n "Stop docker service ..."
synoservicecfg --stop pkgctl-Docker || fail
echo "OK"

# MAIN / END
