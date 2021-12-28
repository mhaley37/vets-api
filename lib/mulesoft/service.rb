# frozen_string_literal: true

module MuleSoft
  class Service < Common::Client::Base
    include Common::Client::Concerns::Monitoring

    HOST = Settings['mulesoft-carma'].url

    # @param payload [String] JSON string of 10-10CG form data to submit to MuleSoft
    # @return [HttpResponse]
    def create_submission(payload)
      monitored_post('/submit', payload)
    end

    # @param payload [String] JSON string of payload to submit to MuleSoft
    # @return [HttpResponse]
    def upload_attachments(payload)
      monitored_post('/addDocument', payload)
    end

    private

    # @return [Hash]
    def auth_headers
      {
        client_id: Settings['mulesoft-carma'].client_id,
        client_secret: Settings['mulesoft-carma'].client_secret
      }
    end

    # @return [URI]
    def endpoint(resource:, api_version: 'v1')
      URI.parse("#{HOST}/va-carma-caregiver-xapi/api/#{api_version}/application/1010CG/#{resource}")
    end

    # @return [HttpResponse]
    def monitored_post(resource, payload)
      with_monitoring do
        submit_post(endpoint(resource: resource), payload)
      end
    end

    # @param payload [String] JSON string of payload to submit to MuleSoft
    # @return [HttpResponse]
    def submit_post(uri, payload)
      Net::HTTP.start(uri.host, uri.port) do |http|
        http.open_timeout = timeout
        http.request(json_post(uri, payload))
      end
    end

    # @return [Net::HTTP::Post]
    def json_post(uri, payload)
      post = Net::HTTP::Post.new(uri, { 'Content-Type' => 'application/json' })
      auth_headers.each { |k, v| post[k] = v }
      post.body = payload
      post
    end

    # @return [Integer] Defaults to 10 if unset
    def timeout
      Settings['mulesoft-carma'].key?(:timeout) ? Settings['mulesoft-carma'].timeout : 10
    end
  end
end
