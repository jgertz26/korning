require "pg"
require "pry"
require "csv"

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
    return false
  else
    return true
  end
end

def find_id(table, id_column, name_column, name)
  sql = "SELECT #{id_column} FROM #{table} WHERE #{name_column}='#{name}'"
  db_connection { |conn| conn.exec(sql)[0][id_column] }
end

def fill_invoice(values)
  sql = "INSERT INTO sales (invoice_num, cust_id, prod_id, units_sold, amount_usd, sale_date, freq_id, emp_id)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8);"
  db_connection { |conn| conn.exec(sql, values)}
end

CSV.foreach('sales.csv', headers: true, header_converters: :symbol) do |row|
  sale = row.to_hash

  customer_array = sale[:customer_and_account_no].split(" (")
  customer_name = customer_array[0]
  customer_acct = customer_array[1].delete ")"

  employee_array = sale[:employee].split(" (")
  employee_name = employee_array[0]
  employee_email = employee_array[1].delete ")"

  invoice = sale[:invoice_no]
  product_name = sale[:product_name]
  units_sold = sale[:units_sold]
  amount_usd = sale[:sale_amount]
  date = sale[:sale_date]
  frequency_type = sale[:invoice_frequency]


  #checks if customer exists, if not enters it to customers table
  if !data_exist?('customers', 'cust_acct', customer_acct)
    sql = "INSERT INTO customers (customer, cust_acct)
           VALUES ($1, $2);"
    db_connection { |conn| conn.exec(sql, [customer_name, customer_acct]) }
  end

  #checks if product exists, if not enters it to products table
  if !data_exist?('products', 'product', product_name)
    sql = "INSERT INTO products (product)
           VALUES ($1);"
    db_connection { |conn| conn.exec(sql, [product_name]) }
  end

  #checks if frequency exists, if not enters it to frequency table
  if !data_exist?('frequency', 'frequency', frequency_type)
    sql = "INSERT INTO frequency (frequency)
           VALUES ($1);"
    db_connection { |conn| conn.exec(sql, [frequency_type]) }
  end

  #checks if employee exists, if not enters it to employees table
  if !data_exist?('employees', 'employee', employee_name)
    sql = "INSERT INTO employees (employee, email)
           VALUES ($1, $2);"
    db_connection { |conn| conn.exec(sql, [employee_name, employee_email]) }
  end

  #finds current id numbers
  customer_id = find_id('customers', 'cust_id', 'customer', customer_name)
  product_id = find_id('products', 'prod_id', 'product', product_name)
  frequency_id = find_id('frequency', 'freq_id', 'frequency', frequency_type)
  employee_id = find_id('employees', 'emp_id', 'employee', employee_name)

  #if invoice doesn't already exist, adds data to sales
  values = [invoice, customer_id, product_id, units_sold, amount_usd, date, frequency_id, employee_id]
  if !data_exist?('sales', 'invoice_num', invoice)
    fill_invoice(values)
  else
    #this section is here because a sadist created this assignment
    check = db_connection { |conn| conn.exec("SELECT sale_date FROM sales WHERE invoice_num='#{invoice}'")[0]['sale_date']}
    if check != date
      fill_invoice(values)
    end
  end
end
