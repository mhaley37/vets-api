# frozen_string_literal: true

module Ask
  module Iris
    module Oracle
      class Field
        attr_accessor :schema_key, :field_type, :field_name, :value

        def initialize(properties)
          @schema_key = properties[:schemaKey]
          @field_name = properties[:fieldName]
          @field_type = properties[:fieldType]
          @transform = properties[:transform]
          @value = nil
        end

        def enter_into_form(browser)
          transformed_value = transform @value

          @field_type.set_value browser, @field_name, transformed_value
        end

        private
         
        def transform(value)
          return value if @transform.nil?

          @transform.call(value)
        end
      end
    end
  end
end
