![](./../graphics/purestorage.png)

# Workshop: Modern Storage Platforms for SQL Server
<br />

# Module 3 - SQL Server Object Integration: Backup and Restore

In this module, you will learn how to use s3 compatible object storage in FlashBlade. You will then configure SQL Server to backup and restore databases to and from s3 compatible object storage on FlashBlade.

There are three activities in this module
* [Exploring your Flashblade Environment](#31---exploring-your-flashblade-environment) 
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


- [ ] **Click on the Google Chrome for FlashBlade icon on the desktop**

    - This will open to https://fb1-sim.testdrive.local/dashboard
   
        <img src=../graphics/m3/3.1.1.png width="100" height="100" >

- [ ]  **Log in to the FlashBlade Web Interface**

    - [ ] Enter the following username and password and click **Log In**.

        - **Username:** pureuser
        - **Password:** pureuser

          <img src=../graphics/m3/3.1.2.png width="40%" height="40%" >

    - On the landing page, there is a menu on the left for various configuration elements and a dashboard showing overall capacity, recent alerts, array performance, and health. 
        <img src=../graphics/m3/3.1.3.png>

Now that you've logged into FlashBlade's Web Interface, let's move on and create and retrieve the Access Key ID and Secret Access Key ID for a user pre-configured in our FlashBlade. We'll be using this information in our upcoming demos. 

## **Examine the s3 Bucket Configuration**

In your lab environment, a bucket, a user, and an access policy are all created for you. The bucket is named `fbs3bucket`, the user is `fbs3`, and the access policy for the user fbs3 is set to full control.  In this section you will create an Access Key ID and a Secret Key ID for the `fbs3` user. Later in the lab, you will use that information to allow SQL Server to authenticate to the fbs3bucket.

- **Create the Access Key ID and Secret Key ID**

    - [ ] In the FlashBlade Web Interface, Click **Storage** and then click **Object Store Buckets**

        <img src=../graphics/m3/3.2.1.png>

        On this screen, in the Buckets panel, you can see the pre-created bucket named `fbs3bucket` and in the Accounts panel, you can see the `fbs3` user. **Click on the `fbs3` account**.

        <img src=../graphics/m3/3.2.2.png>

        On the next screen, in the Users panel, click on the user `fbs3\fbs3` 

        <img src=../graphics/m3/3.2.3.png >

    - [ ] On the next screen, in the Attached Access Policies, you can see the policy `pure:policy/full-access` is configured for this user. Now, in the Access Keys panel, you can create an Access Key for this user by **clicking on the three ellpisis and selecting Create.**

        <img src=../graphics/m3/3.2.4.png >

    - [ ] Once you click Create, you are presented with the Access Key ID, and an obscured Secret Key ID. Click the button to download the credentials as JSON, and then in the download bar in your browser (on the bottom left), click on the file downloaded. 

        <img src=../graphics/m3/3.2.5.png >

    
    - [ ] Examine this file; this is your Access Key ID, which is used to uniquely identify a user, in this case, `fbs3`, and a Secret Key ID, essentially the password for this user. **Hold on to this file.** We will use it in this lab and the next lab.

        <img src=../graphics/m3/3.2.6.png >



Note that your s3 compatible object storage needs a valid TLS Certificate.


<br />
<br />

# 3.2 - Backing up databases to S3 compatible object storage

In this activity, you will configure SQL Server to back up to S3-compatible object storage. 

## **Creating a `CREDENTIAL`**

Once you have your bucket and authentication configured, the next thing to do is to create a `CREDENTIAL`. In the code below, we’re creating a credential in SQL Server. This contains the information needed to authenticate to our s3-compatible object storage. 

First, `CREATE CREDENTIAL [s3://fb1-data.testdrive.local/fbs3bucket]` creates a credential with a name that has the URL to the bucket included. Later, when you execute a backup statement, the URL that you use to write the backup file(s) to is used to locate the correct credentials. This is done by matching the URL defined in the backup command to the one in the name of the credential. The database engine uses the most specific match when looking for a credential. This give you the ability to control which credential is used to access a bucket in your s3 storage. So you can use one credential for the entire s3 compatible object store, a credential for each bucket, or even credentials for nested buckets.

Next, `WITH IDENTITY = 'S3 Access Key'` this string must be set to this value when using s3.

And last, `SECRET = 'PASTE_ACCESS_KEY_HERE:PASTE_SECRET_KEY_HERE;` this is the username (Access Key ID) and the password (Secret Key ID). Notice that there’s a colon as a delimiter between the two values. This means neither the username nor the password can have a colon in their values, so watch out for that.

- [ ] On the desktop of **Windows1**, in SSMS, open a **New Query window**. Connect to the SQL Instance on **WINDOWS1** and create a `CREDENTIAL` using this code.

    ```
    CREATE CREDENTIAL [s3://fb1-data.testdrive.local/fbs3bucket]
        WITH IDENTITY = 'S3 Access Key',
        SECRET = 'anthony:nocentino';
    ```

## **Running a Backup**

With everything ready to go, a bucket created, permissions set, and a credential defined, let’s now run a backup to our s3-compatible object storage. First, we define the database we want to back up with `BACKUP DATABASE TestDB1`. Next, we tell the backup command where to put the backup file with `TO URL = 's3://fb1-data.testdrive.local/fbs3bucket/TestDB1.bak'` Using this, if there’s more than one credential defined, the database engine can find the correct credential to use based on of URLs matching using the most specific match. And to round things off, I’m adding `WITH COMPRESSION` to compress the data written into the backup file(s).

- [ ] On the desktop of **Windows1**, in SSMS, open a **New Query window**. Connect to the SQL Instance on **WINDOWS1** and run a backup using the code below.

    First, let's create a small sample database for this activity and back it up.

    ```
    CREATE DATABASE TestDB1
    GO

    BACKUP DATABASE TestDB1 
        TO URL = 's3://fb1-data.testdrive.local/fbs3bucket/TestDB1.bak' 
        WITH COMPRESSION, STATS = 10, FORMAT, INIT
    ```

<br />
<br />

# 3.3 - Restoring databases from S3 compatible object storage

You can now backup to object storage from SQL Server. You don't have backups unless you can restore from backup. So let's do just that: restore our database to Windows2. We will restore the backup to a new database name

## **Restoring a Backup**

- [ ] On the desktop of **Windows1**, in SSMS, open a **New Query window**. Connect to the SQL Instance on **WINDOWS1** and restore a database with this code.

    ```
    RESTORE DATABASE TestDB1
        FROM URL = 's3://fb1-data.testdrive.local/fbs3bucket/TestDB1.bak' 
        WITH STATS = 10, REPLACE
    ```

- [ ] Confirm that TestDB2 is restored. On the desktop of Windows1, in SSMS, in the Object Explorer, right-click and select Refresh to update the listing of databases.

<br />
<br />


## **Working with "larger" Backup Files**

In s3 object storage, a file is broken up into as many as 10,000 parts. In SQL Server, each part's size is based on the parameter `MAXTRANSFERSIZE` since this is the size of the write operation performed into the backup file. The default value used for backups to s3 compatible storage is 10MB. So 10,000 * 10MB means the largest file size for a single file is about 100GB. And for many databases, that's just not big enough. So what can you do? First you can use compression, which will get more of your data into a single file.  

If you exceed the maximum file size, here's the error that you'll get:

```
Msg 3202, Level 16, State 1, Line 78
Write on 's3://fb1-data.testdrive.local/fbs3bucket/TestDB1.bak' failed: 1117(The request could not be performed because of an I/O device error.)
Msg 3013, Level 16, State 1, Line 78
BACKUP DATABASE is terminating abnormally.
```

Second, you can increase `MAXTRANSFERSIZE`; the default is 10MB. Valid values are 5MB to 20MB. So if you max out `MAXTRANSFERSIZE`, your single file maximum size is just under 200GB.

The third knob you have to turn to help with larger backup sets is to increase the number of backup files by adding more URLs to the backup command. Each file has 10,000 parts * `MAXTRANSFERSIZE` * the number of URLs. So in the example below, each file can be up to 200GB, and there are two files. So we can have about 400GB of backup files. The maximum number of files is 64, so the largest single backup set you can have is just over 12TB. But remember, you can also use compression. So you can have a database of greater than 12TB in size in a backup set.

One note to add here is using `MAXTRANSFERSIZE` requires that `COMPRESSION` be enabled for the backup. 

```
BACKUP DATABASE TestDB1 
TO URL = 's3://fb1-data.testdrive.local/fbs3bucket/TestDB1_1.bak' ,
   URL = 's3://fb1-data.testdrive.local/fbs3bucket/TestDB1_2.bak' 
WITH COMPRESSION, MAXTRANSFERSIZE = 20971520
```


## Activity Summary
In this module, you set up the s3 object integration on SQL Server 2022 and used it to perform a backup and restore from a FlashBlade.

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

