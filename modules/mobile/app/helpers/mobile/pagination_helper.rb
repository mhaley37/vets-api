module Mobile
  class PaginationHelper

    attr_reader :list, :validated_params, :url, :errors, :page_number, :page_size
    def initialize(list, validated_params, url, errors)
      @list = list
      @validated_params = validated_params
      @url = url
      @errors = errors
      @page_number = validated_params[:page_number]
      @page_size = validated_params[:page_size]

      # consider raising error if required params aren't present
      # required params: page size, page number,
      # optional params: start date, end date, use cache, show completed
    end

    def self.paginate(list:, validated_params:, url:, errors: nil)
      new(list, validated_params, url, errors).paginate
    end

    def paginate
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
        links: links(pages.size)
      }
      return [[], page_meta_data] if page_number > pages.size

      [pages[page_number - 1], page_meta_data]
    end

    def links(number_of_pages)
      composed_url = url + "?" + query_strings.join("&")

      prev_link = page_number > 1 ? "#{composed_url}&page[number]=#{[page_number - 1, number_of_pages].min}" : nil
      next_link = page_number < number_of_pages ? "#{composed_url}&page[number]=#{[page_number + 1, number_of_pages].min}" : nil

      {
        self: "#{composed_url}&page[number]=#{page_number}",
        first: "#{composed_url}&page[number]=1",
        prev: prev_link,
        next: next_link,
        last: "#{composed_url}&page[number]=#{number_of_pages}"
      }
    end

    def query_strings
      query_strings = []
      %w(start_date end_date use_cache show_completed).each do |key|
        next unless validated_params.key?(key)

        camelized = key.camelize(:lower)
        query_strings << "#{camelized}=#{validated_params[key]}"
      end

      query_strings << "page[size]=#{page_size}"
      query_strings
    end
  end
end