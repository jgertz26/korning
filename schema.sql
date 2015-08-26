-- DEFINE YOUR DATABASE SCHEMA HERE
DROP TABLE customers, products, frequencies, employees, sales;

CREATE TABLE customers (
  id SERIAL PRIMARY KEY,
  customer varchar(20),
  cust_acct varchar(10)
);

CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  product varchar(30)
);

CREATE TABLE frequencies (
  id SERIAL PRIMARY KEY,
  frequency varchar(15)
);

CREATE TABLE employees (
  id SERIAL PRIMARY KEY,
  employee varchar(30),
  email varchar(40)
);

CREATE TABLE sales (
  id SERIAL PRIMARY KEY,
  invoice_no INTEGER,
  cust_id INT REFERENCES customers(id),
  prod_id INT REFERENCES products(id),
  units_sold INTEGER,
  amount_usd MONEY,
  sale_date DATE,
  freq_id INT REFERENCES frequencies(id),
  emp_id INT REFERENCES employees(id)
);
