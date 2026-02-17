--ROLES & SECURITY
--Create Login
CREATE LOGIN ERPUser WITH PASSWORD = 'Erp@12345';

--Create User
USE ERPDB;

CREATE USER ERPUser FOR LOGIN ERPUser;

--Create Role
CREATE ROLE ERP_ReadOnly;

GRANT SELECT ON SCHEMA::Sales TO ERP_ReadOnly;
GRANT SELECT ON SCHEMA::Master TO ERP_ReadOnly;

EXEC sp_addrolemember 'ERP_ReadOnly', 'ERPUser';