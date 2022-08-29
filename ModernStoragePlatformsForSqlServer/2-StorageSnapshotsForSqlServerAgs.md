![](./../graphics/purestorage.png)

# Workshop: Modern Storage Platforms for SQL Server

#### <i>A Course from the Pure Storage Field Solution Architecture team</i>

# Module 2 - Storage based snapshots and SQL Server

In this module, you will learn how to use array-based volume snapshots to decouple the time it takes to perform DBA operations from the size of the data. You will restore a database, clone a database and present it back to the same SQL Server instance, clone a database and present it to another SQL Server instance, and initialize a SQL Server AlwaysOn Availability Group from a snapshot. 


# 2.4 - Seeding an Availability Group from an array-based snapshot (Optional)
In this activity, you will build an Availability Group from Snapshot leveraging the FlashArray snapshots and the new (TSQL Based Snapshot Backup](https://docs.microsoft.com/en-us/sql/relational-databases/backup-restore/create-a-transact-sql-snapshot-backup?view=sql-server-ver16) functionality in SQL Server 2022.

TODO: Add a high-level description of the process

1. [Prepare Windows2](#prepare-windows2)
1. [Take a snapshot backup of TPCC100 on Windows1](#take-a-snapshot-backup-of-tpcc100-on-windows1)
1. [Restore the snapshot backup to Windows2](#restore-the-snapshot-backup-to-windows2)
1. [Complete the Availability Group Initialization Process](#complete-the-availability-group-initilization-process)
1. [Create the Availability Group](#create-the-availability-group)
1. [Check the state of the Availability Group Replication](#check-the-state-of-the-availability-group-replication)

## Prepare Windows2

For this activity, you will restore `TPCC100` on **Window2** with a TSQL-based snapshot backup of `TPCC100` from **Windows1**. You will start preparing **Windows2** for this operation by detaching the `TPCC100` database and offlining Disk 1. 

1. **Detach the database and offline the disk on Windows2**
    - In **SSMS**, connect to **Windows2** and detach `TPCC100` by right-clicking, selecting **Tasks**, and **Detach**
    
        <img src=../graphics/m2/2.4.1.png width="75%" height="75%" >

    - On **Windows2**, open Disk Management and **Offline Disk 1**

        <img src=../graphics/m2/2.3.1.png width="80%" height="80%" >

    <br />
    <br />

## Take a snapshot backup of TPCC100 on Windows1

1. **Set the database into snapshot mode**
    - On **Windows1**, in **SSMS**, open a **New Query Window** connecting to the **WINDOWS1** SQL Instance and **enter** and **Execute** the following: 
    
        ```
        ALTER DATABASE TPCC100 SET SUSPEND_FOR_SNAPSHOT_BACKUP = ON
        ```

        <img src=../graphics/m2/2.4.2.png>

    <br />
    <br />

1. **Create a Snapshot of the Volume Windows1Vol1**
    - In the **FlashArray Web Interface**, click **Storage, Volumes** and select **Windows1Vol1**. In the **Volume Snapshots** Panel, **click the ellipsis** and **select Create**. **Click Create** when prompted.
    
        <img src=../graphics/m2/2.4.3.png>
        <img src=../graphics/m2/2.4.4.png width="75%" height="75%" >

    <br />
    <br />

1. **Create the metadata backup file**
    - In **SSMS**, open a **New Query Window** connecting to the **WINDOWS1** SQL Instance and **enter** and **Execute** the following: 
    
        ```
        BACKUP DATABASE TPCC100 TO DISK='\\WINDOWS2\BACKUP\TPCC100-Replica.bkm' WITH METADATA_ONLY, INIT
        ```

        <img src=../graphics/m2/2.4.5.png>

    <br />
    <br />

## Restore the snapshot backup to Windows2

1. **Clone the snapshot of Windows1Vol1 to Windows2Vol1**
    - **Click Storage, Volumes, Windows1Vol1**, in the **Volume Snapshot** Panel, **click the ellipsis** next to the snapshot you just took and **select Copy**. Enter the Name **Windows2Vol1**, and move the **Overwrite slider** to the right. **Click Overwrite** when prompted.

        <img src=../graphics/m2/2.4.6.png>
        <img src=../graphics/m2/2.4.7.png width="75%" height="75%" >

    <br />
    <br />

1. **Online Disk 2 on Windows2**
    - On **Windows2**, in **Disk Management**, **online Disk 2**


    <br />
    <br />

1. **Restore the metadata backup on Windows2**
    - On the desktop of **Windows1**, in SSMS, open a **New Query window**. Connect to the SQL Instance on **WINDOWS2** and restore the database from the snapshot using this code.
     
        ```
        RESTORE DATABASE TPCC100 FROM DISK = 'C:\BACKUP\TPCC100-Replica.bkm' WITH METADATA_ONLY, REPLACE, NORECOVERY
        ```
        
    - In SSMS, refresh the Database listing, and you should now see the `TPCC100` database in a `Restoring...` state.

        <img src=../graphics/m2/2.4.8.png>

    <br />
    <br />

## Complete the Availability Group Initialization Process

Let's complete the remainder of the availability group initialization process.
    
- Take a log backup connected to the SQL instance on **WINDOWS1**. Copy and 

    ```
    BACKUP LOG TPCC100 TO DISK = '\\WINDOWS2\BACKUP\\TPCC100-seed.trn' WITH INIT
    ```

    <img src=../graphics/m2/2.4.9.png>

    <br />
    <br />
- Restore the log file on **WINDOWS2** 

    ```
    RESTORE LOG TPCC100 FROM DISK = 'C:\BACKUP\TPCC100-seed.trn' WITH NORECOVERY
    ```

    <img src=../graphics/m2/2.4.10.png>

    <br />
    <br />

## Create the Availability Group

- **Right Click Always On High Availability**, **click New Availability Group Wizard**. On the first page, **click Next**.

    <img src=../graphics/m2/2.4.11.png width="25%" height="25%" >

- Specify Availability Group Options, enter the following values, then **click Next**.

    - **Availability Group Name:** AG1
    - **Cluster Type:** NONE

    <img src=../graphics/m2/2.4.12.png width="75%" height="75%" >

- **Check the checkbox** for `TPCC100` to add it to the AG, **click Next**.

    <img src=../graphics/m2/2.4.13.png width="75%" height="75%" >

- Click **Add Replica**, enter **WINDOWS2** for the serve rname, **click Connect**, **click Next**.

    <img src=../graphics/m2/2.4.14.png width="75%" height="75%" >

- For Data Synchronization Mode, **select Join Only, click Next**.

    <img src=../graphics/m2/2.4.15.png width="75%" height="75%" >

- On the Validation screen, **click Next**. 

    <img src=../graphics/m2/2.4.16.png width="75%" height="75%" >

- On the summary screen, **click Finish**.

    <img src=../graphics/m2/2.4.17.png width="75%" height="75%" >

- Once on the Results, review the results, and a successful Availability Group initialization will have output similar to the screenshot below. Once finished **click Close**.

    <img src=../graphics/m2/2.4.18.png width="75%" height="75%" >

    <br />
    <br />

## Check the state of the Availability Group Replication

- **In SSMS Object Explorer, right-click on Availability Group** Select **Show Dashboard**and double-click on **AG1**.

    <img src=../graphics/m2/2.4.19.png width="25%" height="25%" >

- With the dashboard loaded, notice that the Availability group state is **Healthy**. Data is actively replicating between the two instances, WINDOWS1 and WINDOWS2. 

    <img src=../graphics/m2/2.4.20.png width="75%" height="75%" >

- WINDOWS2's Synchronization State is in **synchronizing** since the current AG Availability Mode is Asynchronous. If we change the Availability Mode to Synchronous for Windows2, the state will change to Synchronized.


<br />
<br />


# More Resources
- [Seeding an Availability Group Replica from Snapshot](https://www.nocentino.com/posts/2022-05-26-seed-ag-replica-from-snapshot/)

<br />
<br />

# Next Steps

Next, Continue to [SQL Server Object Integration: Backup and Restore](./3-SQLObjectIntegrationBackupRestore.md)

