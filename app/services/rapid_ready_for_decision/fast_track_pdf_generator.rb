# frozen_string_literal: true

module RapidReadyForDecision
  class FastTrackPdfGenerator
    PDF_MARKUP_SETTINGS = {
      text: {
        size: 11,
        font: 'SourceSansPro',
        leading: 3
      },
      heading2: {
        size: 22
      },
      heading3: {
        size: 16
      },
      heading4: {
        margin_top: 12
      },
      table: {
        width: 150,
        cell: {
          size: 10,
          border_width: 0,
          background_color: 'fff1d2'
        }
      }
    }.freeze

    def self.extract_patient_name(patient_info)
      full_name = patient_info.values_at(:first, :middle, :last).reject(&:blank?).join ' '
      [full_name, patient_info[:suffix]].reject(&:blank?).join ', '
    end

    def initialize(patient_info, assessed_data, disability_type)
      @pdf = Prawn::Document.new
      @patient_info = patient_info
      @assessed_data = assessed_data
      @date = Time.now.getlocal
      @disability_metadata = RapidReadyForDecision::Constants::DISABILITIES[disability_type]
      @disability_type = @disability_metadata[:label]
      @pdf.markup_options = PDF_MARKUP_SETTINGS
      @pdf.font_families.update('SourceSansPro' => {
                                  normal: Rails.root.join('public', 'fonts', 'sourcesanspro-regular-webfont.ttf'),
                                  italic: Rails.root.join('public', 'fonts', 'sourcesanspro-italic-webfont.ttf'),
                                  bold: Rails.root.join('public', 'fonts', 'sourcesanspro-bold-webfont.ttf'),
                                  bold_italic: Rails.root.join('public', 'fonts',
                                                               'sourcesanspro-bolditalic-webfont.ttf')
                                })
      @pdf.font_families.update('DejaVuSans' => {
                                  normal: Rails.root.join('public', 'fonts', 'deja-vu-sans.ttf')
                                })
    end

    def generate
      template = File.join('app/services/rapid_ready_for_decision/views', "#{@disability_type}.erb")
      @pdf.markup ERB.new(File.new(template).read).result(binding)

      @pdf
    end

    private

    def render_partial(erb_file_relative_path)
      erb_file_full_path = File.join('app/services/rapid_ready_for_decision/views', "#{erb_file_relative_path}.erb")
      ERB.new(File.new(erb_file_full_path).read).result(binding)
    end

    def link_to(url)
      erb_path = File.new('app/services/rapid_ready_for_decision/views/shared/_link_to.erb').read
      ERB.new(erb_path).result(binding)
    end
  end
end
