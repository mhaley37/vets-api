# frozen_string_literal: true

module V0
  # Application for the Program of Comprehensive Assistance for Family Caregivers (Form 10-10CG)
  class Tax1095Controller < ApplicationController

    skip_before_action :authenticate

    PDF_FORMS = PdfForms.new(Settings.binaries.pdftk)

    def download_pdf
     # source_file_path = PdfFill::Filler.fill_form(@claim, SecureRandom.uuid, sign: false)

       PDF_FORMS.fill_form(
        "lib/pdf_fill/forms/pdfs/f1095b.pdf",
        "1095B-NEW.pdf",
        {:"topmostSubform[0].Page1[0].Part1Contents[0].Line1[0].f1_01[0]" => "Hello",
          :"topmostSubform[0].Page1[0].Part1Contents[0].Line1[0].f1_03[0]" => "World",
          :"topmostSubform[0].Page1[0].Table1_Part4[0].Row23[0].f1_25[0]" => "Dependent",
          :"topmostSubform[0].Page1[0].Table1_Part4[0].Row23[0].f1_27[0]" => "One",
          :"topmostSubform[0].Page1[0].Table1_Part4[0].Row23[0].c1_02[0]" => 1,
          :"topmostSubform[0].Page1[0].Table1_Part4[0].Row23[0].c1_03[0]" => 1,
          :"topmostSubform[0].Page1[0].Table1_Part4[0].Row23[0].c1_04[0]" => 1,
          :"topmostSubform[0].Page1[0].Part1Contents[0].f1_04[0]" => "123-12-1234"
        },
        flatten: true
      )
     #  base dir "src" as in "vets-api/src/lib/pdf_fill/forms/pdfs/f1095b.pdf"
    field_names = PDF_FORMS.get_field_names('lib/pdf_fill/forms/pdfs/f1095b.pdf') 
    #puts field_names.inspect
    
     source_file_path = '1095B-NEW.pdf'
     #puts source_file_path
      client_file_name = "1095B.pdf"
      file_contents    = File.read(source_file_path)
    
      #TODO: why do we need this line if its just deleting the pdf reference we need? 
     # File.delete(source_file_path) 

      #auditor.record(:pdf_download)

      send_data file_contents, filename: client_file_name, type: 'application/pdf', disposition: 'attachment'
    end
  end
end
