![](./../graphics/purestorage.png)

# Workshop: Modern Storage Platforms for SQL Server

#### <i>A Course from the Pure Storage Field Solution Architecture team</i>

## Module 2 - Storage based snapshots and SQL Server


# 1.1 - Restore a database from an array-based snapshot
In this activity, you will take a snapshot of a volume that holds both the MDF and LDF of a database. You will then delete a table and use the snapshot to revert the database back to the state prior to the table deletion.

- In the [`demos/m1`](./demos/m2/) folder, open the script [`1-SingleVolumeSnapshot.ps1`](./demos/m2/1-SingleVolumeSnapshot.ps1).
- This script performs the following steps, run each script line by line by right right clicking and selecting run selected text or use the F8 key.
- Take volume snapshot
- Delete table in database
- offline the database
- offline the volume supporting the database
- Revert to the previous snapshot
- online the volume supporting the database
- online the database

But that seems a little heavy handed, let's try cloning the snapshot to a volume and then attaching the database
- Log into the FlashArray Web Interface
- Click Storage, Volumes
- Click the + to create a new volume and enter the name Windows1Vol2, enter 20GB for the size. 
- Click on that Volume
- In the Conntected Hosts panel, click the vertical three dots, and in the Available Hosts column, select windows1, and click Connect.
- Open the Disk Management icon on the desktop.
- You will now see Disk 2, right click select online, right click again select Initialize, and leave the settings default and click OK.
- Format the volume - Right click, select New Simple Volume and then click Next, leave the volume size default and click Next, leave the drive letter as E and click next, select 64k for the Allocation Unit Size, and change the Volume label to SQLDATA2, click Next and Finish
- Right click on Disk 2 and select offline
- In the FlashArray Web Interface, click Storage, Volumes, and select Windows1Vol1
- In the volumes Snapshots panel, find the snapshot you created in the activity above, its name will be Windows1Vol1.n where n is a number. Click the vertical three dots and select copy. 
- For the Name, enter Windows1Vol2. This is the new volume attached to Windows2 that you just initialized and formated. 
- Click the Overwrite slider to the right.
- Click Copy. When the warning appears click Overwrite.
- Back in Disk Management, right click on Disk 2 and online the volume. 
- Open Windows explorer and browse to E:\ you should see an exact copy of the D:\ volume. 
- In SSMS, you can attach the databases. Change the name to TPCC100_RESTORE.
- Now you can use any method you like to get missing table back into the original database TPCC100 and you didn't have to take the original database offline
- When you're finished, detach the database and set Disk 2 offline in Disk Management
- Back in the FlashArray Web Interface, click on Storage, Volumes, Windows1Vol2
- Disconnect the host
- Destroy the Volume
- You will still have this volume around for 24 hours, click the drop down Destroyed. You can bring this Volume back if needed.

# 1.2 - Clone a database to another instance of SQL Server
In this activity, you will clone a volume to a new instance of SQL Server. You can then attach the database on the target instance. Saving the need to backup and restore the database.

- Log into the Window2 virtual machine and launch Disk Management on the desktop.
- Offline Disk 2
- Back on Windows1, open the FlashArray Web Interface, and click on Storage, Volumes, Windows1Vol1.
- In the volumes Snapshots panel, find the snapshot you created in the activity above, its name will be Windows1Vol1.n where n is a number. Click the vertical three dots and select copy. 
- For the Name, enter Windows2Vol1, and move the Overwrite slider to the right. Click Copy. When the warning appears click Overwrite.
- Back on Window2, in disk management, online Disk 2.
- Right Click on the Volume, click open, you should now see the database files for TPCC100 from the clone of Windows1.
- Back on Windows1, in SSMS, connect to Windows2, and attache the databases
- Once complete, in SSMS on Windows1 detach the database, and on Windows2, offline the volume. This step is needed for the next demo

# 1.3 - Seed an Availability Group from an array-based snapshot
In this activity, you will build an Availability Group from Snapshot.

## Set up the databases

- On Windows1, in SSMS, open a New Query Window and enter `ALTER DATABASE TPCC100 SET SUSPEND_FOR_SNAPSHOT_BACKUP = ON`
- In the FlashArray Web Interface, create a snapshot of Windows1Vol1
- In SSMS, open a New Query Window and enter `BACKUP DATABASE TPCC100 TO DISK='C:\BACKUP\TPCC100-Replica.bkm' WITH METADATA_ONLY`
- Copy this file to \\WINDOWS2\BACKUP\
- In the FlashArray Web Interface, clone the snapshot to overwrite the database volume on Window2. Click Storage, Volumes, Windows1Vol1, in the snapshot panel, select the snapshot you just made, click the three vertical dots and select copy. Enter for the Name Windows2Vol1, and move the overwrite slider to the right.
- On Windows2, in Disk Management, online Disk 2

- On Windows1, in SSMS, open a New Query window and restore the database from snapshot
RESTORE DATABASE TPCC100 FROM DISK = 'C:\BACKUP\TPCC100-Replica.bkm' WITH METADATA_ONLY, REPLACE, NORECOVERY
- In SSMS, you should now see the TPCC100 database in a Restoring state.
- Let's complete the remainder of the availbility group intilization process.
- Take a log backup on WINDOWS1 with `BACKUP LOG TPCC100 TO DISK = 'C:\BACKUP\TPCC100-seed.trn' WITH FORMAT`
- Copy this file to \\WINDOWS2\BACKUP\
- Restore the log file on Window2 `RESTORE LOG TPCC100 FROM DISK C:\BACKUP\TPCC100-seed.trn WITH NORECOVERY`

## Create the Availability Group
- Right Click Always On High Availability, click New Availability Group Wizard.
- Availability Group Name: AG1
- Cluster Type: NONE
- Check the checkbox for TPCC100 to add it to the AG, click next
- Click Add Replica, enter WINDOWS2, click CONNECT, click Next.
- For Data Synchronizatoin Mode, select Join Only, click Next
- On the Validation screen, click next. 
- On the summary screen, click Finish.


TODO - ACTIVITY

# More Resources
- one
- one
- one

---

Next, Continue to [SQL Server Object Integration: Backup and Restore](./3-SQLObjectIntegrationBackupRestore.md)

