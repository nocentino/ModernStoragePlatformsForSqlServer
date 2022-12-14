![](graphics/purestorage.png)

# Workshop: Modern Storage Platforms for SQL Server

#### <i>A Course from the Pure Storage Field Solution Architecture team</i>

<br />
<br />


# About this Workshop

Welcome to this Microsoft solutions workshop on Modern Storage Platforms for SQL Server. In this workshop you will learn how to make the most of a modern storage platform for SQL Server. You will learn storage fundamentals and how to leverage snapshots enabling you to dramatically reduce the time it takes data to move between SQL Server instances. We’ll then dive into modern storage architectures with using s3 object storage for backup, restore and data virtualization. 

The focus of this workshop is to understand where storage lives in your data platform and learn how to use modern storage techniques to reduce the overhead and complexity of managing data in your enviroment.

You'll start by logging into a virtual lab enviroment using your own laptop, then work through a module covering storage fundamentals, leveraging sanpshots to reduce time it takes to manage your databases, and how use use s3 object storage for backup, restore and data virtualization. 

# Learning Objectives

The goal of this workshop is to train data professionals on the basics of storage infrastructure and how to use storage subsystems to manage data.

In this workshop you'll learn:

- Storage fundamentals for the DBA
- How to use snapshots to reduce the time it takes to move data between SQL Server instances
- How to use SQL Server 2022's s3 object integration for database backup and restore, along with data virtualizations

The concepts and skills taught in this workshop form the starting points for:

- Technical professionals tasked with managing data and databases
- Data professionals tasked with complete or partial responsibility for database management and availability

<br />
<br />

# Business Applications of this Workshop

Businesses require access to data. The techniques described in this workshop enable data professionals the ability to decouple the size of the databases from the operations needed to be performant. 


<br />
<br />

# Technologies used in this Workshop

The workshop includes the following technologies which form the basis of the workshop. At the end of the workshop you will learn how to extrapolate these components into other solutions, solutions which are not solely limited to the technologies used in the lab. You will cover these at an overview level, with references to much deeper training provided.


| Syntax      | Description |
| ----------- | ----------- |
| Microsoft Windows Operating System	 | This workshop uses the Microsoft Windows operating system |
| Microsoft SQL Server RC0 | In this workshop you will protect, copy, clone and build high availability databases on SQL Server |
| Pure Storage FlashArray	 | This workshop uses a Pure Storage FlashArray as a block device as a storage subsystem for SQL Server |
| Pure Storage FlashBlade	 | This workshop uses a Pure Storage FlashBlase as a object storage device as external object storage used by SQL Server  |

<br />
<br />

# Before Taking this Workshop

You'll need a local system with a modern web browser, Chrome is preferred. You will access Windows based virtual machines running SQL Server in a browser based lab enviroment.

This workshop expects that you understand:
* SQL Server relational database fundamentals - for example, that databases are made of data and log files that are stored on disks
* Basic TCP/IP networking - for example, you know what an IP address is

<br />
<br />

# Workshop Modules


| Module Description |  Topics Covered | Duration
| ----------- | ----------- | ----------- | 
| [1 - Storage fundamentals for DBAs](./ModernStoragePlatformsForSqlServer/1-StorageFundamentalsForDBAs.md) | Explain where data lives in a computer system, and the key performance metrics used to understand the health and performance of your storage subsystem. | 45 mins |
| [2 - Storage based snapshots and SQL Server](./ModernStoragePlatformsForSqlServer/2-StorageSnapshotsForSqlServer.md) | Explain storage based snapshots, distinguish between the two types of snapshots: crash consistent and application consistent, and explore the use cases for each. We’ll look at how to restore a database, copy a database and also seed an Availability Group replica, all nearly instantaneously. | 70 mins | 
| [3 - SQL Server Object Integration: Backup and Restore](./ModernStoragePlatformsForSqlServer/3-SQLObjectIntegrationBackupRestore.md) | Get started with using S3 compatible object storage for backups. We’ll discuss why this is an important feature, how to configure backups to S3 and performance tuning considerations. | 35 mins
| [4 - SQL Server Object Integration: Data Virtualization](./ModernStoragePlatformsForSqlServer/4-SQLObjectIntegrationDataVirtualization.md) | Describe and show how to use SQL Server 2022’s S3 object integration to access data outside of SQL Server in various storage formats such as parquet and CSV. Using this technique you can easily access datasets in various formats to enable analytics scenarios. | 45 mins

In each of the modules, anywhere you see a - [ ], there is an activity you need to perform.


<br />
<br />

# Next Steps

Next, Continue to [Storage fundamentals for DBAs](./ModernStoragePlatformsForSqlServer/1-StorageFundamentalsForDBAs.md)

