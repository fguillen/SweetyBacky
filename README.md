## Run Backup
    ruby sweety_backy_execute.rb configuration_file.yml
    
## Configuration file
### includes
Array of folders to make a backup.

Example:
    includes: ['/var/www', '/var/log']

### excludes
Array of patterns to exclude from backup.

Example:
    excludes: ['/var/www/tmp', '.cvs']
    
### path
Root Path for the backups

Example: 
    path: '/backups'
    
### yearly, monhtly, weekly, daily
Number of yearly, monhtly, weekly, daily backups to keep, starting for the most recent.

Example:
    yearly: 2
    monthly: 12
    weekly: 4
    daily: 7


## Destination Folders

As example for date 2010-06-29 with configuration: 

    include: '/tmp/hhh'
    exclude: '/tmp/hhh/xxx'
    path: '/tmp/backups'
    years: 2
    months: 6
    weeks: 4
    days: 7
    
The files folder will look like this:

    /tmp/backups/files/20081231.yearly.tar.gz
    /tmp/backups/files/20091231.yearly.tar.gz
    /tmp/backups/files/20100131.monthly.tar.gz
    /tmp/backups/files/20100228.monthly.tar.gz
    /tmp/backups/files/20100331.monthly.tar.gz
    /tmp/backups/files/20100430.monthly.tar.gz
    /tmp/backups/files/20100531.monthly.tar.gz
    /tmp/backups/files/20100606.weekly.tar.gz
    /tmp/backups/files/20100613.weekly.tar.gz
    /tmp/backups/files/20100620.weekly.tar.gz
    /tmp/backups/files/20100627.weekly.tar.gz
    /tmp/backups/files/20100623.daily.tar.gz
    /tmp/backups/files/20100624.daily.tar.gz
    /tmp/backups/files/20100625.daily.tar.gz
    /tmp/backups/files/20100626.daily.tar.gz
    /tmp/backups/files/20100627.weekly.tar.gz
    /tmp/backups/files/20100628.daily.tar.gz
    /tmp/backups/files/20100629.daily.tar.gz
    
The databases folder will look like this:
    
    /tmp/backups/databases/20081231.yearly.sql.tar.gz
    /tmp/backups/databases/20091231.yearly.sql.tar.gz
    /tmp/backups/databases/20100131.monthly.sql.tar.gz
    /tmp/backups/databases/20100228.monthly.sql.tar.gz
    /tmp/backups/databases/20100331.monthly.sql.tar.gz
    /tmp/backups/databases/20100430.monthly.sql.tar.gz
    /tmp/backups/databases/20100531.monthly.sql.tar.gz
    /tmp/backups/databases/20100606.weekly.sql.tar.gz
    /tmp/backups/databases/20100613.weekly.sql.tar.gz
    /tmp/backups/databases/20100620.weekly.sql.tar.gz
    /tmp/backups/databases/20100627.weekly.sql.tar.gz
    /tmp/backups/databases/20100623.daily.sql.tar.gz
    /tmp/backups/databases/20100624.daily.sql.tar.gz
    /tmp/backups/databases/20100625.daily.sql.tar.gz
    /tmp/backups/databases/20100626.daily.sql.tar.gz
    /tmp/backups/databases/20100627.weekly.sql.tar.gz
    /tmp/backups/databases/20100628.daily.sql.tar.gz
    /tmp/backups/databases/20100629.daily.sql.tar.gz
    