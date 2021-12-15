# frozen_string_literal: true

module Mobile
  module PaginationLinksHelper
    module_function

    def links(number_of_pages, validated_params, request)
      page_number = validated_params[:page_number]
      page_size = validated_params[:page_size]

      # currently, the ? is necessary but it could lead to malformed urls
      url = request.original_url + "?"
      %w(start_date end_date use_cache show_completed).each do |key|
        next unless validated_params.key?(key)

        camelized = key.camelize(:lower)
        url += "?#{camelized}=#{validated_params[key]}"
      end

      if page_number > 1
        prev_link = "#{url}&page[number]=#{[page_number - 1,
                                            number_of_pages].min}&page[size]=#{page_size}"
      end

      if page_number < number_of_pages
        next_link = "#{url}&page[number]=#{[page_number + 1,
                                            number_of_pages].min}&page[size]=#{page_size}"
      end

      {
        self: "#{url}&page[number]=#{page_number}&page[size]=#{page_size}",
        first: "#{url}&page[number]=1&page[size]=#{page_size}",
        prev: prev_link,
        next: next_link,
        last: "#{url}&page[number]=#{number_of_pages}&page[size]=#{page_size}"
      }
    end
  end
end
