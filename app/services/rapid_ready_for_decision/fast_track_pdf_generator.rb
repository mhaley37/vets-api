# frozen_string_literal: true

module RapidReadyForDecision
  class FastTrackPdfGenerator
    PDF_MARKUP_SETTINGS = {
      text: {
        size: 11
      },
      heading4: {
        margin_top: 12
      },
      table: {
        width: 150,
        cell: {
          size: 10,
          border_width: 0,
          background_color: 'f3f3f3'
        }
      }
    }.freeze

    def initialize(patient_info, assessed_data, disability_type)
      @pdf = Prawn::Document.new
      @patient_info = patient_info
      @blood_pressure_data = assessed_data[:bp_readings]
      @medications = assessed_data[:medications]
      @date = Time.zone.today
      @disability_type = disability_type
      @pdf.markup_options = PDF_MARKUP_SETTINGS
    end

    # progressively builds a pdf and is sensitive to sequence
    def generate
      add_intro
      add_blood_pressure_list
      add_blood_pressure_outro
      add_medications_list
      add_about

      @pdf
    end

    private

    def blood_pressure_data?
      @blood_pressure_data.length.positive?
    end

    def medications?
      @medications.any?
    end

    def blood_pressure_start_date
      (@date - 1.year).strftime('%m/%d/%Y')
    end

    def blood_pressure_end_date
      @date.strftime('%m/%d/%Y')
    end

    def patient_name
      first, middle, last, suffix = @patient_info.values_at(:first, :middle, :last, :suffix)
      full_name = [first, middle, last].reject(&:blank?).join ' '
      [full_name, suffix].reject(&:blank?).join ', '
    end

    def birthdate
      @patient_info[:birthdate]
    end

    def generated_at
      generated_time = Time.now.getlocal
      "#{generated_time.strftime('%m/%d/%Y')} at #{generated_time.strftime('%l:%M %p %Z')}"
    end

    def add_intro
      template = File.read('app/services/rapid_ready_for_decision/views/hypertension/intro.erb')
      @pdf.markup ERB.new(template).result(binding)
    end

    def add_blood_pressure_list
      template = File.read('app/services/rapid_ready_for_decision/views/hypertension/blood_pressure_readings.erb')
      @pdf.markup ERB.new(template).result(binding)
    end

    def add_blood_pressure_outro
      template = File.read('app/services/rapid_ready_for_decision/views/hypertension/rating_schedule.erb')
      @pdf.markup ERB.new(template).result(binding)
    end

    def add_medications_list
      @pdf.text "\n", size: 12

      template = File.read('app/services/rapid_ready_for_decision/views/shared/medications.erb')
      @pdf.markup ERB.new(template).result(binding)
    end

    def add_about
      @pdf.start_new_page

      template = File.read('app/services/rapid_ready_for_decision/views/hypertension/about.erb')
      @pdf.markup ERB.new(template).result(binding)
    end
  end
end
