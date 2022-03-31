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
    print_results
  end

  private

  def run_individual_test_case(data)
    method = data['request']['method']
    path = data['request']['path']
    user_name = data['request']['user']
    client = client(user_name)

    response = case method
               when 'GET'
                 client.get(path)
               else
                 abort("Invalid method: #{method}".red)
               end

    validate_response(data, response)
  end

  def validate_response(expected_data, response)
    test_name = expected_data['name']
    @results[test_name] = []
    @current_test = @results[test_name]

    expected_status = expected_data.dig('response', 'status')
    correct_status_received = expected_status == response.status

    if correct_status_received
      received_data = JSON.parse(response.body)['data']

      count = expected_data.dig('response', 'count')
      add_error('count', count, received_data.count) if count && count != received_data.count

      expected_data = expected_data.dig('response', 'data')
      if expected_data.is_a?(Array)
        expected_data.each_with_index { |record, i| compare(record, received_data[i]) }
      else
        compare(expected_data, received_data)
      end
    else
      add_error('status', expected_status, response.status)
    end

    @current_test.empty? ? print('.'.green) : print('.'.red)
  end

  # there are some inherent limitations here. the original idea was not to check the full
  # response body but to allow spot checking. that approach becomes ambiguous when dealing with arrays.
  # you can't really do a partial check of an array of objects, so if array items are objects we check
  # them positionally. otherwise, we check for a full array match. we can iterate on this as our
  # requirements become clear
  def compare(expected, received)
    expected.each do |k, v|
      case v
      when Hash
        compare(v, received[k])
      when Array
        if v.any? { |item| item.is_a? Hash }
          v.each_with_index do |array_item, i|
            received_item = received[k][i]
            compare(array_item, received_item)
          end
        else
          add_error(k, v, received[k]) unless v == received[k]
        end
      else
        add_error(k, v, received[k]) unless v == received[k]
      end
    end
  end

  # this is a naive implementation that will not be sufficient because a
  # single test can have multiple keys with the same name
  # a better version will need to track the parent keys to give more context.
  def add_error(descriptor, expected, received)
    @current_test << "\t#{descriptor}: \n\t\texpected: '#{expected}' \n\t\treceived '#{received}'"
  end

  def print_results
    successes, failures = @results.partition { |_, v| v.empty? }

    puts
    puts "Successful tests: #{successes.count}".green
    if failures.any?
      puts "Failed tests: #{failures.count}".red
      failures.each do |name, messages|
        puts "Test #{name} failed with errors:".red
        messages.each { |message| puts message.red }
      end
      abort
    end
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
