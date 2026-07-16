# sql-data-warehouse-project

Project Overview

This project demonstrates the complete data analytics workflow, from importing raw data and building a structured data warehouse to analyzing the data and generating business insights.

The project includes:

Data extraction from multiple source files
Data cleaning and transformation
Data warehouse development
Star schema data modeling
SQL-based exploratory data analysis
Business-focused data analysis
Reporting and visualization

The goal of this project is to transform raw and unorganized data into reliable, analysis-ready datasets that can support business decision-making.

Project Objectives

The main objectives of this project are to:

Build a structured SQL data warehouse.
Combine data from multiple source systems.
Clean and standardize inconsistent data.
Create fact and dimension tables for reporting.
Analyze customer, product, and sales performance.
Answer realistic business questions using SQL.
Present findings through reports or dashboards.
Project Architecture

The project follows the Medallion Architecture using three data layers:

Bronze Layer

The Bronze layer stores the raw data exactly as it was received from the source systems.

Main tasks:

Create raw data tables
Import CSV files into SQL
Preserve the original source data
Add load dates or source information when necessary
Silver Layer

The Silver layer contains cleaned and standardized data.

Main tasks:

Remove duplicate records
Handle missing values
Correct invalid data
Standardize names, categories, and codes
Convert columns into the correct data types
Validate relationships between tables
Gold Layer

The Gold layer contains business-ready datasets used for reporting and analysis.

Main tasks:

Create fact and dimension tables
Build a star schema
Create customer, product, and date dimensions
Create sales fact tables
Prepare reusable views for analysis and dashboards
Data Sources

The project uses data from the following source systems:

Source	Description	Format
CRM	Customer, product, and sales information	CSV
ERP	Customer location and additional customer information	CSV
