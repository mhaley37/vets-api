# frozen_string_literal: true

require 'rails_helper'
require 'mulesoft/service'

describe MuleSoft::Service do
  let(:service) { described_class.new }
  let(:fake_id) { 'BEEFCAFE1234' }
  let(:fake_secret) { 'C0FFEEFACE4321' }

  describe 'class' do
    it 'has constants' do
      expect(described_class::HOST).to eq('https://fake-mulesoft.vapi.va.gov')
    end
  end

  describe 'authentication' do
    before do
      allow(Settings['mulesoft-carma']).to receive(:client_id).and_return(fake_id)
      allow(Settings['mulesoft-carma']).to receive(:client_secret).and_return(fake_secret)
    end

    it 'builds the header' do
      auth_hash = service.send(:auth_headers)

      expect(auth_hash).not_to be_nil
      expect(auth_hash[:client_id]).to eq(fake_id)
      expect(auth_hash[:client_secret]).to eq(fake_secret)
    end

    it 'builds a post with the auth headers' do
      uri = service.send(:endpoint, resource: 'submit')
      payload = {}
      post = service.send(:json_post, uri, payload)
      expect(post['client_id']).to eq(fake_id)
      expect(post['client_secret']).to eq(fake_secret)
    end
  end

  describe 'submitting 10-10CG' do
    let(:subject) { service.send(:endpoint, resource: 'submit') }

    it 'builds the correct url' do
      expect(subject.to_s).to eq("#{described_class::HOST}/va-carma-caregiver-xapi/api/v1/application/1010CG/submit")
    end

    describe '#timeout' do
      describe 'nil config' do
        before do
          allow(Settings['mulesoft-carma']).to receive(:key?).with(:timeout).and_return(nil)
        end

        it 'defaults to 10' do
          expect(service.send(:timeout)).to eq(10)
        end
      end

      describe 'config has value' do
        before do
          allow(Settings['mulesoft-carma']).to receive(:key?).with(:timeout).and_return(23)
          allow(Settings['mulesoft-carma']).to receive(:timeout).and_return(23)
        end

        it 'returns the correct value' do
          expect(service.send(:timeout)).to eq(23)
        end
      end
    end

    describe 'submitting' do
      before do
        allow(service).to receive(:with_monitoring).and_yield
        http = double
        allow(Net::HTTP).to receive(:start).and_yield http
        allow(http).to receive(:open_timeout=)
        allow(http).to receive(:request).with(an_instance_of(Net::HTTP::Post)).and_return(Net::HTTPResponse)
      end

      it 'form data' do
        service.create_submission('{}')
      end

      it 'attachments' do
        service.upload_attachments('{}')
      end
    end
  end
end
