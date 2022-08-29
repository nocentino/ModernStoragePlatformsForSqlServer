![](./../graphics/purestorage.png)

# Workshop: Modern Storage Platforms for SQL Server

#### <i>A Course from the Pure Storage Field Solution Architecture team</i>

# Module 4 - SQL Server Object Integration: Data Virtualization

In this module you learn how to use Polybase to interact with data files on s3 compatible object storage.

<br />
<br />

## 4.1 - Query data on S3 compatible object storage with OPENROWSET

In this activity you will configure SQL Server to use Polybase to query data that's stored in s3 compatible object storage.


1. **Configure Polybase in SQL Server instance**

    In SQL Server 2022, Polybase is the feature that allows SQL Server to integrate with s3 compatbile object storage. You must install this feature during the installation of SQL Server or add it to your SQL Server instance after installation. Once the feature is installed, you must configure the Polybase feature, you can do that with the steps listed in this section.

    - Confirm if the Polybase feature is installed, 1 = installed

        ```
        SELECT SERVERPROPERTY ('IsPolyBaseInstalled') AS IsPolyBaseInstalled;
        ```

    - Next, enable Polybase in your instance's configuration
    
        ```
        exec sp_configure @configname = 'polybase enabled', @configvalue = 1;
        ```

    - Confirm if Polybase is in your running config, run_value should be 1

        ```
        exec sp_configure @configname = 'polybase enabled'
        ```

1. **Configure access to external data using Polybase over S3**

    Once Polybase is installed and configured, you can use it within a user database in SQL Server 2022. In this section you will create a database and configure a `CREDENTIAL` used to authentcate to the FlashBlade in your lab enviroment. 

    - Create a database to hold objects used in this module

        ```
        CREATE DATABASE [PolybaseDemo];
        ```

    - Switch into the database context for the PolybaseDemo database
        ```
        USE PolybaseDemo
        ```

    - Create a `MASTER KEY`, this is use to protect the credentials you're about to create
        ```
        CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'S0methingS@Str0ng!';  
        ```

    - Create a `DATABASE SCOPED CREDENTIAL`, this should have at minimum ReadOnly and ListBucket access to the s3 bucket. Your bucket in FlashBlade1 already has this access policy configured.

        ```
        CREATE DATABASE SCOPED CREDENTIAL s3_dc 
        WITH IDENTITY = 'S3 Access Key', 
        SECRET = 'anthony:nocentino' ;
        ```

1. **Create an EXTERNAL DATA SOURCE**

    * Create your `EXTERNAL DATA SOURCE` on your s3 compatible object storage, referencing where it is on the network `LOCATION`, and the `CREDENTIAL` you defined in the previous step used to authenticate to your s3 compatible object storage.

        ```
        CREATE EXTERNAL DATA SOURCE s3_ds
        WITH
        (    LOCATION = 's3://s3.example.com:9000/'
        ,    CREDENTIAL = s3_dc
        )
        ```

1. **Query data on S3 compatible object storage with OPENROWSET**

    - You can access data in the s3 bucket and for a simple test, let's start with CSV. This should output `Hello World!`

        ```
        SELECT  * 
        FROM OPENROWSET
        (    BULK '/sqldatavirt/helloworld.csv'
        ,    FORMAT       = 'CSV'
        ,    DATA_SOURCE  = 's3_ds'
        ) 
        WITH ( c1 varchar(50) )             
        AS   [Test1]
        ```
---

<br />
<br />

## 4.2 - Query data on S3 compatible object storage with EXTERNAL TABLE

- `OPENROWSET` is cool for infrequent access, but if you want to layer on SQL Server security or use statistics on the data in the external data source, let's create an external table.  This first requires defining an external file format.  In this example, its CSV again.

1. **Create and EXTERNAL FILE FORMAT**

    - Define an EXTERNAL FILE FORMAT

        ```
        CREATE EXTERNAL FILE FORMAT CSVFileFormat
        WITH
        (    FORMAT_TYPE = DELIMITEDTEXT
        ,    FORMAT_OPTIONS  ( FIELD_TERMINATOR = ','
        ,                      STRING_DELIMITER = '"'
        ,                      FIRST_ROW = 1 )
        );
        ```

1. **Define the table's structure**

    - The CSV here is mega simple, just a couple rows with a two columns. When defining the external table where the data lives on our network with `DATA_SOURCE`, the `LOCATION` within that `DATA_SOURCE` and the `FILE_FORMAT`

        ```
        CREATE EXTERNAL TABLE HelloWorld ( c1 varchar(50) )
        WITH (
            DATA_SOURCE = s3_ds
        ,    LOCATION = '/sqldatavirt/helloworld.csv'
        ,    FILE_FORMAT = CSVFileFormat
        );
        ```

1. **Query the EXTERNAL TABLE**

    - Now we can access the data just like any other table in SQL server. 

        ```
        SELECT * FROM
        [HelloWorld];
        ```

---

<br />
<br />

# More Resources
- [Backing up to s3 Compatible Object Storage with SQL Server](https://www.nocentino.com/posts/2022-06-06-backing-up-to-s3-storage-with-sqlserver/)
- [Setting up MinIO for SQL Server 2022 s3 Object Storage Integration](https://www.nocentino.com/posts/2022-06-10-setting-up-minio-for-sqlserver-object-storage)
- [Setting up SQL Server 2022 s3 Object Storage Integration using MinIO with Docker Compose](https://www.nocentino.com/posts/2022-08-13-setting-up-minio-for-sqlserver-object-storage-docker-compose/)

---
<br />
<br />

Congratulations! You have completed this workshop on Modern Storage Platforms for SQL Server. You now have the tools, assets, and processes you need to extrapolate this information into other applications.



