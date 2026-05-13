class Admin::DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @student_count = User.where(role: "student").count
    @teacher_count = User.where(role: "teacher").count
    @course_count  = Course.count

    base_query = OrderItem.joins(:order).where(orders: { status: "paid" })

    @total_sales = base_query.count
    @total_income = base_query.sum("order_items.price")
    @platform_profit = @total_income * 0.10

    @period = params[:period] || "month"

    case @period
    when "day"
      period_query = base_query.where("orders.created_at >= ?", 30.days.ago)
      @sales_data = period_query.group_by_day("orders.created_at").count
      @period_income = period_query.sum("order_items.price")
    when "year"
      @sales_data = base_query.group_by_year("orders.created_at").count
      @period_income = base_query.sum("order_items.price")
    else
      @sales_data = base_query.group_by_month("orders.created_at").count
      @period_income = base_query.sum("order_items.price")
    end
  end
end
