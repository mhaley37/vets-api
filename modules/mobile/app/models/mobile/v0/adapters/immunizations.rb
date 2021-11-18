# frozen_string_literal: true

module Mobile
  module V0
    module Adapters
      class Immunizations
        def parse(immunizations)
          immunizations[:entry].map do |i|
            immunization = i[:resource]
            vaccine_coding = immunization.dig(:vaccine_code, :coding)&.first
            cvx_code_string = vaccine_coding.try(:[], :code)
            cvx_code = cvx_code_string.blank? ? nil : cvx_code_string.to_i

            Mobile::V0::Immunization.new(
              id: immunization[:id],
              cvx_code: cvx_code,
              date: immunization[:occurrence_date_time].presence,
              dose_number: dose_number(immunization[:protocol_applied]),
              dose_series: dose_series(immunization[:protocol_applied]),
              group_name: Mobile::CDC_CVX_CODE_MAP[cvx_code],
              location_id: location_id(immunization.dig(:location, :reference)),
              manufacturer: nil,
              note: note(immunization[:note]),
              reaction: reaction(immunization[:reaction]),
              short_description: immunization.dig(:vaccine_code, :text)
            )
          end
        end

        private

        def location_id(reference)
          return nil unless reference

          reference.split('/').last
        end

        def dose_number(protocol_applied)
          return nil if protocol_applied.blank?

          series = protocol_applied.first

          series[:dose_number_positive_int] || series[:dose_number_string]
        end

        def dose_series(protocol_applied)
          return nil if protocol_applied.blank?

          series = protocol_applied.first

          series[:series_doses_positive_int] || series[:series_doses_string]
        end

        def note(note)
          return nil if note.blank?

          note.first[:text]
        end

        def reaction(reaction)
          return nil unless reaction

          reaction.map { |r| r[:detail][:display] }.join(',')
        end
      end
    end
  end
end
