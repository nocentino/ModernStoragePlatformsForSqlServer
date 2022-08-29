![](./../graphics/purestorage.png)

# Workshop: Modern Storage Platforms for SQL Server
<br />

# Module 1 - Storage fundamentals for DBAs

In this module, you will log into the administrative desktop to perform all of the activities in this course and learn the core administrative tools for monitoring the performance of storage platforms. 

<br />
<br />

# 1.1 - Logging into the lab

Follow the instructions in this section to launch the lab to use with this course.

1. Navigate to the Sky Tap Portal. The link was sent to your registered email address.
2. Select your Profile by clicking on your Name in the Top-Right Corner or the Purple photo.
3. If the Lab is not started, Power on the VMs using the button up top; this will start the VMs in the proper sequence.

You will be automatically logged into Windows when you connect to the Virtual Machine's console.

TODO: Add a screenshot of the actual lab interface


**<i>Tip - Click Fit to Window to size the virtual desktop to your browser window. </i>**

<img src=../graphics/m1/1.1.png width="50%" height="50%" >

<br />
<br />

# Lab Information

Your hands on lab consistes of two Windows Servers each with SQL Server installed, and the Polybase feature installed. Also in your lab is a FlashArray for use the primary block storage device and storage subsystem for SQL Server instances. There is also a FlashBlade, for use as the primary external object storage device used by SQL Server

| Resource      | Description |
| -----------   | ----------- |
| **Windows1**  | **Primary administrator desktop and SQL Server Instance** |
| Windows2      | SQL Server Instance |
| FlashArray1   | Primary block storage device and storage subsystem for SQL Server instances |
| FlashBlade1   | Primary external object storage used by SQL Server |

<br />
<br />

# 1.2 - Log into FlashArray Web Interface
In this activity, you will log into the FlashArray web interface. The web interface is where you can configure and monitor your FlashArray. 

1.  **Click on the Google Chrome for FlashArray1 icon on the desktop**
    
    - This will open to https://flasharray1.testdrive.local
   
        <img src=../graphics/m1/1.2.1.png width="100" height="100" >

2. **Log in to the FlashArray Web Interface**

    - Enter the following username and password and click **Log In**.

        - **Username:** pureuser
        - **Password:** pureuser

          <img src=../graphics/m1/1.2.2.png width="40%" height="40%" >

    - On the landing page, there is a menu on the left for various configuration elements and a dashboard showing overall capacity, recent alerts, array performance, and health. 

        <img src=../graphics/m1/1.2.3.png>

Now that you've logged into FlashArray's Web Interface let's kick off a workload so we can dive into some of the performance metrics available.

<br />
<br />

# 1.3 - Start up a database workload

So far, those performance charts above are pretty boring. Let's start up a database workload on Windows1 so you can look at the various performance metrics on the dashboard. 

## **Launch SQL Server Management Studio (SSMS)** 

- [ ] On the desktop, launch **SQL Server Management Studio (SSMS)** by clicking on the icon on the desktop

    <img src=../graphics/m1/1.3.1.png width="100" height="100" >

    - Click **File**, **Connect Object Explorer**
        - **Server Name:** WINDOWS1
        - **Authentication:** Windows Authentication

            <img src=../graphics/m1/1.3.2.png width="50%" height="50%" >

## **Start up a workload**

- [ ] Open a new query window by clicking **New Query** on the toolbar, pasting the following code into the window, and clicking **Execute**. 

    ```
    USE [TPCC100];
    GO

    SELECT * FROM customer
    GO
    ```

- [ ] Open another query window, let's start a write workload. Click **New Query** once more and paste the following code into the window and click **Execute**.

    ```
    USE [TPCC100];
    GO

    SET NOCOUNT ON;

    DECLARE @i INT 
    SET @i = 1
    WHILE ( @i <= 1000)
    BEGIN
        INSERT INTO addresses SELECT REPLICATE('a',7000)
        INSERT INTO addresses SELECT REPLICATE('a',7000)
        INSERT INTO addresses SELECT REPLICATE('a',7000)
        INSERT INTO addresses SELECT REPLICATE('a',7000)
        INSERT INTO addresses SELECT REPLICATE('a',7000)
        WAITFOR DELAY '00:00:01'    SET @i  = @i  + 1
    END
    ```

