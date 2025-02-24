# frozen_string_literal: true

require 'rails_helper'

describe Sidekiq::Form526JobStatusTracker::JobTracker do
  let(:worker_class) do
    Class.new do
      include Sidekiq::Worker
      include Sidekiq::Form526JobStatusTracker::JobTracker
    end
  end

  context 'with an exhausted callback message' do
    let(:msg) do
      {
        'class' => 'EVSS::DisabilityCompensationForm::SubmitForm526AllClaim',
        'jid' => SecureRandom.uuid,
        'args' => [123],
        'error_message' => 'Did not receive a timely response from an upstream server',
        'error_class' => 'Common::Exceptions::GatewayTimeout'
      }
    end
    let!(:form526_submission) { create :form526_submission }
    let!(:from526_job_status) do
      create :form526_job_status, job_id: msg['jid'], form526_submission: form526_submission
    end

    it 'tracks an exhausted job' do
      expect_any_instance_of(Sidekiq::Form526JobStatusTracker::Metrics).to receive(:increment_exhausted)
      worker_class.job_exhausted(msg, 'stats_key')
      job_status = Form526JobStatus.last

      expect(job_status.status).to eq 'exhausted'
      expect(job_status.job_class).to eq 'SubmitForm526AllClaim'
      expect(job_status.error_message).to eq msg['error_message']
      expect(job_status.form526_submission_id).to eq 123

      expect(job_status.bgjob_errors).to be_a Hash
      key = job_status.bgjob_errors.keys.first
      expect(job_status.bgjob_errors[key].keys).to match_array %w[timestamp caller_method error_class error_message]
      expect(job_status.bgjob_errors[key]['caller_method']).to match 'job_exhausted'
    end
  end

  describe '#with_tracking' do
    let(:worker) { worker_class.new }

    before do
      stub_const('DummyClass::STATSD_KEY_PREFIX', 'dummy.worker')
      allow(worker_class).to receive(:name).and_return('WorkerClass')
      allow(worker).to receive(:jid).and_return('0')
    end

    context 'when code in the block returns from the method' do
      it 'marks the status as successful' do
        # `return` requires defining a method to return from
        def dummy_method
          worker.with_tracking('title', 0, 0) { return }
        end
        dummy_method
        expect(Form526JobStatus.last.status).to eq 'success'
      end
    end

    context 'when code in the block breaks from the block' do
      it 'marks the status as successful' do
        worker.with_tracking('title', 0, 0) { break }
        expect(Form526JobStatus.last.status).to eq 'success'
      end
    end

    context 'when an exception is raised' do
      it 'propagates the exception and does not mark the status as successful' do
        expect do
          worker.with_tracking('title', 0, 0) { raise 'an exception' }
        end.to raise_exception(RuntimeError)
        expect(Form526JobStatus.last.status).to eq 'try'
      end
    end
  end
end
