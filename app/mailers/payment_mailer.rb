class PaymentMailer < ApplicationMailer
    default from: 'no-reply@yourdomain.com'
    def student_receipt_email(student, course, amount)
        @student = student
        @course = course
        @amount = amount

        mail(to: @student.email, subject: "Receipt: You've successfully enrolled in #{@course.name}")
    end

    def teacher_notification_email(teacher, student, course)
        @teacher = teacher
        @student = student
        @course = course

        mail(to: @teacher.email, subject: "New Enrollment: #{@student.email} has enrolled in your course #{@course.name}")
    end
end
