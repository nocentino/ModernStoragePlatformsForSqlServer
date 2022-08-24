![](./../graphics/purestorage.png)

# Workshop: Modern Storage Platforms for SQL Server

#### <i>A Course from the Pure Storage Field Solution Architecture team</i>

# Module 2 - Storage based snapshots and SQL Server

In this module, you will learn how to use array based volume snapshots to decouple the time it takes to perform DBA operations from the size of the data. You will restore a database, clone a database and present it back to the same SQL Server instance, clone a database and present it to another SQL Server instance, and also initilized a SQL Server AlwaysOn Availability Group from a snapshot. 

<br />
<br />

# 2.1 - In-place restore a database from an array-based snapshot

In this activity, you will take a snapshot of a volume, the D:\ drive, that holds both the MDF and LDF for the TPCH100 database. You will then delete a table and use the snapshot to revert the database back to the state prior to the table deletion. 

1. **Take a Volume Snapshot**
    - Open the FlashArray Web interface. And browse to Storage, Volumes. In the Volumes pane, click Windows1Vol1. 

        <img src=../graphics/m2/2.1.1.png width="25%" height="25%" >

    - Next, click the elipsis, then click create to create a snapshot of the volume.

        <img src=../graphics/m2/2.1.2.png width="50%" height="50%" >

    - Once complete, the snapshot will appear in the listing. The snapshot name includes the Volume name a dot and is suffixed with an auto-incrementing, unique integer.

        <img src=../graphics/m2/2.1.3.png width="50%" height="50%" >

1. **Delete a Database Table**
    - Open SSMS, and browse to the TPCC100 database, expand tables and delete the customer table by right clicking on the table and clicking Delete. Click OK to conform.

        <img src=../graphics/m2/2.1.4.png width="25%" height="25%" >
    
1. **Set the Database Offline**

    - To recover the database in place, we need to change the database state to offline. Right click on the database, click Tasks, click Take Offline. Check the box to Drop All Active Connections and click OK to confirm.

        <img src=../graphics/m2/2.1.5.png width="50%" height="50%" >
    
1. **Offline the Volume Supporting the Database** 

    - Snapshots are Volume based operations. So to restore a Volume from snapshot, you must first offline the volume. To offline a Volume, Open Disk Management on the Desktop.

        <img src=../graphics/m2/2.1.6.png  width="90" height="100" >

    - Right click on Disk 1 and click Offline.

        <img src=../graphics/m2/2.1.7.png width="25%" height="20%" >

1. **Restore the Volume to a Previous Snapshot**

    - Open the FlashArray Web Interface and browse back to the Volume Windows1Vol1. Click on the elipsis in the Volume Snapshots panel and click Restore. This reverts the contents of the volume back to the state captured in the snapshot. Undoing our 'accidental' table deletion.

        <img src=../graphics/m2/2.1.8.png width="50%" height="50%" >

1. **Online the Volume Supporting the Database**

    - Open Disk Managment back up, right click on Disk 1 and click Online

        <img src=../graphics/m2/2.1.9.png width="25%" height="25%" >

1. **Online the Database**

    - In SSMS, right click on the database, click Tasks, and click Bring Online. 
    
        <img src=../graphics/m2/2.1.10.png width="50%" height="50%" >

1. **Verify the Restore**
    - Refresh the table listing, by expanding the database, expanding tables and right clicking on Tables and select Refresh. The customer table should now be in the table listing.

        <img src=../graphics/m2/2.1.11.png width="25%" height="25%" >

Congratulations, you just restored an entire database in a matter of seconds without having to restore from a backup which can take a little bit longer :P 

<br />
<br />

# 2.2 - Cloning a snapshot to a new volume and attaching the database

But that seems a little heavy handed, let's try cloning the snapshot to another volume and then attaching the database

1. **Create a New Volume**
    - Log into the FlashArray Web Interface, and Click Storage, Volumes.

    - Click the + to create a new volume

        <img src=../graphics/m2/2.2.1.png>

    - Enter the name Windows1Vol2, enter 20GB for the size. 

        <img src=../graphics/m2/2.2.2.png width="50%" height="50%" >

    - Click on that Volume

        <img src=../graphics/m2/2.2.3.png>

    - In the Conntected Hosts panel, click the vertical three dots, and in the Available Hosts column, select windows1, and click Connect.

        <img src=../graphics/m2/2.2.4.png width="50%" height="50%" >
        <img src=../graphics/m2/2.2.5.png width="50%" height="50%" >

1. **Online the Disk and Format the Volume**

    In this section, you will create a new volume, format it with a file system and the offline the volume since it will be replaced with the contents of a snapshot in the next step.

    - Open Disk Management by clicking on the icon on the Desktop.
        - You will now see Disk 2, right click select online, right click again select Initialize, and leave the settings default and click OK.

        <p align="center">
            <img src=../graphics/m2/2.2.6.png width="80%" height="80%" >
        </p>

    - Format the volume
        - Right click, select New Simple Volume and then click Next.

            <img src=../graphics/m2/2.2.7.png width="80%" height="80%" >

            - Simple volume size in MB: leave default 20462 and click Next, 
            - Leave the drive letter as E and click Next,
            - Leave the file system as NTFS, select 64K for the Allocation Unit Size, and change the Volume label to SQLDATA2, leave Perform a quick format checked, then click Next and Finish

    - Offline the volume
        - Right click on Disk 2 and select offline


