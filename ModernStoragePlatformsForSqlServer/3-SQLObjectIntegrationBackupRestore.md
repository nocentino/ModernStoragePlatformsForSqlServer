![](./../graphics/purestorage.png)

# Workshop: Modern Storage Platforms for SQL Server
<br />

# Module 3 - SQL Server Object Integration: Backup and Restore

In this module, you will learn how to use s3 compatible object storage in FlashBlade. You will then configure SQL Server to backup and restore databases to and from s3 compatible object storage on FlashBlade.

There are three activities in this module
* [Exploring your Flashblade Enviroment](#31---exploring-your-flashblade-environment) 
* [Backing up databases to S3 compatible object storage](#32---backing-up-databases-to-s3-compatible-object-storage)
* [Restoring databases from S3 compatible object storage](#33---restoring-databases-from-s3-compatible-object-storage)

<br />
<br />

# Lab Information

In this module, you will work primarily off the Windows1 SQL Server instance and use FlashBlade1 as your primary object storage platform.

| Resource      | Description |
| -----------   | ----------- |
| **Windows1**  | **Primary administrator desktop and SQL Server Instance** |
| **FlashBlade1**   | **Primary external object storage used by SQL Server** |

<br />
<br />

# 3.1 - Exploring your Flashblade Environment

## **Log in to the FlashBlade Web Interface**

In this activity, you will log into the FlashBlade web interface. The web interface is where you can configure and monitor your FlashBlade. 

## **Examine the s3 Bucket Configuration**


- **Examine the access policy for the bucket**

    This user will need readwrite access to the bucket to perform both backups and restores.

- **Find the Access Key ID and Secret Key ID**

    You’ll need a username, sometimes called an Access Key ID, and its password, sometimes called a Secret Key ID.

Note that your s3 compatible object storage needs a valid TLS Certificate.


<br />
<br />

# 3.2 - Backing up databases to S3 compatible object storage

In this activity, you will configure SQL Server to back up to S3-compatible object storage. 

## **Creating a `CREDENTIAL`**

Once you have your bucket and authentication configured, the next thing to do is to create a `CREDENTIAL`. In the code below, we’re creating a credential in SQL Server. This contains the information needed to authenticate to our s3-compatible object storage. 

First, `CREATE CREDENTIAL [s3://FlashBlade1/sqlbackups]` creates a credential with a name that has the URL to the bucket included. Later, when you execute a backup statement, the URL that you use to write the backup file(s) to will be used to locate the correct credentials for that URL by matching the URL defined in the backup command to the one in the name of the credential. The database engine uses the most specific match when looking for a credential. So you can be more or less granular credentials and credentials if needed. Perhaps you want to use one credential for the entire s3 compatible object store, a credential for each bucket, or even credentials for nested buckets.

Next, `WITH IDENTITY = 'S3 Access Key'` this string must be set to this value when using s3.

And last, `SECRET = 'anthony:nocentino;` this is the username (Access Key ID) which is currently anthony, and the password (Secret Key ID) is nocentino. Notice that there’s a colon as a delimiter. This means neither the username nor the password can have a colon in their values. So watch out for that.

- [ ] On the desktop of **Windows1**, in SSMS, open a **New Query window**. Connect to the SQL Instance on **WINDOWS1** and create a `CREDENTIAL` using this code.

    ```
    CREATE CREDENTIAL [s3://FlashBlade1/sqlbackups]
        WITH IDENTITY = 'S3 Access Key',
        SECRET = 'anthony:nocentino';
    ```

## **Running a Backup**

With everything ready to go, a bucket created, permissions set, and a credential defined, let’s now go ahead and run a backup to our s3 compatible object storage. Let’s walk through that code. First, we define the database we want to back up with `BACKUP DATABASE TestDB1`. Next, we tell the backup command where to put the backup file with `TO URL = 's3://FlashBlade1/sqlbackups/TestDB1.bak'` Using this, if there’s more than one credential defined, the database engine can find the correct credential to use based on of URLs matching using the most specific match. And to round things off, I’m adding `WITH COMPRESSION` to compress the data written into the backup file(s).

- [ ] On the desktop of **Windows1**, in SSMS, open a **New Query window**. Connect to the SQL Instance on **WINDOWS1** and run a backup using the code below.

    First, let's create a small sample database for this activity and back it up.

    ```
    CREATE DATABASE TestDB1
    GO

    BACKUP DATABASE TestDB1 
        TO URL = 's3://FlashBlade1/sqlbackups/TestDB1.bak' 
        WITH COMPRESSION, STATS = 10, FORMAT, INIT
    ```

## Working with "larger" Backup Files

In s3 object storage, a file is broken up into as many as 10,000 parts. In SQL Server, the each part's size is based on the parameter `MAXTRANSFERSIZE` since this is the size of the write operation performed into the backup file. The default used for backups to s3 compatible storage is 10MB. So 10,000 * 10MB means the largest file size for a single file is about 100GB. And for many databases, that's just not big enough. So what can you do...first you can use compression. That will get more of your data into a single file.  

If you exceed the maximum file size, here's the error that you'll get:

```
Msg 3202, Level 16, State 1, Line 78
Write on 's3://s3.example.com:9000/sqlbackups/TestDB1.bak' failed: 1117(The request could not be performed because of an I/O device error.)
Msg 3013, Level 16, State 1, Line 78
BACKUP DATABASE is terminating abnormally.
```

Second, you can increase `MAXTRANSFERSIZE`; the default is 10MB. Valid values are 5MB to 20MB. So if you max out `MAXTRANSFERSIZE`, your single file maximum size is just under 200GB.

The third knob you have to turn to help with larger backup sets is to increase the number of backup files by adding more URLs to the backup command. Each file has 10,000 parts * `MAXTRANSFERSIZE` * the number of URLs. So in the example below, each file can be up to 200GB, and there are two files. So we can have about 400GB of backup files. The maximum number of files is 64, so the largest single backup set you can have is just over 12TB. But remember, you can also use compression. So you can have a database of greater than 12TB in size in a backup set. One note to add here is using `MAXTRANSFERSIZE` requires that `COMPRESSION` be enabled for the backup. 

```
BACKUP DATABASE TestDB1 
TO URL = 's3://s3.example.com:9000/sqlbackups/TestDB1_1.bak' ,
   URL = 's3://s3.example.com:9000/sqlbackups/TestDB1_2.bak' 
WITH COMPRESSION, MAXTRANSFERSIZE = 20971520
```


<br />
<br />

# 3.3 - Restoring databases from S3 compatible object storage

You can now backup to object storage from SQL Server. You don't have backups unless you can restore from backup. So let's do just that: restore our database to Windows2. We will restore the backup to a new databases name

## **Restoring a Backup**

- [ ] On the desktop of **Windows1**, in SSMS, open a **New Query window**. Connect to the SQL Instance on **WINDOWS1** and restore a database with this code.

    ```
    RESTORE DATABASE TestDB2
        FROM URL = 's3://FlashBlade1/sqlbackups/TestDB1.bak' 
        WITH STATS = 10
    ```

- [ ] Confirm that TestDB2 is restored. On the desktop of Windows1, in SSMS, in the Object Explorer, right-click and select Refresh to update the listing of databases.

## Activity Summary
in this module, you set up the s3 object integration on SQL Server 2022 and used it to perform a backup and restore from a FlashBlade.

<br />
<br />


# More Resources
- [Backing up to s3 Compatible Object Storage with SQL Server](https://www.nocentino.com/posts/2022-06-06-backing-up-to-s3-storage-with-sqlserver/)
- [Setting up MinIO for SQL Server 2022 s3 Object Storage Integration](https://www.nocentino.com/posts/2022-06-10-setting-up-minio-for-sqlserver-object-storage)
- [Setting up SQL Server 2022 s3 Object Storage Integration using MinIO with Docker Compose](https://www.nocentino.com/posts/2022-08-13-setting-up-minio-for-sqlserver-object-storage-docker-compose/)

<br />
<br />

# Next Steps

Next, Continue to [SQL Server Object Integration: Data Virtualization](./4-SQLObjectIntegrationDataVirtualization.md)

