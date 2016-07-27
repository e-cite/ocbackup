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
VERSION="1.1"

# Set abort options for erroneous commands / pipes
set -o pipefail

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

if [ -r $DB_CredentialsFile ]
  then
    echo "OCBACKUP OK: MySQL credentials file loaded correctly."
  else
    logger -s "OCBACKUP ERROR: MySQL credentials file $DB_CredentialsFile not readable! Aborting..."
    exit 3
fi

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
# --defaults-extra-file must be the first option
mysqldump --defaults-extra-file=$DB_CredentialsFile --lock-tables $DB_Database  | gzip > $DIR$FILE
if [ "$?" -ne "0" ]
  then
    logger -s "OCBACKUP ERROR: Error during mysqldump. Backup not created!"
    rm $DIR$FILE
    EXITSTATUS=2
  else
    echo "OCBACKUP OK: Backup created successfully!"
fi

# Set strong permissions of backup file
if [ -w $DIR$FILE ]
  then
    chmod 640 $DIR$FILE
    if [ "$?" -ne "0" ]
      then
        logger -s "OCBACKUP ERROR: Unable to set strong permissions of backup file $FILE. Backup successfull!"
        EXITSTATUS=1
    fi
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
