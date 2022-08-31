![](./../graphics/purestorage.png)

# Workshop: Modern Storage Platforms for SQL Server
<br />

# Module 2 - Storage based snapshots and SQL Server

In this module, you will learn how to use array-based volume snapshots to decouple the time it takes to perform DBA operations from the size of the data. You will restore a database, clone a database and present it back to the same SQL Server instance, clone a database and present it to another SQL Server instance, and initialize a SQL Server AlwaysOn Availability Group from a snapshot. 

There are four activities in this module:

* [In place, restore a database from an array-based snapshot](#21---in-place-restore-a-database-from-an-array-based-snapshot)
* [Cloning a snapshot to a new volume and attaching the database](#22---cloning-a-snapshot-to-a-new-volume-and-attaching-the-database)
* [Cloning a database to another instance of SQL Server](#23---cloning-a-database-to-another-instance-of-sql-server)
* [Seeding an Availability Group from an array-based snapshot (Optional)](./2-StorageSnapshotsForSqlServerAgs.md/#24---seeding-an-availability-group-from-an-array-based-snapshot-optional)

<br />
<br />

# Lab Information

In this module, you have two Windows Servers, each with SQL Server 2022 RC0 installed. Each server has one 20GB volume attached via iSCSI from FlashArray1. This volume is presented to the operating system as `Disk 1` and is mounted as the Drive `D:\`.

| Resource      | FlashArray Volume Name | Windows Disk Number | Windows Drive Letter
| -----------   |  ----  |  :----: |  :----:  |
| Windows1      | Windows1Vol1 | 1           | D:\          |
| Windows2      | Windows2Vol1 | 1           | D:\          |


<br />
<br />


# 2.1 - In place, restore a database from an array-based snapshot

In this activity, you will take a snapshot of a volume that holds the MDF and LDF for the `TPCC100` database. You will then delete a table and use the snapshot to revert the database to the state before the table deletion. 

## **Take a Volume Snapshot**
- [ ] Open the FlashArray Web interface. And browse to **Storage**, **Volumes**. In the Volumes pane, click **Windows1Vol1**.

    <img src=../graphics/m2/2.1.1.png width="75%" height="75%" >

- [ ] Next, in the **Volume Snapshots** panel, click the **ellipsis**. Then click **Create** to create a snapshot of the volume. Then click **Create** on the popup screen to create the snapshot. 

    <img src=../graphics/m2/2.1.2.png width="75%" height="75%" >

    Once complete, the snapshot will appear in the listing. The snapshot name includes the Volume name, a dot, and suffixed with an auto-incrementing, unique integer.

    <img src=../graphics/m2/2.1.3.png width="75%" height="75%" >

<br />
<br />

## **Delete a Database Table**
- [ ] Open **SSMS**, and **browse** to the TPCC100 database, expand tables and delete the `customer` table by **right clicking** on the table and clicking **Delete**. **Click OK** to confirm.

    <img src=../graphics/m2/2.1.4.png width="50%" height="50%" >
<br />
<br />

## **Set the Database Offline**    
To recover the database, we need to change the database state to offline.

- [ ] **Right click** on the database, click **Tasks**, click **Take Offline**. Check the box to **Drop All Active Connections** and **click OK** to confirm.

    <img src=../graphics/m2/2.1.5.png width="75%" height="75%" >

<br />
<br />

## **Offline the Volume Supporting the Database** 
Snapshots are Volume based operations. So to restore a Volume from a snapshot, you must first offline the volume. 

- [ ] To offline a Volume, **Open Disk Management** on the Windows1 Desktop.

    <img src=../graphics/m2/2.1.6.png  width="90" height="100" >

- **Right click** on Disk 1 and **click Offline**.

    <img src=../graphics/m2/2.1.7.png width="25%" height="20%" >

<br />
<br />

## **Restore the Volume to a Previous Snapshot**
- [ ] **Open the FlashArray Web Interface** and **browse back to the Volume Windows1Vol1**. Click on the **ellipsis** next to the snapshot you took at the start of this activity in the Volume Snapshots panel and **click Restore**. 

This reverts the volume's contents to the state captured in the snapshot. Undoing our 'accidental' table deletion.

<img src=../graphics/m2/2.1.8.png width="75%" height="75%" >

<br />
<br />

## **Online the Volume Supporting the Database**
- [ ] **Open Disk Management** back up, **right click** on Disk 1 and **click Online**.

    <img src=../graphics/m2/2.1.9.png width="25%" height="25%" >

<br />
<br />

## **Online the Database**
- [ ] In **SSMS**, right-click on the database, click Tasks, and click Bring Online. 

    <img src=../graphics/m2/2.1.10.png width="75%" height="75%" >

<br />
<br />

## **Verify the Restore**
- [ ] Refresh the table listing by expanding the database, **expanding tables, right-clicking on Tables, and selecting Refresh**. The `customer` table should now be in the table listing.

    <img src=../graphics/m2/2.1.11.png width="50%" height="50%" >

<br />
<br />

## Activity Summary

***Congratulations, you just restored an entire 10GB database in a matter of seconds without having to restore from a backup which can take a little bit longer :P***

<br />
<br />

# 2.2 - Cloning a snapshot to a new volume and attaching the database

But restoring the entire database to recover one missing table seems a little heavy-handed. Let's try another technique to restore data from the database. In this activity, you will clone the snapshot we took in the first activity to a new volume. You will then attach the database files from that new volume to a new databases name. This way, our primary database can stay online during the recovery process. 

When you clone a volume and present it to a host, it does not consume space until data starts changing. Then each of the changed blocks is tracked and exposed as a performance metric on the FlashArray Web Interface Dashboard and Array Capacity panel.

## **Create a New Volume**
- [ ] Log into the FlashArray Web Interface, and **Click Storage**, **Volumes**.

- [ ] In the **Volumes** Panel, click the **+** to create a new volume

    <img src=../graphics/m2/2.2.1.png>

- [ ] Enter the name **Windows1Vol2**, enter **20GB** for the size. 

    <img src=../graphics/m2/2.2.2.png width="75%" height="75%" >

<br />
<br />

## **Copy a snapshot to a Volume**
- [ ] In the **Volumes** Panel, select **Windows1Vol1**

    <img src=../graphics/m2/2.2.8.png>

- [ ] In the **Volumes Snapshots** Panel, find the snapshot you created in the activity above; its name will be **Windows1Vol1.*n***, where n is a number. **Click the ellipsis** next to that snapshot and **click Copy**.

    <img src=../graphics/m2/2.2.9.png  width="75%" height="75%" >

- [ ] For the **Name, enter Windows1Vol2**. This is the new volume we just created. Move the **Overwrite slider to the right** and **click Copy**.

    <img src=../graphics/m2/2.2.10.png width="75%" height="75%" >

- [ ] When the warning appears, **click Overwrite**. At this point, the contents of Windows1Vol1 are cloned into Window1Vol2. There is now a unique clone of the original volume. The contents of this cloned volume, such as the database files, can be attached to our server.

    <img src=../graphics/m2/2.2.11.png width="75%" height="75%" >

<br />
<br />

## **Connect the new Volume to Window1**
- [ ] In the **Volumes** Panel, click on **Windows1Vol2**

    <img src=../graphics/m2/2.2.3.png>

- [ ] In the **Connected Hosts** Panel, **click the elipsis**, and click **Connect**.

    <img src=../graphics/m2/2.2.4.png width="75%" height="75%" >

- [ ] Then in the **Available Hosts** column, **select windows1**, and **click Connect**.
    <img src=../graphics/m2/2.2.5.png width="75%" height="75%" >

<br />
<br />

## **Online the Disk**
- [ ] In **Disk Management**, **right click on Disk 2** and **online the volume**.  
    <img src=../graphics/m2/2.2.12.b.png width="25%" height="25%" >

    - If Disk 2 doesn't show up, click Action, Refresh.

        <img src=../graphics/m2/2.2.12.a.png width="25%" height="25%" >

    - Once Disk 2 is online, you can see that the volume label is the same as Disk 1 since this is an exact clone of the volume inside the array.

        <img src=../graphics/m2/2.2.12.png   width="75%" height="75%" >

- [ ] Open Windows explorer and browse to `E:\`. You should see a copy of the contents from the `D:\` volume. In this case, it's our database and log files, which we can now attach as a unique database in our SQL Instance.

    <img src=../graphics/m2/2.2.13.png width="75%" height="75%" >

<br />
<br />

## **Attach the database**
- In SSMS, you can now attach the databases and change the name to `TPCC100_RESTORE`.

    - [ ] Right-click on the Databases folder in the SSMS Object Explorer
        
        <img src=../graphics/m2/2.2.14.png width="75%" height="75%" >

    - [ ] Click **Add**

        <img src=../graphics/m2/2.2.14.a.png width="75%" height="75%" >

    - [ ] **Browse** to `E:\SQL`, select `tpcc100.mdf`, and **click OK**.

        <img src=../graphics/m2/2.2.15.png width="75%" height="75%" >

    - [ ] Enter `TPCC100_RESTORE` in the **Attach As** field and click **OK**.

        <img src=../graphics/m2/2.2.16.png width="75%" height="75%" >

    - [ ] Finally, **right-click on Databases** in Object Explorer and click **Refresh** to see the newly attached database in the list.

        <img src=../graphics/m2/2.2.17.png width="40%" height="40%" >

<br />
<br />

## Activity Summary

You now have the original database `TPCC100` on the D:\ drive with the missing `customer` table. You did not have to take this database offline for this operation. You also have a clone of the original snapshot we took before we deleted the customer table in the `TPCC100_RESTORE` attached database. You can now use any method you copy the customer table from `TPCC100_RESTORE` back into the original  `TPCC100` database, and you can do this without taking the database offline.

<br />
<br />

# 2.3 - Cloning a database to another instance of SQL Server
You will clone volume from **Windows1** to **Windows2**in this activity. You will then attach the contents of that cloned volume, the `TPCC100` database, on the target instance, **Windows2**. Saving the need to back up and restore the database. Since this operation is inside the array, it happens nearly instantaneously. 

When you clone a volume and present it to another host, it does not consume space until data starts changing. Then each of the changed blocks is tracked and exposed as a performance metric on the FlashArray Web Interface Dashboard and Array Capacity panel.

## **Offline the Disk on Windows2**

- [ ] Log into the **Window2** virtual machine's desktop
- [ ] Launch **Disk Management** on the desktop and **Offline Disk 1** by **right clicking** on Disk 1 and **selecting Offline**.

    <img src=../graphics/m2/2.3.1.a.png width="80%" height="80%" >

- [ ] Once finished, you can see the status of Disk 1 is now, Offline.

    <img src=../graphics/m2/2.3.1.png width="80%" height="80%" >

<br />
<br />

## **Clone Windows1Vol1 Snapshot to the Volume attached to Windows2**

- [ ] Back on **Windows1**, **open the FlashArray Web Interface**, and click on **Storage, Volumes** and select **Windows1Vol1** from the listing.

    <img src=../graphics/m2/2.3.2.png>

- [ ] In the **Volumes Snapshots** Panel, find the snapshot you created in the first activity in this module; its name will be **Windows1Vol1.*n***, where n is a number. Click the **vertical ellipsis** and **select Copy**. 

    <img src=../graphics/m2/2.3.3.png width="75%" height="75%" >

- [ ] For the Name, enter **Windows2Vol1**, and move the **Overwrite slider** to the right. **Click Copy.** When the warning appears, click **Overwrite**.

    <img src=../graphics/m2/2.3.4.png width="75%" height="75%" >

<br />
<br />

## **Online the disk on Windows2**
- [ ] Back on **Window2**, in **Disk Management**, **online Disk 1**.

- [ ] **Open** Windows Explorer and **browse** to `D:\`; you should now see the database files for `TPCC100` from the snapshot of Windows1.

<br />
<br />

## **Attach the database**

- [ ] Back on the **Windows1** desktop, use **SSMS** to connect to the SQL Instance running on **Windows2**.

    <p align="center">
        <img src=../graphics/m2/2.3.5.png width="75%" height="75%" >
    </p>

- In SSMS, you can now attach the database files from `D:\` with the name `TPCC100`.

    - [ ] **Right-click** on the Databases folder in the SSMS Object Explorer

        <img src=../graphics/m2/2.3.6.png width="40%" height="40%" >

    - [ ] Click **Add**

        <img src=../graphics/m2/2.3.7.a.png width="75%" height="75%" >

    - [ ] **Browse** to `D:\SQL`, select `tpcc100.mdf`, and **click OK**.

        <img src=../graphics/m2/2.3.7.png   width="75%" height="75%" >

    - [ ] **Click OK** to attach the database.

        <img src=../graphics/m2/2.3.8.png width="75%" height="75%" >

    - [ ] Finally, **right-click on Databases** in Object Explorer and click **Refresh** to see the newly attached database in the list.

        <img src=../graphics/m2/2.3.9.png width="40%" height="40%" >



## Activity Summary

In this demo, you copied, nearly instantaneously, a 10GB database between two instances of SQL Server. This snapshot does not take up any additional space in the array since the shared blocks between the volumes will be data reduced. Any changed blocks are reported as Snapshot space in the FlashArray Web Interface Dashboard on the Array Capacity panel.

<br />
<br />

# Next Steps

Optionally, continue to [Seeding an Availability Group from an array-based snapshot](./2-StorageSnapshotsForSqlServerAgs.md)

Or move onto the next lab, [SQL Server Object Integration: Backup and Restore](./3-SQLObjectIntegrationBackupRestore.md)

