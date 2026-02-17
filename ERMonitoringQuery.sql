--MONITORING QUERIES

--Check Database Size
USE ERPDB;
GO
EXEC sp_spaceused;

--To Check All Database Sizes (DBA Method)
EXEC sp_MSforeachdb 'USE ?; EXEC sp_spaceused;';

--Best Professional Way (More Accurate)
SELECT 
    name AS DatabaseName,
    size*8/1024 AS SizeMB
FROM sys.master_files
WHERE type = 0;


--Top 10 Slow Queries
SELECT TOP 10
    total_worker_time/execution_count AS AvgCPU,
    execution_count,
    SUBSTRING(st.text,1,200) AS QueryText
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY AvgCPU DESC;

