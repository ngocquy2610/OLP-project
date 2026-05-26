module PagesHelper
	def chatbot_markdown_to_html(text)
		lines = text.to_s.split(/\r?\n/)
		html_parts = []
		in_list = false

		close_list = lambda do
			next unless in_list

			html_parts << "</ul>"
			in_list = false
		end

		inline_markdown = lambda do |line|
			ERB::Util.h(line).gsub(/\*\*([^*]+)\*\*/, '<strong>\1</strong>')
		end

		lines.each do |line|
			bullet = line.match(/^\s*\*\s+(.+)$/)

			if bullet
				unless in_list
					html_parts << '<ul class="list-disc pl-6 space-y-1">'
					in_list = true
				end

				html_parts << "<li>#{inline_markdown.call(bullet[1])}</li>"
				next
			end

			close_list.call

			if line.strip.empty?
				html_parts << "<br>"
				next
			end

			html_parts << "<p>#{inline_markdown.call(line)}</p>"
		end

		close_list.call

		sanitize(
			html_parts.join,
			tags: %w[p br ul li strong],
			attributes: []
		)
	end
end