Leave these workloads running as we'll need the workloads to generate performance data in the remainder of this module. If the workload stops before you complete the activities below, head back into SSMS and click **Execute** again.

<br />
<br />

# 1.4 - Viewing Performance Metrics in FlashArray

## **Examining Performance Metrics in the FlashArray Web Interface Dashboard**

Now that we have a workload running let's examine some key performance metrics displayed on the FlashArray Array Performance Dashboard.

- [ ] Open the FlashArray web interface again. On main dashboard, the **Array Performance** panel shows the current **Latency**, **IOPS**, and **Bandwidth** metrics for the array. 

- [ ] **Examine** each of the performance metrics in the Array Performance Panel. The metrics reported on the chart show the latests values sampled. To see values from pervious points in time,
    
    - [ ] **Hover** your mouse over the charts and the values in the fields on the upper right of each chart will be updated with the values at that time interval.

        <img src=../graphics/m1/1.2.3-perf.png>

        Chart metric definitions for the Array Performance Dashboard

        - **Latency** - The Latency chart displays the average latency times for various operations.

            - **(R) - Read Latency** - Average arrival-to-completion time, measured in milliseconds, for a read operation.
            - **(W) - Write Latency** - Average arrival-to-completion time, measured in milliseconds, for a write operation.
            - **(Q) - Queue Time** - Average time, measured in microseconds, that an IO request spends in the array waiting to be served. The time is averaged across all IOs of the selected types.

        <br />

        - **IOPS** - The IOPS (Input/output Operations Per Second) chart displays IO requests processed per second by the array. This metric counts requests per second, regardless of how much or how little data is transferred in each.

            - **(R) - Read IOPS** - Number of read requests processed per second.
            - **(W) - Write IOPS** - Number of write requests processed per second.

        <br />

        - **Bandwidth** - The Bandwidth chart displays the number of bytes transferred per second to and from all file systems. The data is counted in its expanded form rather than the reduced form stored in the array to reflect what is transferred over the storage network. 

            - **(R) - Read Bandwidth** - Number of bytes read per second.
            - **(W) - Write Bandwidth** - Number of bytes written per second.



<br />
<br />

## **FlashArray Performance Metrics, a Closer Look**

The Array Performance Dashboard is excellent for a glance at the health of the array. Now let's take a deeper dive into the performance metrics exposed. The Performance Dashboard is a great place to go when you need to understand the workload running on the array. Latency, IOPS, and Bandwidth are all broken down very granularly so that you can identify performance issues if they arise.

- [ ] Navigate to the **Performance page**. In the left menu bar, under **Analysis**, click **Performance** and change the time range dropdown to **5 minutes**. On this page, you have a high-level overview of the key performance metrics for FlashArray, **Latency**, **IOPS**, and **Bandwidth**. 

- [ ] Move your mouse over the charts to get metrics split by the IO type, Read, Write and Mirrored Write. Mirrored Write is a special consideration when using array-based replication.

    <img src=../graphics/m1/1.4.1.0.png>

### **Examining one type of IO, Read IO**

- [ ] To examine one type of IO such as **Read, uncheck the Write** and **Mirrored Write** checkboxes above the charts. 
    
- [ ] Then, take your **mouse and hover over a point in the chart** to examine deeper dive values. You should see output similar to the screenshot below.

    <img src=../graphics/m1/1.4.1.1.png>

### **Examining one type of IO, Write IO**

- [ ] Next, to examine Write IO, **uncheck the Read checkbox** and **check the Write checkbox**. Leave Mirrored Write unchecked. 
    
