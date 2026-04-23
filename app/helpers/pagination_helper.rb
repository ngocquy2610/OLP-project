module PaginationHelper
  def pagination_links(paginated, params_key: :page)
    return nil if paginated.total_pages <= 1

    current = paginated.current_page
    total = paginated.total_pages

    window = 2
    left = [1, current - window].max
    right = [total, current + window].min

    content_tag :nav, class: "flex items-center justify-center space-x-2 my-6" do
      safe_join([
        # Prev
        if paginated.prev_page
          link_to "Prev", url_for(request.params.merge(params_key => paginated.prev_page)), class: "px-4 py-2 bg-white text-blue-600 border border-blue-600 rounded-xl hover:bg-blue-50"
        else
          content_tag(:span, "Prev", class: "px-4 py-2 text-gray-400 bg-gray-100 rounded-xl")
        end,

        # Left gap
        (left > 1 ? link_to(1, url_for(request.params.merge(params_key => 1)), class: "px-4 py-2 bg-white text-blue-600 border border-blue-600 rounded-xl") : nil),
        (left > 2 ? content_tag(:span, "...", class: "px-2 text-gray-500") : nil),

        # Page numbers
        * (left..right).map do |p|
          if p == current
            content_tag(:span, p, class: "px-4 py-2 bg-blue-600 text-white rounded-xl font-semibold")
          else
            link_to p, url_for(request.params.merge(params_key => p)), class: "px-4 py-2 bg-white text-gray-700 border border-gray-200 rounded-xl hover:bg-blue-50"
          end
        end,

        # Right gap
        (right < total - 1 ? content_tag(:span, "...", class: "px-2 text-gray-500") : nil),
        (right < total ? link_to(total, url_for(request.params.merge(params_key => total)), class: "px-4 py-2 bg-white text-blue-600 border border-blue-600 rounded-xl") : nil),

        # Next
        if paginated.next_page
          link_to "Next", url_for(request.params.merge(params_key => paginated.next_page)), class: "px-4 py-2 bg-blue-600 text-white rounded-xl hover:bg-blue-700"
        else
          content_tag(:span, "Next", class: "px-4 py-2 text-gray-400 bg-gray-100 rounded-xl")
        end
      ].compact)
    end
  end
end
