class PaymentMailer < ApplicationMailer
    default from: 'no-reply@yourdomain.com'
    def student_receipt_email(student, course, amount, order)
        @student = student
        @course = course
        @amount = amount
        @order = order

        pdf_html = render_to_string(template: "orders/pdf_invoice", layout: false)
        pdf_file = WickedPdf.new.pdf_from_string(pdf_html)

        attachments["Invoice_#{@order.id}.pdf"] = {
            mime_type: 'application/pdf',
            content: pdf_file
        }

        mail(to: @student.email, subject: "Receipt: You've successfully enrolled in #{@course.name}")
    end

    def teacher_notification_email(teacher, student, course)
        @teacher = teacher
        @student = student
        @course = course

        mail(to: @teacher.email, subject: "New Enrollment: #{@student.email} has enrolled in your course #{@course.name}")
    end
end
