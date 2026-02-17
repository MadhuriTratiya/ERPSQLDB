--Performace Tuning
--Check Missing Index
SELECT *
FROM sys.dm_db_missing_index_details;

--Update Statistics
EXEC sp_updatestats;

--Rebuild Indexes
EXEC sp_MSforeachtable 'ALTER INDEX ALL ON ? REBUILD';
