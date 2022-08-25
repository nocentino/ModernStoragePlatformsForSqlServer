![](./../graphics/purestorage.png)

# Workshop: Modern Storage Platforms for SQL Server

#### <i>A Course from the Pure Storage Field Solution Architecture team</i>

# Module 2 - Storage based snapshots and SQL Server

In this module, you will learn how to use array based volume snapshots to decouple the time it takes to perform DBA operations from the size of the data. You will restore a database, clone a database and present it back to the same SQL Server instance, clone a database and present it to another SQL Server instance, and also initilized a SQL Server AlwaysOn Availability Group from a snapshot. 

### **Lab Information**

| Resource      | FlashArray Volume Name | Windows Disk Number | Windows Drive Letter
| -----------   | -----------  | ----------- | -----------  |
| Windows1      | Windows1Vol1 | 1           | D:\          |
| Windows2      | Windows2Vol1 | 1           | D:\          |


<br />
<br />

# 2.1 - In-place restore a database from an array-based snapshot

In this activity, you will take a snapshot of a volume, that holds both the MDF and LDF for the TPCH100 database. You will then delete a table and use the snapshot to revert the database back to the state prior to the table deletion. 

1. **Take a Volume Snapshot**
    - Open the FlashArray Web interface. And browse to **Storage**, **Volumes**. In the Volumes pane, click **Windows1Vol1**.

        <img src=../graphics/m2/2.1.1.png width="75%" height="75%" >

    - Next, in the **Volume Snapshots** panel, click the **elipsis**. Then click **Create** to create a snapshot of the volume. Then click **Create** on the popup screen to create the snapshot. 

        <img src=../graphics/m2/2.1.2.png width="75%" height="75%" >

    - Once complete, the snapshot will appear in the listing. The snapshot name includes the Volume name a dot and is suffixed with an auto-incrementing, unique integer.

        <img src=../graphics/m2/2.1.3.png width="75%" height="75%" >

    <br />
    <br />

1. **Delete a Database Table**
    - Open **SSMS**, and **browse** to the TPCC100 database, expand tables and delete the `customer` table by **right clicking** on the table and clicking **Delete**. **Click OK** to confirm.

        <img src=../graphics/m2/2.1.4.png width="50%" height="50%" >
    <br />
    <br />
1. **Set the Database Offline**
     
     To recover the database in place, we need to change the database state to offline.
     
     - **Right click** on the database, click **Tasks**, click **Take Offline**. Check the box to **Drop All Active Connections** and **click OK** to confirm.

        <img src=../graphics/m2/2.1.5.png width="75%" height="75%" >
    
    <br />
    <br />

1. **Offline the Volume Supporting the Database** 

    Snapshots are Volume based operations. So to restore a Volume from snapshot, you must first offline the volume. 
    
    - To offline a Volume, **Open Disk Management** on the Windows1 Desktop.

        <img src=../graphics/m2/2.1.6.png  width="90" height="100" >

    - **Right click** on Disk 1 and **click Offline**.

        <img src=../graphics/m2/2.1.7.png width="25%" height="20%" >

    <br />
    <br />

1. **Restore the Volume to a Previous Snapshot**
    - **Open the FlashArray Web Interface** and **browse back to the Volume Windows1Vol1**. Click on the **elipsis** next to the snapshot you took at the start of this activity in the Volume Snapshots panel and **click Restore**. This reverts the contents of the volume back to the state captured in the snapshot. Undoing our 'accidental' table deletion.

        <img src=../graphics/m2/2.1.8.png width="75%" height="75%" >

    <br />
    <br />

1. **Online the Volume Supporting the Database**
    - **Open Disk Managment** back up, **right click** on Disk 1 and **click Online**.

        <img src=../graphics/m2/2.1.9.png width="25%" height="25%" >

    <br />
    <br />

1. **Online the Database**
    - In **SSMS**, right click on the database, click Tasks, and click Bring Online. 
    
        <img src=../graphics/m2/2.1.10.png width="75%" height="75%" >

    <br />
    <br />

1. **Verify the Restore**
    - Refresh the table listing, by expanding the database, **expanding tables and right clicking on Tables and select Refresh**. The `customer` table should now be in the table listing.

        <img src=../graphics/m2/2.1.11.png width="50%" height="50%" >

    <br />
    <br />

