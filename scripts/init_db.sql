/*
========================================================================
Create the Database (DW) and its Schemas
========================================================================
Script Purpose:
	This script creates a new database name 'DataWarehouse' after checking if it is already exists.
	If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas within the database: bronze, silver, and gold.

***** WARNING: *****
	Running this script will drop the entire 'Datawarehouse' database if it exists.
	All data in the database will be permentaly deleted. Proceed with caution and ensure you have proper backups before running this script.

*/

------------------------------------------------------------------------
-- user master system db to be able to create the db
USE master;
GO -- a batch separator /* finish this batch then run the next */



/****** BE CAREFUL WITH NEXT IF STATEMENT LINES ******/

-- Check if db name Exists, make single_user, close any connection, and rollback transactions
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	
	ALTER DATABASE DataWarehouse -- edit db to:
	SET SINGLE_USER -- to make sure none is using it
	WITH ROLLBACK IMMEDIATE; -- to close any open connection & Rollback any happening transactions
	
	DROP DATABASE DataWarehouse; -- Drop db

END
GO

-- Create the DW using model system db
CREATE DATABASE DataWarehouse;
GO

-- use the created db (DW) to start creating its objects
USE DataWarehouse;
GO

-- create schemas for approach Layers (bronze, silver, and gold)
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO

