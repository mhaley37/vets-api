# frozen_string_literal: true

require 'faraday'

class Client
  BASE_URL = 'https://staging-api.va.gov'

  def initialize(token, base_url = BASE_URL)
    @connection = connection(token, base_url)
  end

  def get(path)
    @connection.get(path)
  end

  private

  def connection(token, base_url)
    Faraday.new(
      url: base_url,
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{token}",
        'X-Key-Inflection' => 'camel'
      }
    )
  end
end