Congratulations, you just restored an entire 10GB database in a matter of seconds without having to restore from a backup which can take a little bit longer :P 

<br />
<br />

# 2.2 - Cloning a snapshot to a new volume and attaching the database

But restoring the entire database to recover one missing table seems a little heavy handed. Let's try another technique to get the database. Let's now clone the snapshot we took in the first activy to new volume in the server and then attaching the database. This way our primary database can stay online during the recovery process. And since snapshots share the same physical pages insude the array this operation will not consume any space in the array.

1. **Create a New Volume**
    - Log into the FlashArray Web Interface, and **Click Storage**, **Volumes**.

    - In the **Volumes** Panel, click the **+** to create a new volume

        <img src=../graphics/m2/2.2.1.png>

    - Enter the name **Windows1Vol2**, enter **20GB** for the size. 

        <img src=../graphics/m2/2.2.2.png width="75%" height="75%" >

    <br />
    <br />

1. **Copy a snapshot to a Volume**

    -  In the **Volumes** Panel, select **Windows1Vol1**

        <img src=../graphics/m2/2.2.8.png>

    - In the **Volumes Snapshots** Panel, find the snapshot you created in the activity above, its name will be **Windows1Vol1.*n*** where n is a number. **Click the elipsis** next to that snapshot and **click Copy**.

        <img src=../graphics/m2/2.2.9.png  width="75%" height="75%" >

    - For the **Name, enter Windows1Vol2**. This is the new volume we just create. Move the **Overwrite slider to the right** and **click Copy**.

        <img src=../graphics/m2/2.2.10.png width="75%" height="75%" >
    
    - When the warning appears **click Overwrite**. At this point the contents of Windows1Vol1 are cloned ingo Window1Vol2. There is now a unique clone of the original volume and it's contents available to be attached to our server.

        <img src=../graphics/m2/2.2.11.png width="75%" height="75%" >

    <br />
    <br />

1. **Connect the new Volume to Window1**
    - In the **Volumes** Panel, click on **Windows1Vol2**

        <img src=../graphics/m2/2.2.3.png>

    - In the **Conntected Hosts** Panel, **click the elipsis**, and in the **Available Hosts** column, **select windows1**, and **click Connect**.

        <img src=../graphics/m2/2.2.4.png width="75%" height="75%" >
        <img src=../graphics/m2/2.2.5.png width="75%" height="75%" >

    <br />
    <br />

