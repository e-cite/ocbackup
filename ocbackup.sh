#!/bin/bash
# A small script for automated owncloud backups by a cronjob.
#
# The MIT License (MIT)
# Copyright (c) 2016 Andreas Dolp <dev[at]andreas-dolp.de>
#
# Usage: See https://github.com/e-cite/ocbackup
#
EXITSTATUS=0
CONFIGFILE="/etc/ocbackup.conf"
VERSION="1.0"

echo "OCBACKUP v.$VERSION"
echo "Copyright (c) 2016 Andreas Dolp <dev[at]andreas-dolp.de>"

if [ -r $CONFIGFILE ]
  then
    . $CONFIGFILE
    echo "OCBACKUP OK: Configuration file loaded correctly."
  else
    logger -s "OCBACKUP ERROR: Configuration file $CONFIGFILE not readable! Aborting..."
    exit 3
fi

echo "OCBACKUP: Backing up database $DB_Database on server $DB_Server as user $DB_User."
DIR="${BAKDIR}"
FILE="owncloud-sqlbkp_`date +"%Y%m%d_%H%M%S"`.bak.gz"

# Check existence of directory
if [ !  -d $DIR ]
  then
    logger -s "OCBACKUP ERROR: Target folder of backup $DIR not exsitent! Aborting..."
    exit 3
fi

# Enable maintenance mode
php -f $OC_OCCPATH maintenance:mode --on
if [ "$?" -ne "0" ]
  then
    logger -s "OCBACKUP ERROR: Unable to enable maintenance mode. Aborting..."
    exit 3
fi

# Sleep 2 min
echo "OCBACKUP: Sleeping 2 min to ensure all users are offline..."
sleep 2m

# Dumping mySQL database and gzip
mysqldump --lock-tables -h $DB_Server -u $DB_User --password=$DB_Password $DB_Database  | gzip > $DIR$FILE
if [ "$?" -ne "0" ]
  then
    logger -s "OCBACKUP ERROR: Error during mysqldump. Backup maybe not created correctly!"
    EXITSTATUS=2
  else
    echo "OCBACKUP OK: Backup created successfully!"
fi

# Set strong permissions of backup file
chmod 640 $DIR$FILE
if [ "$?" -ne "0" ]
  then
    logger -s "OCBACKUP ERROR: Unable to set stron permissions of backup file $FILE. Backup successfull!"
    EXITSTATUS=1
fi

# Disable maintenance mode
php -f $OC_OCCPATH maintenance:mode --off
if [ "$?" -ne "0" ]
  then
    logger -s "OCBACKUP ERROR: Unable to disable maintenance mode. Backup successfull!"
    EXITSTATUS=1
fi

if [ $EXITSTATUS -eq "0" ]
  then
    echo "OCBACKUP OK: Backup successfull!"
    logger "OCBACKUP OK: Backup successfull!"
fi

exit $EXITSTATUS
