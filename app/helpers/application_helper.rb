module ApplicationHelper # use for many file
  def format_vnd(amount)
    amount = (amount || 0).to_i
    "#{number_with_delimiter(amount, delimiter: ',')} VNĐ"
  end
end


# service: support for just one business.
# sidekiq = background job. execute a logic.
# downgrade the video quality to upload.
# rollback - like undo - if something goes wrong, return to the previous state before the transaction.
# syntax rollback - raise ActiveRecord::Rollback
# migration - using def change - rails can automatically reverse the migration when rollback.
# if using def up and def down, you need to write the logic for both directions.
# focus on i18n - do i18n for js files
