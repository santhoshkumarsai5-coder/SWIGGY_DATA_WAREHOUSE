# Swiggy Data Warehouse Project

## Project Type

SQL | PostgreSQL | Data Warehousing | Star Schema | Data Analysis

## Project Overview

This project demonstrates the complete workflow of building a Data Warehouse using PostgreSQL.
The raw Swiggy orders dataset was cleaned, transformed, and modeled into a Star Schema design consisting of fact and dimension tables.
The project also includes analytical SQL queries to generate business insights such as revenue trends, top-performing restaurants, and order distribution.

This project showcases skills in SQL, Data Modeling, Data Cleaning, and Data Warehouse design which are required for Data Analyst, Data Engineer, and Business Intelligence roles.

## Objectives

* Perform data cleaning and validation on raw dataset
* Design a Star Schema data model
* Create Dimension tables and Fact table
* Load data using SQL joins
* Perform analytical queries for business insights
* Practice real-world Data Warehouse workflow

## Tools & Technologies

* PostgreSQL
* SQL
* Data Warehousing
* Star Schema Modeling
* GitHub

## Database Design

The database is designed using Star Schema architecture.

### Dimension Tables

* dim_date
* dim_location
* dim_restaurant
* dim_category
* dim_dish

### Fact Table

* fact_swiggy_orders

### Raw Table

* swiggy_orders

## Data Cleaning Steps

* Checked NULL values
* Removed duplicate records
* Standardized column names
* Verified data types
* Validated dates and numeric values

## Analysis Performed

* Total orders count
* Total revenue calculation
* Monthly order trend
* Top cities by orders
* Top restaurants by orders
* Price range distribution
* Rating analysis

## Key Concepts Used

* Star Schema
* Fact & Dimension tables
* Primary Key / Foreign Key
* Joins
* Aggregate Functions
* Window Functions
* Data Cleaning in SQL

## Author

Santhosh
Aspiring Data Analyst | SQL | PostgreSQL | Data Warehousing | Power BI | Python
