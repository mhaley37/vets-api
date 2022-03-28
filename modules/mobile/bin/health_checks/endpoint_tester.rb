# frozen_string_literal: true

require 'colorize'
require 'thor'
require 'yaml'
require_relative 'token_fetcher'
require_relative 'client'

class EndpointTester < Thor
  TEST_DATA_DIR = File.join(File.dirname(__FILE__), 'request_data')

  desc 'run tests', 'tests endpoints based on yaml inputs'
  option :base_url
  option :test_name
  def run_tests
    @users = {}
    @results = {}
    files = Dir["#{TEST_DATA_DIR}/**/*.yaml"]
    files.each do |f|
      test_data = YAML.safe_load(File.read(f))
      sequence = test_data['sequence']
      sequence.each do |test_case|
        test_data = test_case['case']

        next if options[:test_name] && test_data['name'] != options[:test_name]

        run_individual_test_case(test_data)
      end
    end
    process_results
  end

  private

  def run_individual_test_case(data)
    method = data['method']
    url = data['request']['path']
    user_name = data['request']['user']
    client = client(user_name)

    response = case method
               when 'GET'
                 client.get(url)
               else
                 raise "Invalid method: #{method}"
               end

    validate_response(data, response)
  end

  def validate_response(expected_data, response)
    test_name = expected_data['name']
    @results[test_name] = []

    expected_status = expected_data.dig('response', 'status')
    correct_status_received = expected_status == response.status

    if correct_status_received
      received_data = JSON.parse(response.body)['data']

      count = expected_data.dig('response', 'count')
      add_error(test_name, 'count', count, received_data.count) if count && count != received_data.count

      expected_data = expected_data.dig('response', 'data')
      # ensuring that both data sets are hashes to avoid having a special case when data is an array
      compare_data(test_name, { 'data' => expected_data }, { 'data' => received_data }) if expected_data
    else
      add_error(test_name, 'status', expected_status, response.status)
    end

    @results[test_name].empty? ? print('.'.green) : print('.'.red)
  end

  def compare_data(test_name, expected, received)
    expected.each do |k, v|
      case v
      when Hash
        compare_data(test_name, v, received[k])
      when Array
        v.each_with_index do |array_item, i|
          compare_data(test_name, array_item, received[k][i])
        end
      else
        add_error(test_name, k, v, received[k]) unless v == received[k]
      end
    end
  end

  def add_error(test_name, descriptor, expected, received)
    @results[test_name] << "#{descriptor}: expected #{expected}, received #{received}"
  end

  def process_results
    successes, failures = @results.partition { |_, v| v.empty? }

    puts
    puts "Successful tests: #{successes.count}".green
    failures.each do |name, messages|
      puts "Test #{name} failed with errors:".red
      messages.each { |message| puts "\t#{message.red}" }
    end
    abort("Failed tests: #{failures.count}".red) if failures.any?
    puts 'All tests passing'.green
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
end

EndpointTester.start(ARGV)
