# ocbackup

## Functionality
A small script for automated owncloud backups by a cronjob.

## Installation on Debian / Ubuntu
1. Download config file to /etc/: ```wget -O /etc/ocbackup.conf https://raw.githubusercontent.com/e-cite/ocbackup/master/ocbackup.conf```
2. Set ```chown root:www-data /etc/ocbackup.conf``` and ```chmod 640 /etc/ocbackup.conf```
3. Adjust configuration parameters in /etc/ocbackup.conf
4. Download script to /usr/local/bin/: ```wget -O /usr/local/bin/ocbackup.sh https://raw.githubusercontent.com/e-cite/ocbackup/master/ocbackup.sh```
5. Set ```chown root:root /usr/local/bin/ocbackup.sh``` and ```chmod +x /usr/local/bin/ocbackup.sh```
6. Add backup destination folder to comply with path in configuration file
7. Add cronjob for user www-data by ```sudo crontab -u www-data -e``` and adding this line
   ```0  7  *  *  * /usr/local/bin/ocbackup.sh > /dev/null```
8. Errors are mailed to you, otherwise you can check /var/log/syslog to see whether the script has run correctly.

## TODO:
- [ ] Create an automated installer
- [ ] Add support for /var/www/owncloud folder or even the data folder
