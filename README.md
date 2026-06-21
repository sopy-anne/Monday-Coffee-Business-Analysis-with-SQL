# Monday-Coffee-Business-Analysis-with-SQL

## Problem Statement
Monday Coffee is a fictional coffee company that currently operates through online sales across multiple Indian cities. As the business seeks to expand into physical retail locations, management requires data-driven insights to identify the most suitable cities for opening its first coffee shops.
The objective of this project is to analyze sales, customer, product, and city-level data using PostgreSQL to determine the top cities with the highest market potential, strongest customer demand, and most favorable business conditions for expansion.

## Data Description
The analysis was conducted using four datasets provided by Monday Coffee.
- city table, ![https://github.com/sopy-anne/Monday-Coffee-Business-Analysis-with-SQL/blob/main/city.csv] which contains four columns; city_id, city_name, population, estimated_rent, city_rank
- customer table, ![https://github.com/sopy-anne/Monday-Coffee-Business-Analysis-with-SQL/blob/main/customers.csv] which contains four columns; customer_id, customer_name, city_id
- product table, ![https://github.com/sopy-anne/Monday-Coffee-Business-Analysis-with-SQL/blob/main/products.csv] which contains 3 columns; product_id, product_name, price
- sales table, ![https://github.com/sopy-anne/Monday-Coffee-Business-Analysis-with-SQL/blob/main/sales.csv] which 6 contains; sale_id, sale_date, product_id, customer_id, total, rating

## Methodology
The analysis was carried out using PostgreSQL. The datasets were imported into PostgreSQL and linked using primary and foreign key relationships.
The following business questions were answered using SQL queries involving:
•	Joins
•	Aggregate functions
•	Common Table Expressions (CTEs)
•	Window Functions
•	Ranking Functions
•	Date Functions

The questions are 
