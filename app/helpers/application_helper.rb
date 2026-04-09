module ApplicationHelper
	def format_vnd(amount)
		amount = (amount || 0).to_i
		"#{number_with_delimiter(amount, delimiter: ',')} VNĐ"
	end
end
