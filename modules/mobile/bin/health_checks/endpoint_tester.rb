# frozen_string_literal: true

require 'colorize'
require 'thor'
require 'yaml'
require 'pry'
require_relative 'token_fetcher'
require_relative 'client'

class EndpointTester < Thor
  TEST_DATA_DIR = File.join(File.dirname(__FILE__), 'request_data')

  desc 'run tests', 'tests endpoints based on yaml inputs'
  option :base_url
  option :test_name
  def run_tests
    @users = {}
    @results = { success: 0, failure: 0 }
    files = Dir["#{TEST_DATA_DIR}/**/*.yaml"]
    files.each do |f|
      test_data = YAML.safe_load(File.read(f))
      next if options[:test_name] && test_data['case']['name'] != options[:test_name]

      run_individual_test_case(test_data)
    end
    process_results
  end

  private

  def run_individual_test_case(data)
    method = data['case']['method']
    url = data['case']['request']['path']
    user_name = data['case']['request']['user']
    client = client(user_name)

    response = case method
               when 'GET'
                 client.get(url)
               else
                 raise "Invalid method: #{method}"
               end

    validate_response(data, response)
  end

  def client(user_name)
    return @users[user_name] if @users[user_name]

    token = user_token(user_name)
    client = Client.new(token, options[:base_url])
    @users[user_name] = client
    client
  end

  def user_token(user_name)
    fetcher = TokenFetcher.new(user_name)
    fetcher.fetch_token
    fetcher.token
  end

  def validate_response(expected_data, response)
    status = expected_data.dig('case', 'response', 'status')
    assert_equal('status', status, response.status)

    count = expected_data.dig('case', 'response', 'count')
    if count
      body = JSON.parse(response.body)['data']
      assert_equal('count', count, body.count)
    end

    attributes = expected_data.dig('case', 'response', 'attributes')
    if attributes
      body = JSON.parse(response.body)['data']['attributes'] # dedupe this
      process_attributes(attributes, body)
    end
  end

  def process_attributes(hsh, received_value)
    hsh.each do |k, v|
      if v.is_a? Hash
        process_attributes(v, received_value[k])
      else
        parts = k.split('_')
        parts[1..].each(&:capitalize!)
        camelized = parts.join
        assert_equal(k, v, received_value[camelized])
      end
    end
  end

  def assert_equal(descriptor, expected, observed)
    # error handling is in the wrong place; fix later
    if expected == observed
      @results[:success] += 1
      print '.'.green
    else
      @results[:failure] += 1
      puts
      puts "Incorrect #{descriptor}. Expected #{expected}, received #{observed}".red
    end
  end

  def process_results
    puts
    puts "Successful tests: #{@results[:success]}".green
    if @results[:failure] > 0
      abort("Failed tests: #{@results[:failure]}".red)
    end
    puts 'All tests passing'.green
  end
end

EndpointTester.start(ARGV)