1. **Copy a snapshot to a Volume**

    - In the FlashArray Web Interface, click Storage, Volumes, and select Windows1Vol1

        <img src=../graphics/m2/2.2.8.png>

    - In the volumes Snapshots panel, find the snapshot you created in the activity above, its name will be Windows1Vol1.n where n is a number. Click the elipsis next to that snapshot and click Copy.

        <img src=../graphics/m2/2.2.9.png  width="50%" height="50%" >

    - For the Name, enter Windows1Vol2. This is the new volume attached to Windows2 that you just initialized and formated. Click the Overwrite slider to the right and click Copy.

        <img src=../graphics/m2/2.2.10.png width="50%" height="50%" >
    
    - When the warning appears click Overwrite.

        <img src=../graphics/m2/2.2.11.png width="50%" height="50%" >


1. **Online the Disk**

    - Back in Disk Management, right click on Disk 2 and online the volume.  The volume label will no be SQLDATA since is an exact clone from the snapshot
        <img src=../graphics/m2/2.2.12.png width="50%" height="50%" >

    - Open Windows explorer and browse to E:\ you should see an exact copy of the D:\ volume and its contents. In this case, its our database and log files.

        <img src=../graphics/m2/2.2.13.png width="50%" height="50%" >


1. **Attach the database**

    - In SSMS, you can attach the databases and Change the name to TPCC100_RESTORE.

        <img src=../graphics/m2/2.2.14.png width="50%" height="50%" >
        <img src=../graphics/m2/2.2.15.png width="50%" height="50%" >
        <img src=../graphics/m2/2.2.16.png width="50%" height="50%" >
        <img src=../graphics/m2/2.2.17.png width="50%" height="50%" >

    - Now you can use any method you like to get missing customer table back into the original database `TPCC100` and you didn't have to take the original database offline


<br />
<br />

# 2.3 - Clone a database to another instance of SQL Server
In this activity, you will clone a volume to a new instance of SQL Server. You can then attach the database on the target instance. Saving the need to backup and restore the database.

1. **Offline the Disk on Windows2**

    - Log into the Window2 virtual machine and launch Disk Management on the desktop.
    - Open Disk Management on Windows2 and Offline Disk 1

        <img src=../graphics/m2/2.3.1.png width="80%" height="80%" >

1. **Clone Windows1Vol1 Snapshot to the Volume attached to Windows2**

    - Back on Windows1, open the FlashArray Web Interface, and click on Storage, Volumes, Windows1Vol1.

        <img src=../graphics/m2/2.3.2.png>

    - In the volumes Snapshots panel, find the snapshot you created in the first activity in this module, its name will be Windows1Vol1.n where n is a number. Click the vertical elipsis and select Copy. 

        <img src=../graphics/m2/2.3.3.png width="50%" height="50%" >

    - For the Name, enter Windows2Vol1, and move the Overwrite slider to the right. Click Copy. When the warning appears click Overwrite.
    
        <img src=../graphics/m2/2.3.4.png width="50%" height="50%" >

1. **Online the disk**    
    - Back on Window2, in disk management, online Disk 1.
    - Open Windows Explorer and browe to D:\, you should now see the database files for TPCC100 from the clone of Windows1.

1. **Attach the database**

    - Back on Windows1, in SSMS, connect to Windows2.
    
        <p align="center">
            <img src=../graphics/m2/2.3.5.png width="50%" height="50%" >
        </p>

    - Attach the database files from D:\ with the name TPCC100.

        <img src=../graphics/m2/2.3.7.png width="50%" height="50%" >
        <img src=../graphics/m2/2.3.7.png width="50%" height="50%" >
        <img src=../graphics/m2/2.3.8.png width="50%" height="50%" >

This this demo, you copied, nearly instantaneosuly a 10GB database between two instances of SQL Server. 

ADD SCREENSHOT OF CLONED DB HERE



<br />
<br />

# 2.4 - Seed an Availability Group from an array-based snapshot (Optional)
In this activity, you will build an Availability Group from Snapshot.

## Set up the databases

For this activity, you are going to refresh TPCC100 on the D:\ drive with a TSQL based snapshot backup of TPCC100 from Windows1. You will start preparing Windows2 for this operation by detaching the TPCC100 database and offlining Disk 1. 

1. **Detach the database and offlne the disk on Windows2**
    - In SSMS, detach TPCC100 by right clicking, selecting Tasks, and Detach
    
        <img src=../graphics/m2/2.4.1.png width="50%" height="50%" >

    - Open Disk Management on Windows2 and Offline Disk 1

        <img src=../graphics/m2/2.3.1.png width="80%" height="80%" >

