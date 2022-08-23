![](./../graphics/purestorage.png)

# Workshop: Modern Storage Platforms for SQL Server

#### <i>A Course from the Pure Storage Field Solution Architecture team</i>

# Module 3 - SQL Server Object Integration: Backup and Restore

TODO ADD TEXT DESCRIBING LAB

# 3.1 - Exploring your Flashblade Enviroment

- A bucket created on your s3 compatible object storage platform or AWS s3. Refer to your platform’s documentation to get this going.
- You’ll need a username, sometimes called an Access Key ID, and its password, sometimes called a Secret Key ID
- To perform both backups and restores, this user will need readwrite access to the bucket
- And finally, your s3 compatible object storage needs a valid TLS Certificate


# 3.2 - Backing up databases to S3 compatible object storage
---

1. **Create a CREDENTIAL**

    * Once you have your bucket and authentication configured, the next thing to do is to create a CREDENTIAL. In the code below, we’re creating a credential in SQL Server. This contains the information needed to authenticate to our s3 compatible object storage. We’ll unpack this line by line.

        ```
        CREATE CREDENTIAL [s3://s3.example.com:9000/sqlbackups]
            WITH IDENTITY = 'S3 Access Key',
            SECRET = 'anthony:nocentino';
        ```

1. **Running a Backup**

    * With everything ready to go, a bucket created, permissions set, and a credential defined, let’s now go ahead and run a backup to our s3 compatible object storage. Let’s walk through that code.

        First, we define the database we want to back up with BACKUP DATABASE TestDB1 .

        Next, we tell the backup command where to put the backup file with TO URL = 's3://s3.example.com:9000/sqlbackups/TestDB1.bak' Using this, if there’s more than one credential defined, the database engine can find the correct credential to use based off of URLs matching using the most specific match.

        And to round things off, I’m adding WITH COMPRESSION to compress the data written into the backup file(s).

        ```
        BACKUP DATABASE TestDB1 
            TO URL = 's3://s3.example.com:9000/sqlbackups/TestDB1.bak' 
            WITH COMPRESSION, STATS = 10, FORMAT, INIT
        ```

# 3.3 - Restoring databases from S3 compatible object storage
---
TODO - DESCRIPTION

1. **Restoring a Backup**

        ```
        BACKUP DATABASE TestDB1 
            TO URL = 's3://s3.example.com:9000/sqlbackups/TestDB1.bak' 
            WITH COMPRESSION, STATS = 10, FORMAT, INIT
        ```


# 3.4 - Backup tuning fundamentals
---
TODO - DESCRIPTION

TODO - ACTIVITY

        BACKUP DATABASE TestDB1 
            TO URL = 's3://s3.example.com:9000/sqlbackups/TestDB1_1.bak' 
            TO URL = 's3://s3.example.com:9000/sqlbackups/TestDB1_2.bak' 
            TO URL = 's3://s3.example.com:9000/sqlbackups/TestDB1_3.bak' 
            WITH COMPRESSION, STATS = 10, FORMAT, INIT


---

# More Resources
- [Backing up to s3 Compatible Object Storage with SQL Server](https://www.nocentino.com/posts/2022-06-06-backing-up-to-s3-storage-with-sqlserver/)
- [Setting up MinIO for SQL Server 2022 s3 Object Storage Integration](https://www.nocentino.com/posts/2022-06-10-setting-up-minio-for-sqlserver-object-storage)
- [Setting up SQL Server 2022 s3 Object Storage Integration using MinIO with Docker Compose](https://www.nocentino.com/posts/2022-08-13-setting-up-minio-for-sqlserver-object-storage-docker-compose/)

---

Next, Continue to [SQL Server Object Integration: Data Virtualization](./4-SQLObjectIntegrationDataVirtualization.md)

