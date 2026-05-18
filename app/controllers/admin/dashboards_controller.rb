class Admin::DashboardsController < Admin::BaseController
  before_action :authenticate_user!

  def index
    @student_count = User.where(role: "student").count # check user with student roles, count.
    @teacher_count = User.where(role: "teacher").count # check user with teacher roles, count.
    @course_count  = Course.count # count all courses in database.

    base_query = OrderItem.joins(:order).where(orders: { status: "paid" })
    # Join OrderItem with Order, filter orders with "paid" status
    # Inner join - just take the oderitem that suit with the requirement (status paid)

    @total_sales = base_query.count # count total items which paid --> total sale
    @total_income = base_query.sum("order_items.price") # calculate the sum of price
    @platform_profit = @total_income * 0.10

    @period = params[:period] || "month"
    # Get the period from params, default to "month" if not provided
    # period: [ "day", "month", "year" ]

    case @period # case - when: compare the value of @period with each case
    when "day"
      period_query = base_query.where("orders.created_at >= ?", 30.days.ago) # Filter orders created in the last 30 days
      @sales_data = period_query.group_by_day("orders.created_at").count # Group the filtered orders by day and count them
      @period_income = period_query.sum("order_items.price") # Calculate the total income for the filtered orders
    when "year"
      @sales_data = base_query.group_by_year("orders.created_at").count # Group all paid orders by year and count them
      @period_income = base_query.sum("order_items.price") # Calculate the total income for all paid orders
    else
      @sales_data = base_query.group_by_month("orders.created_at").count # Group all paid orders by month and count them
      @period_income = base_query.sum("order_items.price") # Calculate the total income for all paid orders
    end
    # group_by_[period] is a method provided by the chartkick gem, which allows you to easily group records by time periods.
  end
end
