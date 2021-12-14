module Mobile
  module PaginationHelper
    module_function

    def paginate(list:, validated_params:, request:, errors: nil)
      page_number = validated_params[:page_number]
      page_size = validated_params[:page_size]
      pages = list.each_slice(page_size).to_a

      page_meta_data = {
        errors: errors,
        meta: {
          pagination: {
            current_page: page_number,
            per_page: page_size,
            total_pages: pages.size,
            total_entries: list.size
          }
        },
        links: Mobile::PaginationLinksHelper.links(pages.size, validated_params, request)
      }
      return [[], page_meta_data] if page_number > pages.size

      [pages[page_number - 1], page_meta_data]
    end
  end
end