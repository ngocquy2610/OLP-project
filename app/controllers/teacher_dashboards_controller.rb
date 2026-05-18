class TeacherDashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @courses = current_user.courses

    course_ids = @courses.pluck(:id) # take only id of courses. return array of id. ex: [1, 2, 3]

    @sell_quantities = OrderItem.joins(:order)
                                .where(course_id: course_ids, orders: { status: "paid" })
                                .group(:course_id)
                                .count

    @revenues = OrderItem.joins(:order)
                         .where(course_id: course_ids, orders: { status: "paid" })
                         .group(:course_id)
                         .sum(:price)
  end
end
