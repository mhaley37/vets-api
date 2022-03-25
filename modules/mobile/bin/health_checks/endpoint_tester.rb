# frozen_string_literal: true

require 'colorize'
require 'faraday'
require 'thor'
require 'yaml'
require 'pry'
require_relative 'token_fetcher'

class EndpointTester < Thor
  TEST_DATA_DIR = File.join(File.dirname(__FILE__), 'request_data')
  BASE_URL = 'https://staging-api.va.gov'
  ALLOWED_METHODS = %w[GET].freeze

  desc 'run tests', 'tests endpoints based on yaml inputs'
  option :base_url
  option :test_name
  def run_tests
    @users = {}
    files = Dir["#{TEST_DATA_DIR}/**/*.yaml"]
    files.each do |f|
      test_data = YAML.safe_load(File.read(f))
      next if options[:test_name] && test_data['case']['name'] != options[:test_name]

      run_individual_test_case(test_data)
    end
  end

  private

  def run_individual_test_case(data)
    method = data['case']['method']
    url = data['case']['request']['path']
    user_name = data['case']['request']['user']
    token = user_token(user_name)
    conn = client(token)

    response = case method
               when 'GET'
                 get(conn, url)
               else
                 raise "Invalid method: #{method}"
               end

    validate_response(data, response)
  end

  def client(token)
    Faraday.new(
      url: options[:base_url] || BASE_URL,
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{token}",
        'X-Key-Inflection' => 'camel'
      }
    )
  end

  def get(conn, url)
    conn.get(url)
  end

  def user_token(user_name)
    return @users[user_name] if @users[user_name]

    fetcher = TokenFetcher.new(user_name)
    fetcher.fetch_token
    token = fetcher.token
    @users[user_name] = token
    token
  end

  def validate_response(expected_data, response)
    status = expected_data.dig('case', 'response', 'status').to_i
    assert_equal('status', status, response.status)

    count = expected_data.dig('case', 'response', 'count').to_i
    if count
      body = JSON.parse(response.body)['data']
      assert_equal('count', count, body.count)
    end
  end

  def assert_equal(descriptor, expected, observed)
    if expected == observed
      puts '.'.green
    else
      puts "Incorrect #{descriptor}. Expected #{expected}, received #{observed}".red
    end
  end
end

EndpointTester.start(ARGV)
