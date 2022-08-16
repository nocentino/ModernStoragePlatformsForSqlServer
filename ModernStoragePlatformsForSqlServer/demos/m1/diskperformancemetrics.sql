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