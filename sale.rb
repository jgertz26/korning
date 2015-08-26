class Sale
  attr_accessor :customer_name, :customer_acct, :employee_name, :employee_email, :invoice_no,
                :product_name, :units_sold, :amount_usd, :date, :frequency_type
  def initialize(customer, employee, invoice_no, product_name, units_sold, amount_usd, date, frequency_type)
    customer_array = customer.split(" (")
    @customer_name = customer_array[0]
    @customer_acct = customer_array[1].delete ")"

    employee_array = employee.split(" (")
    @employee_name = employee_array[0]
    @employee_email = employee_array[1].delete ")"

    @invoice_no = invoice_no
    @product_name = product_name
    @units_sold = units_sold
    @amount_usd = amount_usd
    @date = date
    @frequency_type = frequency_type
  end
end
