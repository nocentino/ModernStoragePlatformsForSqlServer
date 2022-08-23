![](./../graphics/purestorage.png)

# Workshop: Modern Storage Platforms for SQL Server

#### <i>A Course from the Pure Storage Field Solution Architecture team</i>

# Module 1 - Storage fundamentals for DBAs

TODO ADD TEXT DESCRIBING LAB

<br />
<br />

# 1.1 - Logging into the lab

TODO - DESCRIPTION OF LOGGING INTO THE LAB

**<i>Tip - Click Fit to Window to size the virtual desktop to your browser window. </i>**

<img src=../graphics/m1/1.1.png width="50%" height="50%" >

<br />

## Download the source code files

- On the lab desktop, open Google Chrome and browse to https://github.com/nocentino/ModernStoragePlatformsForSqlServer
- On this page, click the green Code button and select Download ZIP. This will download the file to your Downloads folder. Extract the ZIP file to your desktop. 

    <img src=../graphics/m1/1.1.1.png width="60%" height="60%" >

<br />
<br />

# 1.2 - Log into FlashArray Web Interface
In this lab you will log into the FlashArray web interface. The web interface is where you can configure and monitor your FlashArray. 

1.  Click on the Google Chrome for **FlashArray1** icon on the desktop. 
    
    - This will open to https://flasharray1.testdrive.local
   
        <img src=../graphics/m1/1.2.1.png width="100" height="100" >

2. **Log into the FlashArray Web Interface**

    - Enter the following username and password and click `Log In`.

        - **Username:** pureuser
        - **Password:** pureuser

          <img src=../graphics/m1/1.2.2.png width="40%" height="40%" >

<br />
<br />

# 1.3 - Start up a database workload

In this lab you will start a database workload. 

1. Launch **SQL Server Management Studio (SSMS)** 

    - On the desktop, launch **SQL Server Management Studio (SSMS)** by clicking on the icon on the desktop

        - Click **File**, **Connect Object Explorer**
            - **Server Name:** WINDOWS1
            - **Authentication:** Windows Authentication

                <img src=../graphics/m1/1.4.3.1.png width="50%" height="50%" >

2. Open a new query window, by clicking new query and pasting the following code into the Window and click Execute. 

    ```
    USE [TPCC100];
    GO

    WHILE (1=1)
        SELECT * FROM customer
    GO
    ```

    In another query window, let's start a write workload.

    ```
    USE [TPCC100];
    GO

    SET NOCOUNT ON;

    WHILE (1=1)
        BEGIN
            INSERT INTO addresses SELECT REPLICATE('a',7000)
            INSERT INTO addresses SELECT REPLICATE('a',7000)
            INSERT INTO addresses SELECT REPLICATE('a',7000)
            INSERT INTO addresses SELECT REPLICATE('a',7000)
            INSERT INTO addresses SELECT REPLICATE('a',7000)
            WAITFOR DELAY '00:00:01'
        END
    ```

Leave these workloads running as we'll need the workloads to generate performance data in the remainder of the lab

<br />
<br />

# 1.4 - Viewing Performance Metrics

1. **FlashArray Web interface**

    - Back in the FlashArray web interface, navigate to the Performance page. In the left menu bar, under Analysis, click Performance. 
        
        Right now you are looking at the averages for the Read, Write and Mirrored Write IO types. 
        
        To examine one type of IO such as read, uncheck the Write and Mirrored Write checkboxes above the charts.  Then take your mouse and hover over a point in the chart to examine more deeper dive values. You should see output similar to the screenshot below.

        <img src=../graphics/m1/1.4.1.1.png width="75%" height="75%" >

        Next, to examine write IO, uncked the Read box and check the Write box. Leaving Mirrored Write unchecked. Again, take your mouse and hover over a point in the chart to examine more deeper dive values. You should see output similar to the screenshot below.

        <img src=../graphics/m1/1.4.1.2.png width="75%" height="75%" >

    - Examine the critical performance metrics for read and write. You can view the different types of IO by checking or un checking read or write. Mirrored Write is a special consideration when using array based replication.

        - **Latency**
            - SAN Time
            - QoS Rate Limit Time
            - Queue Time
            - Read Latency
            - Write Latency
            - Total

        - **IOPs**
            - Read IOPs
            - Read Average IO Size        
            - Write IOPs
            - Write Average IO Size 

        - **Bandwitdh**
            - Read Bandwith
            - Write Bandwith

