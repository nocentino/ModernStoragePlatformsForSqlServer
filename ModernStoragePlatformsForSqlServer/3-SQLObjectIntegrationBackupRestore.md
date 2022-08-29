![](./../graphics/purestorage.png)

# Workshop: Modern Storage Platforms for SQL Server

#### <i>A Course from the Pure Storage Field Solution Architecture team</i>

# Module 3 - SQL Server Object Integration: Backup and Restore

In this module you will learn how use s3 compatible object storage in FlashBlade. You will then configure SQL Server to backup and restore databases to and from s3 compatible object storage on FlashBlade.

<br />
<br />

# 3.1 - Exploring your Flashblade Enviroment

### **Lab Information**

In this module, the lab has a FlashBlade with a bucket already configured for use. 

1. **Log into the FlashBlade Web Interface**

    In this activity, you will log into the FlashBlade web interface. The web interface is where you can configure and monitor your FlashBlade. 

1. **Examine the s3 Bucket Configuration**

    1. **Examine the access policy for the bucket**

        To perform both backups and restores, this user will need readwrite access to the bucket

    1. **Find the Access Key ID and Secret Key ID**

        You’ll need a username, sometimes called an Access Key ID, and its password, sometimes called a Secret Key ID

Note, your s3 compatible object storage needs a valid TLS Certificate


<br />
<br />

# 3.2 - Backing up databases to S3 compatible object storage

In this activity you will configured SQL Server to back up to S3 compatible object storage. 

1. **Create a `CREDENTIAL`**

    Once you have your bucket and authentication configured, the next thing to do is to create a `CREDENTIAL`. In the code below, we’re creating a credential in SQL Server. This contains the information needed to authenticate to our s3 compatible object storage. 

    First, `CREATE CREDENTIAL [s3://s3.example.com:9000/sqlbackups]` creates a credential with a name that has the URL to the bucket included. Later, when you execute a backup statement, the URL that you use to write the backup file(s) to will be used to locate the correct credentials for that URL by matching the URL defined the backup command to the one in the name of the credential. The database engine uses the most specific match when looking for a credential. So you can be more or less granular credentials and credentials if needed. Perhaps you want to use one credential for the entire s3 compatible object store, a credential for each bucket, or even credentials for nested buckets.

    Next, `WITH IDENTITY = 'S3 Access Key'` this string must be set to this value when using s3.

    And last, `SECRET = 'anthony:nocentino;` this is the username (Access Key ID) which is currently anthony and the password (Secret Key ID) is nocentino. Notice that there’s a colon as a delimiter. This means neither the username nor the password can have a colon in their values. So watch out for that.

    * On the desktop of **Windows1**, in SSMS, open a **New Query window**. Connect to the SQL Instance on **WINDOWS1** and create a `CREDENTIAL` using this code.

        ```
        CREATE CREDENTIAL [s3://s3.example.com:9000/sqlbackups]
            WITH IDENTITY = 'S3 Access Key',
            SECRET = 'anthony:nocentino';
        ```

1. **Running a Backup**

    With everything ready to go, a bucket created, permissions set, and a credential defined, let’s now go ahead and run a backup to our s3 compatible object storage. Let’s walk through that code. First, we define the database we want to back up with `BACKUP DATABASE TestDB1`. Next, we tell the backup command where to put the backup file with `TO URL = 's3://s3.example.com:9000/sqlbackups/TestDB1.bak'` Using this, if there’s more than one credential defined, the database engine can find the correct credential to use based off of URLs matching using the most specific match. And to round things off, I’m adding `WITH COMPRESSION` to compress the data written into the backup file(s).

    * On the desktop of **Windows1**, in SSMS, open a **New Query window**. Connect to the SQL Instance on **WINDOWS1** and run a backup using this code.

        First, let's create small sample database to this activity and then back it up.

        ```
        CREATE DATABASE TestDB1
        GO

        BACKUP DATABASE TestDB1 
            TO URL = 's3://s3.example.com:9000/sqlbackups/TestDB1.bak' 
            WITH COMPRESSION, STATS = 10, FORMAT, INIT
        ```

<br />
<br />

# 3.3 - Restoring databases from S3 compatible object storage

You now can backup to object storage from SQL Server. You don't have backups unless you can restore from backup. So let's do just that, let's restore our database back to Windows2. We will restore the backup to a new databases name

1. **Restoring a Backup**

    * On the desktop of **Windows1**, in SSMS, open a **New Query window**. Connect to the SQL Instance on **WINDOWS1** and restore a databases with this code.

        ```
        RESTORE DATABASE TestDB2
            FROM URL = 's3://s3.example.com:9000/sqlbackups/TestDB1.bak' 
            WITH STATS = 10
        ```
    * Confirm that TestDB2 is restored. On the desktop of Windows1, in SSMS, in the Object Explorer, right click and select Refresh to update the listing of databases.


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