1. **Online the Disk**

    - In **Disk Management**, **right click on Disk 2** and **online the volume**.  
        <img src=../graphics/m2/2.2.12.b.png width="25%" height="25%" >

        - If Disk 2 doesn't show up click Action, Refresh.

            <img src=../graphics/m2/2.2.12.a.png width="25%" height="25%" >

        - Once the Disk 2 is online, you can see that the volume label is the same as Disk 1 since this is an exact clone of the volume inside the array.

            <img src=../graphics/m2/2.2.12.png   width="75%" height="75%" >

    - Open Windows explorer and browse to `E:\` you should see an exact copy of the `D:\` volume and its contents. In this case, its our database and log files. Which we can now attach as a unique database in our SQL Instance.

        <img src=../graphics/m2/2.2.13.png width="75%" height="75%" >

    <br />
    <br />

1. **Attach the database**

    - In SSMS, you can attach the databases and Change the name to `TPCC100_RESTORE`.

        - Right click on the Databases folder in the SSMS Object Explorer
            
            <img src=../graphics/m2/2.2.14.png width="75%" height="75%" >

        - Click **Add**

            <img src=../graphics/m2/2.2.14.a.png width="75%" height="75%" >

        - **Browse** to `E:\SQL`, select `tpcc100.mdf`, and **click OK**.

            <img src=../graphics/m2/2.2.15.png width="75%" height="75%" >

        - Enter `TPCC100_RESTORE` in the **Attach As** field and click **OK**.

            <img src=../graphics/m2/2.2.16.png width="75%" height="75%" >
    
        - Finally, **right click on Databases** in Object Explorer, click **Refresh** to see the newly attached database in the list.

            <img src=../graphics/m2/2.2.17.png width="40%" height="40%" >

    <br />
    <br />

At this point, you have the original database `TPCC100` on the D:\ drive with the missing `customer` table and you have a clone of the original snapshot we took before we deleted the customer table. You can now use any method you copy the customer table from `TPCC100_RESTORE` back into the original database `TPCC100` and you can do this without taking the database offline.

<br />
<br />

# 2.3 - Clone a database to another instance of SQL Server
In this activity, you will clone volume from Windows1 to Windows2. You can then attach the a copy of the TPCC100 database on the target instance. Saving the need to backup and restore the database. Since this operation is inside the array it happens nearly instantneously. 

**ADD TEXT AROUND DATA REDUCTION

1. **Offline the Disk on Windows2**

    - Log into the Window2 virtual machine 
    - Launch **Disk Management** on the desktop and **Offline Disk 1** by **right clicking** on Disk 1 and **selecting Offline**.

        <img src=../graphics/m2/2.3.1.a.png width="80%" height="80%" >

    - Once finished, you can see the status of Disk 1 is now, Offline.

        <img src=../graphics/m2/2.3.1.png width="80%" height="80%" >

    <br />
    <br />

1. **Clone Windows1Vol1 Snapshot to the Volume attached to Windows2**

    - Back on **Windows1**, **open the FlashArray Web Interface**, and click on **Storage, Volumes, Windows1Vol1**.

        <img src=../graphics/m2/2.3.2.png>

    - In the **Volumes Snapshots** Panel, find the snapshot you created in the first activity in this module, its name will be **Windows1Vol1.*n*** where n is a number. Click the **vertical elipsis** and **select Copy**. 

        <img src=../graphics/m2/2.3.3.png width="75%" height="75%" >

    - For the Name, enter **Windows2Vol1**, and move the **Overwrite slider** to the right. **Click Copy.** When the warning appears click **Overwrite**.
    
        <img src=../graphics/m2/2.3.4.png width="75%" height="75%" >

    <br />
    <br />

1. **Online the disk**    
    - Back on **Window2**, in **Disk Management**, **online Disk 1**.
    - Open Windows Explorer and browse to `D:\`, you should now see the database files for `TPCC100` from the snapshot of Windows1.

    <br />
    <br />

1. **Attach the database**

    - Back on **Windows1**, in **SSMS**, connect to **Windows2**.
    
        <p align="center">
            <img src=../graphics/m2/2.3.5.png width="75%" height="75%" >
        </p>

    - In SSMS, you can attach the database files from `D:\` with the name `TPCC100`.

        - Right click on the Databases folder in the SSMS Object Explorer

            <img src=../graphics/m2/2.3.6.png width="40%" height="40%" >

        - Click **Add**

            <img src=../graphics/m2/2.3.7.a.png width="75%" height="75%" >

        - **Browse** to `D:\SQL`, select `tpcc100.mdf`, and **click OK**.

            <img src=../graphics/m2/2.3.7.png   width="75%" height="75%" >

        - **Click OK** to attach the database.

            <img src=../graphics/m2/2.3.8.png width="75%" height="75%" >

        - Finally, **right click on Databases** in Object Explorer, click **Refresh** to see the newly attached database in the list.

            <img src=../graphics/m2/2.3.9.png width="40%" height="40%" >

This this demo, you copied, nearly instantaneosuly a 10GB database between two instances of SQL Server. This snapshot does not take up any additional space in the array. 

**Explain why

<br />
<br />

# 2.4 - Seed an Availability Group from an array-based snapshot (Optional)
In this activity, you will build an Availability Group from Snapshot leveraging the new (TSQL Based Snapshot Backup](https://docs.microsoft.com/en-us/sql/relational-databases/backup-restore/create-a-transact-sql-snapshot-backup?view=sql-server-ver16) functionality in SQL Serve 2022.

## Set up the databases

For this activity, you are going to restore `TPCC100` on **Window2** with a TSQL based snapshot backup of `TPCC100` from **Windows1**. You will by start preparing **Windows2** for this operation by detaching the `TPCC100` database and offlining Disk 1. 

1. **Detach the database and offlne the disk on Windows2**
    - In **SSMS**, connecto to **Windows2** and detach `TPCC100` by right clicking, selecting **Tasks**, and **Detach**
    
        <img src=../graphics/m2/2.4.1.png width="75%" height="75%" >

    - On **Windows2**, open Disk Management and **Offline Disk 1**

        <img src=../graphics/m2/2.3.1.png width="80%" height="80%" >

    <br />
    <br />

1. **Set the database into snapshot mode**
    - On **Windows1**, in **SSMS**, open a **New Query Window** connecting to the **WINDOWS1** SQL Instance and **enter** and **Execute** the following: 
    
        ```
        ALTER DATABASE TPCC100 SET SUSPEND_FOR_SNAPSHOT_BACKUP = ON
        ```

        <img src=../graphics/m2/2.4.2.png>

    <br />
    <br />

1. **Create a Snapshot of the Volume Windows1Vol1**
    - In the **FlashArray Web Interface**, click **Storage, Volumes** and select **Windows1Vol1**. In the **Volume Snapshots** Panel, **click the elipsis** and **select Create**. **Click Create** when prompted.
    
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

1. **Clone the snapshot of Windows1Vol1 to Windows2Vol1**
    - **Click Storage, Volumes, Windows1Vol1**, in the **Volume Snapshot** Panel, **click the eplisis** next to the snapshot you just took and **select Copy**. Enter for the Name **Windows2Vol1**, and move the **Overwrite slider** to the right. **Click Overwrite** when prompted.

        <img src=../graphics/m2/2.4.6.png>
        <img src=../graphics/m2/2.4.7.png width="75%" height="75%" >

    <br />
    <br />

1. **Online Disk 2 on Windows2**
    - On **Windows2**, in **Disk Management**, **online Disk 2**


    <br />
    <br />

1. **Restore the metadata backup on Windows2**
    - On the desktop of **Windows1**, in SSMS, open a **New Query window** connecting to the SQL Instance on **WINDOWS2** and restore the database from snapshot using this code.
     
        ```
        RESTORE DATABASE TPCC100 FROM DISK = 'C:\BACKUP\TPCC100-Replica.bkm' WITH METADATA_ONLY, REPLACE, NORECOVERY
        ```
        
    - In SSMS, refresh the Database listing and you should now see the `TPCC100` database in a `Restoring...` state.

        <img src=../graphics/m2/2.4.8.png>

    <br />
    <br />

1. **Complete the Availability Group Initilization Process**
    Let's complete the remainder of the availbility group intilization process.
    
    - Take a log backup on connected to the SQL instance on **WINDOWS1**. Copy and 
    
        ```
        BACKUP LOG TPCC100 TO DISK = '\\WINDOWS2\BACKUP\\TPCC100-seed.trn' WITH INIT
        ```

        <img src=../graphics/m2/2.4.9.png>

    - Restore the log file on **WINDOWS2** 
    
        ```
        RESTORE LOG TPCC100 FROM DISK = 'C:\BACKUP\TPCC100-seed.trn' WITH NORECOVERY
        ```

        <img src=../graphics/m2/2.4.10.png>

    <br />
    <br />

1. **Create the Availability Group**

    - **Right Click Always On High Availability**, **click New Availability Group Wizard**. On the first page, **click Next**.

        <img src=../graphics/m2/2.4.11.png width="25%" height="25%" >

    - Specify Availability Group Options, enter the following values then **click Next**.

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

    - Once on the Results, review the results, a successful Availabiliy Group initilization will have output similar to the screeshot below. Once finished **click Close**.

        <img src=../graphics/m2/2.4.18.png width="75%" height="75%" >

        <br />
        <br />

1. **Check the state of the Availability Group Replication**
    - **In SSMS Object Explorer, right click on Availbility Group** Select **Show Dashboard**, and then double click on **AG1**.

        <img src=../graphics/m2/2.4.19.png width="25%" height="25%" >

    - With the dashboard loaded, notice that the Availbility group state is **Healty**. Data is activly replicating between the two instances, WINDOWS1 and WINDOWS2. 
    
        <img src=../graphics/m2/2.4.20.png width="75%" height="75%" >

    - WINDOWS2's Synchronization State is in **synchronizing** since the current AG Availbility Mode is Asynchronous. If we changed the Availability Mode to Synchronous for Windows2 the sate will change to Synchronized.


<br />
<br />


# More Resources
- [Seeding an Availability Group Replica from Snapshot](https://www.nocentino.com/posts/2022-05-26-seed-ag-replica-from-snapshot/)



Next, Continue to [SQL Server Object Integration: Backup and Restore](./3-SQLObjectIntegrationBackupRestore.md)