1. **Windows Performance Monitor**

    - On the desktop, launch the Microsoft Management Console named **Disk Performance Metrics**

        <img src=../graphics/m1/1.4.2.1.png width="100" height="100" >

    - Examine the critical performance metrics
        - **Latency**
            - Avg. Disk sec/Read
            - Avg. Disk sec/Write

        - **IOPs**
            - Disk Reads/sec
            - Disk Writes/sec

        - **IO Size**
            - Avg. Disk Bytes/Read
            - Avg. Disk Bytes/Write

        - **Bandwitdh**
            - Disk Reads Bytes/sec
            - Disk Writes Bytes/sec
        
           <img src=../graphics/m1/1.4.2.2.png width="75%" height="75%" >


1. **SQL Server Dynamic Management Views (DMVs)**

    - Open a new query window and paste in the following query.

        ```
        SELECT 
        DB_NAME(mf.database_id) AS [DBName], 
        mf.name AS [FileName], 
        mf.type_desc AS [FileType],
        vfs.num_of_reads AS [NumReads],           --Number of reads issued on the file.
        vfs.num_of_writes AS [NumWrites],         --Number of writes made on this file.
        vfs.num_of_bytes_read AS [ReadBytes],     --Total number of bytes read on this file.
        vfs.num_of_bytes_written AS [WriteBytes], --Total number of bytes written to the file.

        --Calculate the percentage of bytes read or written to the file
        vfs.num_of_bytes_read    * 100 / (( vfs.num_of_bytes_read + vfs.num_of_bytes_written ))  AS [PercentBytesRead],
        vfs.num_of_bytes_written * 100 / (( vfs.num_of_bytes_read + vfs.num_of_bytes_written ))  AS [PercentBytesWrite],

        --Calculate the average read latency and the average read IO size 
        CASE WHEN vfs.num_of_reads = 0 THEN 0 ELSE   vfs.io_stall_read_ms  / vfs.num_of_reads          END AS [AvgReadLatency_(ms)], 
        CASE WHEN vfs.num_of_reads = 0 THEN 0 ELSE ( vfs.num_of_bytes_read / vfs.num_of_reads ) / 1024 END AS [AvgReadSize_(KB)], 
        
        --Calculate the average write latency and the average write IO size
        CASE WHEN vfs.num_of_writes = 0 THEN 0 ELSE   vfs.io_stall_write_ms    / vfs.num_of_writes          END AS [AvgWriteLatency_(ms)], 
        CASE WHEN vfs.num_of_writes = 0 THEN 0 ELSE ( vfs.num_of_bytes_written / vfs.num_of_writes ) / 1024 END AS [AvgWriteSize_(KB)], 

        --Calculate the average total latency and the average IO size
        CASE WHEN vfs.num_of_reads + vfs.num_of_writes = 0 THEN 0 ELSE vfs.io_stall / ( vfs.num_of_reads + vfs.num_of_writes ) END AS [AvgLatency_(ms)],
        CASE WHEN vfs.num_of_reads + vfs.num_of_writes = 0 THEN 0 
        ELSE ( vfs.num_of_bytes_read + vfs.num_of_bytes_written ) / ( vfs.num_of_reads + vfs.num_of_writes ) / 1024 END AS [AvgIOSize_(KB)], 

        --The physical file name
        mf.physical_name AS [PhysicalFileName]

        FROM 
        sys.dm_io_virtual_file_stats(NULL, NULL) as [vfs] 
        inner join sys.master_files as [mf] ON [vfs].[database_id] = [mf].[database_id] 
        AND [vfs].[file_id] = [mf].[file_id] 
        ORDER BY
        [AvgLatency_(ms)] DESC 
        --  [AvgReadLatency_(ms)]
        --  [AvgWriteLatency_(ms)]
        ```

        You should see output similar to this.

        <img src=../graphics/m1/1.4.3.2.png>

<br />
<br />

# 1.5 Lab Cleanup

 - Terminate the query running from [activity 1.3](#13start-up-a-database-workload) by closing each of the running command prompt boxes

<br />
<br />

# More Resources
- [Understanding SQL Server IO Size](https://www.nocentino.com/posts/2021-12-10-sqlserver-io-size/)
- [Measuring SQL Server File Latency](https://www.nocentino.com/posts/2021-10-06-sql-server-file-latency)



Next, Continue to [Storage based snapshots and SQL Server](./2-StorageSnapshotsForSqlServer.md)
