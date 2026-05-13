class PaymentMailer < ApplicationMailer
    default from: "no-reply@yourdomain.com"
    helper ApplicationHelper
    def student_receipt_email(student, order)
        @student = student
        @order = order
        @courses = @order.order_items.includes(:course).map(&:course)
        @amount = @order.order_items.sum(:price).to_i

                pdf_html = render_to_string(template: "orders/pdf_invoice", layout: false)
                begin
                    pdf_file = WickedPdf.new.pdf_from_string(pdf_html)
                rescue StandardError => e
                    pdf_file = nil
                    Rails.logger.error "PaymentMailer: WickedPdf generation failed for order=#{@order&.id} - #{e.class}: #{e.message}"
                end

                Rails.logger.info "PaymentMailer: generated pdf bytesize=#{pdf_file&.bytesize || 0} for order=#{@order&.id}"

                if pdf_file.present? && pdf_file.bytesize.positive?
                    attachments["Invoice_#{@order.id}.pdf"] = {
                        mime_type: "application/pdf",
                        content: pdf_file
                    }
                else
                    Rails.logger.warn "PaymentMailer: skipping PDF attachment for order=#{@order&.id} - empty pdf"
                end

                subject_text = if @courses.size == 1
                    "Receipt: You've successfully enrolled in #{@courses.first.name}"
                else
                    "Receipt: You've successfully enrolled in #{@courses.count} courses"
                end

                mail(to: @student.email, subject: subject_text)
    end

        def teacher_notification_email(teacher, student, order)
                @teacher = teacher
                @student = student
                # collect courses in this order that belong to this teacher
                @order = order
                @courses = @order.order_items.includes(:course).select { |oi| oi.course.user_id == @teacher.id }.map(&:course)
                @amount = @order.order_items.includes(:course).select { |oi| oi.course.user_id == @teacher.id }.sum(&:price).to_i

                subject_text = if @courses.size == 1
                    "New Enrollment: #{@student.email} has enrolled in your course #{@courses.first.name}"
                else
                    "New Enrollments: #{@student.email} purchased #{@courses.size} of your courses"
                end

                mail(to: @teacher.email, subject: subject_text)
        end
end