- [ ] Again, take your **mouse and hover over a point in the chart** to examine deeper dive values. You should see output similar to the screenshot below.

    <img src=../graphics/m1/1.4.1.2.png>

- [ ] Examine the critical performance metrics for Read and Write. You can view the different types of IO by checking or unchecking read or write. 

    Here are the definitions of each of the performance metrics reported on the Array Performance Analysis Panel

    - **Latency**
        - **SAN Time** - Time required transferring data between initiator and purity target. 
        - **QoS Rate Limit Time** - Average time, measured in microseconds, that an IO request spends waiting on user-defined QoS Policies
        - **Queue Time** - Average time, measured in microseconds, that an IO request spends in the array waiting to be served. 
        - **Read Latency** - Average arrival-to-completion time, measured in milliseconds, for a read operation.
        - **Write Latency** - Average arrival-to-completion time, measured in milliseconds, for a write operation.
        - **Total** - The total amount of latency across all types, measured in millieseconds.

    - **IOPS**
        - **Read IOPS** - Number of read requests processed per second.
        - **Read Average IO Size** - The average read IO Size measured in Kilobytes
        - **Write IOPS** - Number of write requests processed per second.
        - **Write Average IO Size** - The average write IO Size measured in Kilobytes

    - **Bandwidth**
        - **Read Bandwidth** - Amount of data read per second. Unit of measure will scale (KB/s, MB/s, GB/s)
        - **Write Bandwidth**- Amount of data written per second. Unit of measure will scale (KB/s, MB/s, GB/s)

<br />
<br />


# 1.5 - Viewing Additional Performance Metrics (Optional)

So far, we've looked at performance from the array's perspective. When troubleshooting a performance, trying to get a fuller picture of what's occurring, you can use the following techniques to get performance metrics from SQL Server DMVs and Windows Performance Monitor. 

## **SQL Server Dynamic Management Views (DMVs)**

- [ ] Next, open a **New Query** window and paste in the following query.

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

## **Examining Performance Metrics with Windows Performance Monitor - Optional**

- [ ] On the desktop, launch the Microsoft Management Console named **Disk Metrics**

    <img src=../graphics/m1/1.4.2.1.png width="100" height="100" >

- [ ] Examine the critical performance metrics as measured from the operating system level. These are valuable performance metrics especially when used in conjuntion with FlashArray performance metrics which can help you identify latency issue outside of the operating system's control, such as in the storage network or array.

    - **Latency**
        - Avg. Disk sec/Read - Average arrival-to-completion time, measured in milliseconds, for a read operation.
        - Avg. Disk sec/Write - Average arrival-to-completion time, measured in milliseconds, for a write operation.

    - **IO Size**
        - Avg. Disk Bytes/Read - The average read IO Size measured in Kilobytes.
        - Avg. Disk Bytes/Write - The average write IO Size measured in Kilobytes.

    - **IOPS**
        - Disk Reads/sec - Number of read requests processed per second.
        - Disk Writes/sec - Number of write requests processed per second.

    - **Bandwidth**
        - Disk Reads Bytes/sec - Number of bytes read per second.
        - Disk Writes Bytes/sec - Number of bytes read per second.
    
    <img src=../graphics/m1/1.4.2.2.png width="75%" height="75%" >

<br />
<br />

# 1.6 Lab Cleanup

- [ ] Terminate the query running from [activity 1.3](#13---start-up-a-database-workload) by clicking the Stop icon in the SSMS toolbar.

<br />
<br />

# More Resources
- [Understanding SQL Server IO Size](https://www.nocentino.com/posts/2021-12-10-sqlserver-io-size/) - a blog post deep diving into SQL Servers varying IO sizes
- [Measuring SQL Server File Latency](https://www.nocentino.com/posts/2021-10-06-sql-server-file-latency) - a blog post on measuring disk latency at the SQL Server level.

<br />
<br />

# Next Steps

Next, Continue to [Storage based snapshots and SQL Server](./2-StorageSnapshotsForSqlServer.md)
