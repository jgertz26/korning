require "pg"
require "pry"
require "csv"
require_relative "sale"

def db_connection
  begin
    connection = PG.connect(dbname: "korning")
    yield(connection)
  ensure
    connection.close
  end
end

def data_exist?(table, target_column, target)
  sql = "SELECT * FROM #{table} WHERE #{target_column}='#{target}'"
  result = db_connection { |conn| conn.exec(sql).to_a }
  if result == []
    false
  else
    true
  end
end

def find_id(table, name_column, name)
  sql = "SELECT id FROM #{table} WHERE #{name_column}='#{name}'"
  db_connection { |conn| conn.exec(sql)[0]['id'] }
end

def add_stuff(sql, values)
  db_connection { |conn| conn.exec(sql, values) }
end


CSV.foreach('sales.csv', headers: true, header_converters: :symbol) do |row|
  sale = Sale.new(
  row[:customer_and_account_no],
  row[:employee],
  row[:invoice_no],
  row[:product_name],
  row[:units_sold],
  row[:sale_amount],
  row[:sale_date],
  row[:invoice_frequency]
  )

  #checks if customer exists, if not enters it to customers table
  unless data_exist?('customers', 'cust_acct', sale.customer_acct)
    sql = "INSERT INTO customers (customer, cust_acct)
           VALUES ($1, $2);"
    add_stuff(sql, [sale.customer_name, sale.customer_acct])
  end

  #checks if product exists, if not enters it to products table
  unless data_exist?('products', 'product', sale.product_name)
    sql = "INSERT INTO products (product)
           VALUES ($1);"
    add_stuff(sql, [sale.product_name])
  end

  #checks if frequency exists, if not enters it to frequencies table
  unless data_exist?('frequencies', 'frequency', sale.frequency_type)
    sql = "INSERT INTO frequencies (frequency)
           VALUES ($1);"
    add_stuff(sql, [sale.frequency_type])
  end

  #checks if employee exists, if not enters it to employees table
  unless data_exist?('employees', 'employee', sale.employee_name)
    sql = "INSERT INTO employees (employee, email)
           VALUES ($1, $2);"
    add_stuff(sql, [sale.employee_name, sale.employee_email])
  end

  #finds current id numbers
  customer_id = find_id('customers', 'customer', sale.customer_name)
  product_id = find_id('products', 'product', sale.product_name)
  frequency_id = find_id('frequencies', 'frequency', sale.frequency_type)
  employee_id = find_id('employees', 'employee', sale.employee_name)

  #if invoice doesn't already exist, adds data to sales
  unless data_exist?('sales', 'invoice_no', sale.invoice_no)
    sql = "INSERT INTO sales (invoice_no, cust_id, prod_id, units_sold, amount_usd, sale_date, freq_id, emp_id)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8);"
    values = [sale.invoice_no, customer_id, product_id, sale.units_sold, sale.amount_usd, sale.date, frequency_id, employee_id]
    add_stuff(sql, values)
  end
end
