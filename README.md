# Sweety Backy

Simple mechanism to **configure and execute backups** of folders and MySQL DBs and store them in **local folder** or **S3 bucket**.

## State

This is a **really beta** version which is working in my servers actually without problems but you have to use it under your own risk.

## Other possibilities

Please take a look of other **Ruby backups gems**:

* http://ruby-toolbox.com/categories/backups.html

## How install

    gem install 'sweety_backy'

## How to use it

    sweety_backy <config_file>

### Config file

It is a _yaml_ file with all this attributes

    paths: <array of folder paths>
    databases: <array of database names>
    yearly: <quantity of yearly backups>
    monthly: <quantity of monthly backups>
    weekly: <quantity of weekly backups>
    daily: <quantity of daily backups>
    slices_size: <in MB, if present the compressed files will be sliced in pieces>
    database_user: <database user with read privileges of all datases>
    database_pass: <database user password>
    storage_system: { 's3' | 'local' }
    local_opts: (only if the storage_system is 'local')
      path: <absoulte path to the root folder of the backups>
    s3_opts: (only if the storage_system is 's3')
      bucket: <bucket name>
      path: <bucket path where the backups will be stored>
      passwd_file: <path to the S3 credentials>

### S3 credentials file

It is a _yaml_ file with two keys with the S3 credentials:

    access_key_id: "XXX"
    secret_access_key: "YYY"

### Example

#### S3 config example

    # ~/.s3.passwd
    access_key_id: "XXX"
    secret_access_key: "YYY"


#### SweetyBacky config example

    # ~/.sweety_backy.conf
    paths: [ "/Users/fguillen/Develop/Brico", "/Users/fguillen/Develop/Arduino" ]
    databases: [ "test", "mysql" ]
    yearly: 1
    monthly: 2
    weekly: 3
    daily: 4
    slices_size: 100
    database_user: 'root'
    database_pass: ''
    storage_system: 's3'
    s3_opts:
      bucket: 'sweety_backy'
      path: 'fguillen'
      passwd_file: '~/.s3.passwd'

#### Execute

    sweety_backy ~/.sweety_backy.conf

#### Result

This will generate a bunch of backups in the _sweety_backy_ bucket like these ones:

    https://s3.amazonaws.com/sweety_backy/fguillen/files/Users.fguillen.Develop.Arduino.20110626.weekly.part0.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/files/Users.fguillen.Develop.Arduino.20110626.weekly.part1.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/files/Users.fguillen.Develop.Arduino.20110626.weekly.part2.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/files/Users.fguillen.Develop.Arduino.20110703.weekly.part0.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/files/Users.fguillen.Develop.Arduino.20110703.weekly.part1.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/files/Users.fguillen.Develop.Arduino.20110703.weekly.part2.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/files/Users.fguillen.Develop.Arduino.20110704.daily.part0.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/files/Users.fguillen.Develop.Arduino.20110704.daily.part1.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/files/Users.fguillen.Develop.Arduino.20110704.daily.part2.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/files/Users.fguillen.Develop.Arduino.20110705.daily.part0.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/files/Users.fguillen.Develop.Arduino.20110705.daily.part1.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/files/Users.fguillen.Develop.Arduino.20110705.daily.part2.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/files/Users.fguillen.Develop.Arduino.20110706.daily.part0.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/files/Users.fguillen.Develop.Arduino.20110706.daily.part1.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/files/Users.fguillen.Develop.Arduino.20110706.daily.part2.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/files/Users.fguillen.Develop.Arduino.20110707.daily.part0.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/files/Users.fguillen.Develop.Arduino.20110707.daily.part1.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/files/Users.fguillen.Develop.Arduino.20110707.daily.part2.tar.gz

    https://s3.amazonaws.com/sweety_backy/fguillen/files/Users.fguillen.Develop.Brico.20110626.weekly.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/files/Users.fguillen.Develop.Brico.20110703.weekly.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/files/Users.fguillen.Develop.Brico.20110704.daily.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/files/Users.fguillen.Develop.Brico.20110705.daily.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/files/Users.fguillen.Develop.Brico.20110706.daily.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/files/Users.fguillen.Develop.Brico.20110707.daily.tar.gz

    https://s3.amazonaws.com/sweety_backy/fguillen/databases/test.20110626.weekly.sql.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/databases/test.20110703.weekly.sql.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/databases/test.20110704.daily.sql.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/databases/test.20110705.daily.sql.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/databases/test.20110706.daily.sql.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/databases/test.20110707.daily.sql.tar.gz

    https://s3.amazonaws.com/sweety_backy/fguillen/databases/mysql.20110626.weekly.sql.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/databases/mysql.20110703.weekly.sql.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/databases/mysql.20110704.daily.sql.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/databases/mysql.20110705.daily.sql.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/databases/mysql.20110706.daily.sql.tar.gz
    https://s3.amazonaws.com/sweety_backy/fguillen/databases/mysql.20110707.daily.sql.tar.gz

... and so on.

### Cron execution example

    # every day at 02:00 am
    00 02 * * * sweety_backy /home/fguillen/.sweety_backy.conf >> /var/log/sweety_backy.log 2>&1

## License

MIT License. (c) 2011 Fernando Guillen (http://fernandoguillen.info).