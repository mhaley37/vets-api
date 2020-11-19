# frozen_string_literal: true

module Ask
  module Iris
    module Oracle
      module FieldTypes
        class EmailField
          def self.set_value(browser, field_name, value)
            browser.set_text_field(field_name, value)
            browser.tab
            browser.set_text_field((field_name + '_Validation'), value)
          end
        end
      end
    end
  end
end
