# frozen_string_literal: true

require 'sidekiq'
require 'claims_api/cid_mapper'

module ClaimsApi
  class ReportUnsuccessfulSubmissions
    include Sidekiq::Worker

    def perform
      if Settings.claims_api.report_enabled
        @to = Time.zone.now
        @from = 1.day.ago
        @claims_consumers = ClaimsApi::AutoEstablishedClaim.where(created_at: @from..@to).pluck(:cid).uniq

        ClaimsApi::UnsuccessfulReportMailer.build(
          @from,
          @to,
          consumer_claims_totals: claims_totals,
          unsuccessful_claims_submissions: unsuccessful_claims_submissions,
          poa_totals: poa_totals,
          unsuccessful_poa_submissions: unsuccessful_poa_submissions
        ).deliver_now
      end
    end

    def unsuccessful_claims_submissions
      errored_claims.pluck(:cid, :created_at, :id).map do |cid, created_at, id|
        { id: id, created_at: created_at, cid: cid }
      end
    end

    def errored_claims
      ClaimsApi::AutoEstablishedClaim.where(
        created_at: @from..@to,
        status: %w[errored]
      ).order(:cid, :status)
    end

    def with_special_issues(cid: nil)
      claims = ClaimsApi::AutoEstablishedClaim.where(created_at: @from..@to)
      claims = claims.where(cid: cid) if cid.present?

      claims.map { |claim| claim[:special_issues].length.positive? ? 1 : 0 }.sum.to_f
    end

    def with_flashes(cid: nil)
      claims = ClaimsApi::AutoEstablishedClaim.where(created_at: @from..@to)
      claims = claims.where(cid: cid) if cid.present?

      claims.map { |claim| claim[:flashes].length.positive? ? 1 : 0 }.sum.to_f
    end

    def claims_totals
      @claims_consumers.map do |cid|
        counts = ClaimsApi::AutoEstablishedClaim.where(created_at: @from..@to, cid: cid).group(:status).count
        totals = counts.sum { |_k, v| v }.to_f

        percentage_with_flashes = "#{((with_flashes(cid: cid) / totals) * 100).round(2)}%"
        percentage_with_special_issues = "#{((with_special_issues(cid: cid) / totals) * 100).round(2)}%"

        if totals.positive?
          consumer_name = ClaimsApi::CidMapper.new(cid: cid).name
          {
            consumer_name => counts.merge(totals: totals,
                                          percentage_with_flashes: percentage_with_flashes.to_s,
                                          percentage_with_special_issues: percentage_with_special_issues.to_s)
                                   .deep_symbolize_keys
          }
        end
      end
    end

    def poa_totals
      totals = ClaimsApi::PowerOfAttorney.where(created_at: @from..@to).group(:status).count
      total_submissions = totals.sum { |_k, v| v }
      totals.merge(total: total_submissions).deep_symbolize_keys
    end

    def unsuccessful_poa_submissions
      ClaimsApi::PowerOfAttorney.where(created_at: @from..@to, status: %w[errored]).order(:created_at,
                                                                                          :vbms_error_message)
    end
  end
end
