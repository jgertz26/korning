-- DEFINE YOUR DATABASE SCHEMA HERE
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS frequency;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS sales;

CREATE TABLE customers (
  cust_id SERIAL PRIMARY KEY,
  customer varchar(20),
  cust_acct varchar(10)
);

CREATE TABLE products (
  prod_id SERIAL PRIMARY KEY,
  product varchar(30)
);

CREATE TABLE frequency (
  freq_id SERIAL PRIMARY KEY,
  frequency varchar(15)
);

CREATE TABLE employees (
  emp_id SERIAL PRIMARY KEY,
  employee varchar(30),
  email varchar(40)
);

CREATE TABLE sales (
  invoice_num INTEGER,
  cust_id SMALLINT,
  prod_id SMALLINT,
  units_sold INTEGER,
  amount_usd varchar(15),
  sale_date varchar(15),
  freq_id SMALLINT,
  emp_id SMALLINT
);
