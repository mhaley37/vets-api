# frozen_string_literal: true

require 'rails_helper'

describe VANotify::InProgressForm686c do
  it 'can pull veteran details from form data' do
    in_progress_form = create(:in_progress_686c_form)
    subject = described_class.new(in_progress_form.form_data)

    expect(subject.first_name).to eq('first_name')
  end
end
