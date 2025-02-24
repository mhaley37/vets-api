# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form1095::New1095BsJob, type: :job do
  describe 'perform' do
    let(:bucket) { double }
    let(:s3_resource) { double }
    let(:objects) { double }
    let(:object) { double }
    let(:file_names1) { %w[MEC_DataExtract_O_2021_V_2021123016452.txt] }
    let(:file_data1) { File.read('spec/support/form1095/single_valid_form.txt') }
    let(:tempfile1) do
      tf = Tempfile.new(file_names1[0])
      tf.write(file_data1)
      tf.rewind
      tf
    end

    let(:file_names2) { %w[MEC_DataExtract_O_2020_B_2021123017382.txt] }
    let(:file_data2) { File.read('spec/support/form1095/multiple_valid_forms.txt') }
    let(:tempfile2) do
      tf = Tempfile.new(file_names2[0])
      tf.write(file_data2)
      tf.rewind
      tf
    end

    let(:file_names3) { %w[MEC_DataExtract_O_2021_V_2021123014353.txt] }
    let(:file_data3) { File.read('spec/support/form1095/single_invalid_form.txt') }
    let(:tempfile3) do
      tf = Tempfile.new(file_names3[0])
      tf.write(file_data3)
      tf.rewind
      tf
    end

    before do
      allow(Aws::S3::Resource).to receive(:new).and_return(s3_resource)
      allow(s3_resource).to receive(:bucket).and_return(bucket)
      allow(bucket).to receive(:objects).and_return(objects)
      allow(bucket).to receive(:delete_objects).and_return(true)
      allow(bucket).to receive(:object).and_return(object)
      allow(object).to receive(:get).and_return(nil)
    end

    it 'saves valid form from S3 file' do
      allow(objects).to receive(:collect).and_return(file_names1)
      allow(Tempfile).to receive(:new).and_return(tempfile1)

      expect(Rails.logger).not_to receive(:error)
      expect(Rails.logger).not_to receive(:warn)

      subject.perform
    end

    it 'saves multiple forms from a file' do
      allow(objects).to receive(:collect).and_return(file_names2)
      allow(Tempfile).to receive(:new).and_return(tempfile2)

      expect(Rails.logger).not_to receive(:error)
      expect(Rails.logger).not_to receive(:warn)

      subject.perform
    end

    it 'does not save invalid forms from S3 file' do
      allow(objects).to receive(:collect).and_return(file_names3)
      allow(Tempfile).to receive(:new).and_return(tempfile3)

      expect(Rails.logger).to receive(:error).at_least(:once)

      subject.perform
    end
  end
end
