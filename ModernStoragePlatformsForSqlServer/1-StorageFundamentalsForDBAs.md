![](./../graphics/purestorage.png)

# Workshop: Modern Storage Platforms for SQL Server

#### <i>A Course from the Pure Storage Field Solution Architecture team</i>

## Module 1 - Storage fundamentals for DBAs


# 1.1 - Logging into the lab

TODO - DESCRIPTION

TODO - ACTIVITY

**<i>Tip - Click Fit to Window to size the virtual desktop to your browser window. </i>**

<img src=../graphics/1.1.png width="40%" height="40%" >

<br />

# 1.2 - Log into FlashArray Web Interface
In this lab you will log into the FlashArray web interface. The web interface is where you can configure and monitor your FlashArray. 

- Click on the Google Chrome for **FlashArray1** icon on the desktop. This will open to https://flasharray1.testdrive.local
   
    <img src=../graphics/1.2.1.png width="10%" height="10%" >

- Username: pureuser / Password: pureuser
        
    <img src=../graphics/1.2.2.png width="40%" height="40%" >

<br />

# 1.3 - Start up a database workload

In this lab you will start a database workload. 

In the [`demos/m1`](./demos/m1/) folder, run the script [`workload.cmd`](./demos/m1/workload.bat). This will start a read and write workload against the database. Leave this workload running for the next activity.

<br />

# 1.4 - Viewing Performance Metrics

## FlashArray Web interface

- Back in the FlashArray web interface, navigate to the Performance page. In the left menu bar, under Analysis, click Performance. Right now you are looking at the averages for the Read, Write and Mirrored Write IO types. To examine one type of IO such as read, uncheck the Write and Mirrored Write checkboxes above the charts.  Then take your mouse and hover over a point in the chart to examine more deeper dive values. You should see output similar to the screenshot below.

- Examine the critical performance metrics for read and write. You can view the different types of IO by checking or un checking read or write. Mirrored Write is a special consideration when using array based replication.
    - **Latency**
        - SAN Time
        - QoS Rate Limit Time
        - Queue Time
        - Read Latency
        - Total
    - **IOPs**
        - Read IOPs
        - Read Average IO Size        
    - **Bandwitdh**
       - Read Bandwith

        <img src=../graphics/1.4.1.png width="75%" height="75%" >

## Windows Performance Monitor

- On the desktop, launch the Microsoft Management Console named **Disk Performance Metrics**
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
      
        <img src=../graphics/1.4.2.png width="75%" height="75%" >


## SQL Server Dynamic Management Views (DMVs)

- On the desktop, launch **SQL Server Management Studio**
- Open the query named [`diskperformancemetrics.sql`](./demos/m1/diskperformancemetrics.sql), execute the query.
- Username sa/pureuser

    <img src=../graphics/1.4.3.png width="75%" height="75%" >

# 1.4 Lab Cleanup

 - Terminate the query running from [activity 1.3](#13---start-up-a-database-workload) by closing each of the running command prompt boxes

---

## More Resources
- [Understanding SQL Server IO Size](https://www.nocentino.com/posts/2021-12-10-sqlserver-io-size/)
- [Measuring SQL Server File Latency](https://www.nocentino.com/posts/2021-10-06-sql-server-file-latency)



Next, Continue to [Storage based snapshots and SQL Server](./2-StorageSnapshotsForSqlServer.md)
