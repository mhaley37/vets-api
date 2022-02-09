# frozen_string_literal: true

module V0
  # Application for the Program of Comprehensive Assistance for Family Caregivers (Form 10-10CG)
  class Tax1095Controller < ApplicationController

    skip_before_action :authenticate

    PDF_FORMS = PdfForms.new(Settings.binaries.pdftk)


    # If we were unable to submit the user's claim digitally, we allow them to the download
    # the 10-10CG PDF, pre-filled with their data, for them to mail in.
    def download_pdf
      # Brakeman will raise a warning if we use a claim's method or attribute in the source file name.
      # Use an arbitrary uuid for the source file name and don't use the return value of claim#to_pdf
      # as the source_file_path (to prevent changes in the the filename creating a vunerability in the future).
     # source_file_path = PdfFill::Filler.fill_form(@claim, SecureRandom.uuid, sign: false)

    # Dir[Rails.root.join(‘lib’, ‘tasks’, ‘support’, ‘**‘, ‘*.rb’)]
     #puts Rails.root 
      #  PDF_FORMS.fill_form(
      #   "lib/pdf_fill/forms/pdfs/#{form_id}.pdf",
      #   file_path,
      #   new_hash,
      #   flatten: Rails.env.production?
      # )
     #  base dir "src" as in "vets-api/src/lib/pdf_fill/forms/pdfs/f1095b.pdf"
      puts Rails.root.join('lib', 'pdf_fill', 'forms', 'pdfs', 'f1095b.pdf')
    #PDF_FORMS.get_field_names(Rails.root.join('lib', 'pdf_fill', 'forms', 'pdfs', 'f1095b.pdf') 
     source_file_path = 'lib/pdf_fill/forms/pdfs/f1095b.pdf'
     #puts source_file_path
      client_file_name = "1095B.pdf"
      file_contents    = File.read(source_file_path)

     # File.delete(source_file_path)

      #auditor.record(:pdf_download)

      send_data file_contents, filename: client_file_name, type: 'application/pdf', disposition: 'attachment'
    end
  end
end
