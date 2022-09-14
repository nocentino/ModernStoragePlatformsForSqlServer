![](./../graphics/purestorage.png)

# Workshop: Modern Storage Platforms for SQL Server
<br />

# Module 4 - SQL Server Object Integration: Data Virtualization

In this module, you learn how to use Polybase to interact with data files on s3-compatible object storage.

There are two activities in this module
* [Query data on S3 compatible object storage with OPENROWSET](#41---query-data-on-s3-compatible-object-storage-with-openrowset)
* [Query data on S3 compatible object storage with EXTERNAL TABLE](#42---query-data-on-s3-compatible-object-storage-with-external-table)

<br />
<br />

# Lab Information

In this module, you will work primarily on **Windows1** SQL Server instance and use **FlashBlade1** as your primary object storage platform.

| Resource      | Description |
| -----------   | ----------- |
| **Windows1**  | **Primary administrator desktop and SQL Server Instance** |
| **FlashBlade1**   | **Primary external object storage used by SQL Server** |

<br />
<br />

## 4.1 - Query data on S3 compatible object storage with OPENROWSET

In this activity, you will copy data into your s3 bucket and configure SQL Server to use Polybase to query data stored in s3 compatible object storage.


## **Copying source data into your S3 bucket on FlashBlade**

In this activity, you will copy source data into your FlashBlade. You will use this data as part of the upcoming data virtualization activities below. 

- [ ] On your desktop, open S3 Browser.

    <img src=../graphics/m3/4.1.1.png width="100" height="100" >

- [ ] Next the Add New Account screen should open automatically, if not Click Accounts, then select Add new account...

    <img src=../graphics/m3/4.1.2.png>

- [ ] Next **Enter the following configuration information**
    * **Display Name:** `fb1-data`
    * **Account Type:** S3 Compatible Storage
    * **REST Endpoint:** `fb1-data.testdrive.local`
    * **Access Key ID:** Paste in your Access Key ID from the previous lab
    * **Secret Access Key:** Paste in your Secret Access Key ID from the previous lab

    Once finished, **click Add new account**.   

    <img src=../graphics/m3/4.1.3.png>

- [ ] Next, copy the test data into your FlashBlade. Open the Data folder on the desktop and drag the file into the S3 browser window on the right-hand side.  Once the file appears on the right-hand side in the file view, it is successfully uploaded.

    <img src=../graphics/m3/4.1.4.png>

## **Configure Polybase in SQL Server instance**

In SQL Server 2022, Polybase is the feature that allows SQL Server to integrate with s3-compatible object storage. You must install this feature during the SQL Server installation or add it to your SQL Server instance after installation. Once the feature is installed, you must configure the Polybase feature. You can do that with the steps listed in this section.

- On the desktop of **Windows1**, in SSMS, open a **New Query window**. Connect to the SQL Instance on **WINDOWS1** and enable Polybase by copying each line of code below into a new query window and clicking **Execute**.


    - [ ] Confirm if the Polybase feature is installed, 1 = installed

        ```
        SELECT SERVERPROPERTY ('IsPolyBaseInstalled') AS IsPolyBaseInstalled;
        ```

    - [ ] Next, enable Polybase in your instance's configuration

        ```
        exec sp_configure @configname = 'polybase enabled', @configvalue = 1;
        RECONFIGURE;
        ```

    - [ ] Confirm if Polybase is in your running config, run_value should be 1

        ```
        exec sp_configure @configname = 'polybase enabled'
        ```

## **Configure access to external data using Polybase over S3**

Once Polybase is installed and configured, you can use it within a user database in SQL Server 2022. In this section, you will create a database and configure a `CREDENTIAL` used to authenticate to the FlashBlade in your lab environment. 

- [ ] On the desktop of **Windows1**, in SSMS, open a **New Query window**. Connect to the SQL Instance on **WINDOWS1** and configure access to external data by copying each block of code below into a new query window and clicking **Execute**


    - [ ] Create a database to hold objects used in this module

        ```
        CREATE DATABASE [PolybaseDemo];
        ```

    - [ ] Switch into the database context for the `PolybaseDemo` database
        ```
        USE PolybaseDemo
        ```

    - [ ] Create a `MASTER KEY`. This is used to protect the credentials you're about to create
        ```
        CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'S0methingS@Str0ng!';  
        ```

    - [ ] Create a `DATABASE SCOPED CREDENTIAL`. This should have, at minimum, `ReadOnly` and `ListBucket` access to the s3 bucket. Your bucket in FlashBlade1 already has this access policy configured.

        Next, `WITH IDENTITY = 'S3 Access Key" this string must be set to this value when using s3.

        And last, `'PASTE_ACCESS_KEY_ID_HERE:PASTE_SECRET_KEY_ID_HERE'` this is the username (Access Key ID) and the password (Secret Key ID). You can use the values from the JSON file downloaded in the previous lab. Also, notice that there's a colon as a delimiter. This means neither the username nor the password can have a colon in their values. So watch out for that.

        ```
        CREATE DATABASE SCOPED CREDENTIAL s3_dc 
            WITH IDENTITY = 'S3 Access Key', 
            SECRET = 'PASTE_ACCESS_KEY_ID_HERE:PASTE_SECRET_KEY_ID_HERE';
        ```

## **Create an `EXTERNAL DATA SOURCE`**

Create your `EXTERNAL DATA SOURCE` on your s3 compatible object storage, referencing where it is on the network `LOCATION`, and the `CREDENTIAL` you defined in the previous step used to authenticate to your s3 compatible object storage. Use this code in a new query window on Windows1 to configure your external data.

- [ ] Execute this code on **Windows1** to create your `EXTERNAL DATA SOURCE`

    ```
    CREATE EXTERNAL DATA SOURCE s3_ds
    WITH
    (    LOCATION = 's3://fb1-data.testdrive.local/'
    ,    CREDENTIAL = s3_dc
    )
    ```

## **Query data on S3 compatible object storage with `OPENROWSET`**

You can access data in the s3 bucket and for a simple test, let's start our data virtualization journey with CSV. This file contains  several rows of `Hello World!` In the code below, you will define the location of the data with `BULK '/fbs3bucket/HelloWorld.csv'` what you have here it the bucket name `fbs3bucket` and then the file name where the data is, `HelloWorld.csv`. Note, that the file name is case sensitive. The structure of the data depends upon the datastore used. Since this is a CSV, we have to define its structure. Here's we're using a simple two-column CSV for an example using `( c1 int, c2 varchar(20) )`. 

- [ ] Execute this code on **Windows1** to query your CSV file using Polybase over s3.

    ```
    SELECT  * 
    FROM OPENROWSET
    (    BULK '/fbs3bucket/HelloWorld.csv'
    ,    FORMAT       = 'CSV'
    ,    DATA_SOURCE  = 's3_ds'
    ) 
    WITH ( c1 int, c2 varchar(20) )
    AS   [Test1]
    ```
---

## Activity Summary
In this activity, you used the SQL Server Polybase feature to access external data on object storage using `OPENROWSET`.


<br />
<br />

## 4.2 - Query data on S3 compatible object storage with `EXTERNAL TABLE`

In this activity, `OPENROWSET` is cool for infrequent access, but if you want to layer on SQL Server security or use statistics on the data in the external data source, let's create an external table. This first requires defining an `EXTERNAL FILE FORMAT`. In this example, it's CSV again.

## **Create an `EXTERNAL FILE FORMAT`**

In this step...you will define an external file format.

- [ ] Execute this code on **Windows1** to define an `EXTERNAL FILE FORMAT`

    ```
    CREATE EXTERNAL FILE FORMAT CSVFileFormat
    WITH
    (    FORMAT_TYPE = DELIMITEDTEXT
    ,    FORMAT_OPTIONS  ( FIELD_TERMINATOR = ','
    ,                      STRING_DELIMITER = '"'
    ,                      FIRST_ROW = 1 )
    );
    ```

## **Define the table's structure**

The CSV here is mega simple, just one column with a couple of rows. When defining the external table where the data lives on our network with `DATA_SOURCE`, the `LOCATION` within that `DATA_SOURCE` and the `FILE_FORMAT`. Note, the CSV file name is case sensitive.

- [ ] Execute this code on **Windows1** to create an `EXTERNAL TABLE`

    ```
    CREATE EXTERNAL TABLE HelloWorld ( c1 int, c2 varchar(20) )
    WITH 
    (    DATA_SOURCE = s3_ds
    ,    LOCATION = '/fbs3bucket/HelloWorld.csv'
    ,    FILE_FORMAT = CSVFileFormat
    );
    ```

## **Query the EXTERNAL TABLE**

Now we can access the data in the CSV file on the FlashBlade like any other SQL server table. 

- [ ] Execute this code on **Windows1** to query the data in your `EXTERNAL TABLE` using Polybase over s3.

    ```
    SELECT * 
    FROM [HelloWorld];
    ```

---

## Activity Summary
In this activity, you used the SQL Server Polybase feature to access external data on object storage using `EXTERNAL TABLE`.


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