1. **Set the database into snapshot mode**
    - On Windows1, in SSMS, open a New Query Window and enter:
    
        ```ALTER DATABASE TPCC100 SET SUSPEND_FOR_SNAPSHOT_BACKUP = ON```

        <img src=../graphics/m2/2.4.2.png>

1. **Create a Snapshot of the Volume Windows1Vol1**
    - In the FlashArray Web Interface, click, Storage, Volumes and select Windows1Vol1, in the Volume Snapshots panel, click the elipsis and select Create. Click Create when prompted.
    
        <img src=../graphics/m2/2.4.3.png>
        <img src=../graphics/m2/2.4.4.png width="50%" height="50%" >

1. **Create the metadata backup file**
    - In SSMS, open a New Query Window connecting to the WINDOWS1 SQL Instance and enter: 
    
        ```BACKUP DATABASE TPCC100 TO DISK='\\WINDOWS2\BACKUP\TPCC100-Replica.bkm' WITH METADATA_ONLY, INIT```

        <img src=../graphics/m2/2.4.5.png>

1. **Clone the snapshot to Windows1**
    - In the FlashArray Web Interface, clone the snapshot to overwrite the database volume on Window2. 
    Click Storage, Volumes, Windows1Vol1, in the snapshot panel, select the snapshot you just made, click the three vertical dots and select copy. Enter for the Name Windows2Vol1, and move the overwrite slider to the right. Click Overwrite when prompted.

        <img src=../graphics/m2/2.4.6.png>
        <img src=../graphics/m2/2.4.7.png width="50%" height="50%" >

1. **Online Disk2 on Windows2**
    - On Windows2, in Disk Management, online Disk 2

1. **Restore the metadata backup on Windows2**
    - On the Desktop of Windows1, in SSMS, open a New Query window connecting to Windows2 and restore the database from snapshot `RESTORE DATABASE TPCC100 FROM DISK = 'C:\BACKUP\TPCC100-Replica.bkm' WITH METADATA_ONLY, REPLACE, NORECOVERY` In SSMS, you should now see the TPCC100 database in a Restoring state.

        <img src=../graphics/m2/2.4.8.png>

1. **Complete the Availability Group Initilization Process**
    - Let's complete the remainder of the availbility group intilization process.
    - Take a log backup on connected to the SQL instance on WINDOWS1 with `BACKUP LOG TPCC100 TO DISK = '\\WINDOWS2\BACKUP\\TPCC100-seed.trn' WITH INIT`

        <img src=../graphics/m2/2.4.9.png>

    - Restore the log file on Window2 `RESTORE LOG TPCC100 FROM DISK = 'C:\BACKUP\TPCC100-seed.trn' WITH NORECOVERY`

        <img src=../graphics/m2/2.4.10.png>

1. **Create the Availability Group**
- Right Click Always On High Availability, click New Availability Group Wizard. On the first page, click Next.

    <img src=../graphics/m2/2.4.11.png width="25%" height="25%" >

- Specify Availability Group Options

    - **Availability Group Name:** AG1
    - **Cluster Type:** NONE

    <img src=../graphics/m2/2.4.12.png width="50%" height="50%" >

- Check the checkbox for TPCC100 to add it to the AG, click next

    <img src=../graphics/m2/2.4.13.png width="50%" height="50%" >

- Click Add Replica, enter WINDOWS2, click CONNECT, click Next.

    <img src=../graphics/m2/2.4.14.png width="50%" height="50%" >

- For Data Synchronization Mode, select Join Only, click Next

    <img src=../graphics/m2/2.4.15.png width="50%" height="50%" >

- On the Validation screen, click next. 

    <img src=../graphics/m2/2.4.16.png width="50%" height="50%" >

- On the summary screen, click Finish.

    <img src=../graphics/m2/2.4.17.png width="50%" height="50%" >

- Once on the Results screen click close.

    <img src=../graphics/m2/2.4.18.png width="50%" height="50%" >

1. **Check the state of the Availability Group Replication**
    - Right click on 'Availbility Group' Select 'Show Dashboard'

        <img src=../graphics/m2/2.4.19.png width="25%" height="25%" >

    - With the dashboard loaded, notice that the Availbility group state is Healty. Data is activly replicating between the two instances. WINDOWS2 is in Synchronizing mode since the current AG Availbility Mode is Asynchronous. If we changed the Availability Mode to Synchronous for Windows2 the sate will change to Synchronized.

        <img src=../graphics/m2/2.4.20.png width="50%" height="50%" >



<br />
<br />


# More Resources
- [Seeding an Availability Group Replica from Snapshot](https://www.nocentino.com/posts/2022-05-26-seed-ag-replica-from-snapshot/)



Next, Continue to [SQL Server Object Integration: Backup and Restore](./3-SQLObjectIntegrationBackupRestore.md)

