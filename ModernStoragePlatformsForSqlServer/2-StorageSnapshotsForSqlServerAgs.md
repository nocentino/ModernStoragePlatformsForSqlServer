![](./../graphics/purestorage.png)

# Workshop: Modern Storage Platforms for SQL Server
<br />

# Module 2 - Storage based snapshots and SQL Server (con't)

In this module, you will learn how to use array-based volume snapshots to decouple the time it takes to perform DBA operations from the size of the data. You will restore a database, clone a database and present it back to the same SQL Server instance, clone a database and present it to another SQL Server instance, and initialize a SQL Server AlwaysOn Availability Group from a snapshot. 

There are four activities in this module: 

* [In place, restore a database from an array-based snapshot](./2-StorageSnapshotsForSqlServer.md/#21---in-place-restore-a-database-from-an-array-based-snapshot)
* [Cloning a snapshot to a new volume and attaching the database](./2-StorageSnapshotsForSqlServer.md/#22---cloning-a-snapshot-to-a-new-volume-and-attaching-the-database)
* [Cloning a database to another instance of SQL Server](./2-StorageSnapshotsForSqlServer.md/#23---cloning-a-database-to-another-instance-of-sql-server)
* [Seeding an Availability Group from an array-based snapshot (Optional)](./#24---seeding-an-availability-group-from-an-array-based-snapshot-optional)

<br />
<br />

# Lab Information

In this activity, you will work primarily from the **Windows1** desktop, and it will become a primary replica in the availability group you will create in this lab. **Windwows2** will become a secondary replica in the availability group. FlashArray1 is the primary block storage for both instances of SQL Server.


| Resource      | Description |
| -----------   | ----------- |
| **Windows1**  | **Primary administrator desktop and SQL Server Instance become an availability group primary replica** |
| Windows2      | SQL Server Instance this will become an availability group secondary replica |
| FlashArray1   | Primary block storage device and storage subsystem for SQL Server instances |

<br />
<br />

# 2.4 - Seeding an Availability Group from an array-based snapshot (Optional)
In this activity, you will build an Availability Group from Snapshot leveraging FlashArray snapshots and the new [TSQL Based Snapshot Backup](https://docs.microsoft.com/en-us/sql/relational-databases/backup-restore/create-a-transact-sql-snapshot-backup?view=sql-server-ver16) functionality in SQL Server 2022.

If you’ve been using Availability Groups, you’re familiar with the process of replica seeding (sometimes called initializing, preparing, or data synchronization). Seeding is a size of data operation, copying data from a primary replica to one or more secondary replicas. This is required before joining a database to an Availability Group. You can seed a replica with backup and restore, or with automatic seeding, each of which present their own challenges. Regardless of which method you use, the seeding operation can take an extended amount of time. The time it takes to seed a replica is based on the database's size, network, and storage speed. If you have multiple replicas, then seeding all of them is N times the fun!

But what if I told you that you could seed your Availability Group replicas from a storage-based snapshot and that the reseeding process can be nearly instantaneous?

In addition to saving you time, this process saves your database systems from the CPU, network, and disk consumption that comes with using either automatic seeding or backups and restores to seed. 

So let’s do it…we’re going to snapshot a database on **Windows1**, clone that snapshot to the second instance of SQL Server on **Windows2**, and seed an Availability Group replica from that. 

An overview of the process
* [Prepare the secondary replica](#prepare-the-secondary-replica)
* [Take a snapshot backup of TPCC100 on Windows1](#take-a-snapshot-backup-of-tpcc100-on-windows1)
* [Restore the snapshot backup to Windows2](#restore-the-snapshot-backup-to-windows2)
* [Complete the Availability Group Initialization Process](#complete-the-availability-group-initilization-process)
* [Create the Availability Group](#create-the-availability-group)
* [Check the state of the Availability Group Replication](#check-the-state-of-the-availability-group-replication)

# Prepare the secondary replica

In this activity, you will start preparing **Windows2** for this operation by detaching the `TPCC100` database and offlining Disk 1. 

## **Detach the database and offline the disk on Windows2**
- [ ] In **SSMS**, connect to **Windows2** and detach `TPCC100` by right-clicking, selecting **Tasks**, and **Detach**

    <img src=../graphics/m2/2.4.1.png width="75%" height="75%" >

- [ ] On **Windows2**, open Disk Management and **Offline Disk 1**

    <img src=../graphics/m2/2.3.1.png width="80%" height="80%" >

<br />
<br />

# Take a snapshot backup of TPCC100 on Windows1

Next, you will take a TSQL-based snapshot backup of `TPCC100` on **Windows1**. To do this, you must put the database in SUSPEND_FOR_SNAPSHOT_BACKUP mode to prepare it for the snapshot backup. This operation puts the database files in a consistent state and freezes IO inside the database.

## **Set the database into snapshot mode**
- [ ] On **Windows1**, in **SSMS**, open a **New Query Window** connecting to the **WINDOWS1** SQL Instance and **enter** and **Execute** the following: 

    ```
    ALTER DATABASE TPCC100 SET SUSPEND_FOR_SNAPSHOT_BACKUP = ON
    ```

    <img src=../graphics/m2/2.4.2.png>

<br />
<br />

## **Create a Snapshot of the Volume Windows1Vol1**

With the database in `SUSPEND_FOR_SNAPSHOT_BACKUP` mode, you can take a snapshot inside the array. This will be an application consistent snapshot. While we are doing this in the Web Interface today, you can script these actions out to minimize the duration of the IO freeze. 

- [ ] In the **FlashArray Web Interface**, click **Storage, Volumes** and select **Windows1Vol1**. In the **Volume Snapshots** Panel, **click the ellipsis** and **select Create**. **Click Create** when prompted.

    <img src=../graphics/m2/2.4.3.png>
    <img src=../graphics/m2/2.4.4.png width="75%" height="75%" >

<br />
<br />

## **Create the metadata backup file**

Now that you have a snapshot inside the array, you can take a `METADATA_ONLY` backup inside SQL Server. When this backup finishes successfully, the database is thawed, and IO can resume.

- [ ] In **SSMS**, open a **New Query Window** connecting to the **WINDOWS1** SQL Instance and **enter** and **Execute** the following: 

    ```
    BACKUP DATABASE TPCC100 TO DISK='\\WINDOWS2\BACKUP\TPCC100-Replica.bkm' WITH METADATA_ONLY, INIT
    ```

    <img src=../graphics/m2/2.4.5.png>

<br />
<br />

# Restore the snapshot backup to Windows2

Now it is time to restore the snapshot backup to Windows2. Inside the array, we have an application consistent backup. We also have the backup file that has the metadata that describes what's in the snapshot backup. Those two together allow you to restore a database from a snapshot in an application consistent way.

## **Clone the snapshot of Windows1Vol1 to Windows2Vol1**

The snapshot backup we took in the previous can now be clone to a second volume inside the array. So let's clone that snapshot and overwrite the contents of the data volume on **Windows2Vol1* this is the `D:\` drive on **Windows2**. 

- [ ] **Click Storage, Volumes, Windows1Vol1**, in the **Volume Snapshot** Panel, **click the ellipsis** next to the snapshot you just took and **select Copy**. Enter the Name **Windows2Vol1**, and move the **Overwrite slider** to the right. **Click Overwrite** when prompted.

    <img src=../graphics/m2/2.4.6.png>
    <img src=../graphics/m2/2.4.7.png width="75%" height="75%" >

<br />
<br />

## **Online Disk 2 on Windows2**

With the contents of the snapshot cloned to **Windows2's **volume, let's online the disk on *Windows2*

- [ ] On **Windows2**, in **Disk Management**, **online Disk 2**

<br />
<br />

## **Restore the metadata backup on Windows2**

Now that the volume is online on **Windows2**, the volume's contents include the application consistent snapshot backup database files. We can now restore the database from the backup metadata file and leave the database in recovery mode. This means we can use this database to initialize a secondary replica of an availability group. 

- [ ] On the desktop of **Windows1**, in SSMS, open a **New Query window**. Connect to the SQL Instance on **WINDOWS2** and restore the database from the snapshot using this code.
    
    ```
    RESTORE DATABASE TPCC100 FROM DISK = 'C:\BACKUP\TPCC100-Replica.bkm' WITH METADATA_ONLY, REPLACE, NORECOVERY
    ```
    
- [ ] In SSMS, refresh the Database listing, and you should now see the `TPCC100` database in a `Restoring...` state.

    <img src=../graphics/m2/2.4.8.png>

<br />
<br />

# Complete the Availability Group Initialization Process

Let's complete the remainder of the availability group initialization process. This requires taking a regular log backup on the soon to be primary replica **WINDOWS1** and restoring that log backup on the secondary replica **WINDOWS2**.
    
- [ ] Take a log backup connected to the SQL instance on **WINDOWS1**. Copy and 

    ```
    BACKUP LOG TPCC100 TO DISK = '\\WINDOWS2\BACKUP\\TPCC100-seed.trn' WITH INIT
    ```

    <img src=../graphics/m2/2.4.9.png>

- [ ] Restore the log backup on **WINDOWS2**, leaving the database in recovery mode.

    ```
    RESTORE LOG TPCC100 FROM DISK = 'C:\BACKUP\TPCC100-seed.trn' WITH NORECOVERY
    ```

    <img src=../graphics/m2/2.4.10.png>

<br />
<br />

# Create the Availability Group

Now that the databases on both replicas are initialized to the proper state, you can create the availability group. This traditionally would require you to do a full backup and restore or use direct seeding, which is a size of data operation. In this activity, we will instantly initialize the availability group from the snapshot backup.

- [ ] **Right Click Always On High Availability**, **click New Availability Group Wizard**. On the first page, **click Next**.

    <img src=../graphics/m2/2.4.11.png width="25%" height="25%" >

- [ ] Specify Availability Group Options, enter the following values, then **click Next**.

    - **Availability Group Name:** AG1
    - **Cluster Type:** NONE

    <img src=../graphics/m2/2.4.12.png width="75%" height="75%" >

- [ ] **Check the checkbox** for `TPCC100` to add it to the AG, **click Next**.

    <img src=../graphics/m2/2.4.13.png width="75%" height="75%" >

- [ ] Click **Add Replica**, enter **WINDOWS2** for the serve rname, **click Connect**, **click Next**.

    <img src=../graphics/m2/2.4.14.png width="75%" height="75%" >

- [ ] For Data Synchronization Mode, **select Join Only, click Next**.

    <img src=../graphics/m2/2.4.15.png width="75%" height="75%" >

- [ ] On the Validation screen, **click Next**. 

    <img src=../graphics/m2/2.4.16.png width="75%" height="75%" >

- [ ] On the summary screen, **click Finish**.

    <img src=../graphics/m2/2.4.17.png width="75%" height="75%" >

- [ ] Once on the Results, review the results, and a successful Availability Group initialization will have output similar to the screenshot below. Once finished **click Close**.

    <img src=../graphics/m2/2.4.18.png width="75%" height="75%" >

    <br />
    <br />

# Check the state of the Availability Group Replication

In this activity, you will check the state of the availability group using the Availability Group Dashboard.


- [ ] **In SSMS Object Explorer, right-click on Availability Group** Select **Show Dashboard**and double-click on **AG1**.

    <img src=../graphics/m2/2.4.19.png width="25%" height="25%" >

- [ ] With the dashboard loaded, notice that the Availability group state is **Healthy**. Data is actively replicating between the two instances, WINDOWS1 and WINDOWS2. 

    <img src=../graphics/m2/2.4.20.png width="75%" height="75%" >

### Notes

WINDOWS2's Synchronization State is in **synchronizing** since the current AG Availability Mode is Asynchronous. If we change the Availability Mode to Synchronous for Windows2, the state will change to Synchronized.

## Activity Summary

In this activity, you initialized an availability group using TSQL-based snapshots inside SQL Server with array-based snapshots in FlashArray, nearly instantaneously. Traditional availability group initialization or reseeding requires a size of data operation via either backup and restore or direct seeding. 

There's one nuance I want to call out here in this activity. This all happened on one array in our test lab. You will likely want your availability group replicas on separate arrays in a production environment. If you want to dive into the details of that, check out the post in the More Resources section below.

<br />
<br />


# More Resources
- [Seeding an Availability Group Replica from Snapshot](https://www.nocentino.com/posts/2022-05-26-seed-ag-replica-from-snapshot/)

<br />
<br />

# Next Steps

Next, Continue to [SQL Server Object Integration: Backup and Restore](./3-SQLObjectIntegrationBackupRestore.md)

