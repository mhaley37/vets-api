# frozen_string_literal: true

require 'rails_helper'
require 'pdf_fill/forms/va21526ez'

def basic_class
  PdfFill::Forms::Va21526ez.new({})
end

describe PdfFill::Forms::Va21526ez do
  include SchemaMatchers
  include PdfFill::Forms::FormHelper

  let(:fixture_data) do
    get_fixture('pdf_fill/21-526EZ/kitchen_sink')
  end

  let(:form_data) do
    {}
  end

  let(:new_form_class) do
    described_class.new(form_data)
  end

  def class_form_data
    new_form_class.instance_variable_get(:@form_data)
  end

  describe '#merge_fields' do
    it 'merges the right fields', run_at: '2016-12-31 00:00:00 EDT' do
      skip 'WIP, NOTE: need to create `spec/fixtures/pdf_fill/21-526EZ/merge_fields.json`'
      result = JSON.parse(described_class.new(get_fixture('pdf_fill/21-526EZ/kitchen_sink')).merge_fields.to_json)
      fixture_data = get_fixture('pdf_fill/21-526EZ/merge_fields')

      expect(result).to eq(fixture_data)
    end
  end

  describe '#combine alternate names' do
    let(:form_data) { fixture_data }
    let(:result) { new_form_class.merge_fields }
    let(:merged_names) { 'William Schwenk Gilbert, Arthur Sullivan' }

    it 'combines an array of hashes of `:first`,  `:middle`, `:last` into a string' do
      expect(result['alternateNames']).to match merged_names
    end
  end

  describe 'phoneAndEmail' do
    let(:form_data) { fixture_data }
    let(:result) { new_form_class.merge_fields }
    let(:phone_and_email) { result['phoneAndEmail'] }

    describe 'primaryPhone' do
      let(:phone) { phone_and_email['primaryPhone'] }

      context 'domestic' do
        it 'sets the three component of the phone number field' do
          expect(phone.keys).to match_array %w[country_code area_code prefix line_number]
          expect(phone['area_code'].size).to eq 3
          expect(phone['prefix'].size).to eq 3
          expect(phone['line_number'].size).to eq 4
        end
      end

      context 'international' do
        it 'sets the international field' do
          skip 'WIP'
          expect(phone['country_code']).not_to be_empty
        end
      end
    end

    describe 'emailAddress' do
      let(:email) { phone_and_email['emailAddress'] }

      it 'sets the email address' do
        expect(email).not_to be_empty
      end
    end
  end

  describe 'bankAccountType' do
    let(:form_data) { fixture_data }
    let(:result) { new_form_class.merge_fields }
    let(:checking_account_type) { result['bankAccountType']['checking'] }
    let(:savings_account_type) { result['bankAccountType']['savings'] }

    it 'checks `checking` or `savings` account type' do
      expect(checking_account_type).to eq 1
      expect(savings_account_type).to be 'Off'
    end
  end

  describe 'bankName' do
    let(:form_data) { fixture_data }
    let(:result) { new_form_class.merge_fields }
    let(:bank_name) { result['bankName'] }

    it 'has two lines' do
      expect(bank_name.keys).to match_array %w[line_1_2 line_2_2]
    end

    it 'each lines is less than 15 charcters long' do
      expect(bank_name['line_1_2'].size).to be <= 15
      expect(bank_name['line_2_2'].size).to be <= 15
    end
  end

  describe 'bankAccountNumber' do
    let(:form_data) { fixture_data }
    let(:result) { new_form_class.merge_fields }
    let(:bank_account_number) { result['bankAccountNumber'] }

    it 'sets the bank account number' do
      expect(bank_account_number.size).to be <= 9
    end
  end

  describe 'serviceInformation' do
    let(:form_data) { fixture_data }
    let(:result) { new_form_class.merge_fields }

    describe 'expand service branch' do
      let(:service_branch) { result['serviceInformation']['servicePeriods']['serviceBranch'] }

      it 'expands the radio buttons' do
        expect(service_branch.keys).to match_array %w[army
                                                      navy
                                                      marine_corps
                                                      air_force
                                                      coast_guard]
      end

      it 'checks the service branch name that has a field value 1' do
        expect(service_branch[:air_force]).to match 1
      end

      it 'does not check service brach names with value \'Off\'' do
        values = service_branch.except(:air_force).values.uniq.compact
        expect(values).to match_array %w[Off]
      end
    end

    describe 'dateRange' do
      let(:form_data) { fixture_data }
      let(:result) { new_form_class.merge_fields }

      describe 'entry date' do
        let(:entry_date) { result['serviceInformation']['servicePeriods']['dateRange']['from'] }
        let(:month) { entry_date['month'] }
        let(:day) { entry_date['day'] }
        let(:year) { entry_date['year'] }

        it 'sets the entry date, 2 digit month, 2 digit day, and 4 digit year' do
          expect(entry_date.keys).to match_array %w[month day year]
          expect(month.size).to eq 2
          expect(day.size).to eq 2
          expect(year.size).to eq 4
        end

        it 'returns the most recent date' do
          date = "#{year}-#{month}-#{day}"
          expect(date).to match '2017-01-20'
        end
      end

      describe 'exit date' do
        let(:exit_date) { result['serviceInformation']['servicePeriods']['dateRange']['to'] }

        it 'sets the exit date, 2 digit month, 2 digit day, and 4 digit year' do
          expect(exit_date.keys).to match_array %w[month day year]
          expect(exit_date['month'].size).to eq 2
          expect(exit_date['day'].size).to eq 2
          expect(exit_date['year'].size).to eq 4
        end
      end
    end

    describe 'separationLocation' do
      let(:form_data) { fixture_data }
      let(:result) { new_form_class.merge_fields }
      let(:separation_location_name) do
        result['serviceInformation']['separationLocation']['separationLocationName']
      end

      describe 'separationLocationName' do
        it 'has two lines' do
          expect(separation_location_name.keys).to match_array %w[line_1_2 line_2_2]
        end

        it 'each lines is less than 15 charcters long' do
          expect(separation_location_name['line_1_2'].size).to be <= 15
          expect(separation_location_name['line_2_2'].size).to be <= 15
        end
      end
    end
  end

  describe 'separationPayDate' do
    let(:form_data) { fixture_data }
    let(:result) { new_form_class.merge_fields }
    let(:spd) { result['separationPayDate'] }

    it 'sets the entry date, 2 digit month, 2 digit day, and 4 digit year' do
      expect(spd.keys).to match_array %w[month day year]
      expect(spd['month'].size).to eq 2
      expect(spd['day'].size).to eq 2
      expect(spd['year'].size).to eq 4
    end
  end

  # 21-526EZ/Q26
  describe 'waiveRetirementPay' do
    describe 'truthy' do
      let(:form_data) { { 'waiveRetirementPay' => true } }
      let(:box_value) { new_form_class.send(:waive_retirement_pay?) }

      it 'checked if waiving VA compensation' do
        expect(box_value).to eq 1
      end
    end

    describe 'falsy' do
      let(:form_data) { { 'waiveRetirementPay' => false } }
      let(:box_value) { new_form_class.send(:waive_retirement_pay?) }

      it 'unchecked if not waiving VA compensation' do
        expect(box_value).to eq 'Off'
      end
    end
  end

  # 21-526EZ/Q1
  #
  # NOTE:
  #
  # Comment taken from
  #   `vets-website/src/applications/disability-benefits/all-claims/submit-transformer.js:290`
  #
  # standardClaim = false means it's a fully developed claim (FDC); but
  # this value is ignored in the BDD flow unless the submission falls out
  # of BDD status. Then we want it to be a FDC
  #
  describe 'Claim Type' do
    describe 'Standard Claim Process' do
      let(:form_data) { { 'standardClaim' => true } }
      let(:box_value) { new_form_class.send(:claim_type) }

      it 'checks the SCP box' do
        expect(box_value['standard']).to eq 1
      end
    end

    describe 'Fully Developed Claim (FDC)' do
      # NOTE: See note above on Standard Claim type.
      #       It's an FDC if standardClaim is false
      #
      let(:form_data) { { 'standardClaim' => false } }
      let(:box_value) { new_form_class.send(:claim_type) }

      it 'checks the FDC box' do
        expect(box_value['fully_developed']).to eq 1
      end
    end

    describe 'BDD Program Claim' do
      # NOTE: As per Robin Garison ([Slack](https://dsva.slack.com/archives/G016CG5FT6Z/p1641401029017700?thread_ts=1641344689.014400&cid=G016CG5FT6Z)
      #
      #       For BDD you can look at the service dates.
      #       If a date is in the future between 90 and 180 days, then it's probably BDD.
      #
      let(:form_data) do
        {
          'standardClaim' => false,
          'serviceInformation' => {
            'servicePeriods' => {
              'dateRange' => {
                'from' => (3.months.ago + 1.day).strftime('%Y-%m-%d'),
                'to' => (6.months.ago - 1.day).strftime('%Y-%m-%d')
              }
            }
          }
        }
      end
      let(:box_value) { new_form_class.send(:claim_type) }

      it 'checks the BDD box' do
        skip 'WIP, needs further clarification on when to "ignore" `standardClaim`.'
        expect(box_value['bdd']).to eq 1
      end
    end

    describe 'IDES' do
      it 'checks the IDES box' do
        skip 'Not implemented'
      end
    end
  end

  # 21-526EZ/Q13
  describe 'isVAEmployee' do
    describe 'truthy' do
      let(:form_data) { { 'isVaEmployee' => true } }
      let(:box_value) { new_form_class.send(:va_employee?) }

      it 'check the box if VA employee' do
        expect(box_value).to eq 1
      end
    end

    describe 'falsy' do
      let(:form_data) { { 'isVaEmployee' => false } }
      let(:box_value) { new_form_class.send(:va_employee?) }

      it 'does not check the box if not VA employee' do
        expect(box_value).to match 'Off'
      end
    end
  end

  # 21-526EZ/Q15A&C
  # 21-526EZ JSON Schema:
  # "homelessOrAtRisk": {
  #   "type": "string",
  #   "enum": [
  #     "no",
  #     "homeless",
  #     "atRisk"
  #   ]
  # },
  describe 'homelessOrAtRisk' do
    context 'no' do
      let(:form_data) { { 'homelessOrAtRisk' => 'no' } }
      let(:result) { new_form_class.send(:homeless_or_at_risk?) }
      let(:button_homeless) { result['homeless'] }
      let(:button_value_yes) { result['homeless']['button']['yes'] }
      let(:button_value_no) { result['homeless']['button']['no'] }

      it 'does not check button `yes` for Q15A' do
        expect(button_value_yes).to eq 'Off'
      end

      it 'checks button `NO` for button Q15A' do
        expect(button_value_no).to eq 1
      end
    end

    context 'homeless' do
      let(:form_data) { { 'homelessOrAtRisk' => 'homeless' } }
      let(:result) { new_form_class.send(:homeless_or_at_risk?) }
      let(:button_homeless) { result['homeless'] }
      let(:button_value_yes) { result['homeless']['button']['yes'] }
      let(:button_value_no) { result['homeless']['button']['no'] }

      it 'checks button `yes` for Q15A' do
        expect(button_value_yes).to eq 1
      end

      it 'does not check button `NO` for Q15A' do
        expect(button_value_no).to eq 'Off'
      end
    end

    context 'atRisk' do
      let(:form_data) { { 'homelessOrAtRisk' => 'atRisk' } }
      let(:result) { new_form_class.send(:homeless_or_at_risk?) }
      let(:button_at_risk) { result['at_risk'] }
      let(:button_value_yes) { result['at_risk']['button']['yes'] }
      let(:button_value_no) { result['at_risk']['button']['no'] }

      it 'checks button `yes` for Q15C' do
        expect(button_value_yes).to eq 1
      end

      it 'does not check button `NO` for Q15C' do
        expect(button_value_no).to eq 'Off'
      end
    end
  end
end
